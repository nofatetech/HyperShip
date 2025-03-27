# /lib/websocket_manager.gd
extends Node
class_name WebSocketManager

# Signals to broadcast WebSocket events
signal connected
signal connection_error(error_message: String)
signal data_received(data: Dictionary)
signal disconnected(code: int, reason: String, was_clean: bool)
signal connection_state_changed(state: int)

# WebSocket client and URL properties
var socket = WebSocketPeer.new()
var websocket_url: String
var is_connecting := false
var reconnect_attempts := 0
const MAX_RECONNECT_ATTEMPTS := 3

# Connect WebSocket signals to functions for handling events
func setup(url: String):
	websocket_url = url
	if not url.begins_with("ws://") and not url.begins_with("wss://"):
		websocket_url = "ws://" + url

# Initiate a connection to the WebSocket server
func connect_to_server():
	if is_connecting:
		return
		
	is_connecting = true
	print("Connecting to WebSocket server: ", websocket_url)
	
	var err = socket.connect_to_url(websocket_url)
	if err != OK:
		var error_message = "Unable to connect to %s. Error code: %d" % [websocket_url, err]
		print(error_message)
		emit_signal("connection_error", error_message)
		is_connecting = false
		return
	
	# Start processing to handle the connection
	set_process(true)
	
	# Wait for the socket to connect with timeout
	var timeout = 5.0
	while timeout > 0 and socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		await get_tree().create_timer(0.1).timeout
		timeout -= 0.1
	
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		print("Successfully connected to WebSocket server")
		reconnect_attempts = 0
		emit_signal("connected")
	else:
		emit_signal("connection_error", "Connection timeout")
	
	is_connecting = false

# Reconnect to WebSocket with a new URL or token
func reconnect(new_url: String = ""):
	if new_url != "":
		websocket_url = new_url
		if not websocket_url.begins_with("ws://") and not websocket_url.begins_with("wss://"):
			websocket_url = "ws://" + websocket_url
	
	if reconnect_attempts >= MAX_RECONNECT_ATTEMPTS:
		emit_signal("connection_error", "Max reconnection attempts reached")
		return
	
	reconnect_attempts += 1
	print("Reconnecting... Attempt %d of %d" % [reconnect_attempts, MAX_RECONNECT_ATTEMPTS])
	
	if socket.get_ready_state() != WebSocketPeer.STATE_CLOSED:
		socket.close()
	
	connect_to_server()

# Poll WebSocket to check for incoming messages and handle connections
func _process(delta):
	if not socket:
		return
		
	socket.poll()
	var state = socket.get_ready_state()
	
	# Emit state change signal
	emit_signal("connection_state_changed", state)
	
	match state:
		WebSocketPeer.STATE_OPEN:
			while socket.get_available_packet_count():
				var packet = socket.get_packet()
				var data = JSON.parse_string(packet.get_string_from_utf8())
				if data:
					emit_signal("data_received", data)
				else:
					print("Received invalid JSON data")
		
		WebSocketPeer.STATE_CLOSING:
			# Wait for clean close
			pass
		
		WebSocketPeer.STATE_CLOSED:
			var code = socket.get_close_code()
			var reason = socket.get_close_reason()
			var was_clean = code != -1
			print("WebSocket closed with code: %d. Clean: %s. Reason: %s" % [code, was_clean, reason])
			emit_signal("disconnected", code, reason, was_clean)
			set_process(false)

# Send a message to the server
func send_message(data: Dictionary) -> bool:
	if socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		print("Cannot send message: WebSocket not connected")
		return false
	
	var json_string = JSON.stringify(data)
	var err = socket.send_text(json_string)
	if err != OK:
		print("Failed to send message. Error code: ", err)
		return false
	return true

# Close the connection
func close_connection():
	if socket and socket.get_ready_state() != WebSocketPeer.STATE_CLOSED:
		socket.close()
		set_process(false)
