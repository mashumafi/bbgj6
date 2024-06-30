extends Node3D

@onready var start_position := position

func _process(delta: float) -> void:
	position = position.move_toward(start_position, max(position.distance_to(start_position), 2) * delta)
