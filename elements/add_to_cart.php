<?php
include 'cart_functions.php'; // Importuj funkcje koszyka z pierwszego kroku

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $product_id = $_POST['product_id'];
    $product_name = $_POST['product_name'];
    $product_price = $_POST['product_price'];

    add_to_cart($product_id, $product_name, $product_price);
}
?>
