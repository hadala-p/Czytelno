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
        <div class="orderStatusContainer">
            <div class="row">
                <div class="col-md-1"><p id="template-id">Id</p></div>
                <div class="col-md-2"><p id="template-id">Nick</p></div>
                <div class="col-md-2"><p id="template-id">Imie</p></div>
                <div class="col-md-2"><p id="template-id">Nazwisko</p></div>
                <div class="col-md-2"><p id="template-id">Email</p></div>
            </div>
            <div class="row" id="template-body">
                    <template id="car-template">
                        <div class="col-md-12">
                            <div class="row">
                                <div class="col-md-1">
                                    <p id="template-id"> Tutaj ma być id</p>
                                </div>
                                <div class="col-md-2">
                                    <p id="template-nick"> Tutaj ma być nick</p>
                                </div>
                                <div class="col-md-2">
                                    <p id="template-imie"> Tutaj ma być imie</p>
                                </div>
                                <div class="col-md-2">
                                    <p id="template-nazwisko"> Tutaj ma być nazwisko</p>
                                </div>
                                <div class="col-md-2">
                                    <p id="template-email"> Tutaj ma być email</p>
                                </div>
                                <div class="col-md-3">
                                    <button class="delete-btn" data-id="id_placeholder">Usuń</button>
                                </div>
                            </div>
                        </div>    
                    </template>
            </div>
        </div>
        <script src="https://code.jquery.com/jquery-2.1.1.min.js"></script>
        <script src="../database/dataBaseManager.js"></script>
        <script src="../js/usersEditorContent.js"></script>
    </body>
</html>