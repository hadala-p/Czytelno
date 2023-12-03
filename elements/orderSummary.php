<?php
    session_start();
    if(!isset($_SESSION['zalogowany']))
    {
      header("Location:loggin.php");
      exit();
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
        include 'connect.php';
        echo "<div class='row'>";
            echo "<div class='col-md-9 orderSummaryBooks'>";
            $mysqli = new mysqli($host, $db_user, $db_password, $db_name);
            if ($mysqli->connect_error) 
            {
                die("Connection failed: " . $mysqli->connect_error);
            }
            $sum = 0;
            foreach ($_SESSION['cart'] as $product_id => $quantity) 
            {
                $query = "CALL getBookInfo(?)";

                // Przygotowanie zapytania
                if ($stmt = $mysqli->prepare($query)) 
                {
                    //Powiązanie parametrów
                    $stmt->bind_param("i", $product_id);

                    $stmt->execute();

                    // Pobranie wyników
                    $result = $stmt->get_result();
                    while ($product = $result->fetch_assoc()) 
                    {

                        echo "<div class='row'>
                                    <div class='col-md-3'>
                                        <img src='../".$product['img']."'>
                                    </div>
                                    <div class='col-md-3 pad'>
                                        <p>".$product['title']."</p>
                                    </div>
                                    <div class='col-md-3 pad'>
                                        <p>".$quantity['quantity']."</p>
                                    </div>
                                    <div class='col-md-3 pad'>
                                        <p>".$quantity['quantity'] * $quantity['price']." zł</p>
                                    </div>
                               </div>";
                        $sum += $quantity['quantity'] * $quantity['price'];
                    }
                    $stmt->close();
                }
            }
            echo "</div>";
            $nick = $_SESSION['nick'];
            $query2 = "SELECT getAddressInfo(?) as 'address'";
            if ($stmt = $mysqli->prepare($query2)) {
                $stmt->bind_param("s", $nick);
                $stmt->execute();
                $result = $stmt->get_result();
                echo "<div class='col-md-3'>";
                echo "<p id='orderAddressHeader'>Adres wysyłki</p>";
                if ($row = $result->fetch_assoc()) {
                    if($row['address'] != NULL){
                        echo "<p class='orderAddress'>".$row['address']."</p>";
                    }
                    else{
                        echo "<p class='orderAddress' style='color: red;'>Nie podano adresu!<br>Udaj się do zakładki profil aby uzupełnić</p>";
                    }
                } 
                
                $stmt->close();
            } 
            else {
                echo "Błąd zapytania";
            }
            echo"</div>";
        echo"</div>";
        echo "<p id='basketSum'>Suma:".$sum." zł</p>";
        echo "<form class='buton_card' action='../server/api_addOrder.php'>
                <input type='submit' name='submit' value='Zamów'>
            </form>";
    ?>
    </body>
</html>