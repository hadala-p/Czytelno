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
require_once"../elements/connect.php";
$mysqli = new mysqli($host, $db_user, $db_password, $db_name);

// Sprawdzanie po³¹czenia
if ($mysqli->connect_error) {
    die("B³¹d po³¹czenia: " . $mysqli->connect_error);
}

	function deleteUser($userId) {
    global $mysqli;

    // Przygotowanie zapytania SQL
    $stmt = $mysqli->prepare("CALL deleteUser(?)");
    if ($stmt === false) {
        // Obs³uga b³êdów
        die("B³¹d przygotowania zapytania: " . $mysqli->error);
    }

    // Powi¹zanie parametrów
    $stmt->bind_param("i", $userId);

    // Wykonanie zapytania
    if ($stmt->execute()) {
        echo "U¿ytkownik usuniêty.";
    } else {
        echo "B³¹d podczas usuwania u¿ytkownika: " . $stmt->error;
    }

    // Zamkniêcie zapytania
    $stmt->close();
}

// Pobranie ID u¿ytkownika z ¿¹dania
if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['userId'])) {
    deleteUser($_POST['userId']);
} else {
    echo "Niepoprawne ¿¹danie";
}
?>