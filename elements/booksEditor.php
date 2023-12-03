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
        <div class="row" id="template-body">
                <template id="car-template">
                    <div class="col s12 m8 offset-m2 l4">
                        <div class="card">
                            <div class="card-image">
                                <img src="../img/books/Kwazar.png" class="responsive-img" id="template-preview-image" alt="Książka">
                            </div>
                            <div class="card-content grey darken-4" >
                                <p class="white-text height1" id="template-description">Tutaj ma być opis samochodu</p>
                            </div>
                            <div class="card-action orange darken-3" style="text-align: center !important;">
                                <a href="book_card.php" id="reservation-button">Edytuj</a>
                            </div>
                        </div>
                    </div>    
                </template>
            </div>
        <script src="https://code.jquery.com/jquery-2.1.1.min.js"></script>
        <script src="../database/dataBaseManager.js"></script>
        <script src="../js/booksEditorContent.js"></script>
    </body>
</html>