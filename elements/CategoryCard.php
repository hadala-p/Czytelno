<?php session_start();
if (!isset($_SESSION['cart'])) {
    $_SESSION['cart'] = array();
}?>
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
        <?php include 'headerBookCard.php';?>
              <section>
              <h1 id="category-title">Kategoria</h1>
            <div class="row" id="template-body">
                <template id="car-template">
                    <div class="col-md-4">
                        <div class="card">
                            <div>
                            </div>
                            <div class="card-image">
                                <img src="../img/books/Kwazar.png" class="responsive-img" id="template-preview-image" alt="Książka">
                            </div>
                            <div class="card-content grey darken-4" >
                                <p class="white-text height1" id="template-description">Tutaj ma być opis samochodu</p>
                            </div>
                            <div class="card-action orange darken-3" style="text-align: center !important;">
                                <a href="elements/bookCard.php" id="reservation-button" style="text-decoration: none;">Szczegóły</a>
                            </div>
                        </div>
                    </div>    
                </template>
            </div>
        <?php include 'footer.html';?>
        <script src="https://code.jquery.com/jquery-2.1.1.min.js"></script>
        <script src="../database/dataBaseManager.js"></script>
        <script src="../js/categoryCardContent.js"></script>
    </body>
</html>