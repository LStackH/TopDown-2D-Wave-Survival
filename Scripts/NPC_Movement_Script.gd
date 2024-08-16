extends CharacterBody2D

signal healthChanged
signal enemyDied

@export var speed: float = 50.0
@export var friction: float = 1.0 
@export var combat_range: float = 25.0  # Distance at which NPC stops moving
@export var max_health: int = 5
@export var min_health: int = 0
@export var knockback_duration: float = 0.5  # Duration of the knockback effect in seconds

@onready var player: CharacterBody2D
@onready var current_health: int = max_health

@onready var raycast_center: RayCast2D = $RayCast2D_Center
@onready var raycast_left: RayCast2D = $RayCast2D_Left
@onready var raycast_right: RayCast2D = $RayCast2D_Right
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var sprite_2d = $Sprite2D
@onready var gpu_particles_2d = $GPUParticles2D

var navigation_ready = false
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0

func _ready():
	add_to_group("Enemy")
	add_to_group("NPC_Group_Level_1")
	emit_signal("healthChanged")
	
	player = get_tree().get_nodes_in_group("PlayerGroup")[0]
	if not player:
		print("Player node not found!")
	else:
		call_deferred("seeker_setup")

func seeker_setup():
	await get_tree().physics_frame
	navigation_ready = true
	navigation_agent.target_position = player.global_position

func _physics_process(delta):
	# Wait until the navigation is ready
	if not navigation_ready or not player:
		return
	
	# Apply knockback if the timer is active
	if knockback_timer > 0.0:
		velocity = knockback_velocity * (knockback_timer / knockback_duration)
		knockback_timer -= delta
	else:
		# If not knocked back, move towards the player
		navigation_agent.target_position = player.global_position
		if not navigation_agent.is_navigation_finished():
			# Get the next direction from the NavigationAgent2D
			var direction = navigation_agent.get_next_path_position()
			var new_velocity = global_position.direction_to(direction) * speed
			if navigation_agent.avoidance_enabled:
				navigation_agent.set_velocity(new_velocity)
			else:
				_on_navigation_agent_2d_velocity_computed(new_velocity)
	
	# Flip the sprite based on movement direction
	if velocity.x > 0:
		sprite_2d.flip_h = false
	else:
		sprite_2d.flip_h = true
	
	# Move the NPC using move_and_slide()
	move_and_slide()

func take_damage(damage, knockback: Vector2):
	gpu_particles_2d.emitting = true
	current_health -= damage
	emit_signal("healthChanged")
	if current_health <= 0:
		die()
	
	# Apply knockback
	knockback_velocity = knockback
	knockback_timer = knockback_duration

func die():
	emit_signal("enemyDied")
	queue_free()

func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	velocity = safe_velocity
	pass # Replace with function body.
