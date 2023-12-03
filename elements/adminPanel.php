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
        <div class="profile">
            <?php echo "<p style='text-align:center; font-size: 40px;'>Witaj ".$_SESSION['nick']."!</p>";?>
            <div class="imgcontainer">
                <img src="../img/user_avatar.png" alt="Avatar" class="avatar">
            </div>
            <?php
                if(isset($_SESSION['blad']))
                {
                    echo $_SESSION['blad'];
                }
                unset($_SESSION['blad']);
	        ?>

            <button class="s-psw" onclick="passwordChangeButton()">Zmień hasło</button>

            <div id="change-passwd">
                <form method="post" action="../server/api_resetPassword.php">
                    <input type="password" placeholder="Wpisz obecne hasło" name="old_password" id="old_password" required>
                    <input type="password" placeholder="Wpisz nowe hasło" name="new_password_1" id="new_password_1" required>
                    <input type="password" placeholder="Powtórz nowe hasło" name="new_password_2" id="new_password_2" required>
                    <button type="submit">Wyślij nowe hasło</button>
                </form>
            </div>

            <button class="s-psw" onclick="addressChangeButton()">Dane Adresowe</button>
            <div id="change-address">
            <?php
                if($row === null)
                {
                    $row = [
                        'street' => " ",
                        'postcode' => " ",
                        'city' => " ",
                        'number' => " "
                    ];
                }
 
                echo "<form method=\"post\" action=\"../server/api_changeAddress.php\">
                        <label for=\"fname\">Ulica:</label><br>
                        <input type=\"text\" id=\"street\" name=\"street\" required value=$row[street]><br>

                        <label for='lname'>Numer:</label><br>
                        <input type='text' id='number' name='number' required value=$row[number]><br>

                        <label for='lname'>Kod pocztowy:</label><br>
                        <input type='text' id='postcode' name='postcode' required value=$row[postcode]><br>

                        <label for='lname'>Miasto:</label><br>
                        <input type='text' id='city' name='city' required value=$row[city]><br><br>

                        <button type='submit'>Edytuj</button>
                    </form>";
            ?>

            </div>
            <a href="booksEditor.php"><button type="button" class="booksEditorbtn">Edytor książek</button></a>
            <a href="bookAdd.php"><button type="button" class="booksEditorbtn">Dodaj książkę</button></a>
            <a href="orderStatusEditor.php"><button type="button" class="usersbtn">Edytuj status zamówienia</button></a>
            <a href="usersEditor.php"><button type="button" class="usersbtn">Usuń użytkowników</button></a>
            <a href="../server/api_logout.php"><button type="button" class="logoutbtn">Wyloguj się</button></a>
        </div>
        <script src="../js/funkcje.js"></script>
    </body>
</html>