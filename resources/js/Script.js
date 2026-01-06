const sheetName = '2026_Mileage';  // Name of your sheet
const dateColumn = 'Date';   // Column header for the Date
const startColumn = 'Starting Mileage'; // Column header for Starting Mileage
const endColumn = 'Ending Mileage'; // Column header for Ending Mileage
const mileageColumn = 'Total Mileage';  // Column header for Mileage
const amountMadeColumn = 'Amount Made'; // Column header for Amount Made
const typeColumn = 'Type';  // Column header for Maintenance Type
const costColumn = 'Cost';  // Column header for Maintenance Cost

function doPost(e) {
  const lock = LockService.getScriptLock();
  lock.tryLock(10000); // Try to acquire lock for 10 seconds

  try {
    const doc = SpreadsheetApp.getActiveSpreadsheet();
    const sheet = doc.getSheetByName(sheetName);
    const headers = sheet.getRange(1, 1, 1, sheet.getLastColumn()).getValues()[0];
    const dateIndex = headers.indexOf(dateColumn);
    const startIndex = headers.indexOf(startColumn);
    const endIndex = headers.indexOf(endColumn);
    const mileageIndex = headers.indexOf(mileageColumn);
    const amountMadeIndex = headers.indexOf(amountMadeColumn);
    const typeIndex = headers.indexOf(typeColumn);
    const costIndex = headers.indexOf(costColumn);

    if (dateIndex === -1) throw new Error('Date column not found');
    if (mileageIndex === -1) throw new Error('Total Mileage column not found');
    if (amountMadeIndex === -1) throw new Error('Amount Made column not found');


    const rawDate = new Date(e.parameter["date"]);
    const formattedDate = rawDate.toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });

    const startMileage = parseInt(e.parameter["startMileage"]);
    const endMileage = parseInt(e.parameter["endMileage"]);
    const newMileage = parseInt(e.parameter["mileage"], 10);
    const amountMade = e.parameter["amountMade"];
    let type = e.parameter["type"];
    const cost = e.parameter["cost"];

    let rowToUpdate = sheet.getLastRow() + 1;
    let newRow = new Array(headers.length).fill('');
    newRow[dateIndex] = rawDate; // stores as actual Date in Sheets
    if (!isNaN(newMileage)) {
      newRow[mileageIndex] = newMileage;
      newRow[startIndex] = startMileage;
      newRow[endIndex] = endMileage;

      if (amountMadeIndex !== -1 && amountMade !== undefined && amountMade !== '') {
        newRow[amountMadeIndex] = parseFloat(amountMade);
      }
    }
    if (type && cost) {
      newRow[typeIndex] = type;
      newRow[costIndex] = parseFloat(cost);
    }

    sheet.getRange(rowToUpdate, 1, 1, newRow.length).setValues([newRow]);

    return ContentService.createTextOutput(JSON.stringify({ result: 'success', row: rowToUpdate }))
      .setMimeType(ContentService.MimeType.JSON);
  } catch (e) {
    return ContentService.createTextOutput(JSON.stringify({ result: 'error', error: e.message }))
      .setMimeType(ContentService.MimeType.JSON);
  } finally {
    lock.releaseLock();
  }
}

function formatDateOnly(value) {
  if (!value) return '';
  const d = new Date(value);
  return d.toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' });
}

// Convert Date or text to a real Date at midnight for comparisons
function toDateMidnight(value) {
  if (!value) return null;
  const d = new Date(value);
  if (isNaN(d.getTime())) return null;
  d.setHours(0, 0, 0, 0);
  return d;
}

