function myFunction() {
    var x = document.getElementById("myTopnav");
    if (x.className === "topnav") {
        x.className += " responsive";
    } else {
        x.className = "topnav";
    }
}
function myFunction2() {
    var x = document.getElementById("btn-content");
    if (x.style.display === "block") {
        x.style.display = "none";
    } else {
        x.style.display = "block";
    }
}
function passwordChangeButton() {
    var x = document.getElementById("change-passwd");
    if (x.classList.contains("expanded")) {
        x.classList.remove("expanded");
    } else {
        x.classList.add("expanded");
    }
}
function addressChangeButton() {
    var x = document.getElementById("change-address");
    if (x.classList.contains("expanded")) {
        x.classList.remove("expanded");
    } else {
        x.classList.add("expanded");
    }
}
function s_edytor() {
    var x = document.getElementById("edytor");
    if (x.style.display === "block") {
        x.style.display = "none";
    } else {
        x.style.display = "block";
    }
}