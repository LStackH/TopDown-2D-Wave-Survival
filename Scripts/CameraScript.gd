extends Camera2D

@export var camera_follow_speed: float = 1.0

@onready var player: CharacterBody2D = $".."

# Called when the node enters the scene tree for the first time.
func _ready():
	# Ensure the camera is centered on the player initially
	position = player.global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var player_position = player.global_position
	var camera_current_position = global_position
	
	# Linearly interpolate the camera's position towards the player's position
	position = lerp(camera_current_position, player_position, camera_follow_speed * delta)
