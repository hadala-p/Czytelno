<header>
    <div class="row">
        <div class="logo col-sm-12 col-md-3">
            <div class="bookStoreLogo"><a href="index.php"><img src="img/logo.png" width="70" height="70" alt="bookStoreLogo"></a></div>
            <div class="bookStoreName"><a href="index.php">Czytelno</a></div>
        </div>
        <div class="logoo col-sm-8 col-md-8">
            <div class="search-container">
                <form action="/action_page.php">
                    <input type="text" placeholder="Wpisz książkę.." name="search">
                    <button type="submit">Submit</button>
                </form>
            </div>
        </div>
        <div class="col-sm-1 col-md-1 dropdown">
            <img src="img/basket.png" class="dropbtn" width="70" height="70" alt="basket">
            <div class="dropdown-content" style="left:0;">
                <?php
                    foreach ($_SESSION['cart'] as $product_id => $product) 
                    {
                        echo "<a href=''#'>Tytuł: ".$product['name']."<br> Ilość: ".$product['quantity']."<br>Cena: ".$product['price'] * $product['quantity']."</a>";
                    }
                ?>
                <p id="goToBasket"><a href="elements/basketCard.php"> Przejdź do koszyka</a></p>
            </div>
        </div>
    </div>
</header>