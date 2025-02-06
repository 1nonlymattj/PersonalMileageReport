$(document).ready(function () {
    $('#entryType').change(function () {
        if ($(this).val() === 'maintenance') {
            $('#mileageInput').hide();
            $('#companySelection').hide();
            $('#maintenanceFields').show();
        } else {
            $('#mileageInput').show();
            $('#companySelection').show();
            $('#maintenanceFields').hide();
        }
    });



    //     if ($('#companySelection').val() === 'DoorDash') {
    //     $('button').addClass('doordash-btn');
    //     $('button').removeClass('uberEats-btn');
    //     $('button').removeClass('spark-btn');
    //     $('button').removeClass('instaCart-btn');
    //     } else if ($('#companySelection').val() === 'Uber Eats') {
    //     $('button').addClass('uberEats-btn');
    //     $('button').removeClass('doordash-btn');
    //     $('button').removeClass('spark-btn');
    //     $('button').removeClass('instaCart-btn');
    // } else if($('#companySelection').val() === 'InstaCart') {
    //     $('button').addClass('instaCart-btn');
    //     $('button').removeClass('doordash-btn');
    //     $('button').removeClass('uberEats-btn');
    //     $('button').removeClass('spark-btn');
    // } else if(($('#companySelection').val() === 'Spark')) {
    //     $('button').addClass('spark-btn');
    //     $('button').removeClass('doordash-btn');
    //     $('button').removeClass('uberEats-btn');
    //     $('button').removeClass('instaCart-btn');
    // } else {
    //     $('button').removeClass('doordash-btn');
    //     $('button').removeClass('uberEats-btn');
    //     $('button').removeClass('instaCart-btn');
    //     $('button').removeClass('spark-btn');
    // }

     // Store mileage values in local storage when changed
     $('#startMileage').on('input', function () {
            localStorage.setItem(`mileage-start`, $('#startMileage').val());
    });

    $('#endMileage').on('input', function () {
            localStorage.setItem(`mileage-finish`, $('#endMileage').val());
    });
});

function submitForm() {
    let selectedCompanies = [];
    $('input[name="companySelection"]:checked').each(function () {
        selectedCompanies.push($(this).val());
    });
    let mileage = document.getElementById("endMileage").value - document.getElementById("startMileage").value;
    let entryType = document.getElementById("entryType").value;
    let formData = { "date": FORMATED_DATE };
    
    selectedCompanies.forEach((company, index) => {
        formData[`company${index + 1}`] = company;
    });

    if (selectedCompanies.length > 1) {
        formData['companies'] = selectedCompanies.join(' & ');
    }

    if (entryType === "mileage") {
        setMileage();
        if (!mileage || mileage <= 0 || !Number.isInteger(Number(mileage))) {
            createMissingMileageDialog();
            return;
        }
        formData["company"] = companySelection;
        formData["mileage"] = mileage;

        // Remove mileage data from local storage upon submission
        localStorage.removeItem('mileage-start');
        localStorage.removeItem('mileage-finish');
    } else {
        setType();
        setCost();
        let type = document.getElementById("type").value;
        let cost = document.getElementById("cost").value;
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
        document.querySelectorAll('input[name="companySelection"]').forEach(checkbox => {
            checkbox.checked = false;
        });
    });
}