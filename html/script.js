let popup = document.getElementsByClassName('popup')[0];
let input = document.getElementsByClassName('popup-input')[0];
let title = document.getElementsByClassName('popup-title')[0];

// Handler to show the popup
window.addEventListener('message', (event) => {
    let data = event.data;
    if (data.show) {
        popup.style.display = 'block';
        input.focus();
        title.innerText = data.title || 'Input your data:';
        input.value = '';
        input.maxLength = data.maxlength || 100;
        input.dataset.requestId = data.request; // Store request ID for later use

        // Set input type
        switch (data.type) {
            case 'number':
                input.type = 'number';
                break;
            case 'small_text':
                input.type = 'text';
                input.style.height = '50px';
                break;
            default:
                input.type = 'text';
        }
    } else if (data.hide) {
        popup.style.display = 'none';
    }
});

// Handle user keypresses for "Escape" and "Enter"
window.addEventListener('keydown', (event) => {
    if (popup.style.display === 'block') {

        if (event.key === 'Escape') {
            fetch(`http://${GetParentResourceName()}/response`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ request: -1 }) // -1 signifies cancellation
            });
            popup.style.display = 'none';
        } else if (event.key === 'Enter') {
            fetch(`http://${GetParentResourceName()}/response`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    request: parseInt(input.dataset.requestId, 10),
                    value: input.value
                })
            });
            popup.style.display = 'none';
        }
    }
});
