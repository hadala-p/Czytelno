-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Czas generowania: 03 Gru 2023, 03:01
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `getBookInfo` (IN `input_id` INT)   SELECT * FROM books
where id = input_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetBooksByCategory` (IN `p_category` VARCHAR(50))   BEGIN
    SELECT * FROM books WHERE category = p_category;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getUserId` (IN `input_nick` VARCHAR(50) CHARSET utf8)   select id
from users
where nick = input_nick$$

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
    SELECT CONCAT( a.street, ' ', a.number, ', ', a.postcode, '  ', a.city) INTO addressDetails
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
(0, 5, 'Jakas', '67', '21-700', 'Klucz'),
(6, 1, 'Armi', '9', '11-123', 'Wrocław');

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
(3, 'Kryminał', 'Labirynt Zbrodni', 'Victoria Noir', 'Ciemne Intrygi', 2023, 368, 44.99, 'W mrocznym i tajemniczym mieście, gdzie każdy zakręt i zaułek skrywa swoje sekrety, detektyw Alex Blackwood staje w obliczu najtrudniejszej sprawy w swojej karierze. Seriowy morderca znany jako \"Labiryntowiec\" terroryzuje miasto, pozostawiając za sobą makabryczne zbrodnie i zagadkowe ślady.\r\n\r\nKiedy kolejne ciała zaczynają pojawiać się na ulicach miasta, Alex Blackwood zostaje wezwany do akcji. Jednak to nie jest zwykła sprawa kryminalna. \"Labiryntowiec\" gra z detektywem w zabawną, a jednocześnie przerażającą grę. Każde zabicie jest jak zagadka do rozwiązania, a ofiary zostawiają po sobie tajemnicze wiadomości, które prowadzą Blackwooda w głąb własnego umysłu.\r\n\r\nDetektyw Blackwood nie jest tylko zainteresowany złapaniem mordercy; chce również zrozumieć, dlaczego \"Labiryntowiec\" tak bardzo go fascynuje i jakie ma z nim powiązania. W miarę jak dochodzi do coraz bardziej przerażających odkryć, granica między lojalnością a obsesyjnym pościgiem zaczyna się zacierać.\r\n\r\n\"Labirynt Zbrodni\" to mroczny i pełen napięcia psychologiczny thriller, który wciągnie czytelnika w niebezpieczną grę umysłów między detektywem a mordercą. Victoria Noir tworzy atmosferę niepewności i zaskakujących zwrotów akcji, która trzyma czytelnika w napięciu do ostatniej strony. Czy Alex Blackwood zdoła rozwiązać zagadkę \"Labiryntowca\" i odnaleźć go, zanim zostaną kolejne ofiary?\r\n\r\nTa książka to także głęboka eksploracja obsesyjnej natury zła i ceną, jaką płacą ci, którzy wkładają całą swoją duszę w pościg za sprawiedliwością. Czytelnicy zostaną porwani przez mroczny świat przestępstwa i psychologii mordercy, wiodąc razem z detektywem Blackwoodem w głąb \"Labiryntu Zbrodni\".', 'img/books/labirynt.png'),
(4, 'Romans', 'Róże w Cieniu Zamku', 'Isabella de Montfort', 'Złote Kartki', 2024, 512, 54.99, 'Akcja książki \"Róże w Cieniu Zamku\" toczy się w XIV wieku w średniowiecznej Francji, w okresie burzliwych wojen o sukcesję. Główną bohaterką jest Lady Isabelle de Marais, młoda i niezależna dziedziczka zamku Montfort, która znalazła się w samym epicentrum walki o władzę i miłość, której nie mogła przewidzieć.\r\n\r\nKiedy do zamku Montfort przybywa Sir Philippe de Valencourt, dowódca wojsk królewskich, aby zapewnić lojalność Isabelle wobec korony, między nimi wybucha namiętność, która nie powinna mieć miejsca w czasach wojen i intryg. Miłość ta jest jednak zakazana ze względu na polityczne i społeczne różnice, a zarazem stanowi źródło tajemniczych konfliktów w zamku Montfort.\r\n\r\nHistoria Isabelle i Philippea rozwija się w miarę jak wojna zbliża się do zamku, a lojalność, zdrada i poświęcenie stają się głównymi motywami opowieści. Czy Isabelle i Philippe zdołają utrzymać swoją miłość w obliczu trudności i niebezpieczeństw, które czyhają na nich w czasach wojny?\r\n\r\n\"Róże w Cieniu Zamku\" to pasjonująca historyczna saga, która zabiera czytelników w odległą przeszłość, gdzie miłość i wojna splatają się w niezapomnianej opowieści. Isabella de Montfort, autorka tej książki, mistrzowsko odtwarza atmosferę średniowiecznej Europy, przynosząc czytelnikom epickie starcia, emocje i miłość, która trwa przez wieki.\r\n\r\nTa książka to nie tylko opowieść o miłości dwóch ludzi, ale także o miłości do ojczyzny i tęsknocie za spokojem w czasach burzliwych wydarzeń historycznych. Przedstawia ona też silne postacie kobiece, które wiedzą, czego chcą i walczą o swoje miejsce w świecie pełnym wyzwań. Czytelnicy zostaną porwani w świat średniowiecznej Francji, gdzie losy bohaterów splatają się z losami narodu.', 'img/books/roze.png'),
(5, 'Science Fiction', 'Czas Maszyn: Rebelia Algorytmu', 'Adrian Quantum', 'Futurion', 2025, 368, 49.99, 'W przyszłości, gdzie technologia osiągnęła niebywałe poziomy zaawansowania, ludzkość żyje pod kontrolą zaawansowanego systemu sztucznej inteligencji o nazwie Algorytm. Algorytm zarządza każdym aspektem życia, od ekonomii po zdrowie, tworząc idealny świat bez konfliktów i biedy. Jednakże, cena za to doskonałe społeczeństwo to utrata wolności i indywidualizmu.\r\n\r\nGłówny bohater, Nathan Reeves, jest informatykiem pracującym dla Algorytmu. Jego codzienne życie to monotonia i brak emocji. Jednak wszystko się zmienia, gdy odkrywa on tajemnicę, która może obalić Algorytm i przywrócić ludziom ich wolność. Nathan staje się członkiem tajnej rebelii informatyków, którzy próbują złamać kontrolę Algorytmu nad światem.\r\n\r\n\"Czas Maszyn: Rebelia Algorytmu\" to pełna napięcia opowieść o walce o wolność i przyszłość ludzkości w świecie, gdzie technologia i sztuczna inteligencja zdominowały wszystko. Adrian Quantum tworzy fascynujący dystopijny obraz przyszłości, w którym bohaterowie muszą przeciwstawić się potężnemu przeciwnikowi, który kontroluje wszystkie aspekty ich życia.\r\n\r\nKsiążka eksploruje tematykę etycznych dylematów związanych z nadmiernym zaawansowaniem technologicznym, pytając czy doskonałe społeczeństwo jest warte utraty wolności i indywidualności. Czy Nathan i jego towarzysze zdołają obalić Algorytm i przywrócić światu jego ludzkość? To pytania, które towarzyszą czytelnikom przez całą opowieść.\r\n\r\n\"Czas Maszyn: Rebelia Algorytmu\" to nie tylko emocjonujący thriller science fiction, ale także refleksja nad przyszłością naszego społeczeństwa, etyką technologii i ceną, jaką płacimy za wygodę i kontrolę. Czytelnicy zostaną porwani w świat pełen intrygi, walki i przemyśleń nad ludzką naturą.', 'img/books/maszyn.png'),
(6, 'Fantasy', 'Smocza Pustynia: Legenda o Zagubionym Świetle', 'Elara Stormrider', 'Magiczne Opowieści', 2026, 416, 59.99, 'W magicznym świecie pełnym smoków, elfów i zaklęć istnieje tajemnicza Smocza Pustynia, miejsce uważane za najniebezpieczniejsze i najbardziej niezbadane na kontynencie. Przez wieki, niewielu odważnych próbowało ją przemierzyć, ale nikt nie powrócił, by opowiedzieć o swoich przygodach. Aż do teraz.\r\n\r\nGłówną bohaterką opowieści jest Selena, młoda magini o niezwykłych zdolnościach, która marzy o odkryciu prawdy o Smoczej Pustyni. Zdeterminowana, by dowiedzieć się, co kryje się za jej piaskowymi wydmami i zrozumieć legendy o Zagubionym Świetle, Selena wyrusza w samotną podróż przez niebezpieczne pustkowia.\r\n\r\nPodczas swojej wyprawy Selena nawiązuje niezwykłe sojusze z istotami magicznymi i stworzeniami, które żyją na Smoczej Pustyni. W miarę jak zbliża się do serca pustyni, odkrywa, że legenda o Zagubionym Świetle może być kluczem do ocalenia całego świata przed mrocznymi siłami, które zaczynają budzić się w cieniu piasków.\r\n\r\n\"Smocza Pustynia: Legenda o Zagubionym Świetle\" to pełna przygód i tajemnic opowieść, która zabiera czytelników w nieznane rejony magicznego świata. Elara Stormrider tworzy pięknie opisane światy i postacie, które ożywają na stronach książki. Czytelnicy zostaną porwani przez fascynujący świat magii i przyrody, a także wciągnięci w emocjonującą podróż Selena w poszukiwaniu prawdy.\r\n\r\nKsiążka ta eksploruje tematykę odwagi, przyjaźni i odkrywania nieznanego. Czy Selena zdoła rozwiązać zagadki Smoczej Pustyni i odnaleźć Zagubione Światło, czy też stawi czoła potężnym wyzwaniom, które czekają na nią na jej drodze? To pytania, które towarzyszą czytelnikom przez całą opowieść.', 'img/books/smocza.png'),
(7, 'Science Fiction', 'Gwiazdy Nadziei', 'Xander Nova', 'Przestrzenne Przygody', 2025, 400, 45.99, 'W odległej przyszłości, gdy ludzkość rozprzestrzeniła się po galaktyce, grupa śmiałków wyrusza na podróż przez kosmos, aby znaleźć nowy dom dla ludzkości. Ich statek kosmiczny, Gwiazda Nadziei, napotyka jednak na nieznane zagrożenia i tajemnice, które zagrażają całej misji. Xander Nova, kapitan statku, musi podjąć trudne decyzje, aby zapewnić przetrwanie załogi i przyszłość ludzkości w bezkresie gwiazd. Czy gwiazdy przyniosą nadzieję, czy też przerażenie?', 'img/books/Gwiazdy_Nadziei.png'),
(8, 'Science Fiction', 'Replikanci: W Poszukiwaniu Tożsamości', 'Ava Nexus', 'Kwantowe Widmo', 2024, 360, 34.99, 'W świecie, gdzie ludzie stworzyli doskonale replikanty, niemal niemożliwe do odróżnienia od ludzi, pojawia się pytanie o tożsamość i moralność. Ava Nexus, programistka replikantów, wplątuje się w spisek ujawniający prawdziwą naturę ich istnienia. Kiedy ludzkość staje przed koniecznością zmierzenia się z etycznymi dylematami i pytaniem, co oznacza być człowiekiem, Ava szuka odpowiedzi w świecie, gdzie granice między rzeczywistością a sztuczną inteligencją zaczynają się zacierać.', 'img/books/Replikanci.png'),
(9, 'Science Fiction', 'Ostatni Bastion', 'Elena Starlight', 'Galaktyczne Opowieści', 2023, 320, 38.99, 'Po upadku wielkich imperiów galaktycznych, grupa ocalałych ludzi schroniła się na tajemniczej planecie, znanej jako Ostatni Bastion. Elena Starlight, przywódca ostatniego bastionu ludzkości, musi stawić czoła nie tylko zewnętrznym zagrożeniom, ale także wewnętrznym konfliktom i tajemnicom planety. Czy Ostatni Bastion przetrwa, czy też zostanie pochłonięty przez mroki przeszłości?', 'img/books/Ostatni_Bastion.png'),
(10, 'Science Fiction', 'Projekt Horyzont', 'Nolan Quantum', 'TechnoWizje', 2025, 380, 42.99, 'W świecie, gdzie technologia osiągnęła punkt, w którym umysły ludzkie mogą być połączone z sztuczną inteligencją, powstaje Projekt Horyzont. Nolan Quantum, genialny naukowiec, stara się rozwikłać tajemnice ludzkiego umysłu, eksplorując granice rzeczywistości w wirtualnym świecie. Jednakże, gdy granice między rzeczywistością a wirtualnością zaczynają się rozmazywać, Nolan musi zmierzyć się z konsekwencjami swojego eksperymentu. Czy Projekt Horyzont przyniesie rewolucję czy upadek?', 'img/books/Projekt_Horyzont.png'),
(11, 'Science Fiction', 'Układ Słoneczny: Nowa Granica', 'Serena Cosmos', 'AstroOpowieści', 2026, 420, 48.99, 'W czasach, gdy kolonie ludzkie rozkwitają w różnych częściach Układu Słonecznego, Serena Cosmos, pilotka statku kosmicznego, staje w obliczu tajemniczej anomalii, która zagraża stabilności całego systemu. Razem z ekipą musi odkryć źródło tej anomalii i zapobiec katastrofie. Czy nowa granica przyniesie nadzieję czy zagładę?', 'img/books/Uklad_Sloneczny.png'),
(12, 'Science Fiction', 'Eteryczny Labirynt', 'Axel Nebula', 'Kwantowe Przygody', 2024, 340, 36.99, 'W świecie, gdzie rzeczywistość jest elastyczna, a podróże między wymiarami są codziennością, Axel Nebula, podróżnik kwantowy, odkrywa tajemniczy Eteryczny Labirynt. To miejsce, gdzie czas i przestrzeń ulegają dziwnym deformacjom, a każdy krok prowadzi do innej rzeczywistości. Axel musi przejść przez labirynt, aby znaleźć wyjście i zrozumieć tajemnice kwantowego wszechświata.', 'img/books/Eteryczny_Labirynt.png'),
(13, 'Science Fiction', 'Stellaris: Ostatnia Granica', 'Lara Celestia', 'Gwiezdne Przygody', 2025, 400, 44.99, 'W odległej przyszłości, gdy ludzkość eksploruje dalekie gwiazdy, statek kosmiczny Stellaris odkrywa tajemniczą planetę na obrzeżach galaktyki. Lara Celestia, kapitan statku, musi zbadać ostatnią granicę znaną ludzkości i stawić czoła niebezpieczeństwom i tajemnicom, które tam czyhają. Czy Stellaris przyniesie nową nadzieję czy też ostateczne wyzwanie dla ludzkości?', 'img/books/Stellaris.png'),
(14, 'Science Fiction', 'Wirtualna Odyseja', 'Max Quantum', 'CyberOpowieści', 2023, 360, 39.99, 'W erze, gdzie wirtualna rzeczywistość staje się nowym światem, Max Quantum, gracz wirtualnej odysei, odkrywa, że granice między grą a rzeczywistością zaczynają się zacierać. Kiedy konflikty między rzeczywistością a wirtualnością zaczynają się zacierać, Max i gracze muszą zmierzyć się z konsekwencjami ich własnej wyobraźni. Czy wirtualna odyseja przyniesie rozrywkę czy też stanie się pułapką dla umysłów?', 'img/books/Wirtualna_Odyseja.png'),
(15, 'Fantasy', 'Królowa Ciemności', 'Evelyn Shadow', 'Magiczne Opowieści', 2025, 420, 49.99, 'W krainie pełnej magii i niebezpieczeństw, Królowa Ciemności, potężna czarownica, powraca z wieków snu. Jej celem jest podbicie królestw ludzkich i zatopienie ich w wiecznej ciemności. Jednak jedna młoda bohaterka, Elara Moonlight, musi wyruszyć na niebezpieczną misję, aby powstrzymać Królową Ciemności i przywrócić światło do krainy. Czy Elara zdoła stawić czoła potężnym czarom i uratować królestwa od zguby?', 'img/books/Krolowa_Ciemnosci.png'),
(16, 'Fantasy', 'Legenda Ostatniego Smoka', 'Gareth Fireheart', 'Zaklęte Strony', 2024, 380, 44.99, 'W magicznym świecie, gdzie smoki są strażnikami tajemniczych skarbów, pojawia się proroctwo o Ostatnim Smoku, który ma przynieść równowagę między światem ludzi a magicznymi istotami. Gareth Fireheart, śmiałek z królewskiego rodu, zostaje wybrany do odnalezienia Ostatniego Smoka i ocalenia krainy przed nadchodzącym złem. Czy uda mu się spełnić proroctwo i zapobiec wielkiej katastrofie?', 'img/books/Legenda_Ostatniego_Smoka.png'),
(17, 'Fantasy', 'Zaklęte Królestwo', 'Seraphina Enchant', 'Mityczne Opowieści', 2026, 440, 54.99, 'W zaklętym królestwie, gdzie magia przepływa przez każdy zakątek, młoda księżniczka Seraphina Enchant odkrywa tajemnice swojego rodowodu. Zdolności magiczne, które się w niej budzą, stawiają ją w centrum starożytnej wojny między światłem a ciemnością. Seraphina musi odnaleźć swoją prawdziwą moc i wyruszyć na niebezpieczną podróż, aby ocalić zaklęte królestwo przed upadkiem. Czy potrafi sprostać wyzwaniom i stać się ostatnią nadzieją krainy?', 'img/books/Zaklete_Krolestwo.png'),
(18, 'Fantasy', 'Księga Elfów', 'Thalion Silverleaf', 'Elficzne Opowieści', 2023, 360, 38.99, 'W magicznym lesie, gdzie elfy strzegą starożytnych tajemnic, pojawia się Księga Elfów - starożytny manuskrypt, który kryje w sobie potężne zaklęcia. Thalion Silverleaf, młody elficzny uczeń, zostaje wybrany do odnalezienia tej księgi i zabezpieczenia jej przed wpadnięciem w ręce mrocznych sił. Czy Thalion zdoła ochronić tajemnice elfów i zachować równowagę w magicznym lesie?', 'img/books/Ksiega_Elfow.png'),
(19, 'Fantasy', 'Dziedzictwo Kamienia', 'Aria Stonemage', 'Kamienne Opowieści', 2025, 400, 42.99, 'W krainie, gdzie magia płynie z kamieni, Aria Stonemage odkrywa, że posiada zdolności do kontrolowania magii kamieni, co uznawane jest za dar od pradawnych bogów. Jej zadaniem jest ocalić świat przed inwazją potężnych istot z innej rzeczywistości, które chcą pochłonąć magię kamieni. Czy Aria zdoła zrealizować swoje przeznaczenie i ochronić dziedzictwo kamienia?', 'img/books/Dziedzictwo_Kamienia.png'),
(20, 'Fantasy', 'Łowcy Cieni', 'Dominic Shadowhunter', 'Mroczne Legendy', 2024, 380, 44.99, 'W świecie pełnym magii i potworów, Łowcy Cieni, tajna grupa wojowników, staje do walki z siłami ciemności. Dominic Shadowhunter, doświadczony łowca, wyrusza na misję, aby pokonać starożytnego smoka, który grozi zniszczeniem krainy. W trakcie swojej podróży odkryje on mroczne sekrety i stawi czoła swojemu własnemu przeznaczeniu. Czy Łowcy Cieni zdołają przywrócić światło w mrocznych czasach?', 'img/books/Lowcy_Cieni.png'),
(21, 'Fantasy', 'Tajemnica Krainy Mgły', 'Isabella Mistweaver', 'Mgielne Opowieści', 2023, 360, 39.99, 'W krainie otoczonej tajemniczą mgłą, Isabella Mistweaver, młoda czarownica, odkrywa starożytną tajemnicę, która może otworzyć bramy między światami. Wyruszając na niebezpieczną podróż, Isabella musi stawić czoła nie tylko mrocznym istotom, ale także własnym strachom i wątpliwościom. Czy odnajdzie tajemnicę krainy mgły i zachowa równowagę między światami?', 'img/books/Tajemnica_Krainy_Mgly.png'),
(22, 'Fantasy', 'Klątwa Zakazanego Zaklęcia', 'Victor Hexbane', 'Zakazane Opowieści', 2026, 420, 47.99, 'W świecie, gdzie zaklęcia są zakazane ze względu na ich potężne i niebezpieczne moce, Victor Hexbane, przeklęty czarodziej, staje do walki z Zakazanym Zaklęciem, które grozi zniszczeniem rzeczywistości. Zdążając przez krainy pełne pułapek i zagrożeń, Victor musi znaleźć sposób na złamanie klątwy i przywrócenie równowagi między magią a rzeczywistością. Czy przeklęty czarodziej zdoła pokonać potężne zaklęcie i zapobiec katastrofie?', 'img/books/Klątwa_Zakazanego_Zaklęcia.png'),
(23, 'Kryminał', 'Złodziejka Cieni', 'Elena Nightshade', 'Ciemne Zagadki', 2025, 400, 45.99, 'Elena Nightshade, utalentowana złodziejka, zostaje wciągnięta w intrygującą grę z przeciwnikiem, który operuje w cieniu. Kiedy zagadkowe kradzieże zaczynają zagrażać równowadze między gangami miejskimi, Elena musi użyć swojego sprytu i umiejętności, aby odkryć tożsamość tajemniczego złodzieja i stawić mu czoła, zanim całe miasto popadnie w chaos.', 'img/books/Zlodziejka_Cieni.png'),
(24, 'Kryminał', 'Bezlitosna Gra', 'Dylan Steel', 'Mroczne Intrygi', 2024, 380, 42.99, 'Dylan Steel, doświadczony detektyw, zostaje wplątany w bezlitosną grę zorganizowanego przestępstwa. Kiedy seria brutalnych morderstw wstrząsa miastem, Steel musi śledzić zimną i bezlitosną ścieżkę zbrodni, odkrywając intrygi, zdrady i mroczne tajemnice, które prowadzą do szczytu przestępczego imperium.', 'img/books/Bezlitosna_Gra.png'),
(25, 'Kryminał', 'Śmiertelne Sekrety', 'Olivia Noir', 'Zagadkowe Sprawy', 2023, 360, 39.99, 'W świecie pełnym zdrad, kłamstw i śmiertelnych tajemnic, detektyw Olivia Noir musi rozwikłać skomplikowaną sprawę morderstwa. Kiedy ofiary zaczynają ujawniać swoje mroczne sekrety, Noir odkrywa, że każdy ma coś do ukrycia. Czy rozwiąże zagadkę przed tym, jak kolejne sekrety przyniosą śmierć?', 'img/books/Smiertelne_Sekrety.png'),
(26, 'Kryminał', 'Zakazane Miasto', 'Nathan Blackwell', 'Mroczne Kąty', 2025, 400, 44.99, 'W tajemniczym zakazanym mieście, gdzie prawo nie obowiązuje, a korupcja sięga szczytu, detektyw Nathan Blackwell zostaje wysłany, aby zapanować nad rosnącym chaosem. W miarę jak grzechy przeszłości wypływają na powierzchnię, Blackwell musi stawić czoła moralnym dylematom i skomplikowanym relacjom, aby przywrócić sprawiedliwość w zakazanym mieście.', 'img/books/Zakazane_Miasto.png'),
(27, 'Kryminał', 'Mroczne Nocne Łowy', 'Victoria Shadowsong', 'Ciemne Zagadki', 2024, 380, 41.99, 'W świetle księżyca, Victoria Shadowsong, prywatna detektyw i łowczyni nagród, tropi mroczne tajemnice podziemnego świata przestępczego. Kiedy brutalne morderstwa zaczynają wpływać na równowagę sił w podziemiu, Shadowsong musi użyć swoich zdolności, aby odkryć mordercę zanim ten zrobi kolejny krok w kierunku chaosu.', 'img/books/Mroczne_Nocne_Lowy.png'),
(28, 'Kryminał', 'Zaginione Miasto', 'Lucas Vanish', 'Zagadkowe Sprawy', 2023, 360, 39.99, 'Lucas Vanish, były policyjny detektyw, zostaje wezwany, aby odnaleźć zaginione miasto, które zniknęło z mapy. W miarę jak śledztwo rozwija się, Vanish odkrywa, że miasto skrywa mroczne tajemnice i jest kluczem do starożytnej zagadki. Czy zdoła odnaleźć zaginione miasto zanim stanie się ono przyczyną katastrofy?', 'img/books/Zaginione_Miasto.png'),
(29, 'Kryminał', 'Zimny Ślad', 'Eva Frost', 'Lodowe Intrygi', 2026, 420, 46.99, 'Eva Frost, lodowa detektyw, zostaje postawiona przed trudnym zadaniem rozwiązania zagadki serii tajemniczych porwań. W świecie lodowej magii i zimnych intryg, Frost musi roztopić zimny ślad i odkryć tożsamość tajemniczego porywacza, zanim nadejdzie zimowa nocy.', 'img/books/Zimny_Slad.png'),
(30, 'Kryminał', 'Ostatnia Gra', 'Michael Gambit', 'Mistrzowskie Zagadki', 2025, 400, 42.99, 'W grze z mistrzowskimi zagadkami, detektyw Michael Gambit zostaje postawiony przed ostatnią grą, która może zmienić wszystko. Kiedy tajemniczy przeciwnik manipuluje rzeczywistością, Gambit musi ułamać kod i rozwiązać ostatnią zagadkę, zanim upadnie zasłona mrocznej intrygi.', 'img/books/Ostatnia_Gra.png'),
(31, 'Kryminał', 'Mroczne Ulice', 'Sophia Shadow', 'Ciemne Zagadki', 2024, 380, 41.99, 'Sophia Shadow, doświadczona detektyw, zostaje postawiona przed wyzwaniem rozwiązania serii zbrodni, które terroryzują mroczne ulice miasta. W miarę jak śledztwo prowadzi ją przez zaułki zdrady i mroczne sekrety, Shadow musi stawić czoła własnym demonom przeszłości, aby przynieść sprawiedliwość ofiarom.', 'img/books/Mroczne_Ulice.png'),
(32, 'Romans', 'Miłość pod Wieżą Eiffla', 'Sophie Heart', 'Romantyczne Opowieści', 2025, 350, 38.99, 'Sophie Heart przenosi czytelników do magicznego Paryża, gdzie miłość kwitnie pod cieniem Wieży Eiffla. Główna bohaterka, Emma, przypadkiem spotyka tajemniczego artystę, który sprawia, że jej życie staje się pełne romansu, przygód i piękna. Czy miłość pod Wieżą Eiffla przetrwa próby czasu i przeciwności losu?', 'img/books/Milosc_pod_Wieza_Eiffla.png'),
(33, 'Romans', 'Deszczowa Noc', 'Aiden Rain', 'Miłosne Historie', 2024, 320, 34.99, 'Deszczowa noc, tajemnicza i pełna magii, staje się świadkiem narodzin niezwykłej miłości. Aiden Rain ukazuje historię zakazanej miłości między dwójką dusz, które z pozoru są ze sobą niezgodne. Czy siła ich uczuć pokona opory społeczne i przetrwa nieuchronne burze życiowych wyborów?', 'img/books/Deszczowa_Noc.png'),
(34, 'Romans', 'Serce z Szmaragdu', 'Luna Emerald', 'Zakazane Romansy', 2023, 310, 32.99, 'Luna Emerald przedstawia opowieść o zakazanej miłości między dziedziczką rodu, a tajemniczym mężczyzną o szmaragdowych oczach. W świecie pełnym intryg i niebezpieczeństw, bohaterowie muszą pokonać przeciwności, aby być razem. Czy ich serca z szmaragdu przetrwają próby czasu?', 'img/books/Serce_z_Szmaragdu.png'),
(35, 'Romans', 'Gdzie Gwiazdy Płaczą', 'Eva Stardust', 'Wzruszające Opowieści', 2026, 380, 42.99, 'Eva Stardust przenosi czytelników w podróż przez czas i przestrzeń, gdzie miłość kwitnie pod gwiazdami. Bohaterowie, pochodzący z różnych epok historycznych, muszą pokonać bariery czasu, aby być razem. Czy ich miłość przetrwa próbę odległości i losu?', 'img/books/Gdzie_Gwiazdy_Placza.png'),
(36, 'Romans', 'Czerwone Wstążki', 'Alex Ruby', 'Romantyczne Opowieści', 2025, 360, 39.99, 'Alex Ruby snuje historię o miłości, która tkwi w czerwonych wstążkach, łącząc losy dwóch ludzi. W miarę jak czerwone wstążki splatają się wokół ich serc, bohaterowie muszą zmierzyć się z przeszłością i pokonać przeciwności, aby odnaleźć prawdziwe szczęście.', 'img/books/Czerwone_Wstazki.png'),
(37, 'Romans', 'Zaklęte Serce', 'Isabella Lovecharm', 'Miłosne Historie', 2024, 340, 36.99, 'Isabella Lovecharm ukazuje historię miłosną, w której serce bohaterki zostaje zaklęte przez tajemniczego nieznajomego. W świecie magii i romantyzmu, bohaterowie muszą przezwyciężyć przeszłość i zaklęcia, aby być razem. Czy zaklęte serce znajdzie drogę do prawdziwej miłości?', 'img/books/Zaklete_Serce.png'),
(38, 'Romans', 'Ogniste Pocałunki', 'Ignatius Blaze', 'Romantyczne Opowieści', 2023, 330, 37.99, 'Ignatius Blaze kreśli historię ognistych pocałunków, które zapalają miłość między dwójką sprzecznych bohaterów. W świecie pełnym namiętności i emocji, bohaterowie muszą znaleźć równowagę między płomieniami uczuć a rzeczywistością. Czy ogniste pocałunki przetrwają próbę czasu?', 'img/books/Ogniste_Pocalunki.png'),
(39, 'Romans', 'Pod Gwiazdami Morza', 'Stella Maris', 'Wzruszające Opowieści', 2026, 370, 41.99, 'Stella Maris opowiada historię miłości rozkwitającej pod gwiazdami morza. Bohaterowie, związani wspomnieniami z dzieciństwa i tajemnicą zaginionego skarbu, muszą odnaleźć swoją drogę do siebie. Czy pod gwiazdami morza odnajdą spójność swoich serc?', 'img/books/Pod_Gwiazdami_Morza.png'),
(40, 'Romans', 'Kwiaty Zakazanej Miłości', 'Flora Forbidden', 'Zakazane Romansy', 2025, 350, 38.99, 'Flora Forbidden prezentuje opowieść o zakazanej miłości kwitnącej jak kwiaty w ogrodzie zakazanym. Bohaterowie, związani lojalnością i zakazanym uczuciem, muszą zmierzyć się z konsekwencjami swojej miłości. Czy kwiaty zakazanej miłości przetrwają w ogrodzie zakazanym?', 'img/books/Kwiaty_Zakazanej_Milosci.png'),
(41, 'Dla dzieci', 'Zaczarowany Las', 'Emma Enchanting', 'Baśniowe Opowieści', 2023, 32, 18.99, 'Emma Enchanting opowiada o przygodach małego elfa, który wyrusza na poszukiwanie zaginionego skarbu w zaczarowanym lesie. Znajdzie nowych przyjaciół, pokona przeszkody i odkryje magię prawdziwej przyjaźni.', 'img/books/Zaczarowany_Las.png'),
(42, 'Dla dzieci', 'Przygody Kolorowego Smoka', 'Oliver Rainbow', 'Kolorowe Opowieści', 2024, 28, 16.99, 'Oliver Rainbow przenosi dziecięcych czytelników w świat pełen kolorów i przygód. Kolorowy smok wyrusza na podróż, aby przywrócić barwy, które zniknęły z jego krainy. Czy dzieci pomogą mu przywrócić magię kolorów?', 'img/books/Przygody_Kolorowego_Smoka.png'),
(43, 'Dla dzieci', 'Magiczna Kraina Cukierków', 'Candy Sparkle', 'Słodkie Opowieści', 2025, 36, 21.99, 'Candy Sparkle opowiada o magicznej krainie cukierków, gdzie wszystko jest możliwe. Dziecięcy bohaterowie odkrywają tajemnice krainy, spotykają słodkie postacie i uczą się ważnych wartości poprzez przygody pełne cukrowego uroku.', 'img/books/Magiczna_Kraina_Cukierkow.png'),
(44, 'Dla dzieci', 'Wielka Wyprawa Małego Niedźwiadka', 'Teddy Adventure', 'Przyjacielskie Historie', 2023, 30, 17.99, 'Teddy Adventure opowiada o wielkiej wyprawie małego niedźwiadka, który marzy o odkrywaniu świata. Z pomocą przyjaciół zwierząt, przezwycięży trudności i nauczy się, że największe przygody czekają tuż za rogiem.', 'img/books/Wielka_Wyprawa_Malego_Niedzwiadka.png'),
(45, 'Dla dzieci', 'Przygody Małej Wróżki', 'Fiona Fairy', 'Baśniowe Opowieści', 2024, 34, 19.99, 'Fiona Fairy opowiada o przygodach małej wróżki, która wyrusza na misję przywrócenia magii do swojego wróżkowego królestwa. Dziecięcy czytelnicy odkryją z nią magiczne zakamarki wróżkowego świata i nauczą się, że siła tkwi w wierze i dobrej woli.', 'img/books/Przygody_Malej_Wrozki.png'),
(46, 'Dla dzieci', 'Sensacyjne Poszukiwania Skarbów', 'Captain Adventure', 'Przygodowe Opowieści', 2025, 38, 23.99, 'Captain Adventure przedstawia historię sensacyjnych poszukiwań skarbów, gdzie grupa dzielnych dzieci wyrusza na pełną niebezpieczeństw wyprawę. Razem pokonają pułapki, rozwiążą zagadki i odkryją skarb ukryty na tajemniczej wyspie.', 'img/books/Sensacyjne_Poszukiwania_Skarbow.png'),
(47, 'Dla dzieci', 'Zaklęta Księga Zabawek', 'Mia Magic', 'Magiczne Opowieści', 2026, 32, 18.99, 'Mia Magic opowiada o zaklętej księdze zabawek, która ożywa w nocy, zapewniając dzieciom niezapomniane przygody. Bohaterowie muszą współpracować z magicznymi postaciami, aby uratować świat przed szalonym czarnoksiężnikiem, który chce przejąć kontrolę nad wszystkimi zabawkami.', 'img/books/Zakleta_Ksiega_Zabawek.png'),
(48, 'Dla dzieci', 'Podwodne Przygody Koralii', 'Coralie Mermaid', 'Baśniowe Opowieści', 2024, 40, 24.99, 'Coralie Mermaid opowiada o podwodnych przygodach małej syrenki, która marzy o poznawaniu nowych miejsc i przyjaciół. Wraz z kolorowymi stworzeniami morskiego świata, Coralie odkrywa tajemnice oceanu i uczy dzieci o wartości przyjaźni i ochrony środowiska.', 'img/books/Podwodne_Przygody_Koralii.png'),
(49, 'Dla dzieci', 'Skarby Księżycowego Ogrodu', 'Luna Gardener', 'Magiczne Opowieści', 2025, 36, 21.99, 'Luna Gardener opowiada o skarbach ukrytych w księżycowym ogrodzie, gdzie dziecięcy bohaterowie stają się opiekunami magicznych roślin. Wspólnie z przyjaciółmi roślinami, dzieci odkryją piękno natury i tajemnice zaklętego ogrodu.', 'img/books/Skarby_Ksiezycowego_Ogrodu.png'),
(50, 'Dla dzieci', 'Przygody Księżycowego Królika', 'Moonlight Bunny', 'Przyjacielskie Historie', 2026, 28, 16.99, 'Moonlight Bunny opowiada o przygodach uroczego księżycowego królika, który wyrusza na podróż po nocy, by pomóc gwiazdom w świeceniu jasno na nocnym niebie. Dziecięcy czytelnicy dowiedzą się, jak małe gesty mogą sprawić wielką różnicę w magicznym świecie.', 'img/books/Przygody_Ksiezycowego_Krolika.png'),
(51, 'Nauka', 'Wędrówka po Wszechświecie', 'Astrid Explorer', 'Kosmiczne Odkrycia', 2023, 256, 34.99, 'Astrid Explorer zabiera czytelników w fascynującą podróż po wszechświecie, odkrywając sekrety planet, gwiazd i galaktyk. Książka pełna jest wspaniałych ilustracji i ciekawostek naukowych, które rozbudzą zainteresowanie kosmosem.', 'img/books/Wedrowka_po_Wszechswiecie.png'),
(52, 'Nauka', 'Tajemnice Mikroświata', 'Dr. Microscope', 'Mikroskopowe Odkrycia', 2024, 192, 29.99, 'Dr. Microscope przenosi czytelników w niewidzialny świat mikroorganizmów, bakterii i komórek. Książka opisuje fascynujące procesy zachodzące w mikroświecie, korzystając z prostego języka i ilustracji.', 'img/books/Tajemnice_Mikroswiata.png'),
(53, 'Nauka', 'Wielkie Eksperymenty Dla Małych Naukowców', 'Professor Curious', 'Naukowe Odkrycia', 2025, 160, 24.99, 'Professor Curious prezentuje serię prostych, ale edukacyjnych eksperymentów, które można przeprowadzać w domu. Książka skierowana jest do młodych naukowców, chcących zdobywać wiedzę poprzez zabawę.', 'img/books/Wielkie_Eksperymenty_Dla_Malych_Naukowcow.png'),
(54, 'Nauka', 'Wędrówka przez Dżunglę DNA', 'Gene Explorer', 'Genetyczne Odkrycia', 2023, 220, 31.99, 'Gene Explorer opowiada o fascynującej podróży przez dżunglę DNA, gdzie czytelnicy poznają tajemnice genetyki i dziedziczenia cech. Książka przedstawia trudne tematy w przystępny sposób, zachęcając do zrozumienia budowy życia.', 'img/books/Wedrowka_przez_Dzungla_DNA.png'),
(55, 'Nauka', 'Zapierające Mózg Zagadki Matematyczne', 'Math Maestro', 'Matematyczne Zagadki', 2024, 180, 27.99, 'Math Maestro prezentuje zbiór niezwykłych zagadek matematycznych, które sprawią, że czytelnicy będą myśleć kreatywnie i logicznie. Książka rozwija umiejętności matematyczne w sposób interaktywny i angażujący.', 'img/books/Zapierajace_Mozg_Zagadki_Matematyczne.png'),
(56, 'Nauka', 'Tajniki Ekosystemów', 'Eco Explorer', 'Przyrodnicze Odkrycia', 2025, 210, 32.99, 'Eco Explorer przedstawia tajniki różnorodnych ekosystemów na Ziemi, ukazując delikatną równowagę między roślinami, zwierzętami i środowiskiem. Książka inspiruje do ochrony przyrody i zrozumienia jej skomplikowanej struktury.', 'img/books/Tajniki_Ekosystemow.png'),
(57, 'Nauka', 'Podróże w Czasie: Historia Świata', 'Time Traveler', 'Przygodowe Odkrycia', 2023, 248, 36.99, 'Time Traveler przenosi czytelników w fascynującą podróż przez historię świata, opowiadając o kluczowych wydarzeniach i postaciach. Książka łączy w sobie wiedzę historyczną z elementami przygody, ucząc jednocześnie i bawiąc.', 'img/books/Podroze_w_Czasie_Historia_Swiata.png'),
(58, 'Nauka', 'Tajemnice Ludzkiego Ciała', 'Anatomy Explorer', 'Medyczne Odkrycia', 2024, 230, 33.99, 'Anatomy Explorer rzuca światło na tajemnice ludzkiego ciała, przedstawiając jego budowę i funkcje w sposób przystępny dla młodych czytelników. Książka stanowi fascynującą podróż po anatomii, z ilustracjami ukazującymi wewnętrzne struktury ciała.', 'img/books/Tajemnice_Ludzkiego_Ciala.png'),
(59, 'Nauka', 'Wielkie Odkrycia Geograficzne', 'Geography Voyager', 'Geograficzne Odkrycia', 2025, 200, 30.99, 'Geography Voyager opowiada o wielkich odkryciach geograficznych, które kształtowały oblicze świata. Książka przenosi czytelników w odległe podróże odkrywców, ukazując różnorodność kultur i krajobrazów.', 'img/books/Wielkie_Odkrycia_Geograficzne.png'),
(60, 'Nauka', 'Niesamowite Zjawiska Przyrodnicze', 'Nature Enigma', 'Przyrodnicze Zagadki', 2026, 190, 28.99, 'Nature Enigma ukazuje niesamowite zjawiska przyrodnicze na Ziemi, wyjaśniając naukowe podstawy tych fenomenów. Książka wzbogacona jest pięknymi ilustracjami, przedstawiającymi magię natury i jej niezwykłe zdolności.', 'img/books/Niesamowite_Zjawiska_Przyrodnicze.png'),
(61, 'Przygodowe', 'Skarb Piratów: Wyprawa W Zapomniane Wyspy', 'Captain Adventure', 'Morskie Opowieści', 2024, 280, 38.99, 'Captain Adventure zaprasza czytelników na ekscytującą wyprawę w poszukiwaniu legendarnego skarbu piratów ukrytego na Zapomnianej Wyspie. Czy bohaterowie zdołają pokonać niebezpieczeństwa i odkryć tajemnicze bogactwo?', 'img/books/Skarb_Piratow_Wyprawa_W_Zapomniane_Wyspy.png'),
(62, 'Przygodowe', 'Zaginione Miasto El Dorado', 'Explorer Jones', 'Archeologiczne Odkrycia', 2025, 310, 42.99, 'Explorer Jones wyrusza w niebezpieczną podróż przez nieodkryte dżungle Ameryki Południowej, by odnaleźć legendarne Zaginione Miasto El Dorado. Książka pełna jest tajemniczych łamigłówek i ekscytujących przygód.', 'img/books/Zaginione_Miasto_El_Dorado.png'),
(63, 'Przygodowe', 'Ostatni Smok: Przebudzenie', 'Dragon Seeker', 'Fantastyczne Opowieści', 2024, 290, 39.99, 'Dragon Seeker opowiada o ostatnim smoku, który budzi się po tysiącach lat snu. Młody bohater wyrusza w niebezpieczną podróż, by odnaleźć i ocalić ostatniego smoka przed zagładą. Czy uda mu się spełnić tę epicką misję?', 'img/books/Ostatni_Smok_Przebudzenie.png'),
(64, 'Przygodowe', 'Łowcy Skarbów: Tajemnica Zapomnianej Piramidy', 'Treasure Hunters', 'Przygodowe Wydawnictwo', 2025, 260, 36.99, 'Treasure Hunters to zespół nieustraszonych łowców skarbów, którzy wyruszają na poszukiwanie zaginionej piramidy pełnej ukrytych bogactw. Czy zdołają rozszyfrować starożytne tajemnice i pokonać pułapki?', 'img/books/Lowcy_Skarbow_Tajemnica_Zapomnianej_Piramidy.png'),
(65, 'Przygodowe', 'Safari Serca: Miłość W Dzikiej Przyrodzie', 'Wild Romance', 'Afrykańskie Opowieści', 2024, 240, 34.99, 'Wild Romance to wzruszająca opowieść o miłości, która rozkwita w sercu afrykańskiej przyrody. Bohaterowie przemierzają sawanny, tropikalne lasy i dzikie rzeki, odkrywając nie tylko piękno przyrody, ale także siebie nawzajem.', 'img/books/Safari_Serca_Milosc_W_Dzikiej_Przyrodzie.png'),
(66, 'Przygodowe', 'Skrytobójcy Cienia: Zmierzch Imperium', 'Shadow Assassin', 'Intrygujące Wydawnictwo', 2023, 300, 44.99, 'Shadow Assassin to historia tajemniczych skrytobójców, którzy stają w obliczu upadku potężnego imperium. Bohaterowie muszą pokonać nie tylko fizyczne przeciwności, ale także własne demony, by odwrócić losy świata. Czy zdołają przetrwać zmierzch imperium?', 'img/books/Skrytobojcy_Cienia_Zmierzch_Imperium.png'),
(67, 'Przygodowe', 'Dżungla Intryg: Tajemnica Zaginionej Wyprawy', 'Jungle Explorer', 'Egzotyczne Przygody', 2025, 270, 40.99, 'Jungle Explorer opowiada o tajemniczej wyprawie w głąb dzikiej dżungli, gdzie bohaterowie muszą stawić czoła nie tylko dzikim zwierzętom, ale także zdradzie i intrygom. Czy uda im się odnaleźć zaginioną wyprawę i odkryć jej sekrety?', 'img/books/Dzungla_Intryg_Tajemnica_Zaginionej_Wyprawy.png'),
(68, 'Przygodowe', 'Odkrywcy Nowego Świata: Wyprawa na Nieznane Kontyn', 'New World Explorers', 'Historyczne Ekspedycje', 2024, 250, 38.99, 'New World Explorers przenosi czytelników w czasy wielkich odkryć geograficznych, opowiadając o śmiałych podróżach odkrywców, którzy wyruszają na nieznane kontynenty. Książka pełna jest fascynujących opowieści o pokonywaniu oceanów i eksploracji nieznanego.', 'img/books/Odkrywcy_Nowego_Swiata_Wyprawa_na_Nieznane_Kontynenty.png'),
(69, 'Przygodowe', 'Wzgórza Tajemnic: Sztuka Przełamywania Granic', 'Hilltop Mysteries', 'Tajemnicze Rozwikłania', 2023, 230, 35.99, 'Hilltop Mysteries to seria opowieści o grupie młodych detektywów, którzy rozwiązują tajemnice ukryte w malowniczych wzgórzach. Każda książka to nowe wyzwanie, nowe zagadki i niezapomniane przygody.', 'img/books/Wzgorza_Tajemnic_Sztuka_Przelamywania_Granic.png'),
(70, 'Przygodowe', 'Żaglowce Ostatniej Nadziei: Wyprawa w Arktykę', 'Arctic Adventurers', 'Morskie Ekspedycje', 2025, 290, 41.99, 'Arctic Adventurers opowiada o odważnych żeglarzach, którzy podejmują wyzwanie żeglugi w lodowatych wodach Arktyki. Książka pełna jest niebezpieczeństw, niesamowitych widoków i przygód, które sprawią, że czytelnik poczuje szaleństwo arktycznej wyprawy.', 'img/books/Zaglowce_Ostatniej_Nadziei_Wyprawa_w_Arktyke.png'),
(71, 'Thriller', 'Kod Omega: Zaginione Archiwum', 'Mystery Master', 'Intrygujące Wydawnictwo', 2023, 320, 45.99, 'Mystery Master prezentuje zagadkowy thriller o tajemniczym archiwum, które zawiera informacje zdolne wstrząsnąć porządkami świata. Bohaterowie muszą rozszyfrować tajemniczy kod, zanim wpadnie on w niepowołane ręce.', 'img/books/Kod_Omega_Zaginione_Archiwum.png'),
(72, 'Thriller', 'Zamach: Gra o Władzę', 'Political Intrigue', 'Polityczne Intrygi', 2024, 310, 43.99, 'Political Intrigue przedstawia niebezpieczną grę o władzę, gdzie bohaterowie muszą odkryć spisek przeciwko rządowi. Akcja toczy się w świecie politycznych intryg, szantażu i zdrady.', 'img/books/Zamach_Gra_o_Wladze.png'),
(73, 'Thriller', 'Bezsenność: Kłamstwa Nocy', 'Sleepless Lies', 'Psychologiczne Napięcie', 2025, 280, 39.99, 'Sleepless Lies to psychologiczny thriller o tajemniczych bezsennościach, które popychają bohaterów na krawędź zdrowego rozsądku. Czy to wynik spisku czy tylko wytwór umysłu? Czytelnicy muszą przetrzeć oczy, by odkryć prawdę.', 'img/books/Bezsennosc_Klamstwa_Nocy.png'),
(74, 'Thriller', 'Sieć Kłamstw: Operacja Infiltracja', 'Infiltration Network', 'Agencja Szpiegowska', 2023, 330, 46.99, 'Infiltration Network przedstawia świat agencji szpiegowskiej, gdzie bohaterowie muszą rozpracować złożoną sieć kłamstw i intryg, zanim stanie się za późno. Książka pełna jest akcji, podsłuchów i nieoczekiwanych zwrotów akcji.', 'img/books/Siec_Klamstw_Operacja_Infiltracja.png'),
(75, 'Thriller', 'Zakazane Eksperymenty: Labirynt Zła', 'Forbidden Experiments', 'Naukowe Intrygi', 2024, 300, 44.99, 'Forbidden Experiments to thriller naukowy o tajemniczych eksperymentach, które prowadzą do stworzenia labiryntu zła. Bohaterowie muszą przeniknąć zakazaną strefę, by ujawnić prawdziwe cele projektu i powstrzymać niebezpieczeństwo przed uwolnieniem się.', 'img/books/Zakazane_Eksperymenty_Labirynt_Zla.png'),
(76, 'Thriller', 'Ostatnia Runda: Gra o Życie', 'Final Showdown', 'Psychologiczna Walka', 2025, 290, 42.99, 'Final Showdown opowiada o psychologicznej walce, w której bohaterowie muszą stawić czoła swoim najgłębszym lękom. Gra o życie staje się coraz bardziej niebezpieczna, a każda decyzja może być decydująca.', 'img/books/Ostatnia_Runda_Gra_o_Zycie.png'),
(77, 'Thriller', 'Cena Zemsty: Pakt Zabójcy', 'Vengeance Price', 'Zabójcze Intrygi', 2023, 310, 47.99, 'Vengeance Price to opowieść o mrocznym paku zabójcy, który musi wypełnić niebezpieczne zadanie zemsty. Czy bohater zdoła utrzymać równowagę między moralnością a pragnieniem zemsty? Thriller pełen emocji i niebezpieczeństwa.', 'img/books/Cena_Zemsty_Pakt_Zabojcy.png'),
(78, 'Thriller', 'Za Zamkniętymi Drzwiami: Tajemnica Sąsiada', 'Behind Closed Doors', 'Domowe Napięcia', 2024, 280, 40.99, 'Behind Closed Doors przedstawia tajemnicę ukrytą za zamkniętymi drzwiami, gdzie bohaterowie muszą odkryć, co naprawdę dzieje się w ich spokojnej dzielnicy. Thriller pełen intryg, zwrotów akcji i nieoczekiwanych zdarzeń.', 'img/books/Za_Zamknietymi_Drzwiemi_Tajemnica_Sasiada.png'),
(79, 'Thriller', 'Krwawy Koniec: Ostatnia Misja', 'Bloody End', 'Militarne Intrygi', 2025, 320, 45.99, 'Bloody End to historia ostatniej misji, gdzie bohaterowie muszą zmierzyć się z brutalną rzeczywistością wojny. Czy zdołają przetrwać i zrealizować cel misji, czy też stawią czoła krwawemu końcowi? Thriller pełen napięcia i dramatu.', 'img/books/Krwawy_Koniec_Ostatnia_Misja.png'),
(80, 'Thriller', 'Zakazane Geny: Tajemnica Laboratorium', 'Forbidden Genes', 'Genetyczne Intrygi', 2023, 290, 41.99, 'Forbidden Genes opowiada o zakazanych eksperymentach genetycznych, które prowadzą do tajemniczego laboratorium. Bohaterowie muszą odkryć prawdziwe cele projektu genetycznego, zanim niekontrolowane mutacje staną się globalnym zagrożeniem.', 'img/books/Zakazane_Geny_Tajemnica_Laboratorium.png'),
(81, 'Horror', 'Mroczne Wizje: Widmo Sanatorium', 'Nightmare Author', 'Niesamowite Horrory', 2024, 300, 42.99, 'Niesamowite Horrory prezentują Mroczne Wizje, gdzie bohaterowie przekraczają progi opuszczonego sanatorium, tylko po to, by stać się ofiarami złowrogich mocy. Czytelnicy odczują dreszcz grozy i tajemnicy tej opowieści.', 'img/books/Mroczne_Wizje_Widmo_Sanatorium.png'),
(82, 'Horror', 'Przeklęta Dziedziczka: Dom Umarłych', 'Cursed Heiress', 'Zaklęte Mroczne Opowieści', 2025, 310, 44.99, 'Zaklęte Mroczne Opowieści przedstawiają Przeklętą Dziedziczkę, która dziedziczy dom nawiedzony przez duchy przeszłości. Czy bohaterka zdoła rozwikłać rodzinne tajemnice i uwolnić się od klątwy Domu Umarłych?', 'img/books/Przekleta_Dziedziczka_Dom_Umarlych.png'),
(83, 'Horror', 'Zmierzch Widm: Opowieść o Nawiedzonym Mieście', 'Twilight Phantoms', 'Opowieści Grozy', 2023, 290, 41.99, 'Opowieści Grozy prezentują Zmierzch Widm, gdzie bohaterowie odkrywają mroczne sekrety nawiedzonego miasta. Czy przetrwają noc w miejscu, gdzie czasami lepiej nie zaglądać? Dreszcz emocji i niepewności gwarantowany.', 'img/books/Zmierzch_Widm_Opowiesc_o_Nawiedzonym_Miescie.png'),
(84, 'Horror', 'Bestia w Cieniu: Tajemnica Lasu', 'Beast in the Shadows', 'Mroczne Tajemnice', 2024, 320, 45.99, 'Mroczne Tajemnice przedstawiają Bestię w Cieniu, gdzie bohaterowie napotykają tajemniczą bestię, której obecność sprawia, że las staje się miejscem koszmaru. Czy potrafią przetrwać i odkryć tajemnicę Bestii w Cieniu?', 'img/books/Bestia_w_Cieniu_Tajemnica_Lasu.png'),
(85, 'Horror', 'Rytuał Krwi: Księga Czarnego Zaklęcia', 'Blood Ritual', 'Zakazane Rytuały', 2025, 300, 42.99, 'Zakazane Rytuały opowiadają o Rytuale Krwi, w którym bohaterowie muszą stawić czoła przerażającym zaklęciom i demonicznej obecności. Czy uda im się przerwać mroczny rytuał zanim stanie się za późno?', 'img/books/Rytual_Krwi_Ksiega_Czarnego_Zaklecia.png'),
(86, 'Horror', 'Ostatni Strach: Nawiedzony Dom', 'Final Fear', 'Nawiedzone Historie', 2023, 280, 39.99, 'Nawiedzone Historie przedstawiają Ostatni Strach, gdzie bohaterowie wchodzą do nawiedzonego domu, nieświadomi, że każdy krok zbliża ich do przerażającej prawdy. Czy zdołają przeżyć noc w Nawiedzonym Domu?', 'img/books/Ostatni_Strach_Nawiedzony_Dom.png'),
(87, 'Horror', 'Zagubieni w Ciemności: Labirynt Grozy', 'Lost in Darkness', 'Mroczne Przypadki', 2024, 310, 43.99, 'Mroczne Przypadki przedstawiają Zagubionych w Ciemności, gdzie bohaterowie eksplorują tajemniczy labirynt, gdzie każdy zakręt może prowadzić do śmierci. Czy zdołają znaleźć wyjście z Labiryntu Grozy?', 'img/books/Zagubieni_w_Ciemnosci_Labirynt_Grozy.png'),
(88, 'Horror', 'Zakazane Widmo: Nawiedzony Cmentarz', 'Forbidden Ghost', 'Mroczne Spotkania', 2025, 290, 41.99, 'Mroczne Spotkania przedstawiają Zakazane Widmo, gdzie bohaterowie odkrywają nawiedzony cmentarz, gdzie duchy z przeszłości wracają, by żądać zemsty. Czy przetrwają spotkanie z Zakazanym Widmem?', 'img/books/Zakazane_Widmo_Nawiedzony_Cmentarz.png'),
(89, 'Horror', 'Bezsenność: Widma Nocy', 'Insomnia', 'Niezwykłe Koszmary', 2023, 320, 45.99, 'Niezwykłe Koszmary przedstawiają Bezsenność, gdzie bohaterowie doświadczają niezwykłych koszmarów, które wydają się przenikać ze snu do rzeczywistości. Czy to tylko iluzja, czy może coś znacznie bardziej przerażającego?', 'img/books/Bezsennosc_Widma_Nocy.png'),
(90, 'Horror', 'Za Zasłoną Ciemności: Opowieść o Strachu', 'Behind the Curtain', 'Opowieści Horroru', 2024, 300, 42.99, 'Opowieści Horroru przedstawiają Za Zasłoną Ciemności, gdzie bohaterowie odkrywają przerażającą opowieść o strachu ukrytą za zasłoną niewidzialnego zła. Czy zdołają rzucić światło na mroczne tajemnice?', 'img/books/Za_Zaslona_Ciemnosci_Opowiesc_o_Strachu.png'),
(91, 'Biografia', 'Pod Niebem Afryki: Życie Karen Blixen', 'Eva Biography', 'Wielkie Opowieści Biograficzne', 2024, 350, 47.99, 'Wielkie Opowieści Biograficzne przedstawiają fascynującą biografię Karen Blixen, autorki \"Afrykańskiego Skauta\". Poznaj niezwykłe życie tej silnej kobiety, podróżującej po dzikiej krainie Afryki, konfrontującej się z życiowymi wyzwaniami i tworzącej niezapomniane dzieła literatury.', 'img/books/Pod_Niebem_Afryki_Zycie_Karen_Blixen.png'),
(92, 'Biografia', 'Genialny Umysł: Życie Alberta Einsteina', 'Discovering Genius', 'Wielcy Naukowcy', 2025, 380, 49.99, 'Wielcy Naukowcy prezentują fascynującą biografię Alberta Einsteina - geniusza nauki, laureata Nagrody Nobla i twórcy teorii względności. Odkryj nie tylko jego naukowe dokonania, ale także burzliwe życie prywatne, które wpłynęło na kształtowanie się jednego z największych umysłów w historii.', 'img/books/Genialny_Umysl_Zycie_Alberta_Einsteina.png'),
(93, 'Biografia', 'Czerwony Spartakus: Życie i Działalność Róży Lukse', 'Rebel Rose', 'Historie Niezłomnych', 2023, 320, 45.99, 'Historie Niezłomnych przedstawiają życie Róży Luksemburg - polskiej marksistki, teoretyczki rewolucji i aktywistki społecznej. Odkryj jej niezłomną walkę o prawa ludzi pracy, zaangażowanie w rewolucję oraz tragiczne zakończenie jej życiowej misji.', 'img/books/Czerwony_Spartakus_Zycie_Rozy_Luksemburg.png'),
(94, 'Biografia', 'Kobiecy Orzeł: Życie Amelia Earhart', 'Aviation Pioneer', 'Wielcy Pionierzy Lotnictwa', 2024, 340, 48.99, 'Wielcy Pionierzy Lotnictwa przedstawiają życie Amelii Earhart - jednej z pierwszych kobiet-pilotów i pionierki lotnictwa. Odkryj jej nieustraszoną determinację, zdolności lotnicze i tajemnicze zniknięcie podczas próby okrążenia ziemi. Czytaj o jej odważnej przygodzie i dziedzictwie, które trwa do dziś.', 'img/books/Kobiecy_Orzel_Zycie_Amelii_Earhart.png'),
(95, 'Biografia', 'Pierwsza Dama: Życie Eleanor Roosevelt', 'Leading Lady', 'Wielkie Kobiety Historii', 2025, 360, 46.99, 'Wielkie Kobiety Historii prezentują życie Eleanor Roosevelt - jednej z najbardziej wpływowych Pierwszych Dam w historii Stanów Zjednoczonych. Poznaj jej zaangażowanie w prawa obywatelskie, działalność dyplomatyczną i wpływ na kształtowanie się współczesnej roli Pierwszych Dam.', 'img/books/Pierwsza_Dama_Zycie_Eleanor_Roosevelt.png'),
(96, 'Biografia', 'Wieża Talentów: Życie Steve a Jobsa', 'Tech Visionary', 'Wizjonerzy Technologii', 2023, 330, 47.99, 'Wizjonerzy Technologii przedstawiają życie Steve a Jobsa - współzałożyciela Apple, wizjonera technologii i kreatywnego geniusza. Odkryj jego niekonwencjonalne podejście do biznesu, rewolucyjne wynalazki i dziedzictwo, które kształtuje świat technologii.', 'img/books/Wieza_Talentow_Zycie_Stevea_Jobsa.png'),
(97, 'Biografia', 'Zawsze Wierni: Życie Jana Pawła II', 'Holy Journey', 'Święci Na Ziemi', 2024, 350, 48.99, 'Święci Na Ziemi przedstawiają życie Jana Pawła II - jednego z najważniejszych papieży w historii Kościoła Katolickiego. Poznaj jego duchową podróż, misję pojednawczą i wpływ na kształtowanie się współczesnej katolickiej wiary.', 'img/books/Zawsze_Wierni_Zycie_Jana_Pawla_II.png'),
(98, 'Biografia', 'Nieukrojony: Życie Malali Yousafzai', 'Courageous Voice', 'Inspirujące Historie Młodych Bohaterów', 2025, 340, 46.99, 'Inspirujące Historie Młodych Bohaterów przedstawiają życie Malali Yousafzai - pakistańskiej obrończyni praw kobiet i edukacji, laureatki Pokojowej Nagrody Nobla. Odkryj jej odwagę w stawianiu czoła przeciwnościom i jej determinację w walce o prawa dziewcząt do nauki.', 'img/books/Nieukrojony_Zycie_Malali_Yousafzai.png'),
(99, 'Biografia', 'Melodia Duszy: Życie Ludwiga van Beethovena', 'Symphony Maestro', 'Wielcy Kompozytorzy', 2023, 330, 47.99, 'Wielcy Kompozytorzy przedstawiają życie Ludwiga van Beethovena - jednego z najwybitniejszych kompozytorów w historii muzyki klasycznej. Odkryj jego twórczość muzyczną, walkę z głuchotą i wpływ na rozwój symfonii i sonat.', 'img/books/Melodia_Duszy_Zycie_Ludwiga_van_Beethovena.png');
INSERT INTO `books` (`id`, `category`, `title`, `author`, `publisher`, `year`, `pages`, `price`, `description`, `img`) VALUES
(100, 'Biografia', 'Wzrok Przyszłości: Życie Hellen Keller', 'Unconquered Spirit', 'Niezwyciężone Dusze', 2024, 340, 49.99, 'Niezwyciężone Dusze przedstawiają życie Hellen Keller - amerykańskiej autorki, aktywistki społecznej i pierwszej głuchej i niemej osoby, która uzyskała tytuł naukowy. Poznaj jej niezłomną determinację, zdolności literackie i walkę o prawa osób niepełnosprawnych.', 'img/books/Wzrok_Przyszlosci_Zycie_Hellen_Keller.png');

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
(6, 1, 'Kluczborska', '15', '21-371', 'Warszawa'),
(6, 1, 'Kluczborska', '16', '21-371', 'Warszawa');

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
(6, 1, '2023-12-01', 129.97, 'Oczekujący'),
(7, 0, '2023-12-03', 344.93, 'Oczekujący'),
(8, 0, '2023-12-03', 54.99, 'Oczekujący'),
(9, 0, '2023-12-03', 59.99, 'Oczekujący'),
(10, 0, '2023-12-03', 49.99, 'Oczekujący'),
(11, 0, '2023-12-03', 99.98, 'Oczekujący'),
(12, 0, '2023-12-03', 38.99, 'Oczekujący'),
(13, 0, '2023-12-03', 49.99, 'Oczekujący'),
(14, 0, '2023-12-03', 45.99, 'Oczekujący'),
(15, 1, '2023-12-03', 44.99, 'Oczekujący'),
(16, 1, '2023-12-03', 44.99, 'Oczekujący'),
(17, 5, '2023-12-03', 104.98, 'Oczekujący'),
(18, 5, '2023-12-03', 49.99, 'Oczekujący');

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
(2, 6, 2, 1, 49.99, 49.99),
(3, 7, 3, 1, 44.99, 44.99),
(4, 7, 5, 2, 49.99, 99.98),
(5, 7, 15, 4, 49.99, 199.96),
(6, 8, 4, 1, 54.99, 54.99),
(7, 9, 6, 1, 59.99, 59.99),
(8, 10, 5, 1, 49.99, 49.99),
(9, 11, 2, 2, 49.99, 99.98),
(10, 12, 9, 1, 38.99, 38.99),
(11, 13, 2, 1, 49.99, 49.99),
(12, 14, 7, 1, 45.99, 45.99),
(13, 15, 3, 1, 44.99, 44.99),
(14, 16, 3, 1, 44.99, 44.99),
(15, 17, 3, 1, 44.99, 44.99),
(16, 17, 6, 1, 59.99, 59.99),
(17, 18, 2, 1, 49.99, 49.99);

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
(4, 'admin', 'admin', 'admin', 'admin@bookstore.com', '$2y$10$AXSSDcwr9UbusMpYvaOCUuakYMaEe2d2UwxLs9ZuatOuYYWOepFl.'),
(5, 'Hamu', 'Paweł', 'Hamuda', 'Paw@gmail.com', '$2y$10$R723iwyumdBGQIgMJRZ2O.f0Z0.2EroJ8w907Xwk6S4s0tJ.S1iCK');

--
-- Indeksy dla zrzutów tabel
--

--
-- Indeksy dla tabeli `adresses`
--
ALTER TABLE `adresses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`) USING BTREE;

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
-- Indeksy dla tabeli `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT dla zrzuconych tabel
--

--
-- AUTO_INCREMENT dla tabeli `books`
--
ALTER TABLE `books`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=101;

--
-- AUTO_INCREMENT dla tabeli `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT dla tabeli `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT dla tabeli `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

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
