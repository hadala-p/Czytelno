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
$id = $_POST['ID']; 
$status = $_POST['status']; 
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

        if($connection->query("CALL setOrderStatus('$id', '$status')"))
        {
            header('Location: ../elements/OrderStatusEditor.php');
        }
        else
        {
            throw new Exception($connection->error);
        }

        $connection->close();
    }


 ?>