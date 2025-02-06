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

const SCRIPT_URL = 'https://script.google.com/macros/s/AKfycbz3IBmkvQYzrRS6rW3iBq9PsmD9OE6wiJ52COavWk4fG1ELdqagJpuR98T3EzTqHPUaiA/exec';

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