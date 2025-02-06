$(document).ready(function () {
    checkMileageLocalStorage();

    localMileageStorageHeartbeat();
    localMaintenanceStorageHeartbeat();

    $('#entryType').change(function () {
        if ($(this).val() === 'maintenance') {
            $('#mileageInput').hide();
            $('#maintenanceFields').show();
            checkMaintenanceLocalStorage();
        } else {
            $('#mileageInput').show();
            $('#maintenanceFields').hide();
        }
    });

     // Store mileage values in local storage when changed
     $('#startMileage').on('input', function () {
            localStorage.setItem(`mileage-start`, $('#startMileage').val());
    });

    $('#endMileage').on('input', function () {
            localStorage.setItem(`mileage-finish`, $('#endMileage').val());
            localStorage.setItem('total-mileage', $('#endMileage').val() - $('#startMileage').val())
            // Store current timestamp when ending mileage is entered
            localStorage.setItem('mileage-timestamp', Date.now());
    });

    $('#maintenanceType').on('input', function () {
        localStorage.setItem(`maintenance-type`, $('#maintenanceType').val().toUpperCase());
    });
    
    $('#maintenanceCost').on('input', function () {
        localStorage.setItem(`maintenance-cost`, $('#maintenanceCost').val());
        // Store current timestamp when ending mileage is entered
        localStorage.setItem('maintenance-timestamp', Date.now());
    });
});

function submitForm() {
    let startMileage = document.getElementById("startMileage").value;
    let endMileage = document.getElementById("endMileage").value;
    let mileage = endMileage - startMileage;
    let entryType = document.getElementById("entryType").value;
    let formData = { "date": FORMATED_DATE };

    if (entryType === "mileage") {
        setMileage();
        if (!mileage || mileage <= 0 || !Number.isInteger(Number(mileage))) {
            createMissingMileageDialog();
            return;
        }
        formData["startMileage"] = startMileage;
        formData["endMileage"] = endMileage
        formData["mileage"] = mileage;
    } else {
        setType();
        setCost();
        let type = document.getElementById("maintenanceType").value.toUpperCase();
        let cost = document.getElementById("maintenanceCost").value;
        if (!type || !cost || isNaN(cost)) {
            createMissingMaintenanceDialog();
            return;
        }

        formData["type"] = type;
        formData["cost"] = cost;
    }

    fetch(SCRIPT_URL, {
        method: 'POST',
        body: new URLSearchParams(formData),
        mode: 'no-cors',
    })
    .then(() => {
        if (entryType == "mileage") {
            createMileageSubmitted();
            removeMileageLocalStorage();
            clearMileageInputValues();
        } else {
            createMaintenanceSubmitted();
            removeMaintenanceLocalStorage();
            clearMaintenanceInputValues();
        }
    });
}

function submitMissingForm(missingDate) {
    if (missingDate) {
        formatTimestamp(missingDate);
    }

    let startMileage = document.getElementById("startMileage").value;
    let endMileage = document.getElementById("endMileage").value;
    let mileage = endMileage - startMileage;
    let entryType = document.getElementById("entryType").value;
    let formData = { "date": MISSING_DATE };

    if (entryType === "mileage") {
        setMileage();
        if (!mileage || mileage <= 0 || !Number.isInteger(Number(mileage))) {
            createMissingMileageDialog();
            return;
        }
        formData["startMileage"] = startMileage;
        formData["endMileage"] = endMileage
        formData["mileage"] = mileage;
    } else {
        setType();
        setCost();
        let type = document.getElementById("maintenanceType").value;
        let cost = document.getElementById("maintenanceCost").value;
        if (!type || !cost || isNaN(cost)) {
            createMissingMaintenanceDialog();
            return;
        }
        formData["type"] = type;
        formData["cost"] = cost;
    }

    fetch(SCRIPT_URL, {
        method: 'POST',
        body: new URLSearchParams(formData),
        mode: 'no-cors',
    })
    .then(() => {
        if (entryType == "mileage") {
            createMissingMileageSubmitted();
            removeMileageLocalStorage();
            clearMileageInputValues();
        } else {
            createMissingMaintenanceSubmitted();
            removeMaintenanceLocalStorage();
            clearMaintenanceInputValues();
        }
    });
}

