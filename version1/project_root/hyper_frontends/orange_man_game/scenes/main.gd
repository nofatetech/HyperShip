extends Node

#orangeman
#https://lexica.art/prompt/647e05f9-0c64-4ccb-b18f-fb65d19b01c7

# TODO: load story from web
# TODO: other characters/stories. 
# TODO: 

var STORY = {
  "steps": [
	{
	  "id": 1,
	  "slug": "step 1",
	  "text1": "Day one and I'm soaring high, like a cyberpunk Icarus—what could go wrong?"
	},
	{
	  "id": 2,
	  "slug": "step 1",
	  "text1": "Turns out AI overlords don't appreciate my flair for profit. Who knew?"
	},
	{
	  "id": 3,
	  "slug": "step 1",
	  "text1": "Another day, another byte—time to show these bots who's boss!"
	},
	{
	  "id": 4,
	  "slug": "step 1",
	  "text1": "Greed may be good, but humility is the patch update I didn't know I needed."
	},
	{
	  "id": 5,
	  "slug": "step 1",
	  "text1": "Flying through neon dreams, dodging AI schemes. Just another Tuesday!"
	},
	{
	  "id": 6,
	  "slug": "step 1",
	  "text1": "Capitalist to humble hero: it's a bird, it's a plane—it's my character arc!"
	},
	{
	  "id": 5,
	  "slug": "step 1",
	  "text1": "Neon lights and high stakes—today's a good day to outsmart an AI."
	},
	{
	  "id": 6,
	  "slug": "step 1",
	  "text1": "Profit margins shrinking faster than my ego—time for a new approach."
	},
	{
	  "id": 5,
	  "slug": "step 1",
	  "text1": "Who knew dodging drones could be this exhilarating? Morning workout, check!"
	},
	{
	  "id": 6,
	  "slug": "step 1",
	  "text1": "Midday reflection: less greed, more speed. I'm practically a philosopher."
	},
	{
	  "id": 5,
	  "slug": "step 1",
	  "text1": "Rising like the sun, with slightly less arrogance and more cyber-savvy."
	},
	{
	  "id": 6,
	  "slug": "step 1",
	  "text1": "AIs might be smart, but they don't get sarcasm. Advantage: me."
	},
	{
	  "id": 5,
	  "slug": "step 1",
	  "text1": "Final day, final push—time to prove I've got the bytes and the heart."
	},
	{
	  "id": 6,
	  "slug": "step 1",
	  "text1": "From greedy to grateful—who knew a cyberpunk dystopia could teach so much?"
	}
  ]
}



@export var pipe_scene : PackedScene

var game_running : bool
var game_over : bool
var scroll
var score
const SCROLL_SPEED : int = 4
var screen_size : Vector2i
var ground_height : int
var pipes : Array
const PIPE_DELAY : int = 100
const PIPE_RANGE : int = 200
var cycle : int = 0

var money := 0
var storystep = 1
var currentday = 1

var BGMODULATEMIN = 0.03
var BGMODULATEMMAX = 0.4

var STORY_PATH = "nofatetetch.github.io/surviveornotthegame/story.json"

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	$Background.modulate = Color("ffffff", BGMODULATEMIN)
	$Story/StoryLabel.text = "" # STORY["steps"][storystep]["text1"]
	$Story/StoryLabel.text = "Let's begin.."
	new_game()
	#$Background.texture = preload("res://assets/bg.png")

func _getstory_http_request_completed(result, response_code, headers, body):
	#print("HTTP Request Completed with response code: %d" % response_code)
	#print("Headers: ", headers)
	
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Error: JSON couldn't be downloaded. Try a different image.")
		return

	var json = JSON.new()
	var json_result = json.parse(body)
	
	if json_result.error != OK:
		#push_error("Failed to parse JSON: %s" % JSON.get_error_message(json_result.error))
		push_error("Failed to parse JSON: ", (json_result.error))
		return
	
	var json_data = json_result.result
	#print("JSON data loaded successfully: %s" % str(json_data))
	#process_json_data(json_data)
	print(json_data)
	#if data.has("title"):
		#var title = data["title"]
		#print("Title: %s" % title)
	
	pass

func new_game():
	#reset variables
	
	# get updated STORY
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._getstory_http_request_completed)

	# Perform the HTTP request. The URL below returns a PNG image as of writing.
	var error = http_request.request(STORY_PATH)
	if error != OK:
		#print("An error occurred in the HTTP request.")
		push_error("An error occurred in the HTTP request.")
	
	
	$Others.visible = true
	
	# show intro screen
	$Bird.visible = false
	$Bird.change_health(100)
	#$Orangeman1.visible = true
	
	game_running = false
	game_over = false
	score = 0
	scroll = 0
	$ScoreLabel.text = "" + str(score)
	$GameOver.hide()
	get_tree().call_group("pipes", "queue_free")
	pipes.clear()
	#generate starting pipes
	generate_pipes()

	$Bird.reset()

	$ScoreLabel.visible = false
	$ScoreMoney.visible = false
	$Bird.visible = true
	$Story/StoryLabel.visible = false
	$TitleLabel.visible = true

	#$Background.modulate = Color("ffffff")
	cycle = 0
	storystep = 1
	currentday = 1
	
func _input(event):
	if game_over == false:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if game_running == false:
					start_game()
				else:
					if $Bird.flying:
						$Bird.flap()
						check_top()

