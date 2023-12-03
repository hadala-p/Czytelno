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
        $id = $_POST['ID']; 
        $category = $_POST['category']; 
        $title = $_POST['title']; 
        $author = $_POST['author']; 
        $publisher = $_POST['publisher']; 
        $year = $_POST['year']; 
        $pages = $_POST['pages']; 
        $price = $_POST['price']; 
        $description = $_POST['description']; 
        $img = $_POST['img']; 

        if($connection->query("CALL EditBook('$id', '$category', '$title', '$author', '$publisher', '$year', '$pages', '$price', '$description', '$img')"))
        {
            $_SESSION['blad']='<span style="color:green; font-size: 30px;"><br>Edytowano książkę pomyślnie<br></span>';
            header('Location: ../elements/adminPanel.php');
        }
        else
        {
            throw new Exception($connection->error);
        }

        $connection->close();
    }


 ?>