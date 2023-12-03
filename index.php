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
    <link rel="stylesheet" href="css/bootstrap.min.css">
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/style.resposive.css">
    <link rel="stylesheet" href="fontello/css/fontello.css" type="text/css" />
  </head>
  <body>
    <?php 
        include 'elements/headerMainPage.php';
        include 'elements/navigationBar.html';
    ?>

    <div class="row">
    <main class="col-md-8 col-lg-9 col-xl-10">
      <section class="recommended">
        <h1>Polecane</h1>
        <?php include 'elements/slider.html';?>
      </section>
      <section class="index_news">
        <h1>Nowości</h1>
        <div class="row" id="template-body">
                <template id="car-template">
                    <div class="col-md-4">
                        <div class="card">
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
      </section>
      <section class="top_view">
        <h1>BestSellery</h1>
        <div class="row">
        </div>
      </section>
      <section class="index_sale">
        <h1>Wyprzedaż</h1>
        <div class="row">
        </div>
      </section>
      <section class="index_for_kids">
        <h1>Hity dla dzieci</h1>
        <div class="row">
        </div>
      </section>
    </main>
    </div>
    <?php include 'elements/footer.html';?>
    <script src="js/funkcje.js"></script>
    <script src="js/bootstrap.min.js"></script>
    <script src="js/slider.js"></script>
    <script src="https://code.jquery.com/jquery-2.1.1.min.js"></script>
    <script src="database/dataBaseManager.js"></script>
    <script src="js/indexContent.js"></script>
  </body>
</html>