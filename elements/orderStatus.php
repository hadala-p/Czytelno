<?php
    session_start();
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
        <div class="orderStatusContainer">
            <form id="orderStatusInfo" method="post" action="../server/api_orderStatusInfo.php">
                <label for="title">Podaj numer zamówienia</label><br>
                <input type="text" id="order" name="order" required><br>
                <button type='submit'>Sprawdź</button>
            </form>
            <?php
            if(isset($_SESSION['blad']))
                {
                    echo $_SESSION['blad'];
                }
                unset($_SESSION['blad']);
            ?>
        </div>
    </body>
</html>