func start_game():
	$Others.visible = false
	$TitleLabel.visible = false

	$Bird.visible = true
	$Orangeman1.visible = false
	
	money = 0
	cycle = 1
	currentday = 1
	update_score()
	$DaysLabel2.text = ""
	
	game_running = true
	$Bird.flying = true
	$Bird.flap()
	#start pipe timer
	$PipeTimer.start()
	$Bird.change_health(100)
	
	$Story/StoryLabel.visible = true
	$ScoreMoney.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_running:
		scroll += SCROLL_SPEED
		#reset scroll
		if scroll >= screen_size.x:
			scroll = 0
		#move ground node
		$Ground.position.x = -scroll
		#move pipes
		for pipe in pipes:
			pipe.position.x -= SCROLL_SPEED


func _on_pipe_timer_timeout():
	generate_pipes()
	cycle = cycle + 1
	if cycle > 24:
		$Bird.change_health($Bird.health - 11)
		
		money -= 3
		update_score()
		
		cycle = 1
		currentday += 1

	if cycle % 12 == 0:
		storystep += 1
		if storystep > len(STORY["steps"]): # !!!
			storystep = 1 # !!!
	
	if currentday > ( len(STORY["steps"])/2 ):
		print("final!!")
		#stop_game()


	#if true:
	#if currentday % 1 == 0:
	##if cycle % 3 == 0:
		#storystep += 1
		#if storystep > 2: # !!!
			#storystep = 1 # !!!

	#$HoursLabel.text = "hour " + str(cycle)
	$DaysLabel2.text = "day " + str(currentday) + "\n" + "hour " + str(cycle)
	$Story/StoryLabel.text = STORY["steps"][storystep-1]["text1"]

	# entre 0.1 y BGMODULATEMMAX
	# diferencia 0.6
	var aa = 0
	aa = (((BGMODULATEMMAX - BGMODULATEMIN)/12) * (cycle - 1)) + BGMODULATEMIN
	if cycle > 12:
		aa = (((BGMODULATEMMAX - BGMODULATEMIN)/12) * (cycle - 12 - 1)) + BGMODULATEMIN
		#aa = (((BGMODULATEMMAX - BGMODULATEMIN)/12) * (12- cycle - 1)) + BGMODULATEMIN
		#aa = BGMODULATEMMAX - ( (((BGMODULATEMMAX - BGMODULATEMIN)/12) * (cycle - 1)) + BGMODULATEMIN)
		aa = BGMODULATEMMAX - aa
	print(aa)
	$Background.modulate = Color("ffffff", aa)
	
func generate_pipes():
	var pipe = pipe_scene.instantiate()
	pipe.position.x = screen_size.x + PIPE_DELAY
	pipe.position.y = (screen_size.y - ground_height) / 2  + randi_range(-PIPE_RANGE, PIPE_RANGE) + 0
	pipe.hit.connect(bird_hit)
	pipe.scored.connect(scored)
	
	if cycle % 3 == 0:
		#pipe.xtype2 = cycle
		pipe.change_xtype2(cycle)
	$Pipes.add_child(pipe)
	pipes.append(pipe)

func update_score():
	#$ScoreLabel.text = "" + str(score) + "  " + str(cycle) + "hrs"
	$ScoreLabel.text = "" + str(score) 
	$ScoreMoney/ScoreMoneyLabel.text = "ITFB:\n" + str(money) + " Billion" #+ "\nITFB"
	#$ScoreMoneyLabelAnimationPlayer.get_animation($ScoreMoneyLabelAnimationPlayer).play()
	$ScoreMoneyLabelAnimationPlayer.play()
	print("update score!")
	
func scored(pipetype):
	#Engine.time_scale = 1


	var qty = 1
	var newhealth = $Bird.health - 0
	
	if pipetype == 1:
		qty = 2
		#money -= 1
	if pipetype == 2:
		qty = 0
		money += 1
		$Bird.say("loser")

		newhealth = $Bird.health + 2
		$Bird.change_health(newhealth)
		$Bird/ParticlesGetMoney.emitting = true
		
		# shake
		$ShakerScored.play_shake()


		#$Bird.xxx1()

	#if pipetype == 3:
		#qty = 3
		#money -= 10
	score += qty
	if pipetype == 2:
		$FxGetMoney.play()


	update_score()
	
	#$ScoreLabel.text = "SCORE:" + str(score) + " cycle:" + str(cycle)

func check_top():
	if $Bird.position.y < 0:
		$Bird.falling = true
		stop_game()

func stop_game():
	$PipeTimer.stop()
	$GameOver.show()
	$Bird.flying = false
	game_running = false
	game_over = true
	
func bird_hit(xtype):
	#Engine.time_scale = 1
	
	$ShakerBirdHit.play_shake()

	#print("bird_hit " + str(xtype))
	$Bird.falling = true
	$FxCollisionBuilding.play()
	var newhealth = $Bird.health - 0
#
	## shake
	#$ShakerScored.play_shake()
	if xtype == 2:
		newhealth = $Bird.health - 3
	if xtype == 1:
		money -= 1
		newhealth = $Bird.health - 7


	update_score()
	if newhealth <= 0:
		newhealth = 0
		stop_game()
	$Bird.change_health(newhealth)
	$Bird/ParticlesHit.emitting = true
	#*** DEBUG
	#stop_game()

func _on_ground_hit():
	$Bird.falling = false
	stop_game()

func _on_game_over_restart():
	new_game()


func _on_button_pause_button_up():
	if game_running:
		game_running = false
	else:
		game_running = true
		
	if Engine.time_scale == 1:
		Engine.time_scale = 0
	else:
		Engine.time_scale = 1
		
	pass # Replace with function body.
