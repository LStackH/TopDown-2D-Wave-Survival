extends RigidBody2D

@export var max_length: float = 10.0
@export var spring_strenght: float = 15.0
@export var damping: float = 0.8

@onready var weapon_sprite: Sprite2D = $Sprite2D
@onready var player: CharacterBody2D = $".."


# Called when the node enters the scene tree for the first time.
func _ready():
	# Confine the mouse inside the window and center it at game start.
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	var viewport_size = get_viewport().size
	var center_position = viewport_size / 2
	Input.warp_mouse(center_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var mouse_position = get_global_mouse_position()
	var player_position = player.global_position
	
	# Get the normalized vector pointing towards the mouse, from the player
	var direction_to_mouse = (mouse_position - player_position).normalized()
	
	# Get the weapons ideal position, by adding the vector from the players center, times the length variable
	var target_position = player_position + direction_to_mouse * max_length
	
	# Get the direction for the weapons current position to the ideal target position
	#var current_direction = (target_position - global_position)
	
	var displacement = target_position - global_position
	
	# Apply spring force to pull the weapon towards the target position
	var spring_force = displacement * spring_strenght - linear_velocity * damping
	apply_central_force(spring_force)
	
	rotation = (mouse_position - global_position).angle()

