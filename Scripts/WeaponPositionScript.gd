extends RigidBody2D

@export var max_length: float = 10.0
@export var max_spring_strength: float = 15.0
@export var damping: float = 0.8
@export var attack_damage: int = 1
@export var attack_speed: float = 15.0
@export var jab_max_length: float = 30.0  # Extended reach during jab
@export var jab_max_spring_strength: float = 0.5
@export var jab_duration: float = 0.2  # Duration of the jab
@export var hit_cooldown: float = 0.1  # Cooldown time between hits
@export var knockback_multiplier: float = 3.0

@onready var weapon_sprite: Sprite2D = $Sprite2D
@onready var player: CharacterBody2D = $".."

var original_max_length: float
var original_spring_strength: float
var jab_timer: float = 0.0
var do_rotate: bool = true
var last_hit_time: float = 0.0

func _ready():
	# Store the original max length and spring strength
	original_max_length = max_length
	original_spring_strength = max_spring_strength
	
	# Confine the mouse inside the window and center it at game start.
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	var viewport_size = get_viewport().size
	var center_position = viewport_size / 2
	Input.warp_mouse(center_position)

func _on_body_entered(body):
	var current_time = Time.get_ticks_msec() / 1000.0
	if body.is_in_group("Enemy") and (current_time - last_hit_time) >= hit_cooldown:
		# Jab can hit only one enemy
		if jab_timer > 0.0:
			disable_weapon_collision() # Disable collision after a successful jab hit
			deal_damage(body)
			max_length = original_max_length
			max_spring_strength = original_spring_strength
		else:
			deal_damage(body)
		last_hit_time = current_time  # Reset the hit cooldown timer

func _physics_process(delta):
	var mouse_position = get_global_mouse_position()
	var player_position = player.global_position
	
	# Get the normalized vector pointing towards the mouse, from the player
	var direction_to_mouse = (mouse_position - player_position).normalized()
	
	# Handle jab input
	if Input.is_action_just_pressed("primary_action") and jab_timer <= 0.0:
		max_length = jab_max_length
		max_spring_strength = jab_max_spring_strength
		apply_central_impulse(direction_to_mouse * attack_speed)
		jab_timer = jab_duration
	
	# Manage jab timer and rotation
	if jab_timer > 0.0:
		jab_timer -= delta
		do_rotate = false
		if jab_timer <= 0.0:
			do_rotate = true
			max_length = original_max_length
			max_spring_strength = original_spring_strength
			enable_weapon_collision()  # Re-enable collision after the jab ends
	
	position_weapon(player_position, direction_to_mouse, mouse_position, do_rotate)

func position_weapon(player_position, direction_to_mouse, mouse_position, do_rotate):
	var target_position = player_position + direction_to_mouse * max_length
	var displacement = target_position - global_position
	
	# Apply spring force to pull the weapon towards the target position
	var spring_force = displacement * max_spring_strength - linear_velocity * damping
	apply_central_force(spring_force)
	if do_rotate:
		rotation = (mouse_position - global_position).angle()

func deal_damage(body):
	if body.has_method("take_damage"):
		# Calculate knockback direction and force
		var knockback_direction = (body.global_position - player.global_position).normalized()
		var knockback_force = knockback_direction * attack_speed * knockback_multiplier
		body.take_damage(attack_damage, knockback_force)
	else:
		print("The body is not attackable")

func disable_weapon_collision():
	set_collision_layer_value(2, false)
	set_collision_mask_value(2, false)
	set_collision_mask_value(3, false)

func enable_weapon_collision():
	set_collision_layer_value(2, true)
	set_collision_mask_value(2, true)
	set_collision_mask_value(3, true)
