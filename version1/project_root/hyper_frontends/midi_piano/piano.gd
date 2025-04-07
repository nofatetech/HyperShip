extends Control

# A standard piano with 88 keys has keys from 21 to 108.
# To get a different set of keys, modify these numbers.
# A maximally extended 108-key piano goes from 12 to 119.
# A 76-key piano goes from 23 to 98, 61-key from 36 to 96,
# 49-key from 36 to 84, 37-key from 41 to 77, and 25-key
# from 48 to 72. Middle C is pitch number 60, A440 is 69.
const START_KEY = 48 # 21
const END_KEY = 108 #72 # 108

const WhiteKeyScene = preload("res://piano_keys/white_piano_key.tscn")
const BlackKeyScene = preload("res://piano_keys/black_piano_key.tscn")
const FallingCircleScene = preload("res://falling_circle.tscn")

var piano_key_dict := Dictionary()
var websocket_manager: WebSocketManager
var received_notes_grid: GridContainer
var username: String = ""
var state_check_timer: Timer

@onready var white_keys = $Container/WhiteKeys
@onready var black_keys = $Container/BlackKeys
@onready var username_input = $HBoxContainer/TextEdit
@onready var play_button = $HBoxContainer/Button
@onready var connection_status = $HBoxContainer/ConnectionStatus

@onready var hypership = $HyperShip



func _ready():


	# auth
	
	# Example UI button connections (assuming you have these buttons in your scene)
	#$HBoxContainer/Login.pressed.connect(_on_login_button_pressed)
	#$LogoutButton.pressed.connect(_on_logout_button_pressed)
	#$TestApiButton.pressed.connect(_on_test_api_button_pressed)
	
	hypership.auth_manager.connect("login_completed", _on_login_completed)





	# Create state check timer
	state_check_timer = Timer.new()
	state_check_timer.wait_time = 1.0  # Check every second
	state_check_timer.timeout.connect(_check_websocket_state)
	add_child(state_check_timer)
	#state_check_timer.start()
	#!!! XXX 
	
	# Get reference to WebSocket manager
	websocket_manager = hypership.websocket_manager
	connection_status.text = "Disconnected"


	#WEBSOCKET !!
	#websocket_manager.setup("ws://127.0.0.1:6001")
	#websocket_manager.is_enabled = true
	#websocket_manager.connect("connected", _on_websocket_connected)
	#websocket_manager.connect("disconnected", _on_websocket_disconnected)
	#websocket_manager.connect("data_received", _on_websocket_data_received)
	#websocket_manager.connect("connection_error", _on_websocket_connection_error)
	#websocket_manager.connect("connection_state_changed", _on_websocket_connection_state_changed)
	#websocket_manager.connect_to_server()
#
	#connection_status.text = "Connecting..."
	#connection_status.modulate = Color(1, 1, 0)  # Yellow

	# Sanity checks.
	if _is_note_index_sharp(_pitch_index_to_note_index(START_KEY)):
		printerr("The start key can't be a sharp note (limitation of this piano-generating algorithm). Try 21.")
		return

	for i in range(START_KEY, END_KEY + 1):
		piano_key_dict[i] = _create_piano_key(i)

	if white_keys.get_child_count() != black_keys.get_child_count():
		_add_placeholder_key(black_keys)
	

	# Setup UI
	play_button.connect("pressed", _on_play_button_pressed)
	
	OS.open_midi_inputs()
	print(OS.get_connected_midi_inputs())

	# Check for URL parameters
	if OS.has_feature("web"):
		
		var tk = hypership.get_url_param("tk")
		print("tk from URL:", tk)

func _check_websocket_state():
	if not websocket_manager or not websocket_manager.socket:
		_handle_disconnected_state()
		return
		
	var state = websocket_manager.socket.get_ready_state()
	if state != WebSocketPeer.STATE_OPEN:
		_handle_disconnected_state()
		return
		
	# If we're supposed to be connected but haven't received data in a while,
	# try sending a ping to check the connection
	if state == WebSocketPeer.STATE_OPEN:
		var message = {
			"type": "ping",
			"timestamp": Time.get_unix_time_from_system()
		}
		websocket_manager.send_message(message)

