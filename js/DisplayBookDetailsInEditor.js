var $_GET = new Array();

function GET() {
	var url = location.search.replace("?", "").split("&");
	for (var index = 0; index < url.length; index++) {
		var value = url[index].split("=");
		$_GET[value[0]] = value[1];
	}
}
GET();

async function displayDetails() {
	if ($_GET['id'] == undefined)
		window.location = "index.php";
	let id = $_GET['id'] - 1;

	let response = await getBookInfoArray();

	let ID = response[id]['id'] + " ";
	let IDDiv = document.getElementById("ID");
	IDDiv.innerText = ID;

	let title = response[id]['title'] + " ";
	let titleDiv = document.getElementById("title");
	titleDiv.innerText = title;

	let author = response[id]['author'];
	let authorDiv = document.getElementById("author");
	authorDiv.innerText += " " + author;

	let publisher = response[id]['publisher'];
	let publisherDiv = document.getElementById("publisher");
	publisherDiv.innerText += " " + publisher;

	let year = response[id]['year'];
	let yearDiv = document.getElementById("year");
	yearDiv.innerText += " " + year;

	let pages = response[id]['pages'];
	let pagesDiv = document.getElementById("pages");
	pagesDiv.innerText += " " + pages;

	let category = response[id]['category'];
	let categoryDiv = document.getElementById("category");
	categoryDiv.innerText += " " + category;

	let price = response[id]['price'];
	let priceDiv = document.getElementById("price");
	priceDiv.innerText += " " + price;

	let description = response[id]['description'];
	let descriptionDiv = document.getElementById("description");
	descriptionDiv.innerText = description;

	let imgsrc = response[id]['img'];
	let imageDiv = document.getElementById("img");
	imageDiv.innerText += " " + imgsrc;

	let basketBookId = response[id]['id'];
	let basketBookName = response[id]['title'];
	let basketBookPrice = response[id]['price'];


	let addToCartButton = document.getElementById("addToCartButton");
	addToCartButton.setAttribute('onclick', `addToCart(${basketBookId}, '${basketBookName}', ${basketBookPrice})`);



}

displayDetails();