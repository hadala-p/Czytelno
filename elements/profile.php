<?php
    session_start();
    if(!isset($_SESSION['zalogowany']))
    {
      header("Location:loggin.php");
      exit();
    }
    if($_SESSION['nick'] === "admin")
    {
        header("Location:adminPanel.php");
        exit();
    }


    require_once"connect.php";
	mysqli_report(0);

    $connection = new mysqli($host,$db_user,$db_password,$db_name);
    $connection2 = new mysqli($host,$db_user,$db_password,$db_name);
    $connection3 = new mysqli($host,$db_user,$db_password,$db_name);

    if($connection -> connect_errno)
    {
        echo "Failed to connect to MySQL: " . $connection -> connect_errno;
    }
    else
    {
		$login = $_SESSION['nick'];
        $result = $connection->query(sprintf("CALL getAddress('%s')",
		mysqli_real_escape_string($connection,$login)));
        if($result)
	    {
            $row = $result->fetch_assoc();
        }

        $result2 = $connection2->query("CALL getUserId('$login')");
        if ($result2) {
            $row2 = $result2->fetch_assoc();
        }

        $result3 = $connection3->query("CALL getUserOrders(".$row2['id'].")");
        if ($result3) 
        {
            $row3 = array();
            while ($row4 = $result3->fetch_assoc()) 
            {
                $row3[] = $row4;
            }
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
            <a href="../server/api_logout.php"><button type="button" class="logoutbtn">Wyloguj się</button></a>
        </div>
        <div class="row profileOrders">
            <h1>Zamówienia</h1>
            <div class="col-md-2">Id</div>
            <div class="col-md-3">Data</div>
            <div class="col-md-3">Cena</div>
            <div class="col-md-4">Status</div>
            <div class="col-md-12 borderr"></div>
            <?php
            foreach ($row3 as $singleRow)
            {
                echo "<div class=\"col-md-2\"><p>".$singleRow['id']."</p></div>";
                echo "<div class=\"col-md-3\"><p>".$singleRow['date']."</p></div>";
                echo "<div class=\"col-md-3\"><p>".$singleRow['price']."</p></div>";
                echo "<div class=\"col-md-4\"><p>".$singleRow['status']."</p></div>";
                echo "<div class='col-md-12 borderr'>.</div>";
            }
            ?>
        </div>
        <script src="../js/funkcje.js"></script>
    </body>
</html>