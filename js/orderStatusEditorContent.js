
async function drawContent() {
    let response = await getOrdersInfoArray();

    var tbody = document.querySelector("#template-body");
    var template = document.querySelector('#car-template');

    if(tbody == null || template == null)
        return;

    let length = Object.keys(response).length;
    for(let i = 0; i < length; i++) {
        let instance = template.content.cloneNode(true);
        let instanceId = instance.querySelector('#template-id');
        let instanceDate = instance.querySelector('#template-date');
        let instancePrice = instance.querySelector('#template-price');
        let instanceStatus = instance.querySelector('#template-status');

        instanceId.innerText = response[i]['id'];
        instanceDate.innerText = response[i]['date'];
        instancePrice.innerText = response[i]['price'];
        instanceStatus.innerText = response[i]['status'];

        tbody.appendChild(instance);
    }
}
drawContent()