extends ProgressBar


@export var host: CharacterBody2D

func _ready():
	host.healthChanged.connect(update)
	update()

func update():
	value = host.current_health * 100 / host.max_health
	if value == 100:
		self.visible = false
	else:
		self.visible = true
