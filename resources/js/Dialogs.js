function createMileageSubmitted() {
    if (MILEAGE > 1) {
        message = MILEAGE + ' miles have  been submitted for ' + FORMATED_DATE + '.';
    } else {
        message = MILEAGE + ' mile has  been submitted for ' + FORMATED_DATE + '.';
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