<?php
    session_start();
    if(!isset($_SESSION['zalogowany']))
    {
      header("Location:loggin.php");
      exit();
    }
    if($_SESSION['nick'] !== "admin")
    {
        header("Location:loggin.php");
        exit();
    }


    require_once"connect.php";
	mysqli_report(0);

    $connection = @new mysqli($host,$db_user,$db_password,$db_name);

    if($connection -> connect_errno)
    {
        echo "Failed to connect to MySQL: " . $connection -> connect_errno;
    }
    else
    {
		$login = $_SESSION['nick'];
        $result = @$connection->query(sprintf("CALL getAddress('%s')",
		mysqli_real_escape_string($connection,$login)));

        if($result)
	    {
            $row = $result->fetch_assoc();
        }

    }
 ?>
<!doctype html>
<html lang="pl">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Czytelno</title>
        <link rel="stylesheet" href="../css/bootstrap.min.css">
        <link rel="stylesheet" href="../css/style.css">
        <link rel="stylesheet" href="../css/style.resposive.css">
    </head>
    <body>
        <?php include 'header.html';?>
              <section>
            <div class="container" id="bookinfo">
                <div class="row">
                    <div class="col s12 m12 l12">
                        <h3 class="grey-text" id="title">Tytuł</h3>
                        <div class="col s6 offset-s3 m6 offset-m3 l6 offset-l3 xl6 offset-xl3">
                            <img src="../img/books/labirynt.png" class="responsive-img" id="miniatureImg">
                        </div>
                        <table>
                            <tr>
                                <td class="flow-text grey-text" id="author">Autor:</td>
                                <td class="flow-text grey-text" id="year">Data wydania:</td>
                            </tr>
                            <tr>
                                <td class="flow-text grey-text" id="publisher">Wydawnictwo:</td>
								<td class="flow-text grey-text" id="pages">Liczba stron:</td>
                            </tr>
                            <tr>
                                <td class="flow-text grey-text" id="category">Kategoria:</td>
                                <td class="flow-text grey-text" id="price">Cena:</td>
                            </tr>
                        </table>
                    </div>
                </div>
                <div class="row">
                    <div class="col s12 m12 l12">
                        <h3 class="grey-text">Opis książki:</h3>
                        <p class="flow-text grey-text" id="description">
                            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam consequat egestas luctus. Morbi et mauris augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Aenean at nunc nisi. Aliquam mauris tortor, iaculis sit amet luctus sit amet, varius et enim. Sed tristique, nulla ac ultricies euismod, lacus erat ornare lectus, id venenatis diam erat et risus. Interdum et malesuada fames ac ante ipsum primis in faucibus. Nunc eu dolor vel dui volutpat dignissim condimentum eu elit. In lacinia leo quis magna posuere accumsan. Nulla urna eros, interdum vitae laoreet nec, rutrum a risus. Curabitur consequat lobortis ligula vitae egestas. Nullam sed imperdiet tellus. Interdum et malesuada fames ac ante ipsum primis in faucibus.</p>
                    </div>
                </div>
            </div>

    <script src="https://code.jquery.com/jquery-2.1.1.min.js"></script>
    <script src="../database/dataBaseManager.js"></script>
    <script src="../js/DisplayBookDetails.js"></script>
    </body>
</html>