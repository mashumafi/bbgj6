extends Node

@onready var fade_overlay := %FadeOverlay as FadeOverlay
@onready var pause_overlay := %PauseOverlay as PauseOverlay

@export var player : CharacterBody3D
@export var camera_pivot: Node3D
@export var progress: ProgressBar

func _ready() -> void:
	fade_overlay.visible = true

	if SaveGame.has_save():
		SaveGame.load_game(get_tree())

	pause_overlay.game_exited.connect(_save_game)

func _physics_process(delta: float) -> void:
	progress.value += delta * 20
	if is_equal_approx(progress.value, progress.max_value):
		progress.value = 0
		create_tween().tween_property(camera_pivot, "rotation:y", randf_range(0, TAU), .5).set_trans(Tween.TRANS_EXPO)

func _input(event: InputEvent) -> void:
	player._input(event)
	var mouse_button := event as InputEventMouseButton
	if mouse_button:
		if mouse_button.pressed and mouse_button.button_index == MOUSE_BUTTON_LEFT:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event.is_action_pressed(&"pause") and not pause_overlay.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_viewport().set_input_as_handled()
		get_tree().paused = true
		pause_overlay.grab_button_focus()
		pause_overlay.visible = true


func _save_game() -> void:
	SaveGame.save_game(get_tree())
