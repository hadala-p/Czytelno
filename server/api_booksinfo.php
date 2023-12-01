<?php
    require_once '../elements/connect.php';

    $connection = new mysqli($host, $db_user, $db_password, $db_name);

    if(mysqli_connect_errno()) {
        echo 'error';
        die();
    }

    $sql = 'CALL getAllBooks';
    $result = mysqli_query($connection, $sql);

    if(mysqli_connect_errno()) {
        echo 'error';
        die();
    }

    $booksArray = array();
    while($row = mysqli_fetch_assoc($result)) {
        $booksArray[] = $row;
    }

    mysqli_close($connection);
    echo json_encode($booksArray);
?>