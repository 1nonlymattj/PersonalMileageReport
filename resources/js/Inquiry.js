const FUZZY_DESIGN = document.getElementById("fuzzyWebDesign");
const INQUIRY_SCRIPT_URL = "https://script.google.com/macros/s/AKfycby496xFOH9y6aVv928OshrDCe6HmdCUQV2-clxyYns7d7AaI4PosynTM6SG8DDH34ttUg/exec";

FUZZY_DESIGN.addEventListener("click", function () {
    InquiryDialog();
});

function InquiryDialog() {
    let message = 'Thank you for Reaching out, Please fill out the form and we will contact you as soon as we can';
    $('<div id = dialog align =center > ' + '<h3>' + message + '</h3>' + '<br>' +
        '<form id = inquiryForm class= form-group>' + ' <input type= name name= InquiryName class= form-control id= inquiryName placeholder= Name required>' + '<br><br>'
        + '<input type= email name= InquiryEmail class= form-control id= inquiryEmail placeholder= Email Address required>' + '<br><br> ' +
        '<textarea name= InquiryMessage class= form-control-textfield rows = 5 col = 10 maxlength= 400 id= inquiryMessage placeholder= "Message" resize:none required></textarea>' + '<br><br><br><br><br>' +
        ' </form>' + ' </div>'
    ).dialog({
        title: 'Web Design Inquiry',
        autoOpen: true,
        modal: true,
        width: $(window).width() > 400 ? 400 : 'auto',
        resizable: false,
        draggable: false,
        buttons: {
            'Ok': {
                text: 'Send Inquiry',
                'class': 'dialogButton',
                'id': 'confim',
                click: function () {
                    if (document.getElementById("inquiryName").value != "" && document.getElementById("inquiryEmail").value != "" && document.getElementById("inquiryMessage").value != "") {
                        let form = document.getElementById('inquiryForm');
                        let data = new FormData(form);
                        fetch(INQUIRY_SCRIPT_URL, {
                            method: 'POST',
                            body: data,
                        }).then(() => {
                            $(this).dialog('destroy');
                            contactThankYouDialog();
                        })
                    } else {
                        InquiryInfoDialog();
                    }

                }
            },
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

function InquiryInfoDialog() {
    let message = 'Please fill out Information before submitting inquiry';
    $('<div id = dialog align =center > ' + '<h3>' + '<span class = caution> &#9888; <br></span>' + message + '</h3>' + '<br>' + ' </div>'
    ).dialog({
        title: 'Error Information Missing',
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