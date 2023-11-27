<?php
    session_start();
 
    if(isset($_POST['email']))
    {
        $wszystko_OK=true;
        //  checking nickname length
        $nick=$_POST['nick'];
        if(strlen($nick)<3||(strlen($nick)>20))
        {
            $wszystko_OK=false;
            $_SESSION['e_nick']="Nick musi posiadać od 3 do 20 znaków!";
        }
        // checking the letters of the given nickname
        if(ctype_alnum($nick)==false)
        {
            $wszystko_OK=false;
            $_SESSION['e_nick']="Nick może składać się tylko z liter i cyfr (bez polskich znaków)";
        }
        // checking the correctness of the entered email through the filter
        $email= $_POST['email'];
        $emailB=filter_var($email,FILTER_SANITIZE_EMAIL);

        if((filter_var($emailB,FILTER_VALIDATE_EMAIL)==false)||($emailB!=$email))
        {
            $wszystko_OK=false;
            $_SESSION['e_email']="Podaj poprawny adres e-mail!";
        }

        $haslo1=$_POST['psw1'];
        $haslo2=$_POST['psw2'];
        // checking the password length is correct
        if(strlen($haslo1)<8||(strlen($haslo1)>20))
        {
            $wszystko_OK=false;
            $_SESSION['e_haslo']="Haslo musi posiadać od 8 do 20 znaków";
        }
        // checking if passwords are identical
        if($haslo1!=$haslo2)
        {
            $wszystko_OK=false;
            $_SESSION['e_haslo']="Podane hasła nie są identyczne!";
        }
        // password hashing
        $haslo_hash=password_hash($haslo1,PASSWORD_DEFAULT);

        // acceptance of the rules

        if(!isset($_POST['regulamin']))
        {
            $wszystko_OK=false;
            $_SESSION['e_regulamin']="Niezaakceptowano regulaminu!";
        }

        require_once "connect.php";
        try
        {
            $polaczenie = new mysqli($host,$db_user,$db_password,$db_name);
            if($polaczenie -> connect_errno)
            {
                throw new Exception(mysqli_connect_errno());
            }
            else
            {
                // checking if the email exists
                $result=$polaczenie->query("SELECT DoesEmailExist('$email') As result");
                $row = $result->fetch_assoc();
                $doesEmailExist = $row['result'];
                if($doesEmailExist)
                {
                    $wszystko_OK=false;
                    $_SESSION['e_email']="Istnieje juz konto zarejestrowane na podany email! "; 
                }
                // checking if the nickname exists
                $result=$polaczenie->query("SELECT DoesUserExist('$nick') As result");
                $row = $result->fetch_assoc();
                $doesNickExist = $row['result'];

                if($doesNickExist)
                {
                    $wszystko_OK=false;
                    $_SESSION['e_nick']="Istnieje juz użytkownik o takiej nazwie!"; 
                }
                if($wszystko_OK==true)
                {
                    $firstName=$_POST['firstName'];
                    $lastName=$_POST['lastName'];
                    if($polaczenie->query("CALL RegisterUser('$nick','$firstName','$lastName', '$email', '$haslo_hash')"))
                    {
                        header('Location: loggin.php');
                    }
                    else
                    {
                        throw new Exception($polaczenie->error);
                    }
                }
                $polaczenie->close();
            }
        }
        catch(Exception $e)
        {
            echo '<span style="color:red;">Błąd servera! przepraszamy</span>';
            echo '<br />Informacja developerska:'.$e;
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

        <form class="fo" method="post">
          <div class="container">
            <h1>Rejestracja</h1>
            <p>Wypełnij formularz aby utworzyć konto</p>
            <hr>

            <label for="firstName"><b>Imię</b></label>
            <input type="text" placeholder="Wpisz imię" name="firstName" id="firstName" required>
            <label for="lastName"><b>Nazwisko</b></label>
            <input type="text" placeholder="Wpisz nazwisko" name="lastName" id="lastName" required>

            <label for="nick"><b>Nick</b></label>
            <input type="text" placeholder="Wpisz nick" name="nick" id="nick" required>
            <?php
                if(isset($_SESSION['e_nick']))
                {
                    echo '<div class="error">'.$_SESSION['e_nick'].'</div>';
                    unset($_SESSION['e_nick']);
                }
            ?>

            <label for="email"><b>E-mail</b></label>
            <input type="text" placeholder="Wpisz e-mail" name="email" id="email" required>
            <?php
                if(isset($_SESSION['e_email']))
                {
                    echo '<div class="error">'.$_SESSION['e_email'].'</div>';
                    unset($_SESSION['e_email']);
                }
            ?>

            <label for="psw1"><b>Hasło</b></label>
            <input type="password" placeholder="Wpisz hasło" name="psw1" id="psw1" required>
            <?php
                if(isset($_SESSION['e_haslo']))
                {
                    echo '<div class="error">'.$_SESSION['e_haslo'].'</div>';
                    unset($_SESSION['e_haslo']);
                }
            ?>

            <label for="psw2"><b>Powtórz hasło</b></label>
            <input type="password" placeholder="Powtórz hasło" name="psw2" id="psw2" required>
            <hr>

            <label><input type="checkbox" name="regulamin"/> Akceptuje regulamin</label>
            <?php
                if(isset($_SESSION['e_regulamin']))
                {
                    echo '<div class="error">'.$_SESSION['e_regulamin'].'</div>';
                    unset($_SESSION['e_regulamin']);
                }
            ?>
            <button type="submit" class="registerbtn">Register</button>
          </div>

          <div class="container signin">
            <p>Posiadasz już konto? <a href="loggin.php">Zaloguj się</a></p>
          </div>
        </form> 
    </body>
</html>