function checkMileageLocalStorage() {
    // Check and load mileage values from local storage
    if (localStorage.getItem('mileage-start')) {
        $('#startMileage').val(localStorage.getItem('mileage-start'));
    }
    if (localStorage.getItem('mileage-finish')) {
        $('#endMileage').val(localStorage.getItem('mileage-finish'));
    }

    if (localStorage.getItem('mileage-timestamp')) {
        let storedTimestamp = parseInt(localStorage.getItem('mileage-timestamp'), 10);
        let currentTime = Date.now();
        let timeDifference = currentTime - storedTimestamp;
        let hoursPassed = timeDifference / (1000 * 60 * 60);

        if (hoursPassed > 6) {
            createForgotMileageSubmitDialog();
        }
    }
}

function checkMaintenanceLocalStorage() {
    if (localStorage.getItem('maintenance-type')) {
        $('#maintenanceType').val(localStorage.getItem('maintenance-type'));
    }
    if (localStorage.getItem('maintenance-cost')) {
        $('#maintenanceCost').val(localStorage.getItem('maintenance-cost'));
    }

    if (localStorage.getItem('maintenance-timestamp')) {
        let storedTimestamp = parseInt(localStorage.getItem('maintenance-timestamp'), 10);
        let currentTime = Date.now();
        let timeDifference = currentTime - storedTimestamp;
        let hoursPassed = timeDifference / (1000 * 60 * 60);

        if (hoursPassed > 24) {
            createForgotMaintenanceSubmitDialog();
        }
    }
}

function removeMileageLocalStorage() {
    localStorage.removeItem('mileage-start');
    localStorage.removeItem('mileage-finish');
    localStorage.removeItem('total-mileage');
    localStorage.removeItem('mileage-timestamp');
}

function removeMaintenanceLocalStorage() {
    localStorage.removeItem('maintenance-type');
    localStorage.removeItem('maintenance-cost');
    localStorage.removeItem('maintenance-timestamp');
}

function clearMileageInputValues() {
    document.getElementById("startMileage").value = "";
    document.getElementById("endMileage").value = "";
}

function clearMaintenanceInputValues() {
        document.getElementById("maintenanceType").value = "";
        document.getElementById("maintenanceCost").value = "";
}

function localMileageStorageHeartbeat() {
    // Heartbeat: Logs "Heartbeat" every hour
    setInterval(function () {
        console.log("Heartbeat");
        checkMileageLocalStorage();
    }, 60 * 60 * 1000); // 6 Hours Check
}

function localMaintenanceStorageHeartbeat() {
    // Heartbeat: Logs "Heartbeat" every hour
    setInterval(function () {
        console.log("Heartbeat");
        checkMaintenanceLocalStorage();
    // }, 10 * 1000); // 60 minutes * 60 seconds * 1000 milliseconds
    }, 24 * 60 * 60 * 1000); // Daily Check
}

function formatTimestamp(timestamp) {
    let date = new Date(parseInt(timestamp, 10)); // Convert string to integer and create Date object

    MISSING_DATE = date.toLocaleDateString('en-US', { 
        year: 'numeric', 
        month: 'long', 
        day: 'numeric' 
    });

    return MISSING_DATE; // Returns formatted date as "Month DD, YYYY"
}

function formatMissingTimestamp(missingTimestamp) {
    let date = new Date(parseInt(missingTimestamp, 10)); // Convert string to integer and create Date object
    
    let month = date.toLocaleString('en-US', { month: 'long' }); // Full month name (e.g., "February")
    let day = date.getDate().toString().padStart(2, '0'); // Ensures two-digit day
    let year = date.getFullYear(); // Gets full year (e.g., "2025")
    
    CHANGE_TIME = date.toLocaleString('en-US', { 
        hour: 'numeric', 
        minute: '2-digit', 
        hour12: true 
    });

    return `${month} ${day}, ${year} at ${CHANGE_TIME}`; // Format as Month DD, YYYY
}