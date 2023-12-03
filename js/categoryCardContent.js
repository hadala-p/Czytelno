var $_GET = new Array();

function GET() {
    var url = location.search.replace("?", "").split("&");
    for (var index = 0; index < url.length; index++) {
        var value = url[index].split("=");
        $_GET[value[0]] = value[1];
    }
}
GET();
async function drawContent() {

    let category = $_GET['category'];
    category = category.replace("_", " ");
    if (category == 'Kryminal') {
        category = "Kryminał";
    }
    console.log(category);
    let response = await getBookInfoArray();

    var tbody = document.querySelector("#template-body");
    var template = document.querySelector('#car-template');
    var categoryTitle = document.querySelector('#category-title');
    categoryTitle.innerText = category;

    if(tbody == null || template == null)
        return;

    let length = Object.keys(response).length;
    for (let i = 0; i < length; i++) {
        if (response[i]['category'] == category) {
            let instance = template.content.cloneNode(true);
            let instanceImage = instance.querySelector('#template-preview-image');
            let instanceDesc = instance.querySelector('#template-description');
            let reservationButton = instance.querySelector('#reservation-button');

            instanceImage.src = ("../" + response[i]['img']);
            instanceDesc.innerText = response[i]['title'];
            reservationButton.href = "bookCard.php?id=" + response[i]["id"];

            tbody.appendChild(instance);
        }
        
    }
}
drawContent()