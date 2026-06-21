class_name Player

extends CharacterBody3D

@export var freecam_movement_speed := 10.0
@export var boost_multiplier := 3.0
@export var mouse_sensitivity := 0.002

@export var movement_speed := 5.0
@export var jump_velocity := 4.5
@export var starting_state := State.Freecam

@export var scout_fov := 30.0
@export var scout_mouse_sensitivity_multiplier := 0.5

@export var betting_fov := 50.0

@onready var camera: Camera3D = $Camera3D

var speed_multiplier := 1.0
var state: State

var _pitch: float
var _default_fov: float
var _start_pos: Vector3

var sliding = false

enum State {
	Betting,
	Scouting,
	Running,
	Freecam
}

func _ready() -> void:
	camera.current = true
	_default_fov = camera.fov
	_pitch = camera.rotation.x
	_start_pos = position
	enter(starting_state)

func enter(new_state: State):
	match new_state:
		State.Scouting:
			camera.fov = scout_fov
		State.Betting:
			camera.fov = betting_fov
		_:
			camera.fov = _default_fov
	
	match new_state:
		State.Betting:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		State.Running, State.Freecam, State.Scouting:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	match new_state:
		State.Running:
			speed_multiplier = 1.5
			get_tree().create_tween().tween_property(self, "speed_multiplier", 1.0, 0.8)
		State.Betting:
			position = _start_pos
			rotation = Vector3.ZERO
	
	state = new_state

func _physics_process(delta: float) -> void:
	match state:
		State.Scouting:
			_scouting_physics_process(delta)
		State.Running:
			_running_physics_process(delta)
		State.Freecam:
			_freecam_physics_process(delta)

func _scouting_physics_process(delta: float):
	if Input.is_action_just_pressed("jump"):
		enter(State.Running)

func _running_physics_process(delta: float):
	if sliding:
		return;
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var speed := movement_speed * speed_multiplier
	camera.fov = _default_fov * sqrt(speed_multiplier)
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func _freecam_physics_process(delta: float):
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := Vector3.ZERO
	var camera_basis := camera.global_transform.basis

	direction += camera_basis.x * input_dir.x
	direction += camera_basis.z * input_dir.y

	if Input.is_action_pressed("jump") or Input.is_physical_key_pressed(KEY_E):
		direction += Vector3.UP
	if Input.is_physical_key_pressed(KEY_Q) or Input.is_physical_key_pressed(KEY_CTRL):
		direction += Vector3.DOWN

	var speed := freecam_movement_speed
	if Input.is_physical_key_pressed(KEY_SHIFT):
		speed *= boost_multiplier

	if direction != Vector3.ZERO:
		global_position += direction.normalized() * speed * delta

func _input(event):
	if event is not InputEventMouseMotion or Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	match state:
		State.Betting:
			pass
		State.Freecam, State.Running, State.Scouting:
			var multiplier = scout_mouse_sensitivity_multiplier if state == State.Scouting else 1
			var sensitivity = mouse_sensitivity * multiplier
			rotate_y(-event.relative.x * sensitivity)
			_pitch = clampf(_pitch - event.relative.y * sensitivity, -PI * 0.49, PI * 0.49)
			camera.rotation.x = _pitch
			#get_viewport().set_input_as_handled()

func on_slide_enter():
	sliding = true

func on_slide_exit():
	sliding = false
