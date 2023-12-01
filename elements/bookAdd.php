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
            <form method="post" action="../server/api_bookAdd.php">

                <label for="category">Kategoria</label><br>
                <input type="text" id="category" name="category" required><br>

                <label for="title">Tytuł</label><br>
                <input type="text" id="title" name="title" required><br>

                <label for='author'>Autor</label><br>
                <input type='text' id='author' name='author' required><br>

                <label for='publisher'>Wydawnictwo</label><br>
                <input type='text' id='publisher' name='publisher' required><br>

                <label for='year'>Rok wydania</label><br>
                <input type='text' id='year' name='year' required><br><br>

                <label for='pages'>Ilość stron</label><br>
                <input type='text' id='pages' name='pages' required><br><br>

                <label for='price'>Cena</label><br>
                <input type='text' id='price' name='price' required><br><br>

                <label for='description'>Opis</label><br>
                <textarea id='description' name='description' rows='20' cols='100' required></textarea><br><br>

                <label for='img'>Nazwa obrazka</label><br>
                <input type='text' id='img' name='img' required><br><br>

                <button type='submit'>Dodaj</button>
            </form>";
            <a href="adminPanel.php"><button type="button">Powrót</button></a>
        </div>
    </body>
</html>