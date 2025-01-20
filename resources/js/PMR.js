function submitMileage() {
    // Ensure MILEAGE is updated before use
    setMileage();  // Update MILEAGE from input

    if (!MILEAGE || MILEAGE <= 0 || !Number.isInteger(Number(MILEAGE))) {
        createMissingMileageDialog();
        return;
    }

    let formData = {
        "date": FORMATED_DATE,
        "mileage": MILEAGE
    };

    fetch(SCRIPT_URL, {
        method: 'POST',
        body: new URLSearchParams(formData),
        mode: 'no-cors',
    })
    .then(() => {
        createMileageSubmitted();
    });

    document.getElementById("mileage").value = ""; // Clear input
}

