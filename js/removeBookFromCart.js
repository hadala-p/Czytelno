// Pobierz wszystkie przyciski "Usuñ"
const removeButtons = document.querySelectorAll('.remove-button');

// Obs³u¿ klikniêcie przycisku "Usuñ" dla ka¿dej ksi¹¿ki w koszyku
removeButtons.forEach(button => {
    button.addEventListener('click', () => {
        // Pobierz identyfikator ksi¹¿ki z atrybutu data
        const bookId = button.getAttribute('data-book-id');

        // Wyœlij identyfikator ksi¹¿ki do PHP za pomoc¹ zapytania AJAX
        fetch('cart_functions.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'book_id=' + bookId,
        })
        .then(response => {

            location.reload(); // odœwie¿ strone
        })
        .catch(error => {
            console.error('B³¹d AJAX:', error);
        });
    });
});