<?php
session_start();

if (!isset($_SESSION['cart'])) {
    $_SESSION['cart'] = array();
}

function add_to_cart($product_id, $product_name, $product_price) {
    if (!isset($_SESSION['cart'][$product_id])) {
        $_SESSION['cart'][$product_id] = array(
            'name' => $product_name,
            'price' => $product_price,
            'quantity' => 1
        );
    } else {
        $_SESSION['cart'][$product_id]['quantity'] += 1;
    }
}
?>