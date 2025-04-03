class_name PianoKey
extends Control

var pitch_scale: float
var note_index: float

signal piano_key_activate(pitch_index: int)
signal piano_key_deactivate(pitch_index: int)

@onready var key: ColorRect = $Key
@onready var start_color: Color = key.color
@onready var color_timer: Timer = $ColorTimer

var pitch_index: int = -1

const START_KEY = 48 # 21
const END_KEY = 108 #72 # 108


func setup(pitch_index: int, rnote_index: float, rkeyname: String):
	pitch_index = pitch_index
	name = "PianoKey" + str(note_index)
	#print(name)
	var exponent := (pitch_index - 69.0) / 12.0
	pitch_scale = pow(2, exponent)
	
	note_index = rnote_index
	
	# Let's normalize the size between 0 and 100 based on pitch range (21-108)
	var normalized_size = remap(pitch_index, 21, 108, 0, 100)
	#$Graph1.size = Vector2(normalized_size * 10, $Graph1.size.y)  # Keep original height
	#print("pitch_index: " + str(pitch_index) + " normalized_size: " + str(normalized_size))
	#$Graph1.size = Vector2(11, normalized_size * 1)  # Keep original height
	$Graph1.size = Vector2(11, pitch_index * 7)  # Keep original height
	#$Graph1.size = Vector2(33, 333)  # Keep original height
	$Graph1.visible = true
	$Graph1.position = Vector2(0, 200)

	#$Graph1.size = Vector2(0, 0)
	
	$Graph2.position = Vector2(12, 200)
	$Graph2.size = Vector2(11, randi_range(33, 333))  # Keep original height


func activate():
	key.color = (Color.YELLOW + start_color) / 2
	var audio := AudioStreamPlayer.new()
	add_child(audio)
	audio.stream = preload("res://piano_keys/A440.wav")
	audio.pitch_scale = pitch_scale
	audio.play()
	color_timer.start()
	
	$Label2.visible = true
	$Label2.text = "" + str(pitch_scale) # + str(pitch_scale)
	
	piano_key_activate.emit(pitch_scale)
	
	#TODO: animation
	#print("!! KEY !! pitch_scale:" + str(pitch_scale))
	#print("*** TODO: send websocket message. user, pitch_scale:" + str(pitch_scale))
	
	await get_tree().create_timer(8.0).timeout
	audio.queue_free()


func deactivate():
	key.color = start_color
	$Label2.visible = false
	
	piano_key_deactivate.emit(pitch_scale)
	
