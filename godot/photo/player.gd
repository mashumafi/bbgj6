extends CharacterBody3D

@export var animation_tree: AnimationTree
@onready var state_machine : AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]
@onready var camera_transform : RemoteTransform3D = $CameraRemoteTransform3D
@onready var footstep_audio : AudioStreamPlayer3D = $FootstepAudioStreamPlayer3D
@onready var footstep_particles : GPUParticles3D = $FootstepParticles3D
@onready var belt_audio : AudioStreamPlayer3D = $BeltAudioStreamPlayer3D

const SPEED = 5.0
const JUMP_VELOCITY = 6.5

enum State {
	ALIVE,
	DEAD
}
var state := State.ALIVE

var last_spawn := Vector3.ZERO

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta: float) -> void:
	if is_on_floor() and state == State.ALIVE:
		if Input.is_action_just_pressed(&"jump"):
			state_machine.travel("Jump_Start")
			belt_audio.play()
			velocity.y = JUMP_VELOCITY
	else:
		velocity.y -= gravity * delta

	var input_dir := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	var direction = ($ModelWrapper.transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	if direction and state == State.ALIVE:
		var velocity2 := Vector2(velocity.x, velocity.z)
		var direction2 := Vector2(direction.x, direction.z)
		var dot := velocity2.normalized().dot(direction2.normalized())
		var factor := remap(dot, -1.0, 1.0, 2.0, 1.0)
		var target := velocity2.move_toward(direction2 * SPEED, delta * SPEED * factor)
		velocity.x = target.x
		velocity.z = target.y
		if is_on_floor():
			if not footstep_audio.playing:
				footstep_audio.play()
			footstep_audio.pitch_scale = remap(velocity2.length(), 0, SPEED, .3, 0.9)
			footstep_particles.emitting = true
		else:
			footstep_particles.emitting = false
	else:
		var target := Vector2(velocity.x, velocity.z).move_toward(Vector2.ZERO, delta * SPEED * 1.5)
		velocity.x = target.x
		velocity.z = target.y
		footstep_particles.emitting = false

	animation_tree.set("parameters/move/move_blend/blend_amount", remap(Vector2(velocity.x, velocity.z).length_squared(), 0, SPEED * SPEED, -1, 1))
	var down_velocity := velocity.y
	move_and_slide()

	if not is_equal_approx(down_velocity, velocity.y) and state == State.ALIVE:
		state_machine.travel("Jump_Land")
		belt_audio.play()

	if global_position.y < -10:
		die()

func _input(event: InputEvent) -> void:
	if state != State.ALIVE:
		return

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		$ModelWrapper.rotation.y -= event.relative.x / 500.0

		var tilt : float = $ModelWrapper/Model/Rig/Skeleton3D/head.rotation.x
		$ModelWrapper/Model/Rig/Skeleton3D/head.rotation.x = clamp(tilt +  event.relative.y / 500.0, -PI/4, PI/4)

func teleport(target: Vector3) -> void:
	$ModelWrapper/Model/Rig/Skeleton3D/head.override_pose = true
	var camera_position := camera_transform.global_position
	global_position = target
	last_spawn = target
	camera_transform.global_position = camera_position

func die() -> void:
	if state == State.DEAD:
		return

	state = State.DEAD
	$ModelWrapper/Model/Rig/Skeleton3D/head.override_pose = false
	state_machine.travel("Death_B")
	await animation_tree.animation_finished
	$ModelWrapper/Model/Rig/Skeleton3D/head.rotation = Vector3.ZERO
	$ModelWrapper/Model/Rig/Skeleton3D/head.position = Vector3(0, 1.208, 0)
	teleport(last_spawn)
	state = State.ALIVE


func load_data(data:Dictionary) -> void:
	if data.spawn:
		teleport(str_to_var(data.spawn))

func save_data() -> Dictionary:
	return {
		"spawn": var_to_str(last_spawn)
	}
