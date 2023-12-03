<?php
session_start();
    require_once '../elements/connect.php';

    $order = $_POST['order'];

    $connection = new mysqli($host, $db_user, $db_password, $db_name);

    if(mysqli_connect_errno()) {
        echo 'error';
        die();
    }

    $sql = "SELECT OrderStatus($order) as Super";
    $result = mysqli_query($connection, $sql);

    if(mysqli_connect_errno()) {
        echo 'error';
        die();
    }

    $booksArray = array();
    $row = mysqli_fetch_assoc($result);

    $_SESSION['blad']="<p style='color:black; font-size: 30px; text-align: center;'><br>".$row['Super']."<br></p>";
    header('Location:../elements/orderStatus.php');

    mysqli_close($connection);
?>