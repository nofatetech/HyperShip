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

var piano_key_dict := Dictionary()
var websocket_manager: WebSocketManager

@onready var white_keys = $Container/WhiteKeys
@onready var black_keys = $Container/BlackKeys
@onready var username_input = $TextEdit
@onready var play_button = $Button

func _ready():
	# Sanity checks.
	if _is_note_index_sharp(_pitch_index_to_note_index(START_KEY)):
		printerr("The start key can't be a sharp note (limitation of this piano-generating algorithm). Try 21.")
		return

	for i in range(START_KEY, END_KEY + 1):
		piano_key_dict[i] = _create_piano_key(i)

	if white_keys.get_child_count() != black_keys.get_child_count():
		_add_placeholder_key(black_keys)
	
	# Setup WebSocket
	websocket_manager = $HyperShip/WebSocketManager
	websocket_manager.setup("ws://localhost:8080")  # Replace with your WebSocket server URL
	websocket_manager.connect("connected", _on_websocket_connected)
	websocket_manager.connect("connection_error", _on_websocket_error)
	websocket_manager.connect("data_received", _on_websocket_data_received)
	websocket_manager.connect("disconnected", _on_websocket_disconnected)
	
	# Setup UI
	play_button.connect("pressed", _on_play_button_pressed)
	
	OS.open_midi_inputs()
	print(OS.get_connected_midi_inputs())

func _on_play_button_pressed():
	var username = username_input.text.strip_edges()
	if username.is_empty():
		print("Please enter a username")
		return
	
	websocket_manager.connect_to_server()

func _on_websocket_connected():
	print("Connected to WebSocket server")
	play_button.disabled = true
	username_input.editable = false

func _on_websocket_error(error_message: String):
	print("WebSocket error: ", error_message)
	play_button.disabled = false
	username_input.editable = true

func _on_websocket_disconnected(code: int, reason: String, was_clean: bool):
	print("Disconnected from WebSocket server. Code: ", code, " Reason: ", reason)
	play_button.disabled = false
	username_input.editable = true

func _on_websocket_data_received(data: Dictionary):
	if data.has("type") and data["type"] == "piano_key":
		var pitch = data.get("pitch")
		var is_pressed = data.get("pressed", false)
		var username = data.get("username", "Unknown")
		print("[WebSocket] Received key event - Pitch: ", pitch, " Pressed: ", is_pressed, " User: ", username)
		if pitch in piano_key_dict:
			if is_pressed:
				piano_key_dict[pitch].activate()
			else:
				piano_key_dict[pitch].deactivate()

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
		key.activate()
		_broadcast_key_event(midi_event.pitch, true)
	else:
		key.deactivate()
		_broadcast_key_event(midi_event.pitch, false)

func _broadcast_key_event(pitch: int, is_pressed: bool):
	if websocket_manager and websocket_manager.socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		var message = {
			"type": "piano_key",
			"pitch": pitch,
			"pressed": is_pressed,
			"username": username_input.text
		}
		print("[WebSocket] Broadcasting key event - Pitch: ", pitch, " Pressed: ", is_pressed, " User: ", username_input.text)
		websocket_manager.send_message(message)

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
