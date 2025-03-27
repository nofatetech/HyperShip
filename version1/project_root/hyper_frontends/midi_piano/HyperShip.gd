extends Node2D
var websocket_manager: WebSocketManager

@onready var xauth = $AuthManager
@onready var piano = get_parent()  # HyperShip is a child of Piano node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize WebSocketManager
	websocket_manager = $WebSocketManager
	websocket_manager.setup("ws://127.0.0.1:6001")
	
	# Connect WebSocket signals to HyperShip handlers
	websocket_manager.connect("connected", _on_websocket_connected)
	websocket_manager.connect("connection_error", _on_websocket_connection_error)
	websocket_manager.connect("data_received", _on_websocket_data_received)
	websocket_manager.connect("disconnected", _on_websocket_disconnected)
	
	# Wait for the next frame to ensure Piano is ready
	await get_tree().process_frame
	
	# Connect WebSocket signals to Piano handlers
	if piano:
		print("Found Piano node, connecting signals...")
		websocket_manager.connect("connected", piano._on_websocket_connected)
		websocket_manager.connect("connection_error", piano._on_websocket_error)
		websocket_manager.connect("data_received", piano._on_websocket_data_received)
		websocket_manager.connect("disconnected", piano._on_websocket_disconnected)
		websocket_manager.connect("connection_state_changed", piano._on_connection_state_changed)
	else:
		print("Warning: Piano node not found! Node path: ", get_parent().get_path())
	
	# Connect immediately without waiting for authentication
	print("[WebSocket] Attempting immediate connection...")
	websocket_manager.connect_to_server()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#region AUTH
func _on_is_authenticated_completed(_result, _response_code, _headers, _body):
	print("_on_is_authenticated_completed: ", _response_code)
	if _response_code == 200:  # Success response
		var json = JSON.new()
		var error = json.parse(_body.get_string_from_utf8())
		if error == OK:
			var tdata = json.data
			# Send authentication success message
			websocket_manager.send_message({"type": "auth", "status": "success"})
	else:
		print("NOT AUTHENTICATED")
		websocket_manager.send_message({"type": "auth", "status": "failed"})

#endregion AUTH

#region WEBSOCKETS

# Event Handlers
func _on_websocket_connected():
	print("Connected to WebSocket server.")
	# Send a test message
	websocket_manager.send_message({"message": "Hello, Server!"})

func _on_websocket_connection_error():
	print("Failed to connect to WebSocket server.")

func _on_websocket_data_received(data):
	print("Data received from server:", data)

func _on_websocket_disconnected(code, reason, was_clean):
	print("Disconnected from WebSocket server. Code:", code, "Reason:", reason)

#endregion WEBSOCKETS
