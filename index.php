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
  <header>
  <div class="row">
    <div class="logo col-sm-12 col-md-6">
      <div class="bookStoreLogo"><a href="index.php"><img src="img/book_logo.png" width="50" height="50" alt="bookStoreLogo"></a></div>
      <div class="bookStoreName"><a href="index.php">BookStore</a></div>  
    </div>
    <div class="logoo col-sm-12 col-md-6">
      <div class="cytat col-sm-9">
        <div id="quote1">Czytaj...</div>
        <div id="quote2">Odkrywaj...</div>
        <div id="quote3">Analizuj...</div>
      </div>  
    </div>
  </div>
</header>
<nav class="topnav" id="myTopnav">
  <ul>
    <li class="btnn"><a href="javascript:void(0);" onclick="myFunction2()">Kategorie<i class="icon-down-open iconn"></i></a>
      <ul id="btn-content">
        <li><a href="#">Biografie</a></li>
        <li><a href="#">Biznes</a></li>
        <li><a href="#">Fantastyka</a></li>
        <li><a href="#">Historia</a></li>
        <li><a href="#">Komiksy</a></li>
      </ul>
    </li>
    <li><a href="#">Nowości</a></li>
    <li><a href="#">Promocje</a></li>

    <li><a href="#">Outlet</a></li>
    <li class="log-btn"><a href="#">zaloguj się</a></li>
  </ul>
<a href="javascript:void(0);" class="icon" onclick="myFunction()">
<i class="icon-menu"></i>
</a>
</nav>
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
    <footer>
        <div class="info">Social Links</div>
            <ul>
                <li class="social fb"><a href="https://www.facebook.com"><i class="icon-facebook"></i></a></li>
                <li class="social gplus"><a href="https://plus.google.com"><i class="icon-gplus"></i></a></li>
                <li class="social tw"><a href="https://twitter.com"><i class="icon-twitter"></i></a></li>
                <li class="social yt"><a href="https://youtube.com"><i class="icon-youtube"></i></a></li>
            </ul>
        <div class="info">Copyright @2023 | Designed by  Grosicki Bartosz & Hadała Piotr</div>
    </footer>
    <script src="js/zegar.js"></script>
    <script src="js/funkcje.js"></script>
    <script src="js/bootstrap.min.js"></script>
    <script src="js/slider.js"></script>
  </body>
</html>