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

	let model = response[id]['title'] + " ";
	let modelDiv = document.getElementById("title");
	modelDiv.innerText = model;

	let imgsrc = "../" + response[id]['img'];
	let imageDiv = document.getElementById("miniatureImg");
	imageDiv.src = imgsrc;

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
}

displayDetails();