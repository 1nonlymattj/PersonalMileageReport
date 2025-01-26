// variables.js

// Ensure mileage is updated before submission
let MILEAGE = 0;
let TYPE = '';
let COST = 0;
const DATE = new Date().toISOString().split("T")[0];
const FORMATED_DATE = new Date().toLocaleDateString('en-US', { 
    year: 'numeric', 
    month: 'long', 
    day: 'numeric' 
});

const SCRIPT_URL = 'https://script.google.com/macros/s/AKfycbzDlHuOq8lYiIXLmFVddySJZWatHuGkElZ__f-gVo7oofMVxWO-LrZxOOlJAg_xAch12Q/exec';

// Function to get the mileage input value
function setMileage() {
    MILEAGE = document.getElementById("endMileage").value - document.getElementById("startMileage").value;
}
function setType() {
    TYPE = document.getElementById("type").value;
}

function setCost() {
    COST = document.getElementById("cost").value;
}