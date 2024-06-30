extends Area3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var open_audio: AudioStreamPlayer3D = $OpenAudioStreamPlayer3D
@onready var particles: GPUParticles3D = $GPUParticles3D

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		open_audio.play()
		animation_player.play(&"open")
		particles.emitting = true
