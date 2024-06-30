extends StaticBody3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var open_audio: AudioStreamPlayer3D = $OpenAudioStreamPlayer3D

@export var next_zone : Node3D

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		open_audio.play()
		animation_player.play(&"open")
		if next_zone:
			await get_tree().create_timer(1).timeout
			body.teleport(next_zone.global_position)
			SaveGame.save_game(get_tree())
