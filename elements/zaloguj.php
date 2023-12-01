<?php

	session_start();

	if((!isset($_POST['login'])) || (!isset($_POST['password'])))
	{
		header('Location: ../index.php');
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
        $login = $_POST['login'];
        $password = $_POST['password']; 
		$login = htmlentities($login, ENT_QUOTES, "UTF-8");

        if($result = @$connection->query(sprintf("SELECT GetPassword('%s') as hash_password",
		mysqli_real_escape_string($connection,$login))))
		{

			if($result)
			{
				$row = $result->fetch_assoc();

				if(password_verify($password,$row['hash_password']))
				{

					$_SESSION['zalogowany'] = true;
					$_SESSION['nick'] = $_POST['login'];
					unset($_SESSION['blad']);
					$result->free_result();
					header('Location:../index.php');
				}
				else
				{
					$_SESSION['blad']='<span style="color:red">Nieprawidłowy login lub hasło!</span>';
					header('Location:loggin.php');
				}
				
			}
			else
			{
				$_SESSION['blad']='<span style="color:red">Nieprawidłowy loogin lub hasło!</span>';
				header('Location:loggin.php');
			}
		}

        $connection->close();
    }

?>
