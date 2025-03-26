# /lib/websocket_manager.gd
extends Node
class_name WebSocketManager

# Signals to broadcast WebSocket events
signal connected
signal connection_error
signal data_received(data)
signal disconnected(code, reason, was_clean)

# WebSocket client and URL properties
var socket = WebSocketPeer.new()
var websocket_url: String

# Connect WebSocket signals to functions for handling events
func setup(url: String):
	websocket_url = url


# Initiate a connection to the WebSocket server
func connect_to_server():
	print("connect_to_server!")
	var err = socket.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect: ", websocket_url)
		emit_signal("connection_error")
		set_process(false)
	else:
		# Wait for the socket to connect.
		await get_tree().create_timer(2).timeout
		
		emit_signal("connected")

		## Send data.
		#socket.send_text("Test packet")

# Reconnect to WebSocket with a new URL or token
func reconnect(new_url: String):
	print("RECONNECT!!! ", new_url)
	if socket.get_connected_host() != null:
		socket.close()
	websocket_url = new_url
	connect_to_server()


# Poll WebSocket to check for incoming messages and handle connections
func _process(delta):
	# Call this in _process or _physics_process. Data transfer and state updates
	# will only happen when calling this function.
	socket.poll()

	# get_ready_state() tells you what state the socket is in.
	var state = socket.get_ready_state()

	# WebSocketPeer.STATE_OPEN means the socket is connected and ready
	# to send and receive data.
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			print("Got data from server: ", socket.get_packet().get_string_from_utf8())

	# WebSocketPeer.STATE_CLOSING means the socket is closing.
	# It is important to keep polling for a clean close.
	elif state == WebSocketPeer.STATE_CLOSING:
		pass

	# WebSocketPeer.STATE_CLOSED means the connection has fully closed.
	# It is now safe to stop polling.
	elif state == WebSocketPeer.STATE_CLOSED:
		# The code will be -1 if the disconnection was not properly notified by the remote peer.
		var code = socket.get_close_code()
		print("WebSocket closed with code: %d. Clean: %s" % [code, code != -1])
		set_process(false) # Stop processing.


# Send a message to the server
func send_message(data: Dictionary):
	#socket.send_text("Test packet")
	socket.send_text(JSON.stringify(data))
	#if websocket.get_connection_status() == WebSocketPeer.STATE_OPEN:
		#var message = JSON.stringify(data)
		#websocket.get_peer(1).put_packet(message.to_utf8())
	#else:
		#print("WebSocket not connected; cannot send message.")
