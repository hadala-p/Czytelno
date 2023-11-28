-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Czas generowania: 28 Lis 2023, 13:37
-- Wersja serwera: 10.4.27-MariaDB
-- Wersja PHP: 8.2.0

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Baza danych: `bookstore`
--

DELIMITER $$
--
-- Procedury
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `CheckSurnameOrders` (IN `last_name` VARCHAR(30))   BEGIN
  SELECT orders.id AS order_id, orders.user_id, orders.date, orders.price, orders.status
  FROM orders
  INNER JOIN users ON orders.user_id = users.id
  WHERE users.lastName = last_name;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `LoginUser` (IN `p_email` VARCHAR(50) COLLATE utf8mb4_general_ci, IN `p_password` VARCHAR(255) COLLATE utf8mb4_general_ci, OUT `login_success` BOOLEAN)   BEGIN
  DECLARE user_count INT;

  -- Sprawdzamy, czy istnieje użytkownik o podanym adresie e-mail i haśle
  SELECT COUNT(*) INTO user_count
  FROM users
  WHERE email = p_email COLLATE utf8mb4_general_ci
    AND password = p_password COLLATE utf8mb4_general_ci;

  -- Jeśli użytkownik istnieje, ustawiamy login_success na TRUE
  IF user_count > 0 THEN
    SET login_success = TRUE;
  ELSE
    -- Jeśli użytkownik nie istnieje lub hasło nie pasuje, ustawiamy login_success na FALSE
    SET login_success = FALSE;
  END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `RegisterUser` (IN `p_nick` VARCHAR(50), IN `p_firstName` VARCHAR(30), IN `p_lastName` VARCHAR(30), IN `p_email` VARCHAR(50), IN `p_password` VARCHAR(255))   BEGIN
    INSERT INTO users (nick, firstName, lastName, email, password)
    VALUES (p_nick, p_firstName, p_lastName, p_email, p_password);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SetPassword` (IN `userNick` VARCHAR(255), IN `newPassword` VARCHAR(255))   BEGIN
    UPDATE users SET password = newPassword WHERE nick = userNick;
END$$

--
-- Funkcje
--
CREATE DEFINER=`root`@`localhost` FUNCTION `DoesEmailExist` (`user_email` VARCHAR(50) CHARSET utf8) RETURNS TINYINT(1)  BEGIN
  DECLARE user_count INT;

  SELECT COUNT(*) INTO user_count
  FROM users
  WHERE email = user_email;

  IF user_count > 0 THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `DoesUserExist` (`user_nick` VARCHAR(50)) RETURNS TINYINT(1)  BEGIN
  DECLARE user_count INT;

  SELECT COUNT(*) INTO user_count
  FROM users
  WHERE nick = user_nick;

  IF user_count > 0 THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `GetPassword` (`userNick` VARCHAR(255)) RETURNS VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_polish_ci  BEGIN
    DECLARE userPassword VARCHAR(255);
    SELECT password INTO userPassword FROM users WHERE nick = userNick;
    RETURN userPassword;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `OrderStatus` (`order_id` INT) RETURNS VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN
  DECLARE order_status VARCHAR(255);

  SELECT status INTO order_status
  FROM orders
  WHERE id = order_id;

  IF order_status IS NOT NULL THEN
    RETURN CONCAT('Status zamówienia ', order_status);
  ELSE
    RETURN 'Zamówienie o podanym identyfikatorze nie istnieje.';
  END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `adresses`
--

CREATE TABLE `adresses` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `street` varchar(30) NOT NULL,
  `postcode` varchar(10) NOT NULL,
  `city` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_polish_ci;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `books`
--

CREATE TABLE `books` (
  `id` int(11) NOT NULL,
  `title` varchar(50) NOT NULL,
  `author` varchar(50) NOT NULL,
  `publisher` varchar(50) NOT NULL,
  `year` year(4) NOT NULL,
  `pages` int(11) NOT NULL,
  `price` double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_polish_ci;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `orders`
--

CREATE TABLE `orders` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `date` date NOT NULL,
  `price` double NOT NULL,
  `status` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_polish_ci;

--
-- Zrzut danych tabeli `orders`
--

INSERT INTO `orders` (`id`, `user_id`, `date`, `price`, `status`) VALUES
(1, 1, '2023-11-27', 50, 'realizacja');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `order_items`
--

CREATE TABLE `order_items` (
  `id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `book_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_polish_ci;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `nick` varchar(50) NOT NULL,
  `firstName` varchar(30) NOT NULL,
  `lastName` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `email` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_polish_ci;

--
-- Zrzut danych tabeli `users`
--

INSERT INTO `users` (`id`, `nick`, `firstName`, `lastName`, `email`, `password`) VALUES
(0, 'Vadim0143', 'Piotr', 'Hadała', 'example@op.pl', '$2y$10$cHVhMIV5lVf.DEIHGgu7pOx/9BfvwgHod60gPt3O6Q0QIS9j/99n6');

--
-- Indeksy dla zrzutów tabel
--

--
-- Indeksy dla tabeli `adresses`
--
ALTER TABLE `adresses`
  ADD PRIMARY KEY (`id`);

--
-- Indeksy dla tabeli `books`
--
ALTER TABLE `books`
  ADD PRIMARY KEY (`id`);

--
-- Indeksy dla tabeli `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`);

--
-- Indeksy dla tabeli `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_order_items_books` (`book_id`),
  ADD KEY `idx_order_items_order_id` (`order_id`);

--
-- AUTO_INCREMENT dla zrzuconych tabel
--

--
-- AUTO_INCREMENT dla tabeli `adresses`
--
ALTER TABLE `adresses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `books`
--
ALTER TABLE `books`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Ograniczenia dla zrzutów tabel
--

--
-- Ograniczenia dla tabeli `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `fk_order_items_books` FOREIGN KEY (`book_id`) REFERENCES `books` (`id`),
  ADD CONSTRAINT `fk_order_items_orders` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
