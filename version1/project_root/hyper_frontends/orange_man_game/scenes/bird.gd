extends CharacterBody2D

const GRAVITY : int = 1000
const MAX_VEL : int = 600
const FLAP_SPEED : int = -500
var flying : bool = false
var falling : bool = false
const START_POS = Vector2(200, 400)
var health = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	reset()

func reset():
	falling = false
	flying = false
	position = START_POS
	set_rotation(0)
	
	# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if flying or falling:
		velocity.y += GRAVITY * delta
		#terminal velocity
		if velocity.y > MAX_VEL:
			velocity.y = MAX_VEL
		if flying:
			set_rotation(deg_to_rad(velocity.y * 0.05))
			$AnimatedSprite2D.animation = "flying2"
			$AnimatedSprite2D.play()
		elif falling:
			set_rotation(PI/2)
			$AnimatedSprite2D.stop()
		move_and_collide(velocity * delta)
	else:
		$AnimatedSprite2D.stop()
		
func flap():
	velocity.y = FLAP_SPEED

func change_health(newhealth):
	if newhealth < 0:
		newhealth = 0
	if newhealth > 100:
		newhealth = 100
	
	if newhealth < health:
		#say("loser")
		pass


	$ParticlesGreen.emitting = true
	$ParticlesGreen.visible = true
	$ParticlesSmoke.emitting = false
	$ParticlesSmoke.visible = false
	$ParticlesFire.emitting = false
	$ParticlesFire.visible = false
	if newhealth < 70:
		$ParticlesGreen.emitting = false
		$ParticlesGreen.visible = false
		$ParticlesSmoke.emitting = true
		$ParticlesSmoke.visible = true
		$ParticlesFire.emitting = false
		$ParticlesFire.visible = false
	if newhealth < 40:
		$ParticlesGreen.emitting = false
		$ParticlesGreen.visible = false
		$ParticlesSmoke.emitting = false
		$ParticlesSmoke.visible = false
		$ParticlesFire.emitting = true
		$ParticlesFire.visible = true
	#else:
		#$ParticlesGreen.emitting = true
		#$ParticlesGreen.visible = true
		#$ParticlesSmoke.emitting = false
		#$ParticlesSmoke.visible = false
		#$ParticlesFire.emitting = false
		#$ParticlesFire.visible = false
		
		
	health = newhealth
	$HealthLabel.text = str(health) + "%"# + " global.lvies: " + str(Xglobal.lives)
	print("change_health!")
	$HealthAnimationPlayer.play()
	# animation? ***
	pass

func say(text):
	if text == "loser":
		$AudioLoser.play()
	pass
