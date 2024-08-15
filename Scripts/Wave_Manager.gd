# wave_manager.gd
extends Node

@export var npc_spawner: NodePath
@export var wave_data: Resource  # Link to wave_data.gd script
@export var intermission_duration: float = 5.0  # Time between waves

var current_wave: int = 0
var wave_active: bool = false

signal wave_started(wave_number)
signal wave_completed(wave_number)

func _ready():
	start_round()

func start_round():
	current_wave = 0
	start_wave()

func start_wave():
	if current_wave >= wave_data.waves.size():
		return  # End of round
	
	wave_active = true
	var wave_info = wave_data.waves[current_wave]
	emit_signal("wave_started", current_wave + 1)
	await spawn_wave(wave_info)

func spawn_wave(wave_info):
	for enemy_config in wave_info["enemies"]:
		for i in range(enemy_config["count"]):
			await get_tree().create_timer(enemy_config["spawn_interval"]).timeout
			spawn_enemy(enemy_config["type"])
	
	wave_active = false
	emit_signal("wave_completed", current_wave + 1)
	current_wave += 1
	
	# Start the next wave after a short intermission
	await get_tree().create_timer(intermission_duration).timeout
	start_wave()

func spawn_enemy(enemy_type: String):
	var spawner = get_node(npc_spawner)
	var enemy_scene = load(enemy_type)
	spawner.spawn_enemy(enemy_scene)