function doGet(e) {
  try {
    const action = (e.parameter && e.parameter.action) ? e.parameter.action : '';
    if (action !== 'dashboard') {
      return ContentService.createTextOutput(
        JSON.stringify({ result: 'error', error: 'Invalid action' })
      ).setMimeType(ContentService.MimeType.JSON);
    }

    const startParam = e.parameter.start || ''; // YYYY-MM-DD
    const endParam = e.parameter.end || '';     // YYYY-MM-DD
    const startDate = startParam ? toDateMidnight(startParam) : null;
    const endDate = endParam ? toDateMidnight(endParam) : null;

    const doc = SpreadsheetApp.getActiveSpreadsheet();
    const sheet = doc.getSheetByName(sheetName);
    const values = sheet.getDataRange().getValues();

    if (values.length < 2) {
      return ContentService.createTextOutput(
        JSON.stringify({ mileage: [], maintenance: [], monthly: [] })
      ).setMimeType(ContentService.MimeType.JSON);
    }

    const headers = values[0];
    const dateIndex = headers.indexOf(dateColumn);
    const mileageIndex = headers.indexOf(mileageColumn);
    const amountMadeIndex = headers.indexOf(amountMadeColumn);
    const typeIndex = headers.indexOf(typeColumn);
    const costIndex = headers.indexOf(costColumn);

    const mileageByDate = {};   // { dateKey: { dateObj, miles, amount } }
    const monthlyByKey = {};    // { "yyyy-MM": { miles, amount } }
    const maintenance = [];

    for (let i = 1; i < values.length; i++) {
      const row = values[i];

      const rowDate = toDateMidnight(row[dateIndex]);
      if (!rowDate) continue;

      // filter inclusive
      if (startDate && rowDate < startDate) continue;
      if (endDate && rowDate > endDate) continue;

      const dateText = formatDateOnly(rowDate); // "January 5, 2026"

      // mileage row
      const miles = Number(row[mileageIndex] || 0);
      const amount = Number((amountMadeIndex !== -1 ? row[amountMadeIndex] : 0) || 0);

      if (miles > 0) {
        const dateKey = Utilities.formatDate(rowDate, Session.getScriptTimeZone(), "yyyy-MM-dd");

        if (!mileageByDate[dateKey]) {
          mileageByDate[dateKey] = { dateObj: rowDate, dateText: dateText, miles: 0, amount: 0 };
        }
        mileageByDate[dateKey].miles += miles;
        mileageByDate[dateKey].amount += amount;

        const monthKey = Utilities.formatDate(rowDate, Session.getScriptTimeZone(), "yyyy-MM");
        if (!monthlyByKey[monthKey]) monthlyByKey[monthKey] = { miles: 0, amount: 0 };
        monthlyByKey[monthKey].miles += miles;
        monthlyByKey[monthKey].amount += amount;
      }

      // maintenance row
      const type = (typeIndex !== -1 ? row[typeIndex] : '') || '';
      const cost = Number((costIndex !== -1 ? row[costIndex] : 0) || 0);

      if (type && cost > 0) {
        maintenance.push({
          dateObj: rowDate,
          date: dateText,
          type: String(type).toUpperCase(),
          cost: Number(cost.toFixed(2))
        });
      }
    }

    // Daily mileage sorted by real date
    const mileage = Object.keys(mileageByDate)
      .sort((a, b) => mileageByDate[a].dateObj - mileageByDate[b].dateObj)
      .map(key => {
        const miles = mileageByDate[key].miles;
        const amount = mileageByDate[key].amount;
        const perMile = miles > 0 ? (amount / miles) : 0;

        return {
          date: mileageByDate[key].dateText,
          miles: Number(miles.toFixed(0)),
          amount: Number(amount.toFixed(2)),
          perMile: Number(perMile.toFixed(2))
        };
      });

    // Monthly totals sorted yyyy-MM
    const monthly = Object.keys(monthlyByKey)
      .sort()
      .map(key => {
        const miles = monthlyByKey[key].miles;
        const amount = monthlyByKey[key].amount;
        const perMile = miles > 0 ? (amount / miles) : 0;

        const monthDate = new Date(key + "-01T00:00:00");
        const label = monthDate.toLocaleDateString('en-US', { month: 'long', year: 'numeric' });

        return {
          monthKey: key,
          label: label,
          miles: Number(miles.toFixed(0)),
          amount: Number(amount.toFixed(2)),
          perMile: Number(perMile.toFixed(2))
        };
      });

    // Maintenance sorted by real date
    maintenance.sort((a, b) => a.dateObj - b.dateObj);
    const maintenanceOut = maintenance.map(r => ({ date: r.date, type: r.type, cost: r.cost }));

    return ContentService.createTextOutput(
  JSON.stringify({ result: 'success', mileage, monthly, maintenance: maintenanceOut })
).setMimeType(ContentService.MimeType.JSON);

  } catch (err) {
    return ContentService.createTextOutput(
      JSON.stringify({ result: 'error', error: err.message })
    ).setMimeType(ContentService.MimeType.JSON);
  }
}

