<?php

 session_start();
 if(!isset($_SESSION['zalogowany']))
{
  header("Location:loggin.php");
  exit();
} 
require_once"../elements/connect.php";
	mysqli_report(0);

    $connection = @new mysqli($host,$db_user,$db_password,$db_name);

    if($connection -> connect_errno)
    {
        echo "Failed to connect to MySQL: " . $connection -> connect_errno;
		exit();
    }
    else
    {
        if (isset($_SESSION['cart']) && !empty($_SESSION['cart']))
        {
            $cart_data = array();
            foreach ($_SESSION['cart'] as $product_id => $product_info) 
            {
                $cart_data[] = array(
                    'book_id' => $product_id,
                    'quantity' => $product_info['quantity']
                );
            }
            $login = $_SESSION['nick'];
		    $result = $connection->query(sprintf("CALL getUserId('%s')",
            mysqli_real_escape_string($connection, $login)));

            while ($connection->more_results()) {
                $connection->next_result();
            }

            if ($result) {
                $row = $result->fetch_assoc();
                $user_id = $row['id'];
            } else {
                throw new Exception($connection->error);
            }

            $json_data = json_encode($cart_data);

            if($connection->query("CALL AddOrder('$user_id','$json_data')"))
            {
                $_SESSION['blad']="<span style='color:green'><br><br></span>";
                
            }
            else
            {
                throw new Exception($connection->error);
            }

            $connection->close();
            // Wyczyszczenie sesji 'cart'
            unset($_SESSION['cart']);
            header('Location: ../index.php');
        }

        
        
    } 


 ?>