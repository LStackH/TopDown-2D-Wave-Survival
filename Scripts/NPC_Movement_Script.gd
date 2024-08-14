extends CharacterBody2D


@export var SPEED: float = 75.0
@export var friction: float = 5.0 

@onready var player: CharacterBody2D

func _ready():
	add_to_group("NPC_Group_Level_1")
	player = get_tree().get_nodes_in_group("PlayerGroup")[0]
	if not player:
		print("Player node not found!")

func _physics_process(delta):
	var direction = (player.global_position - global_position).normalized()
	
	velocity = direction * SPEED
	
	if velocity.length() > 0:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	position += velocity * delta

	move_and_slide()