func _handle_disconnected_state():
	print("[Piano] 🔍 Detected disconnected state during periodic check")
	play_button.disabled = false
	username_input.editable = true
	connection_status.text = "Disconnected"
	connection_status.modulate = Color(1, 0, 0)  # Red
	
	# Attempt to reconnect
	await get_tree().create_timer(2.0).timeout
	if not websocket_manager.socket or websocket_manager.socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		print("[Piano] 🔄 Attempting to reconnect...")
		connection_status.text = "Reconnecting..."
		connection_status.modulate = Color(1, 1, 0)  # Yellow
		websocket_manager.connect_to_server()

func _on_websocket_connection_state_changed(state: int):
	print("[Piano] 🔄 Connection state changed to: ", state)
	match state:
		WebSocketPeer.STATE_OPEN:
			connection_status.text = "Connected"
			connection_status.modulate = Color(0, 1, 0)  # Green
		WebSocketPeer.STATE_CLOSING:
			connection_status.text = "Closing..."
			connection_status.modulate = Color(1, 0.5, 0)  # Orange
		WebSocketPeer.STATE_CLOSED:
			_handle_disconnected_state()
		_:
			connection_status.text = "Connecting..."
			connection_status.modulate = Color(1, 1, 0)  # Yellow

func _on_websocket_connected():
	print("[Piano] ✅ Connected to server as: ", username_input.text)
	play_button.disabled = true
	username_input.editable = false
	connection_status.text = "Connected"
	connection_status.modulate = Color(0, 1, 0)  # Green

func _on_websocket_connection_error(error_message: String):
	print("[Piano] ❌ Connection error: ", error_message)
	play_button.disabled = false
	username_input.editable = true
	connection_status.text = "Connection Error"
	connection_status.modulate = Color(1, 0, 0)  # Red

func _on_websocket_disconnected(code: int, reason: String, was_clean: bool):
	print("[Piano] 🔌 Disconnected from server - Code: ", code, " Clean: ", was_clean, " Reason: ", reason)
	play_button.disabled = false
	username_input.editable = true
	connection_status.text = "Disconnected"
	connection_status.modulate = Color(1, 0, 0)  # Red
	
	# Attempt to reconnect after a delay
	await get_tree().create_timer(2.0).timeout  # Wait 2 seconds before reconnecting
	if not websocket_manager.socket or websocket_manager.socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		print("[Piano] 🔄 Attempting to reconnect...")
		connection_status.text = "Reconnecting..."
		connection_status.modulate = Color(1, 1, 0)  # Yellow
		websocket_manager.connect_to_server()

func _on_websocket_data_received(data: Dictionary):
	if data.has("type") and data["type"] == "piano_key":
		#pitch_index, velocity, timestamp
		var pitch_index: float = data.get("pitch_index", 0.0)
		var velocity: int = data.get("velocity", 0)
		var timestamp: float = data.get("timestamp", 0.0)
		var username: String = data.get("username", "Unknown")
		
		#var is_pressed = data.get("pressed", false)
		#var username = data.get("username", "Unknown")
		print("[Piano] 🎵 Received key event - Pitch: ", pitch_index, " pitch_index: ", velocity, "username: ", username, " timestamp: ", timestamp)
		
		# Create and setup falling circle
		var circle = FallingCircleScene.instantiate()
		add_child(circle)
		
		# Position the circle above the corresponding key
		if pitch_index in piano_key_dict:
			var key = piano_key_dict[pitch_index]
			circle.position.x = key.position.x + key.size.x / 2 - circle.size.x / 2
			circle.setup(username, pitch_index, pitch_index)

func _broadcast_key_event(pitch_index: float, pressed: bool) -> void:
	#print("[Piano] 📤 Attempting to broadcast key event...")
	if websocket_manager and websocket_manager.socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		var message = {
			"pitch_index": pitch_index,
			"velocity": 100 if pressed else 0,
			"timestamp": Time.get_unix_time_from_system(),
			"username": "Unknown",
		}
		print("[Piano] 📤 Broadcasting key event: ", message)
		websocket_manager.send_message(message)
	else:
		print("[Piano] ❌ Cannot broadcast - WebSocket not ready. State: ", 
			websocket_manager.socket.get_ready_state() if websocket_manager and websocket_manager.socket else "No socket")

