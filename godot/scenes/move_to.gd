extends Node3D

@export var target : Node3D
@export var delay_start := 0.0

@export var to_wait_time := .300
@export var to_time := .200
@export var back_wait_time := .300
@export var back_time := .500

func _ready() -> void:
	await get_tree().create_timer(delay_start).timeout

	var tween := create_tween()

	tween.tween_interval(to_wait_time)
	tween.tween_property(self, "global_position", target.global_position, to_time)
	tween.tween_interval(back_wait_time)
	tween.tween_property(self, "global_position", global_position, back_time)
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_loops()
