<?php

 session_start();
 if(!isset($_SESSION['zalogowany']))
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
		exit();
    }
    else
    {
        $user = $_SESSION['nick'];
        $street = $_POST['street'];
        $number = $_POST['number'];
        $postcode = $_POST['postcode'];
        $city = $_POST['city'];

        if($result = @$connection->query(sprintf("CALL setAddress('%s', '%s', '%s', '%s', '%s')",$user, $street, $number, $postcode, $city)))
		{
            $_SESSION['blad']='<span style="color:green"><br>Zmieniono has³o<br></span>';
            header('Location: profile.php');

		}
        else
        {
            $str =  strval($connection->error);
            echo "Failed to connect to MySQL: $str";
        }

        $connection->close();
    }


 ?>