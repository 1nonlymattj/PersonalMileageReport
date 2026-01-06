// variables.js
const adminPin = '5609';

// Ensure mileage is updated before submission
let MILEAGE = 0;
let TYPE = '';
let COST = 0;
let AMOUNT_MADE = 0;

const DATE = new Date().toISOString().split("T")[0];
const FORMATED_DATE = new Date().toLocaleDateString('en-US', { 
    year: 'numeric', 
    month: 'long', 
    day: 'numeric' 
});
let MISSING_DATE = new Date().toLocaleDateString('en-US', { 
    year: 'numeric', 
    month: 'long', 
    day: 'numeric' 
});

const SCRIPT_URL = 'https://script.google.com/macros/s/AKfycbwh2JYB160zgeOcZGRCp5Hb-zkrOiu1wvt1UpDUE--Hx3ok87hXEOnw3fvCpWP_o00gYw/exec';

// Function to get the mileage input value
function setMileage() {
    MILEAGE = document.getElementById("endMileage").value - document.getElementById("startMileage").value;
}
function setType() {
    TYPE = document.getElementById("maintenanceType").value.toUpperCase();
}

function setCost() {
    COST = document.getElementById("maintenanceCost").value;
}

function setAmountMade() {
  AMOUNT_MADE = document.getElementById("amountMade").value;
}