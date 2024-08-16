# npc_spawner.gd
extends Node2D

@export var spawn_points: Array[NodePath] = []
@export var npc_scene: PackedScene
@export var max_enemies: int = 1000
var current_enemy_count: int = 0

func _ready():
	if spawn_points.size() == 0:
		for child in get_children():
			if child is Marker2D:
				spawn_points.append(child.get_path())
	if spawn_points.size() == 0:
		print("No spawn points found!")

func _on_timer_timeout():
	if current_enemy_count < max_enemies:
		spawn_enemy()

func spawn_enemy(npc_scene: PackedScene = null):
	if npc_scene == null:
		npc_scene = self.npc_scene
	var spawn_index = randi() % spawn_points.size()
	var spawn_point = get_node(spawn_points[spawn_index])
	var enemy_instance = npc_scene.instantiate()
	add_child(enemy_instance)
	enemy_instance.global_position = spawn_point.global_position

	# Increment enemy count
	current_enemy_count += 1
	print("One added: ", current_enemy_count)
	
	enemy_instance.connect("enemyDied", Callable(self, "_on_enemy_died"))

func _on_enemy_died():
	current_enemy_count -= 1
	print("One lost: ",current_enemy_count)
