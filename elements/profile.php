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
        <title>Muszyna</title>
        <link rel="stylesheet" href="../css/bootstrap.min.css">
        <link rel="stylesheet" href="../css/style.css">
        <link rel="stylesheet" href="../css/style.resposive.css">
    </head>
    <body>
        <?php include 'header.html';?>
        <div class="profile">
            <?php echo "<p style='text-align:center; font-size: 40px;'>Witaj ".$_SESSION['nick']."!</p>";?>
            <div class="imgcontainer">
                <img src="../img/user_avatar.png" alt="Avatar" class="avatar">
            </div>
            <button class="s-psw" onclick="s_passwd()">Zmień hasło</button>
            <div id="change-passwd">
            <form method="post" action="resetPassword.php">
                <input type="password" placeholder="Wpisz obecne hasło" name="old_password" id="old_password" required>
                <input type="password" placeholder="Wpisz nowe hasło" name="new_password_1" id="new_password_1" required>
                <input type="password" placeholder="Powtórz nowe hasło" name="new_password_2" id="new_password_2" required>
                <button type="submit">Wyślij nowe hasło</button>
            </form>
            </div>
            <?php if(isset($_SESSION['blad']))
              {
                echo $_SESSION['blad'];
              }
                unset($_SESSION['blad']);
	        ?>
            <a href="logout.php"><button type="button" class="logoutbtn">Wyloguj się</button></a>
        </div>
        <script src="../js/funkcje.js"></script>
    </body>
</html>