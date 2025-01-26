$(document).ready(function () {
    $('#entryType').change(function () {
        if ($(this).val() === 'maintenance') {
            $('#mileageInput').hide();
            $('#maintenanceFields').show();
        } else {
            $('#mileageInput').show();
            $('#maintenanceFields').hide();
        }
    });
});

function submitForm() {
    let mileage = document.getElementById("endMileage").value - document.getElementById("startMileage").value;

    const entryType = document.getElementById("entryType").value;
    let formData = { "date": FORMATED_DATE };

    if (entryType === "mileage") {
        setMileage();
        if (!mileage || mileage <= 0 || !Number.isInteger(Number(mileage))) {
            createMissingMileageDialog();
            return;
        }
        formData["mileage"] = mileage;
    } else {
        setType();
        setCost();
        const type = document.getElementById("type").value;
        const cost = document.getElementById("cost").value;
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
        } else {
            createMaintenanceSubmitted();
        }
        document.getElementById("startMileage").value = "";
        document.getElementById("endMileage").value = "";
        document.getElementById("type").value = "";
        document.getElementById("cost").value = "";
    });
}