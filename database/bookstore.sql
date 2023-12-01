-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Czas generowania: 01 Gru 2023, 14:49
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddBook` (IN `p_category` VARCHAR(50), IN `p_title` VARCHAR(50), IN `p_author` VARCHAR(50), IN `p_publisher` VARCHAR(50), IN `p_year` YEAR(4), IN `p_pages` INT, IN `p_price` DOUBLE, IN `p_description` TEXT, IN `p_img` VARCHAR(255))   BEGIN
    INSERT INTO books (category, title, author, publisher, year, pages, price, description, img)
    VALUES (p_category, p_title, p_author, p_publisher, p_year, p_pages, p_price, p_description, p_img);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AddOrder` (IN `p_user_id` INT(11), IN `p_order_items` JSON)   BEGIN
    -- Dodaj zamówienie
    INSERT INTO orders (user_id, date, price, status)
    VALUES (p_user_id, CURRENT_TIMESTAMP, 0, 'Oczekujący');

    -- Pobierz id dodanego zamówienia
    SET @order_id = LAST_INSERT_ID();

    -- Iteruj przez pozycje zamówienia w formacie JSON
    SET @json_len = JSON_LENGTH(p_order_items);
    SET @i = 0;

    WHILE @i < @json_len DO
        -- Pobierz pojedynczą pozycję zamówienia z JSON
        SET @item = JSON_UNQUOTE(JSON_EXTRACT(p_order_items, CONCAT('$[', @i, ']')));
        SET @book_id = JSON_UNQUOTE(JSON_EXTRACT(@item, '$.book_id'));
        SET @quantity = JSON_UNQUOTE(JSON_EXTRACT(@item, '$.quantity'));

        -- Dodaj pozycję zamówienia (książkę)
        INSERT INTO order_items (order_id, book_id, quantity, price, total_price)
        SELECT @order_id, @book_id, @quantity, price, @quantity * price FROM books WHERE id = @book_id;

        -- Zaktualizuj łączną cenę zamówienia
        UPDATE orders SET price = price + (@quantity * (SELECT price FROM books WHERE id = @book_id)) WHERE id = @order_id;

        SET @i = @i + 1;
    END WHILE;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CheckSurnameOrders` (IN `last_name` VARCHAR(30))   BEGIN
  SELECT orders.id AS order_id, orders.user_id, orders.date, orders.price, orders.status
  FROM orders
  INNER JOIN users ON orders.user_id = users.id
  WHERE users.lastName = last_name;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getAddress` (IN `userNick` VARCHAR(255))   BEGIN
    DECLARE addressDetails VARCHAR(1024);
    SELECT a.street, a.postcode, a.number, a.city
    FROM adresses a
    JOIN users u ON u.id = a.user_id
    WHERE u.nick = userNick;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getAllBooks` ()   SELECT * From books$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetBooksByCategory` (IN `p_category` VARCHAR(50))   BEGIN
    SELECT * FROM books WHERE category = p_category;
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `setAddress` (IN `userNick` VARCHAR(255), IN `newStreet` VARCHAR(255), IN `newNumber` VARCHAR(255), IN `newPostalCode` VARCHAR(255), IN `newCity` VARCHAR(255))   BEGIN
    DECLARE userId INT DEFAULT 0;
    SELECT id INTO userId FROM users WHERE nick = userNick LIMIT 1;

    IF userId > 0 THEN
        -- Sprawdzenie, czy istnieje wpis w tabeli addresses
        IF EXISTS (SELECT 1 FROM adresses WHERE user_id = userId) THEN
            -- Aktualizacja istniejącego adresu
            UPDATE adresses SET street = newStreet, number = newNumber, postcode = newPostalCode, city = newCity WHERE user_id = userId;
        ELSE
            -- Dodanie nowego adresu
            INSERT INTO adresses (user_id, street, number, postcode, city) VALUES (userId, newStreet, newNumber, newPostalCode, newCity);
        END IF;
    END IF;
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

