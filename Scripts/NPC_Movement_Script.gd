extends CharacterBody2D


@export var speed: float = 50.0
@export var friction: float = 1.0 
@export var combat_range: float = 25.0  # Distance at which NPC stops moving

@onready var player: CharacterBody2D

func _ready():
	add_to_group("NPC_Group_Level_1")
	player = get_tree().get_nodes_in_group("PlayerGroup")[0]
	if not player:
		print("Player node not found!")

func _physics_process(delta):
	if player:
		# Calculate direction to the player
		var direction = (player.global_position - global_position).normalized()
		
		# Calculate the distance to the player
		var distance_to_player = global_position.distance_to(player.global_position)
		
		# Check if the NPC is within the combat range
		if distance_to_player > combat_range:
			# Move towards the player
			velocity = direction * speed
		else:
			# Stop moving if within combat range
			velocity = Vector2.ZERO
		
		# Move the NPC using move_and_slide()
		move_and_slide()
	
