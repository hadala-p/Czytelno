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

        if($rezultat = @$connection->query(sprintf("SELECT * FROM users WHERE nick='%s'",$user)))
		{
			$wiersz = $rezultat->fetch_assoc();
            $password = $_POST['old_password']; 
            $password1 = $_POST['new_password_1']; 
            $password2 = $_POST['new_password_2']; 
            $wszystko_OK=true;
		    if(password_verify($password,$wiersz['password']))
			{
                
                 // sprawdzanie długość hasła jest odpowiednia
                if(strlen($password1)<8||(strlen($password1)>20))
                {
                    $wszystko_OK=false;
                    $_SESSION['blad']='<span style="color:red"><br>Hasło powinno zawierać od 8 do 20znaków!<br></span>';
                    header('Location:profile.php');
                }
                // sprawdzanie długości czy hasło są identyczne
                if($password1!=$password2)
                {
                    $wszystko_OK=false;
                    $_SESSION['blad']='<span style="color:red"><br>Hasła się różnią!<br></span>';
                    header('Location:profile.php');
                }
                // haszowanie haseł
                $password_hash=password_hash($password1,PASSWORD_DEFAULT);
                $rezultat->free_result();

                if($wszystko_OK==true)
                {
                    if($connection->query("UPDATE users SET password = '$password_hash' WHERE nick='$user'"))
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