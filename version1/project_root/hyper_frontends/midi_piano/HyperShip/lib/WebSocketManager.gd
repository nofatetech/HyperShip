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
	# Add protocol path if not present
	#if not websocket_url.ends_with("/piano"):
		#websocket_url = websocket_url + "/piano"

# Attempt to connect to the WebSocket server
func connect_to_server() -> void:
	if is_connecting:
		print("[WebSocket] ⚠️ Already connecting, skipping...")
		return
		
	print("[WebSocket] 🔌 Attempting to connect to ", websocket_url)
	
	# Clean up any existing connection
	if socket:
		print("[WebSocket] 🧹 Cleaning up existing connection...")
		socket.close()
		socket = null
		is_connecting = false
	
	# Create new WebSocket connection
	socket = WebSocketPeer.new()
	
	# Add a small delay before connecting
	await get_tree().create_timer(0.5).timeout
	
	# Connect to the server
	var err = socket.connect_to_url(websocket_url)
	if err != OK:
		print("[WebSocket] ❌ Failed to initiate connection. Error code: ", err)
		is_connecting = false
		return
	
	is_connecting = true
	print("[WebSocket] 🔄 Connection initiated, waiting for state change...")
	
	# Wait for connection with timeout
	var timeout = 5.0  # 5 second timeout
	var last_state = -1
	var poll_count = 0
	
	while timeout > 0:
		# Poll the socket
		socket.poll()
		poll_count += 1
		
		var state = socket.get_ready_state()
		
		# Log state changes and periodic updates
		if state != last_state or poll_count % 10 == 0:
			print("[WebSocket] 📊 State: ", _get_state_name(state), " Timeout: ", timeout, " Polls: ", poll_count)
			last_state = state
		
		match state:
			WebSocketPeer.STATE_OPEN:
				print("[WebSocket] ✅ Connected successfully!")
				is_connecting = false
				reconnect_attempts = 0  # Reset reconnect attempts on success
				emit_signal("connected")
				return
			WebSocketPeer.STATE_CLOSED:
				var code = socket.get_close_code()
				var reason = socket.get_close_reason()
				print("[WebSocket] ❌ Connection closed. Code: ", code, " Reason: ", reason)
				is_connecting = false
				emit_signal("connection_error")
				return
			WebSocketPeer.STATE_CONNECTING:
				if poll_count % 10 == 0:
					print("[WebSocket] ⏳ Still connecting... Timeout: ", timeout)
		
		timeout -= 0.1
		await get_tree().create_timer(0.1).timeout
	
	print("[WebSocket] ❌ Connection timeout to ", websocket_url, ". Final state: ", _get_state_name(last_state))
	print("[WebSocket] 📊 Total polls: ", poll_count)
	is_connecting = false
	emit_signal("connection_error")

# Helper function to get state name
func _get_state_name(state: int) -> String:
	match state:
		WebSocketPeer.STATE_OPEN:
			return "OPEN"
		WebSocketPeer.STATE_CLOSING:
			return "CLOSING"
		WebSocketPeer.STATE_CLOSED:
			return "CLOSED"
		WebSocketPeer.STATE_CONNECTING:
			return "CONNECTING"
		_:
			return "UNKNOWN"

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
					print("[WebSocket] ⚠️ Received invalid JSON data")
		
		WebSocketPeer.STATE_CLOSING:
			print("[WebSocket] 🔄 Connection is closing...")
			# Wait for clean close
			pass
		
		WebSocketPeer.STATE_CLOSED:
			var code = socket.get_close_code()
			var reason = socket.get_close_reason()
			var was_clean = code != -1
			print("[WebSocket] 🔌 Connection closed - Code: %d, Clean: %s, Reason: %s" % [code, was_clean, reason])
			emit_signal("disconnected", code, reason, was_clean)
			set_process(false)
			
			# Only attempt to reconnect if we're not already connecting
			if not is_connecting and reconnect_attempts < MAX_RECONNECT_ATTEMPTS:
				reconnect_attempts += 1
				print("[WebSocket] 🔄 Attempting to reconnect (%d/%d)..." % [reconnect_attempts, MAX_RECONNECT_ATTEMPTS])
				await get_tree().create_timer(2.0).timeout
				connect_to_server()
			else:
				print("[WebSocket] ❌ Max reconnection attempts reached or already connecting")

# Send a message to the server
func send_message(data: Dictionary) -> bool:
	if socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		print("[WebSocket] ❌ Cannot send message: WebSocket not connected")
		return false
	
	var json_string = JSON.stringify(data)
	var err = socket.send_text(json_string)
	if err != OK:
		print("[WebSocket] ❌ Failed to send message. Error code: ", err)
		return false
	return true

# Close the connection
func close_connection():
	if socket and socket.get_ready_state() != WebSocketPeer.STATE_CLOSED:
		socket.close()
		set_process(false)
