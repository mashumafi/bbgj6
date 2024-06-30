extends Area3D

@export var slice_audio : AudioStreamPlayer3D


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		slice_audio.play()
		body.die()
