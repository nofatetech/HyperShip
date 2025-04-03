extends Control

@onready var circle: ColorRect = $Circle
@onready var username_label: Label = $Username

var fall_speed: float = 200.0  # pixels per second
var target_y: float = 0.0
var start_y: float = 0.0
var elapsed_time: float = 0.0
var duration: float = 2.0  # seconds

func setup(username: String, note_index: float, is_pressed: bool):
	username_label.text = username
	circle.color = Color(0, 1, 0, 1) if is_pressed else Color(1, 0, 0, 1)
	
	# Calculate start and target positions
	start_y = -100  # Start above the screen
	target_y = 400  # Fall to this position
	position.y = start_y
	
	# Start the animation
	elapsed_time = 0.0

func _process(delta: float):
	elapsed_time += delta
	
	if elapsed_time < duration:
		# Ease out animation
		var t = elapsed_time / duration
		t = 1 - (1 - t) * (1 - t)  # Quadratic ease out
		position.y = start_y + (target_y - start_y) * t
	else:
		queue_free()  # Remove the circle after animation completes 
