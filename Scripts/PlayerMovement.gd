extends CharacterBody2D


@export var SPEED: float = 75.0
@export var friction: float = 5.0 
var screen_size

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	add_to_group("PlayerGroup")

func _process(delta):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func _physics_process(delta):
	var direction = Vector2.ZERO # The player's movement vector.
	
	if Input.is_action_just_pressed("dash"):
		pass
	
	if Input.is_action_pressed("right"):
		direction.x += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("down"):
		direction.y += 1
	if Input.is_action_pressed("up"):
		direction.y -= 1
	
	velocity = direction * SPEED
	
	if velocity.length() > 0:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	position += velocity * delta
	
	move_and_slide()