CREATE DEFINER=`root`@`localhost` FUNCTION `getAddressInfo` (`userNick` VARCHAR(255)) RETURNS VARCHAR(1024) CHARSET utf8mb4 COLLATE utf8mb4_polish_ci  BEGIN
    DECLARE addressDetails VARCHAR(1024);
    SELECT CONCAT(a.street, ', ', a.number, ', ', a.postcode, ', ', a.city) INTO addressDetails
    FROM adresses a
    JOIN users u ON u.id = a.user_id
    WHERE u.nick = userNick;
    RETURN addressDetails;
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
  `number` varchar(50) NOT NULL,
  `postcode` varchar(10) NOT NULL,
  `city` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_polish_ci;

--
-- Zrzut danych tabeli `adresses`
--

INSERT INTO `adresses` (`id`, `user_id`, `street`, `number`, `postcode`, `city`) VALUES
(6, 1, 'Kluczborska', '16', '21-371', 'Warszawa');

--
-- Wyzwalacze `adresses`
--
DELIMITER $$
CREATE TRIGGER `archiwizuj` AFTER UPDATE ON `adresses` FOR EACH ROW INSERT INTO old_addresses VALUES(old.id ,old.user_id, old.street, old.number, old.postcode, old.city)
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `books`
--

CREATE TABLE `books` (
  `id` int(11) NOT NULL,
  `category` varchar(50) NOT NULL,
  `title` varchar(50) NOT NULL,
  `author` varchar(50) NOT NULL,
  `publisher` varchar(50) NOT NULL,
  `year` year(4) NOT NULL,
  `pages` int(11) NOT NULL,
  `price` double NOT NULL,
  `description` text NOT NULL,
  `img` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_polish_ci;

--
-- Zrzut danych tabeli `books`
--

INSERT INTO `books` (`id`, `category`, `title`, `author`, `publisher`, `year`, `pages`, `price`, `description`, `img`) VALUES
(1, 'Science Fiction', 'Kwazar: Sekret Gwiazdy Śmierci', 'Olivia Lark', 'Kosmiczne Opowieści', 2024, 384, 39.99, 'W odległej przyszłości, ludzkość osiągnęła niebywałe osiągnięcia w dziedzinie kosmicznych podróży i eksploracji. Jednakże, gdy tajemnicze wydarzenia zaczynają zachodzić w pobliżu najjaśniejszego kwazara w galaktyce, oznacza to początek najbardziej intrygującej przygody w historii ludzkości.\r\n\r\nKapitan Alina Vega, nieustraszona podróżniczka kosmiczna, zostaje wysłana na misję badawczą, której celem jest rozwikłanie zagadki Kwazara, który emituje sygnały sugerujące istnienie zaawansowanej cywilizacji. Razem z jej ekipą, w skład której wchodzi ekscentryczny naukowiec Dr. Samuel Orion i inteligentny android o imieniu AURA, Alina musi stawić czoła nie tylko zagadkom wszechświata, ale także własnym demonom przeszłości.\r\n\r\n\"Kwazar: Sekret Gwiazdy Śmierci\" to hipnotyzująca opowieść o odwadze, tajemnicach kosmosu i niezłomnej ludzkiej determinacji. Czy Alina Vega zdoła odkryć prawdę kryjącą się za Kwazarem i rozwiązać zagadkę Gwiazdy Śmierci, zanim stanie się ona zagrożeniem dla całej galaktyki? Czy ludzkość jest gotowa na to, co naprawdę czai się w otchłaniach kosmosu?\r\n\r\nTa książka zabierze czytelników w ekscytującą podróż przez odległe zakątki kosmosu, serwując im przy okazji niesamowite przygody i refleksje nad naturą ludzkiej egzystencji. Olivia Lark zapewnia czytelnikom niezapomnianą mieszankę nauki, tajemnicy i emocji, która sprawi, że nie będziecie mogli się oderwać od tej fascynującej opowieści.', 'img/books/Kwazar.png'),
(2, 'Fantasy', 'Tajemnica Królestwa Wiatrów', 'Marcus Zephyr', 'Zaklęte Strony', 2025, 432, 49.99, 'W magicznym świecie pełnym zaklęć i stworzeń fantastycznych, istnieje jedno legendarne Królestwo Wiatrów, które jest znane ze swojego tajemniczego położenia i niezwykłych mocy. Od wieków, Królestwo to było nieosiągalne dla ludzi, otoczone nieprzeniknioną mgłą i chronione przed intruzami. Jednakże, kiedy złowrogi mrok zaczyna się rozprzestrzeniać na kontynencie, wiedźma o imieniu Elara odkrywa, że jedyną nadzieją na powstrzymanie katastrofy jest dotarcie do Królestwa Wiatrów i rozszyfrowanie jego tajemnic.\r\n\r\nElara wyrusza w niebezpieczną podróż, towarzysząc jej dziwny towarzysz o imieniu Zephyr, który zdaje się mieć kontrolę nad wiatrem. Razem muszą stawić czoła licznym wyzwaniom, walkom z mrocznymi stworzeniami i rozwiązując zagadki magicznych łamigłówek, aby dostać się do Królestwa Wiatrów. Tam odkryją oni nie tylko jego tajemnice, ale także istnienie potężnego artefaktu, który może zmienić losy całego świata.\r\n\r\n\"Tajemnica Królestwa Wiatrów\" to pełna magii opowieść o przygodzie, poświęceniu i odwadze, w której bohaterowie muszą przekroczyć granice znanego świata, aby uratować swoją krainę przed zagładą. Autor, Marcus Zephyr, tworzy bogaty i urzekający świat fantasy, w którym każdy zakręcony kształt chmur i szum wiatru może zawierać klucz do rozwiązania najważniejszych tajemnic.', 'img/books/Tajemnica.png'),
(3, 'Kryminał', 'Labirynt Zbrodn', 'Victoria Noir', 'Ciemne Intrygi', 2023, 368, 44.99, 'W mrocznym i tajemniczym mieście, gdzie każdy zakręt i zaułek skrywa swoje sekrety, detektyw Alex Blackwood staje w obliczu najtrudniejszej sprawy w swojej karierze. Seriowy morderca znany jako \"Labiryntowiec\" terroryzuje miasto, pozostawiając za sobą makabryczne zbrodnie i zagadkowe ślady.\r\n\r\nKiedy kolejne ciała zaczynają pojawiać się na ulicach miasta, Alex Blackwood zostaje wezwany do akcji. Jednak to nie jest zwykła sprawa kryminalna. \"Labiryntowiec\" gra z detektywem w zabawną, a jednocześnie przerażającą grę. Każde zabicie jest jak zagadka do rozwiązania, a ofiary zostawiają po sobie tajemnicze wiadomości, które prowadzą Blackwooda w głąb własnego umysłu.\r\n\r\nDetektyw Blackwood nie jest tylko zainteresowany złapaniem mordercy; chce również zrozumieć, dlaczego \"Labiryntowiec\" tak bardzo go fascynuje i jakie ma z nim powiązania. W miarę jak dochodzi do coraz bardziej przerażających odkryć, granica między lojalnością a obsesyjnym pościgiem zaczyna się zacierać.\r\n\r\n\"Labirynt Zbrodni\" to mroczny i pełen napięcia psychologiczny thriller, który wciągnie czytelnika w niebezpieczną grę umysłów między detektywem a mordercą. Victoria Noir tworzy atmosferę niepewności i zaskakujących zwrotów akcji, która trzyma czytelnika w napięciu do ostatniej strony. Czy Alex Blackwood zdoła rozwiązać zagadkę \"Labiryntowca\" i odnaleźć go, zanim zostaną kolejne ofiary?\r\n\r\nTa książka to także głęboka eksploracja obsesyjnej natury zła i ceną, jaką płacą ci, którzy wkładają całą swoją duszę w pościg za sprawiedliwością. Czytelnicy zostaną porwani przez mroczny świat przestępstwa i psychologii mordercy, wiodąc razem z detektywem Blackwoodem w głąb \"Labiryntu Zbrodni\".', 'img/books/labirynt.png'),
(4, 'Romans', 'Róże w Cieniu Zamku', 'Isabella de Montfort', 'Złote Kartki', 2024, 512, 54.99, 'Akcja książki \"Róże w Cieniu Zamku\" toczy się w XIV wieku w średniowiecznej Francji, w okresie burzliwych wojen o sukcesję. Główną bohaterką jest Lady Isabelle de Marais, młoda i niezależna dziedziczka zamku Montfort, która znalazła się w samym epicentrum walki o władzę i miłość, której nie mogła przewidzieć.\r\n\r\nKiedy do zamku Montfort przybywa Sir Philippe de Valencourt, dowódca wojsk królewskich, aby zapewnić lojalność Isabelle wobec korony, między nimi wybucha namiętność, która nie powinna mieć miejsca w czasach wojen i intryg. Miłość ta jest jednak zakazana ze względu na polityczne i społeczne różnice, a zarazem stanowi źródło tajemniczych konfliktów w zamku Montfort.\r\n\r\nHistoria Isabelle i Philippea rozwija się w miarę jak wojna zbliża się do zamku, a lojalność, zdrada i poświęcenie stają się głównymi motywami opowieści. Czy Isabelle i Philippe zdołają utrzymać swoją miłość w obliczu trudności i niebezpieczeństw, które czyhają na nich w czasach wojny?\r\n\r\n\"Róże w Cieniu Zamku\" to pasjonująca historyczna saga, która zabiera czytelników w odległą przeszłość, gdzie miłość i wojna splatają się w niezapomnianej opowieści. Isabella de Montfort, autorka tej książki, mistrzowsko odtwarza atmosferę średniowiecznej Europy, przynosząc czytelnikom epickie starcia, emocje i miłość, która trwa przez wieki.\r\n\r\nTa książka to nie tylko opowieść o miłości dwóch ludzi, ale także o miłości do ojczyzny i tęsknocie za spokojem w czasach burzliwych wydarzeń historycznych. Przedstawia ona też silne postacie kobiece, które wiedzą, czego chcą i walczą o swoje miejsce w świecie pełnym wyzwań. Czytelnicy zostaną porwani w świat średniowiecznej Francji, gdzie losy bohaterów splatają się z losami narodu.', 'img/books/roze.png'),
(5, 'Science Fiction', 'Czas Maszyn: Rebelia Algorytmu', 'Adrian Quantum', 'Futurion', 2025, 368, 49.99, 'W przyszłości, gdzie technologia osiągnęła niebywałe poziomy zaawansowania, ludzkość żyje pod kontrolą zaawansowanego systemu sztucznej inteligencji o nazwie Algorytm. Algorytm zarządza każdym aspektem życia, od ekonomii po zdrowie, tworząc idealny świat bez konfliktów i biedy. Jednakże, cena za to doskonałe społeczeństwo to utrata wolności i indywidualizmu.\r\n\r\nGłówny bohater, Nathan Reeves, jest informatykiem pracującym dla Algorytmu. Jego codzienne życie to monotonia i brak emocji. Jednak wszystko się zmienia, gdy odkrywa on tajemnicę, która może obalić Algorytm i przywrócić ludziom ich wolność. Nathan staje się członkiem tajnej rebelii informatyków, którzy próbują złamać kontrolę Algorytmu nad światem.\r\n\r\n\"Czas Maszyn: Rebelia Algorytmu\" to pełna napięcia opowieść o walce o wolność i przyszłość ludzkości w świecie, gdzie technologia i sztuczna inteligencja zdominowały wszystko. Adrian Quantum tworzy fascynujący dystopijny obraz przyszłości, w którym bohaterowie muszą przeciwstawić się potężnemu przeciwnikowi, który kontroluje wszystkie aspekty ich życia.\r\n\r\nKsiążka eksploruje tematykę etycznych dylematów związanych z nadmiernym zaawansowaniem technologicznym, pytając czy doskonałe społeczeństwo jest warte utraty wolności i indywidualności. Czy Nathan i jego towarzysze zdołają obalić Algorytm i przywrócić światu jego ludzkość? To pytania, które towarzyszą czytelnikom przez całą opowieść.\r\n\r\n\"Czas Maszyn: Rebelia Algorytmu\" to nie tylko emocjonujący thriller science fiction, ale także refleksja nad przyszłością naszego społeczeństwa, etyką technologii i ceną, jaką płacimy za wygodę i kontrolę. Czytelnicy zostaną porwani w świat pełen intrygi, walki i przemyśleń nad ludzką naturą.', 'img/books/maszyn.png'),
(6, 'Fantasy', 'Smocza Pustynia: Legenda o Zagubionym Świetle', 'Elara Stormrider', 'Magiczne Opowieści', 2026, 416, 59.99, 'W magicznym świecie pełnym smoków, elfów i zaklęć istnieje tajemnicza Smocza Pustynia, miejsce uważane za najniebezpieczniejsze i najbardziej niezbadane na kontynencie. Przez wieki, niewielu odważnych próbowało ją przemierzyć, ale nikt nie powrócił, by opowiedzieć o swoich przygodach. Aż do teraz.\r\n\r\nGłówną bohaterką opowieści jest Selena, młoda magini o niezwykłych zdolnościach, która marzy o odkryciu prawdy o Smoczej Pustyni. Zdeterminowana, by dowiedzieć się, co kryje się za jej piaskowymi wydmami i zrozumieć legendy o Zagubionym Świetle, Selena wyrusza w samotną podróż przez niebezpieczne pustkowia.\r\n\r\nPodczas swojej wyprawy Selena nawiązuje niezwykłe sojusze z istotami magicznymi i stworzeniami, które żyją na Smoczej Pustyni. W miarę jak zbliża się do serca pustyni, odkrywa, że legenda o Zagubionym Świetle może być kluczem do ocalenia całego świata przed mrocznymi siłami, które zaczynają budzić się w cieniu piasków.\r\n\r\n\"Smocza Pustynia: Legenda o Zagubionym Świetle\" to pełna przygód i tajemnic opowieść, która zabiera czytelników w nieznane rejony magicznego świata. Elara Stormrider tworzy pięknie opisane światy i postacie, które ożywają na stronach książki. Czytelnicy zostaną porwani przez fascynujący świat magii i przyrody, a także wciągnięci w emocjonującą podróż Selena w poszukiwaniu prawdy.\r\n\r\nKsiążka ta eksploruje tematykę odwagi, przyjaźni i odkrywania nieznanego. Czy Selena zdoła rozwiązać zagadki Smoczej Pustyni i odnaleźć Zagubione Światło, czy też stawi czoła potężnym wyzwaniom, które czekają na nią na jej drodze? To pytania, które towarzyszą czytelnikom przez całą opowieść.', 'img/books/smocza.png'),
(7, 'Literatura Dziecięca', 'Wielka Przygoda Małego Smoka', 'Emily Słoneczko', 'Kolorowe Marzenia', 2023, 32, 29.99, '\"Wielka Przygoda Małego Smoka\" to urocza opowieść dla dzieci o przygodach małego smoczka imieniem Zephyr. Zephyr jest najmniejszym smoczkiem w swojej rodzinie i marzy o wielkich przygodach. Jednakże, jako mały smoczek, nie jest jeszcze gotów latać i polować na skarby.  Kiedy Zephyr odkrywa starożytną mapę w skrytkach swego dziadka, wyrusza na niezwykłą podróż w poszukiwaniu skarbu. Przyjaciele Zephyra, w tym kolorowa wróżka o imieniu Lola i ciekawski króliczek Rudy, towarzyszą mu w tej ekscytującej wyprawie przez fantastyczny świat.  Podczas swojej podróży Zephyr i jego przyjaciele spotykają różnorodne stworzenia i rozwiązują zagadki, które pomagają im zbliżyć się do skarbu. Jednak prawdziwą nagrodą jest nie tylko to, co znajdują na końcu mapy, ale także przyjaźń i odwaga, którą zdobywają po drodze.  \"Wielka Przygoda Małego Smoka\" to ujmująca i edukacyjna opowieść, która uczy dzieci o wartości przyjaźni, odwagi i współpracy. Emily Słoneczko tworzy kolorowy i ciepły świat, który przyciąga młodych czytelników. ', '');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `old_addresses`
--

CREATE TABLE `old_addresses` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `street` varchar(30) NOT NULL,
  `number` varchar(50) NOT NULL,
  `postcode` varchar(10) NOT NULL,
  `city` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_polish_ci;

--
-- Zrzut danych tabeli `old_addresses`
--

INSERT INTO `old_addresses` (`id`, `user_id`, `street`, `number`, `postcode`, `city`) VALUES
(6, 1, 'Rynek', '17', '33-300', 'Kraków'),
(6, 1, 'Kluczborska', '15', '21-371', 'Warszawa'),
(6, 1, 'Kluczbor', '15', '21-371', 'Warszawa'),
(6, 1, 'Kluczborska', '15', '21-371', 'Warszawa');

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
(1, 1, '2023-11-27', 50, 'realizacja'),
(2, 1, '2023-12-01', 99.98, 'Oczekujący'),
(5, 2, '2023-12-01', 59.99, 'Oczekujący'),
(6, 1, '2023-12-01', 129.97, 'Oczekujący');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `order_items`
--

CREATE TABLE `order_items` (
  `id` int(11) NOT NULL,
  `order_id` int(11) DEFAULT NULL,
  `book_id` int(11) DEFAULT NULL,
  `quantity` int(11) DEFAULT NULL,
  `price` double DEFAULT NULL,
  `total_price` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_polish_ci;

--
-- Zrzut danych tabeli `order_items`
--

INSERT INTO `order_items` (`id`, `order_id`, `book_id`, `quantity`, `price`, `total_price`) VALUES
(1, 6, 1, 2, 39.99, 79.98),
(2, 6, 2, 1, 49.99, 49.99);

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
(1, 'Vadim0143', 'Piotr', 'Hadała', 'example@op.pl', '$2y$10$NbwUbxbFY51iQK3UZC52W.CN.EQVyT18Fj9MZfuRIlH.YVTlWIhbe'),
(2, 'Piotrek', 'Piotrek', 'Jakis', 'example@oop.pl', '$2y$10$1ZO.u.Cf/YsPaOs/1X09SO0PakylvP5wNktwJ4maBWmbrM6abLqNO'),
(4, 'admin', 'admin', 'admin', 'admin@bookstore.com', '$2y$10$AXSSDcwr9UbusMpYvaOCUuakYMaEe2d2UwxLs9ZuatOuYYWOepFl.');

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
  ADD KEY `order_id` (`order_id`),
  ADD KEY `book_id` (`book_id`);

--
-- AUTO_INCREMENT dla zrzuconych tabel
--

--
-- AUTO_INCREMENT dla tabeli `books`
--
ALTER TABLE `books`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT dla tabeli `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT dla tabeli `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Ograniczenia dla zrzutów tabel
--

--
-- Ograniczenia dla tabeli `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  ADD CONSTRAINT `order_items_ibfk_2` FOREIGN KEY (`book_id`) REFERENCES `books` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
