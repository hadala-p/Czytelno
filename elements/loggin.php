<?php
 session_start();
 
 if((isset($_SESSION['zalogowany']))&&($_SESSION['zalogowany']==true))
 {
	 header('Location: profile.php');
     exit();
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
<body id="pix">
<?php include 'header.html';?>
<div class="containerlg">

    <form class="fo" action="zaloguj.php" method="post">
        <div class="imgcontainer">
            <img src="../img/user_avatar.png" alt="Avatar" class="avatar">
        </div>

        <div class="container">
            <label><b>Twój nick:</b></label>
            <input type="text" placeholder="Wpisz nick" name="login" required>

            <label><b>Hasło:</b></label>
            <input type="password" placeholder="Wpisz hasło" name="haslo" required>
                
            <button type="submit">Zaloguj</button>
            <label>
            <input type="checkbox" checked="checked" name="remember"> Zapamiętaj mnie
            </label>
			<?php if(isset($_SESSION['blad']))
      {
        echo $_SESSION['blad'];
      }
				unset($_SESSION['blad']);
			?>
        </div>

        <div class="container" style="background-color:#f1f1f1">
        <button class="cancelbtn" onclick="window.location.href='../index.php'">Cancel</button>
            <span class="psw">Nie posiadasz konta?  <a href="register.php">Zarejestruj się</a></span>
        </div>
    </form>
</div>
</body>
</html>
