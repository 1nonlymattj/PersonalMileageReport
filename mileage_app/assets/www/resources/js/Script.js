const sheetName = '2026_Mileage';  // Name of your sheet
const dateColumn = 'Date';   // Column header for the Date
const startColumn = 'Starting Mileage'; // Column header for Starting Mileage
const endColumn = 'Ending Mileage'; // Column header for Ending Mileage
const mileageColumn = 'Total Mileage';  // Column header for Mileage
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
    const typeIndex = headers.indexOf(typeColumn);
    const costIndex = headers.indexOf(costColumn);

    if (dateIndex === -1) {
      throw new Error('Date column not found');
    }

    const rawDate = new Date(e.parameter["date"]);
    const formattedDate = rawDate.toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });

    const startMileage = parseInt(e.parameter["startMileage"]);
    const endMileage = parseInt(e.parameter["endMileage"]);
    const newMileage = parseInt(e.parameter["mileage"], 10);
    let type = e.parameter["type"];
    const cost = e.parameter["cost"];

    let rowToUpdate = sheet.getLastRow() + 1;
    let newRow = new Array(headers.length).fill('');
    newRow[dateIndex] = formattedDate;
    if (!isNaN(newMileage)) {
      newRow[mileageIndex] = newMileage;
      newRow[startIndex] = startMileage;
      newRow[endIndex] = endMileage;
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
