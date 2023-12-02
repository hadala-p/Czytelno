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
        <?php include 'header.html';
        include 'connect.php';
        $mysqli = new mysqli($host, $db_user, $db_password, $db_name);
        if ($mysqli->connect_error) 
        {
            die("Connection failed: " . $mysqli->connect_error);
        }
        if (isset($_SESSION['cart']) && !empty($_SESSION['cart']))
        {
            $sum = 0;
            foreach ($_SESSION['cart'] as $product_id => $quantity) 
            {
                $query = "CALL getBookInfo(?)";

                // Przygotowanie zapytania
                if ($stmt = $mysqli->prepare($query)) 
                {
                    // Prawidłowe powiązanie parametrów
                    $stmt->bind_param("i", $product_id);

                    $stmt->execute();

                    // Pobranie wyników
                    $result = $stmt->get_result();
                    while ($product = $result->fetch_assoc()) 
                    {

                        echo "<div class='basket_books'>
                                  <div class='row'>
                                    <div class='col-md-3'>
                                        <img src='../".$product['img']."'>
                                    </div>
                                    <div class='col-md-2 center'>
                                        <p>".$product['title']."</p>
                                    </div>
                                    <div class='col-md-2 center'>
                                        <p>".$quantity['quantity']."</p>
                                    </div>
                                    <div class='col-md-2 center'>
                                        <p>".$quantity['quantity'] * $quantity['price']." zł</p>
                                    </div>
                                    <div class='col-md-2 center'>
                                        <button class='remove-button' data-book-id='".$product['id']."'>X</button>
                                    </div>
                                  </div>
                              </div>";
                        $sum += $quantity['quantity'] * $quantity['price'];
                    }
                    $stmt->close();
                }
            }
            echo "<p id='basketSum'>Suma:".$sum." zł</p>";
        }
        else
        {
            echo "<p id='emptyBasket'>Koszyk jest pusty!</p>";
        }
        ?>
        <script src="../js/removeBookFromCart.js"></script>
    </body>
</html>