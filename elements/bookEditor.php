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
        <?php include 'header.html';

            if(isset($_SESSION['blad']))
            {
                echo $_SESSION['blad'];
            }
            unset($_SESSION['blad']);
	    ?>
        <div class="row">
            <form method="post" action="../server/api_bookEdit.php">

                <label for='ID'>Id (Zmieniać tylko w uzasadnionych przypadkach)</label><br>
                <textarea id='ID' name='ID' rows='2' cols='10' required></textarea><br><br>

                <label for='category'>Kategoria</label><br>
                <textarea id='category' name='category' rows='2' cols='100' required></textarea><br><br>

                <label for='title'>Tytuł</label><br>
                <textarea id='title' name='title' rows='2' cols='100' required></textarea><br><br>

                <label for='author'>Autor</label><br>
                <textarea id='author' name='author' rows='2' cols='100' required></textarea><br><br>

                <label for='publisher'>Wydawnictwo</label><br>
                <textarea id='publisher' name='publisher' rows='2' cols='100' required></textarea><br><br>

                <label for='year'>Rok wydania</label><br>
                <textarea id='year' name='year' rows='2' cols='100' required></textarea><br><br>

                <label for='pages'>Ilość stron</label><br>
                <textarea id='pages' name='pages' rows='2' cols='100' required></textarea><br><br>

                <label for='price'>Cena</label><br>
                <textarea id='price' name='price' rows='2' cols='100' required></textarea><br><br>

                <label for='description'>Opis</label><br>
                <textarea id='description' name='description' rows='20' cols='100' required></textarea><br><br>

                <label for='img'>Nazwa obrazka</label><br>
                <textarea id='img' name='img' rows='2' cols='100' required></textarea><br><br>

                <button type='submit'>Edytuj</button>
            </form>";
            <a href="adminPanel.php"><button type="button">Powrót</button></a>
        </div>
        <script src="../database/dataBaseManager.js"></script>
        <script src="../js/DisplayBookDetailsInEditor.js"></script>
    </body>
</html>