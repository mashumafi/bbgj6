@tool
extends Node3D

@export var axis := Vector3.UP
@export var angle := 30.0

func _physics_process(delta: float) -> void:
	rotate(axis, deg_to_rad(angle) * delta)
