// PMR Dashboard
function createDashboardPinDialog() {
  const isDarkMode = document.body.classList.contains("dark-mode");

  const dialogHtml = `
    <div id="pinDialog" style="text-align:center;">
      <h3>Enter PIN</h3>
      <input id="pinInput" type="password" inputmode="numeric" maxlength="4"
        style="width:140px; text-align:center; font-size:22px; padding:10px; border-radius:10px;">
      <div id="pinError" style="margin-top:10px; display:none; color:${isDarkMode ? '#fb7185' : '#dc2626'}; font-weight:bold;">
        Incorrect PIN
      </div>
    </div>
  `;

  $(dialogHtml).dialog({
    title: 'Dashboard Access',
    autoOpen: true,
    modal: true,
    width: $(window).width() > 420 ? 420 : 'auto',
    resizable: false,
    draggable: false,
    open: function () {
      setTimeout(() => $('#pinInput').focus(), 50);
      $('#pinInput').on('keydown', function(e){
        if (e.key === 'Enter') $('.ui-dialog-buttonpane button:contains("Unlock")').click();
      });
    },
    buttons: {
      'Unlock': {
        text: 'Unlock',
        'class': 'dialogButton',
        click: function () {
          const pin = $('#pinInput').val().trim();
          if (pin === adminPin) {
            $(this).dialog('destroy');
            loadDashboard(); // default no filter
          } else {
            $('#pinError').show();
            $('#pinInput').val('').focus();
          }
        }
      },
      'Close': {
        text: 'Close',
        'class': 'dialogButton',
        click: function () {
          $(this).dialog('destroy');
        }
      }
    }
  });
}

function loadDashboard(start = '', end = '') {
  const url = new URL(SCRIPT_URL);
  url.searchParams.set('action', 'dashboard');
  if (start) url.searchParams.set('start', start); // YYYY-MM-DD
  if (end) url.searchParams.set('end', end);

  fetch(url.toString(), { method: 'GET' })
    .then(r => r.json())
    .then(data => createDashboardDialog(data, start, end))
    .catch(err => {
      console.error(err);
      $('<div style="text-align:center;"><h3>Dashboard Error</h3><p>Could not load dashboard data.</p></div>').dialog({
        title: 'Error',
        modal: true,
        width: $(window).width() > 420 ? 420 : 'auto',
        buttons: { Close: function(){ $(this).dialog('destroy'); } }
      });
    });
}