func _input(input_event):
	if not (input_event is InputEventMIDI):
		return
	var midi_event: InputEventMIDI = input_event
	if midi_event.pitch < START_KEY or midi_event.pitch > END_KEY:
		# The given pitch isn't on the on-screen keyboard, so return.
		return
	_print_midi_info(midi_event)
	var key: PianoKey = piano_key_dict[midi_event.pitch]
	
	# Handle MIDI event
	if midi_event.message == MIDI_MESSAGE_NOTE_ON:
		print("[Piano] 🎹 Note ON - Pitch: ", midi_event.pitch, " Velocity: ", midi_event.velocity)
		key.activate()
		#_broadcast_key_event(midi_event.pitch, true)
	else:
		print("[Piano] 🎹 Note OFF - Pitch: ", midi_event.pitch)
		key.deactivate()
		#_broadcast_key_event(midi_event.pitch, false)

#region CREATE KEYS
func _add_placeholder_key(container):
	var placeholder = Control.new()
	placeholder.size_flags_horizontal = SIZE_EXPAND_FILL
	placeholder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	placeholder.name = &"Placeholder"
	container.add_child(placeholder)

func _create_piano_key(pitch_index):
	var note_index = _pitch_index_to_note_index(pitch_index)
	var piano_key: PianoKey
	if _is_note_index_sharp(note_index):
		piano_key = BlackKeyScene.instantiate()
		black_keys.add_child(piano_key)
	else:
		piano_key = WhiteKeyScene.instantiate()
		white_keys.add_child(piano_key)
		if _is_note_index_lacking_sharp(note_index):
			_add_placeholder_key(black_keys)
	piano_key.setup(pitch_index, note_index, "D")
	
	piano_key.connect("piano_key_activate", _on_piano_key_activate)
	piano_key.connect("piano_key_deactivate", _on_piano_key_deactivate)
	
	return piano_key

func _is_note_index_lacking_sharp(note_index: int):
	# B and E, because no B# or E#
	return note_index in [2, 7]

func _is_note_index_sharp(note_index: int):
	# A#, C#, D#, F#, and G#
	return note_index in [1, 4, 6, 9, 11]

func _pitch_index_to_note_index(pitch: int):
	pitch += 3
	return pitch % 12
#endregion

func _on_piano_key_activate(pitch_index: float):
	print("_on_piano_key_activate "+ str(pitch_index))
	_broadcast_key_event(pitch_index, true)

func _on_piano_key_deactivate(pitch_index: float):
	print("_on_piano_key_deactivate")
	_broadcast_key_event(pitch_index, false)

func _on_play_button_pressed():
	var username = username_input.text.strip_edges()
	if username.is_empty():
		print("Please enter a username")
		return
		
	# Send authentication message
	var message = {
		"type": "auth",
		"username": username
	}
	websocket_manager.send_message(message)
	
	# Update UI
	play_button.disabled = true
	username_input.editable = false
	connection_status.text = "Authenticating..."
	connection_status.modulate = Color(1, 1, 0)  # Yellow

func _on_login_button_up() -> void:
	
	pass # Replace with function body.

func _print_midi_info(midi_event: InputEventMIDI):
	print(midi_event)
	print("Channel: " + str(midi_event.channel))
	print("Message: " + str(midi_event.message))
	print("Pitch: " + str(midi_event.pitch))
	print("Velocity: " + str(midi_event.velocity))
	print("Instrument: " + str(midi_event.instrument))
	print("Pressure: " + str(midi_event.pressure))
	print("Controller number: " + str(midi_event.controller_number))
	print("Controller value: " + str(midi_event.controller_value))


func _on_login_button_pressed() -> void:
	hypership.auth_manager.login_with_credentials("hypershipuser1@test.com", "111")
	pass # Replace with function body.

func _on_login_completed(success, data):
	print("success", success)
	print("data", data)
	if success:
		print("Logged in! Token: ", hypership.auth_manager.token)
	else:
		print("Login failed")
	pass
