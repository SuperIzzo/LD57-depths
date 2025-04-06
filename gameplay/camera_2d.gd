extends Camera2D

@export var target: Node = null

func _physics_process(delta):
	if target:
		position.y = target.position.y