function createDashboardDialog(data, startVal = '', endVal = '') {
  const isDarkMode = document.body.classList.contains("dark-mode");

  // theme-aware colors for $/mile
  const COLORS = isDarkMode
    ? { good: '#34d399', ok: '#fbbf24', bad: '#fb7185' }
    : { good: '#16a34a', ok: '#ca8a04', bad: '#dc2626' };

  const amountGreen = isDarkMode ? '#34d399' : '#16a34a';
  const costRed = isDarkMode ? '#fb7185' : '#dc2626';
  const border = isDarkMode ? 'rgba(255,255,255,.15)' : 'rgba(0,0,0,.12)';
  const text = isDarkMode ? '#e5e7eb' : '#111827';
  const muted = isDarkMode ? 'rgba(229,231,235,.75)' : 'rgba(17,24,39,.70)';

  function perMileColor(v){
    if (v >= 2.0) return COLORS.good;
    if (v >= 1.25) return COLORS.ok;
    return COLORS.bad;
  }

  // --- Filter UI ---
  const filterHtml = `
    <div class="dash-filter">
        <div class="dash-field">
        <label class="dash-label">Start</label><br>
        <input id="dashStart" class="dash-input" type="date" value="${startVal}">
        </div>

        <div class="dash-field">
        <label class="dash-label">End</label><br>
        <input id="dashEnd" class="dash-input" type="date" value="${endVal}">
        </div>

        <button id="dashApply" class="dash-btn">Apply</button>
        <button id="dashClear" class="dash-btn">Clear</button>
    </div>
    `;

  // --- Daily rows ---
  const mileageRows = (data.mileage || []).map(r => {
    const pm = Number(r.perMile || 0);
    return `
      <tr style="border-bottom:1px solid ${border};">
        <td style="padding:8px;">${r.date}</td>
        <td style="padding:8px; text-align:right;">${r.miles}</td>
        <td style="padding:8px; text-align:right; font-weight:700;"><span class="dash-income">$${Number(r.amount).toFixed(2)}</span></td>
        <td style="padding:8px; text-align:right; font-weight:700;"><span class="dash-permile" style="color:${perMileColor(pm)};">$${pm.toFixed(2)}</span></td>

      </tr>
    `;
  }).join('');

  // --- Monthly totals rows (expects data.monthly from Apps Script) ---
  const monthlyRows = (data.monthly || []).map(r => {
    const pm = Number(r.perMile || 0);
    return `
      <tr style="border-bottom:1px solid ${border};">
        <td style="padding:8px;">${r.label}</td>
        <td style="padding:8px; text-align:right;">${r.miles}</td>
        <td style="padding:8px; text-align:right; font-weight:700;"><span class="dash-income">$${Number(r.amount).toFixed(2)}</span></td>
        <td style="padding:8px; text-align:right; font-weight:700;"><span class="dash-permile" style="color:${perMileColor(pm)};">$${pm.toFixed(2)}</span></td>
      </tr>
    `;
  }).join('');

  // --- Maintenance rows ---
  const maintRows = (data.maintenance || []).map(r => `
    <tr style="border-bottom:1px solid ${border};">
      <td style="padding:8px;">${r.date}</td>
      <td style="padding:8px;">${(r.type || '').toString().toUpperCase()}</td>
      <td style="padding:8px; text-align:right; font-weight:700;"> <span class="dash-expense">-$${Number(r.cost).toFixed(2)}</span></td>
    </tr>
  `).join('');

  const html = `
    <div id="dashboardDialog">
      ${filterHtml}

      <h3 style="margin:0 0 10px;">Mileage Summary</h3>
      <div style="overflow:auto; border:1px solid ${border}; border-radius:12px;">
        <table class="dash-table" style="width:100%; border-collapse:collapse; font-size:14px;">
          <thead>
            <tr style="border-bottom:1px solid ${border};">
              <th style="padding:8px; text-align:left;">Date</th>
              <th style="padding:8px; text-align:right;">Total Miles</th>
              <th style="padding:8px; text-align:right;">Amount Made</th>
              <th style="padding:8px; text-align:right;">$/Mile</th>
            </tr>
          </thead>
          <tbody>
            ${mileageRows || `<tr><td colspan="4" style="padding:12px; text-align:center; opacity:.8;">No mileage entries found.</td></tr>`}
          </tbody>
        </table>
      </div>

      <h3 style="margin:18px 0 10px;">Monthly Totals</h3>
      <div style="overflow:auto; border:1px solid ${border}; border-radius:12px;">
        <table <table class="dash-table" style="width:100%; border-collapse:collapse; font-size:14px;">
          <thead>
            <tr style="border-bottom:1px solid ${border};">
              <th style="padding:8px; text-align:left;">Month</th>
              <th style="padding:8px; text-align:right;">Total Miles</th>
              <th style="padding:8px; text-align:right;">Amount Made</th>
              <th style="padding:8px; text-align:right;">$/Mile</th>
            </tr>
          </thead>
          <tbody>
            ${monthlyRows || `<tr><td colspan="4" style="padding:12px; text-align:center; opacity:.8;">No monthly totals found.</td></tr>`}
          </tbody>
        </table>
      </div>

      <h3 style="margin:18px 0 10px;">Maintenance & Repairs</h3>
      <div style="overflow:auto; border:1px solid ${border}; border-radius:12px;">
        <table class="dash-table" style="width:100%; border-collapse:collapse; font-size:14px;">
          <thead>
            <tr style="border-bottom:1px solid ${border};">
              <th style="padding:8px; text-align:left;">Date</th>
              <th style="padding:8px; text-align:left;">Type</th>
              <th style="padding:8px; text-align:right;">Cost</th>
            </tr>
          </thead>
          <tbody>
            ${maintRows || `<tr><td colspan="3" style="padding:12px; text-align:center; opacity:.8;">No maintenance entries found.</td></tr>`}
          </tbody>
        </table>
      </div>
    </div>
  `;

  $(html).dialog({
    title: 'Dashboard',
    autoOpen: true,
    modal: true,
    width: $(window).width() > 900 ? 900 : 'auto',
    maxHeight: Math.floor(window.innerHeight * 0.85),
    resizable: false,
    draggable: false,
    open: function () {
      applyDashboardTheme();
      // Apply filter
      $('#dashApply').on('click', function () {
        const s = $('#dashStart').val();
        const e = $('#dashEnd').val();

        // basic validation (optional)
        if (s && e && s > e) {
          alert("Start date cannot be after End date.");
          return;
        }

        $(this).closest('.ui-dialog-content').dialog('destroy');
        loadDashboard(s, e);
      });

      // Clear filter
      $('#dashClear').on('click', function () {
        $(this).closest('.ui-dialog-content').dialog('destroy');
        loadDashboard('', '');
      });
    },
    buttons: {
      Close: function () { $(this).dialog('destroy'); }
    }
  });
}

function applyDashboardTheme() {
  const isDarkMode = document.body.classList.contains("dark-mode");

  // Add/remove dark-mode class on the dashboard dialog + its controls
  const root = document.getElementById("dashboardDialog");
  if (!root) return;

  root.classList.toggle("dark-mode", isDarkMode);

  root.querySelectorAll("input, button, select").forEach(el => {
    el.classList.toggle("dark-mode", isDarkMode);
  });

  // Helps date inputs render correctly in dark mode (calendar widget)
  root.style.colorScheme = isDarkMode ? "dark" : "light";
}
