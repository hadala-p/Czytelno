<?php session_start();?>
<!doctype html>
<html lang="pl">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>BookStore</title>
    <link rel="stylesheet" href="css/bootstrap.min.css">
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/style.resposive.css">
    <link rel="stylesheet" href="fontello/css/fontello.css" type="text/css" />
  </head>
  <body>
    <?php 
        include 'elements/headerMainPage.html';
        include 'elements/navigationBar.html';
    ?>

    <div class="row">
    <main class="col-md-8 col-lg-9 col-xl-10">
      <section class="recommended">
        <h1>Polecane</h1>
        <div class="img-slider">
          <div class="slide active">
            <a href="#"><img src="img/fantasy.png" alt="Fantastyka"></a>
            <div class="info">
              <p>Fantastyka</p>
            </div>
          </div>
          <div class="slide">
            <img src="img/business.png" alt="Biznes">
              <div class="info">
                <p>Biznes</p>
              </div>
          </div>
          <div class="slide">
            <a href="#"><img src="img/travel&turism.png" alt="Podróże i Turystyka"></a>
            <div class="info">
              <p>Podróże i Turystyka</p>
            </div>
          </div>
          <div class="slide">
            <a href="#"><img src="img/languageLearning.png" alt="Nauka Języków"></a>
            <div class="info">
              <p>Nauka Języków</p>
            </div>
          </div>
          <div class="slide">
            <a href="#"><img src="img/ebooks.png" alt="E-Booki"></a>
            <div class="info">
              <p>E-Booki</p>
            </div>
          </div>
          <div class="navigation">
            <div class="btn active"></div>
            <div class="btn"></div>
            <div class="btn"></div>
            <div class="btn"></div>
            <div class="btn"></div>
          </div>
        </div>
      </section>
      <section class="index_news">
        <h1>Nowości</h1>
        <div class="row">

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
    <script src="js/zegar.js"></script>
    <script src="js/funkcje.js"></script>
    <script src="js/bootstrap.min.js"></script>
    <script src="js/slider.js"></script>
  </body>
</html>