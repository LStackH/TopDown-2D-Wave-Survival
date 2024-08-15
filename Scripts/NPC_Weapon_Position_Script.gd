extends RigidBody2D

@export var max_length: float = 10.0
@export var spring_strenght: float = 15.0
@export var damping: float = 0.8
@export var reaction_speed: float = 0.1
@export var attack_damage: int = 1


@onready var weapon_sprite: Sprite2D = $Sprite2D
@onready var NPC: CharacterBody2D = $".."
@onready var player: CharacterBody2D




# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_nodes_in_group("PlayerGroup")[0]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	player = get_tree().get_nodes_in_group("PlayerGroup")[0]
	var player_position = player.global_position
	var NPC_position = NPC.global_position
	
	# Get the normalized vector pointing towards the player, from the NPC
	var direction_to_player = (player_position - NPC_position).normalized()
	
	position_weapon(NPC_position, direction_to_player, player_position)

func position_weapon(NPC_position, direction_to_player, player_position):
	var target_position = NPC_position + direction_to_player * max_length
	
	var displacement = target_position - global_position
	
	# Apply spring force to pull the weapon towards the target position
	var spring_force = displacement * spring_strenght - linear_velocity * damping
	var distance_to_player = global_position.distance_to(player.global_position)
	
	apply_central_force(spring_force)
		
	rotation = (player_position - global_position).angle()

func _on_body_entered(body):
	if body.is_in_group("PlayerGroup"):
		deal_damage(body)

func deal_damage(body):
	if body.has_method("take_damage") and body.is_in_group("PlayerGroup"):
		body.take_damage(attack_damage)
	else:
		print("The body is not attackable")
