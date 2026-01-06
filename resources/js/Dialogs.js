function createMileageSubmitted() {
    const isDarkMode = document.body.classList.contains("dark-mode");

    let amountMade = parseFloat(document.getElementById("amountMade")?.value || 0);
    let perMile = 0;
    let perMileText = '';
    let perMileColor = isDarkMode ? '#e5e7eb' : '#111827'; // fallback text color

    // Theme-aware colors
    const COLORS = isDarkMode
        ? { good: '#34d399', ok: '#fbbf24', bad: '#fb7185' }   // softer/brighter for dark
        : { good: '#16a34a', ok: '#ca8a04', bad: '#dc2626' };  // richer for light

    if (amountMade > 0 && MILEAGE > 0) {
        perMile = amountMade / MILEAGE;

        if (perMile >= 2.0) {
            perMileColor = COLORS.good;
        } else if (perMile >= 1.25) {
            perMileColor = COLORS.ok;
        } else {
            perMileColor = COLORS.bad;
        }

        perMileText = `
            <br>
            <strong>Amount Made:</strong> $${amountMade.toFixed(2)}<br>
            <strong>Per Mile:</strong>
            <span style="color:${perMileColor}; font-weight:bold;">
                $${perMile.toFixed(2)} / mile
            </span>
        `;
    }

    let message = '';
    if (MILEAGE > 1) {
        message = MILEAGE + ' miles have been submitted for ' + FORMATED_DATE + '.';
    } else {
        message = MILEAGE + ' mile has been submitted for ' + FORMATED_DATE + '.';
    }

    $('<div id="dialog" align="center">' +
        '<h3>' + message + '</h3>' +
        perMileText +
        '<br></div>'
    ).dialog({
        title: 'Thank You',
        autoOpen: true,
        modal: true,
        width: $(window).width() > 400 ? 400 : 'auto',
        resizable: false,
        draggable: false,
        buttons: {
            'Close': {
                text: 'Close',
                'class': 'dialogButton',
                'id': 'confirm',
                click: function () {
                    $(this).dialog('destroy');
                }
            }
        }
    });
}

function createMaintenanceSubmitted() {
    message = TYPE + ' : $' + COST + ' has  been submitted for ' + FORMATED_DATE + '.';
    $('<div id = dialog align =center > ' + '<h3>' + message + '</h3>' + '<br>' + ' </div>'
    ).dialog({
        title: 'Thank You',
        autoOpen: true,
        modal: true,
        width: $(window).width() > 400 ? 400 : 'auto',
        resizable: false,
        draggable: false,
        buttons: {
            'Close': {
                text: 'Close',
                'class': 'dialogButton',
                'id': 'confim',
                click: function () {
                    $(this).dialog('destroy');
                }
            }
        }
    });
}

function createMissingMileageSubmitted() {
    if (MILEAGE > 1) {
        message = MILEAGE + ' miles have  been submitted for ' + MISSING_DATE + '.';
    } else {
        message = MILEAGE + ' mile has  been submitted for ' + MISSING_DATE + '.';
    }
    $('<div id = dialog align =center > ' + '<h3>' + message + '</h3>' + '<br>' + ' </div>'
    ).dialog({
        title: 'Thank You',
        autoOpen: true,
        modal: true,
        width: $(window).width() > 400 ? 400 : 'auto',
        resizable: false,
        draggable: false,
        buttons: {
            'Close': {
                text: 'Close',
                'class': 'dialogButton',
                'id': 'confim',
                click: function () {
                    $(this).dialog('destroy');
                }
            }
        }
    });
}

function createMissingMaintenanceSubmitted() {
    message = TYPE + ' : $' + COST + ' has  been submitted for ' + MISSING_DATE + '.';
    $('<div id = dialog align =center > ' + '<h3>' + message + '</h3>' + '<br>' + ' </div>'
    ).dialog({
        title: 'Thank You',
        autoOpen: true,
        modal: true,
        width: $(window).width() > 400 ? 400 : 'auto',
        resizable: false,
        draggable: false,
        buttons: {
            'Close': {
                text: 'Close',
                'class': 'dialogButton',
                'id': 'confim',
                click: function () {
                    $(this).dialog('destroy');
                }
            }
        }
    });
}

function createInvalidMileageDialog(startMileage, endMileage) {
    message = endMileage + ' is less than start mileage of ' + startMileage;
    $('<div id = dialog align =center > ' + '<h3>' + message + '</h3>' + '<br>' + ' </div>'
    ).dialog({
        title: ' Invalid End Mileage Entered',
        autoOpen: true,
        modal: true,
        width: $(window).width() > 400 ? 400 : 'auto',
        resizable: false,
        draggable: false,
        buttons: {
            'Close': {
                text: 'Close',
                'class': 'dialogButton',
                'id': 'confim',
                click: function () {
                    $(this).dialog('destroy');
                }
            }
        }
    });
}

