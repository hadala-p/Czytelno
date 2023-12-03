
async function drawContent() {
    let response = await getUsersInfoArray();

    var tbody = document.querySelector("#template-body");
    var template = document.querySelector('#car-template');

    if(tbody == null || template == null)
        return;

    let length = Object.keys(response).length;
    for(let i = 0; i < length; i++) {
        let instance = template.content.cloneNode(true);
        let instanceId = instance.querySelector('#template-id');
        let instanceNick = instance.querySelector('#template-nick');
        let instanceFirstName = instance.querySelector('#template-imie');
        let instanceLastName = instance.querySelector('#template-nazwisko');
        let instanceEmail = instance.querySelector('#template-email');
        let deleteButton = instance.querySelector('.delete-btn');

        instanceId.innerText = response[i]['id'];
        instanceNick.innerText = response[i]['nick'];
        instanceFirstName.innerText = response[i]['firstName'];
        instanceLastName.innerText = response[i]['lastName'];
        instanceEmail.innerText = response[i]['email'];
        deleteButton.dataset.id = response[i]['id'];

        deleteButton.addEventListener('click', function () {
            deleteUser(this.dataset.id);
        });

        tbody.appendChild(instance);
    }
}
function deleteUser(userId) {
    fetch('../server/api_deleteUser.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: `userId=${userId}`
    })
        .then(response => response.text())
        .then(data => {
            console.log(data);
            // Mo¿esz tutaj dodaæ logikê do odœwie¿enia listy u¿ytkowników po usuniêciu
        })
        .catch(error => {
            console.error('B³¹d:', error);
        });
}
drawContent()