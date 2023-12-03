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
                <div class="col-md-2"><p id="template-id">Data</p></div>
                <div class="col-md-2"><p id="template-id">Cena</p></div>
                <div class="col-md-2"><p id="template-id">Status</p></div>
                <div class="col-md-3"><p id="template-id">Zmień status</p></div>
            </div>
            <div class="row" id="template-body">
                    <template id="car-template">
                        <div class="col-md-12">
                        <form id="template_edit_status" method="post" action="../server/api_orderUpdate.php">
                            <div class="row">
                                <div class="col-md-1">
                                    <label for='ID'></label><br>
                                        <textarea id='template-id' name='ID' rows='1' cols='1' required></textarea><br><br>
                                </div>
                                <div class="col-md-2">
                                    <p id="template-date"> Tutaj ma być data</p>
                                </div>
                                <div class="col-md-2">
                                    <p id="template-price"> Tutaj ma być cena</p>
                                </div>
                                <div class="col-md-2">
                                    <p id="template-status"> Tutaj ma być status</p>
                                </div>
                                <div class="col-md-3">
                                    
                                      <label for="status">Edytuj status:</label>
                                      <select id="status" name="status">
                                        <option value="Oczekujący">Oczekujący</option>
                                        <option value="Realizacja">Realizacja</option>
                                        <option value="Wysyłka">Wysyłka</option>
                                        <option value="Wysłano">Wysłano</option>
                                        <option value="Zakończono">Zakończono</option>
                                        <option value="Anulowano">Anulowano</option>
                                      </select>
                                      <input type="submit">
                                    </form>
                                </div>
                            </div>
                        </div>    
                    </template>
            </div>
        </div>
        <script src="https://code.jquery.com/jquery-2.1.1.min.js"></script>
        <script src="../database/dataBaseManager.js"></script>
        <script src="../js/orderStatusEditorContent.js"></script>
    </body>
</html>