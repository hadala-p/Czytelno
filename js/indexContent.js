
async function drawContent() {
    let response = await getBooksInfoArray();

    var tbody = document.querySelector("#template-body");
    var template = document.querySelector('#car-template');

    if(tbody == null || template == null)
        return;

    let length = Object.keys(response).length;
    for(let i = 0; i < length; i++) {
        let instance = template.content.cloneNode(true);
        let instanceImage = instance.querySelector('#template-preview-image');
        let instanceDesc = instance.querySelector('#template-description');
        let reservationButton = instance.querySelector('#reservation-button');

        instanceImage.src = response[i]['img'];
        instanceDesc.innerText = response[i]['title'];
        reservationButton.href = "elements/bookCard.php?id=" + response[i]["id"];

        tbody.appendChild(instance);
    }
}
drawContent()