extends Camera3D

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x / 500.0

		rotation.x = clamp(rotation.x - event.relative.y / 500.0, -PI/4, PI/4)
