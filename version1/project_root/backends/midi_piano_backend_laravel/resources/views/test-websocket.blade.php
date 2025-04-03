<!DOCTYPE html>
<html>
<head>
    <title>WebSocket Test</title>
    <meta name="auth-token" content="{{ $token }}">
    <script>
        let ws = null;
        let reconnectAttempts = 0;
        const maxReconnectAttempts = 5;
        let isAuthenticated = false;

        function connectWebSocket() {
            try {
                ws = new WebSocket('ws://127.0.0.1:6001');

                ws.onopen = function() {
                    console.log('Connected to WebSocket server');
                    reconnectAttempts = 0;
                    document.getElementById('status').textContent = 'Connected';
                    document.getElementById('status').style.color = 'green';
                    
                    // Authenticate after connection
                    authenticate();
                };

                ws.onmessage = function(event) {
                    console.log('Received message:', event.data);
                    const data = JSON.parse(event.data);
                    
                    if (data.type === 'success') {
                        isAuthenticated = true;
                        document.getElementById('status').textContent = 'Authenticated';
                        document.getElementById('status').style.color = 'green';
                    } else if (data.type === 'error') {
                        isAuthenticated = false;
                        document.getElementById('status').textContent = 'Authentication failed: ' + data.message;
                        document.getElementById('status').style.color = 'red';
                    } else {
                        document.getElementById('events').innerHTML += `<div>${event.data}</div>`;
                    }
                };

                ws.onclose = function() {
                    console.log('Disconnected from WebSocket server');
                    isAuthenticated = false;
                    document.getElementById('status').textContent = 'Disconnected';
                    document.getElementById('status').style.color = 'red';
                    
                    // Attempt to reconnect
                    if (reconnectAttempts < maxReconnectAttempts) {
                        reconnectAttempts++;
                        console.log(`Attempting to reconnect (${reconnectAttempts}/${maxReconnectAttempts})...`);
                        setTimeout(connectWebSocket, 2000);
                    } else {
                        console.error('Max reconnection attempts reached');
                        document.getElementById('status').textContent = 'Connection failed';
                        document.getElementById('status').style.color = 'red';
                    }
                };

                ws.onerror = function(error) {
                    console.error('WebSocket error:', error);
                    isAuthenticated = false;
                    document.getElementById('status').textContent = 'Error';
                    document.getElementById('status').style.color = 'red';
                };
            } catch (error) {
                console.error('Failed to create WebSocket:', error);
                document.getElementById('status').textContent = 'Connection error';
                document.getElementById('status').style.color = 'red';
            }
        }

        function authenticate() {
            if (!ws || ws.readyState !== WebSocket.OPEN) {
                console.error('WebSocket is not connected');
                return;
            }

            // Get the authentication token from the meta tag
            const token = document.querySelector('meta[name="auth-token"]').content;
            
            const authMessage = {
                type: 'auth',
                token: token
            };
            
            ws.send(JSON.stringify(authMessage));
        }

        // Connect when page loads
        connectWebSocket();

        // Function to send a test note
        function sendTestNote() {
            if (!ws || ws.readyState !== WebSocket.OPEN) {
                console.error('WebSocket is not connected');
                return;
            }

            if (!isAuthenticated) {
                console.error('Not authenticated');
                return;
            }

            const data = {
                note: 60,
                velocity: 100,
                timestamp: Date.now() / 1000
            };
            
            ws.send(JSON.stringify(data));
            
            // Also send to API endpoint
            fetch('/api/piano/play', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                    'Authorization': 'Bearer ' + document.querySelector('meta[name="auth-token"]').content
                },
                body: JSON.stringify(data)
            })
            .then(response => response.json())
            .then(data => console.log('Success:', data))
            .catch((error) => console.error('Error:', error));
        }

        // Function to manually reconnect
        function reconnect() {
            if (ws) {
                ws.close();
            }
            reconnectAttempts = 0;
            connectWebSocket();
        }
    </script>
    <style>
        #status {
            font-weight: bold;
            margin: 10px 0;
        }
        #events {
            margin-top: 20px;
            max-height: 400px;
            overflow-y: auto;
            border: 1px solid #ccc;
            padding: 10px;
        }
    </style>
</head>
<body>
    <h1>WebSocket Test Page</h1>
    <div id="status">Connecting...</div>
    <button onclick="sendTestNote()">Send Test Note</button>
    <button onclick="reconnect()">Reconnect</button>
    <div id="events"></div>
</body>
</html>
