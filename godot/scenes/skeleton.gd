extends Area3D

@export var target1 : Node3D
@export var target2 : Node3D

@onready var current_target := target1

@export var animation_player : AnimationPlayer

func _ready() -> void:
	animation_player.play(&"Walking_A")

func _physics_process(delta: float) -> void:
	if not current_target:
		return

	look_at(current_target.global_position)
	global_position = global_position.move_toward(current_target.global_position, delta * 3)

	if global_position.is_equal_approx(current_target.global_position):
		swap_target()

func swap_target():
	if not current_target:
		return

	if current_target == target1:
		current_target = target2
		return

	if current_target == target2:
		current_target = target1
		return


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		body.die()

