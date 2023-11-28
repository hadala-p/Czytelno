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

        if($result = @$connection->query(sprintf("SELECT GetPassword('%s') as hash_password",$user)))
		{
			$wiersz = $result->fetch_assoc();
            $password = $_POST['old_password']; 
            $password1 = $_POST['new_password_1']; 
            $password2 = $_POST['new_password_2']; 
            $all_OK=true;
		    if(password_verify($password,$wiersz['hash_password']))
			{
                
                 // sprawdzanie długość hasła jest odpowiednia
                if(strlen($password1)<8||(strlen($password1)>20))
                {
                    $all_OK=false;
                    $_SESSION['blad']='<span style="color:red"><br>Nowe hasło powinno zawierać od 8 do 20znaków!<br></span>';
                    header('Location:profile.php');
                }
                // sprawdzanie długości czy hasło są identyczne
                if($password1!=$password2)
                {
                    $all_OK=false;
                    $_SESSION['blad']='<span style="color:red"><br>Nowe hasła się różnią!<br></span>';
                    header('Location:profile.php');
                }
                // haszowanie haseł
                $password_hash=password_hash($password1,PASSWORD_DEFAULT);
                $result->free_result();

                if($all_OK==true)
                {
                    if($connection->query("CALL SetPassword('$user', '$password_hash')"))
                    {
                        $_SESSION['blad']='<span style="color:green"><br>Zmieniono hasło<br></span>';
                        header('Location: profile.php');
                    }
                    else
                    {
                        throw new Exception($connection->error);
                    }
                }
            }
            else
            {
                $_SESSION['blad']='<span style="color:red"><br>Nie prawidłowe stare hasło!<br></span>';
                header('Location:profile.php');
            }
				
		}
        else
        {
            $str =  strval($connection->error);
            echo "Failed to connect to MySQL: $str";
        }

        $connection->close();
    }


 ?>