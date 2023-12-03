async function getBooksInfoArray(requestPrefix = '') {
	let reponse = await fetch(requestPrefix + 'server/api_booksinfo.php');
	let json = await reponse.json();

	return json;
}
async function getBookInfoArray(requestPrefix = '') {
	let reponse = await fetch(requestPrefix + '../server/api_booksinfo.php');
	let json = await reponse.json();

	return json;
}
async function getOrdersInfoArray(requestPrefix = '') {
	let reponse = await fetch(requestPrefix + '../server/api_ordersinfo.php');
	let json = await reponse.json();

	return json;
}
async function getUsersInfoArray(requestPrefix = '') {
	let reponse = await fetch(requestPrefix + '../server/api_usersInfo.php');
	let json = await reponse.json();

	return json;
}