function createMissingMileageDialog() {
    message = 'Please enter a valid whole number for mileage.';
    $('<div id = dialog align =center > ' + '<h3>' + message + '</h3>' + '<br>' + ' </div>'
    ).dialog({
        title: ' Missing Mileage',
        autoOpen: true,
        modal: true,
        width: $(window).width() > 400 ? 400 : 'auto',
        resizable: false,
        draggable: false,
        buttons: {
            'Close': {
                text: 'Close',
                'class': 'dialogButton',
                'id': 'confim',
                click: function () {
                    $(this).dialog('destroy');
                }
            }
        }
    });
}

function createMissingAmountMadeDialog() {
    message = 'Please enter an amount made.';
    $('<div id = dialog align =center > ' + '<h3>' + message + '</h3>' + '<br>' + ' </div>'
    ).dialog({
        title: ' Missing Amount Made',
        autoOpen: true,
        modal: true,
        width: $(window).width() > 400 ? 400 : 'auto',
        resizable: false,
        draggable: false,
        buttons: {
            'Close': {
                text: 'Close',
                'class': 'dialogButton',
                'id': 'confim',
                click: function () {
                    $(this).dialog('destroy');
                }
            }
        }
    });
}

function createMissingMaintenanceDialog() {
        message = 'Please enter valid maintenance details.';
    $('<div id = dialog align =center > ' + '<h3>' + message + '</h3>' + '<br>' + ' </div>'
    ).dialog({
        title: ' Missing Maintenance Details',
        autoOpen: true,
        modal: true,
        width: $(window).width() > 400 ? 400 : 'auto',
        resizable: false,
        draggable: false,
        buttons: {
            'Close': {
                text: 'Close',
                'class': 'dialogButton',
                'id': 'confim',
                click: function () {
                    $(this).dialog('destroy');
                }
            }
        }
    });
}

function createForgotMileageSubmitDialog() {
    missingDate = localStorage.getItem('mileage-timestamp');
    mileageTotal = localStorage.getItem('total-mileage');

    if (missingDate) {
         missingFormattedDate = formatMissingTimestamp(missingDate);
    }

    message = 'You entered ' + mileageTotal + ' miles on ' 
    + missingFormattedDate + ' but it did not submit';
    question = 'Would you like to submit now?'
    $('<div id = dialog align =center > ' + '<h3>' + message + '</h3>' 
        + '<br><h4>' + question + '</h4>'+ '<br>' + ' </div>'
    ).dialog({
        title: ' Forgot to Submit Mileage?',
        autoOpen: true,
        modal: true,
        width: $(window).width() > 400 ? 400 : 'auto',
        resizable: false,
        draggable: false,
        buttons: {
            'Yes': {
                text: 'Yes',
                'class': 'dialogButton',
                'id': 'confim',
                click: function () {
                    submitMissingForm(missingDate);
                    $(this).dialog('destroy');
                }
            }, 
            'No': {
                text: 'No',
                'class': 'dialogButton',
                'id': 'confim',
                click: function () {
                    removeMileageLocalStorage();
                    clearMileageInputValues();
                    $(this).dialog('destroy');
                }
            }
        }
    });
}

function createForgotMaintenanceSubmitDialog() {
    missingDate = localStorage.getItem('maintenance-timestamp');
    maintenanceType = localStorage.getItem('maintenance-type');
    maintenanceCost = localStorage.getItem('maintenance-cost');

    if (missingDate) {
        missingFormattedDate = formatMissingTimestamp(missingDate);
   }

   message = 'You entered ' + maintenanceType + ':' + maintenanceCost + ' on ' 
   + missingFormattedDate + ' but it did not submit';
   question = 'Would you like to submit now?'
    $('<div id = dialog align =center > ' + '<h3>' + message + '</h3>' 
        + '<br><h4>' + question + '</h4>'+ '<br>' + ' </div>'
    ).dialog({
        title: ' Forgot to Submit Maintenance?',
        autoOpen: true,
        modal: true,
        width: $(window).width() > 400 ? 400 : 'auto',
        resizable: false,
        draggable: false,
        buttons: {
            'Yes': {
                text: 'Yes',
                'class': 'dialogButton',
                'id': 'confim',
                click: function () {
                    submitMissingForm(missingDate);
                    $(this).dialog('destroy');
                }
            }, 
            'No': {
                text: 'No',
                'class': 'dialogButton',
                'id': 'confim',
                click: function () {
                    removeMaintenanceLocalStorage();
                    clearMaintenanceInputValues();
                    $(this).dialog('destroy');
                }
            }
        }
    });
}