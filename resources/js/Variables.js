// variables.js

// Ensure mileage is updated before submission
let MILEAGE = 0;
const DATE = new Date().toISOString().split("T")[0];
const FORMATED_DATE = new Date().toLocaleDateString('en-US', { 
    year: 'numeric', 
    month: 'long', 
    day: 'numeric' 
});

const SCRIPT_URL = 'https://script.google.com/macros/s/AKfycbxzk9SiAPPTpzg9Xe9HDknAUlps8vee9iMJNpGOUkYl17e1_fNzBL6EsKFl_t63CV1Vlw/exec';

// Function to get the mileage input value
function setMileage() {
    MILEAGE = document.getElementById("mileage").value;
}