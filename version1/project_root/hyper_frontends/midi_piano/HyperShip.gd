extends Node2D
var websocket_manager: WebSocketManager

@onready var xauth = $AuthManager


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	#xauth.setup("ws://127.0.0.1:3000/cable")
	xauth.is_authenticated(_on_is_authenticated_completed)


	# Initialize WebSocketManager with your server's URL
	#websocket_manager = WebSocketManager.new()
	websocket_manager = $WebSocketManager
	#	
	#websocket_manager.setup(WEBSOCKET_URL) # ("ws://127.0.0.1:3000/cable")
	websocket_manager.setup("ws://127.0.0.1:3000/cable?token=123123")
	#
	# Connect signals to handle WebSocket events
	websocket_manager.connect("connected", _on_websocket_connected)
	websocket_manager.connect("connection_error", _on_websocket_connection_error)
	websocket_manager.connect("data_received", _on_websocket_data_received)
	websocket_manager.connect("disconnected", _on_websocket_disconnected)
	#
	websocket_manager.connect_to_server()

	pass # Replace with function body.




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
	else:
		print("NOT AUTHENTICATED")

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
