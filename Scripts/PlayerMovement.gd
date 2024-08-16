extends CharacterBody2D

signal healthChanged

@export var speed: float = 100.0
@export var friction: float = 5.0 
@export var max_health: int = 10
@export var min_health: int = 0
@export var dash_speed: float = 400.0
@export var dash_acceleration: float = 2000.0  # Acceleration during dash
@export var dash_duration: float = 0.2  # Duration of the dash in seconds


@onready var current_health: int = max_health
@onready var sprite_2d = $Sprite2D
@onready var dash_cooldown = $Dash_Cooldown


var screen_size
var is_dashing: bool = false
var dash_time_remaining: float = 0.0
var dash_direction: Vector2
var moving: bool


func _ready():
	add_to_group("PlayerGroup")
	emit_signal("healthChanged")

func _process(delta):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func _physics_process(delta):
	var direction = Vector2.ZERO
	
	# Movement input
	if Input.is_action_pressed("right"):
		direction.x += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("down"):
		direction.y += 1
	if Input.is_action_pressed("up"):
		direction.y -= 1
	
	# Normalize direction
	if direction != Vector2.ZERO:
		direction = direction.normalized()

	# Start dash
	if direction != Vector2.ZERO and Input.is_action_just_pressed("dash") and !is_dashing:
		start_dash(direction)
	
	# Handle dash
	if is_dashing:
		# Accelerate the player in the dash direction
		velocity = velocity.move_toward(dash_direction * dash_speed, dash_acceleration * delta)
		dash_time_remaining -= delta
		if dash_time_remaining <= 0:
			stop_dash()
	else:
		# Regular movement and friction
		velocity = direction * speed
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	# Flip sprite based on movement direction
	if velocity.x > 0:
		sprite_2d.flip_h = false
	elif velocity.x < 0:
		sprite_2d.flip_h = true
	
	move_and_slide()

func start_dash(direction: Vector2):
	is_dashing = true
	dash_direction = direction
	dash_time_remaining = dash_duration

func stop_dash():
	is_dashing = false

func take_damage(damage):
	current_health -= damage
	emit_signal("healthChanged")
	if current_health <= 0:
		die()

func die():
	pass
