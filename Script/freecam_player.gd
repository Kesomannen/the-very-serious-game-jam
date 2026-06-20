extends CharacterBody3D

@export var movement_speed: float = 10.0
@export var boost_multiplier: float = 3.0
@export var mouse_sensitivity: float = 0.002
@export var capture_mouse_on_ready: bool = true

@onready var camera: Camera3D = get_node_or_null("Camera3D") as Camera3D

var _pitch := 0.0


func _ready() -> void:
	if camera == null:
		push_warning("Freecam player needs a Camera3D child named Camera3D.")
		return

	camera.current = true
	_pitch = camera.rotation.x

	if capture_mouse_on_ready:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	if camera == null:
		return

	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := Vector3.ZERO
	var camera_basis := camera.global_transform.basis

	direction += camera_basis.x * input_dir.x
	direction += camera_basis.z * input_dir.y

	if Input.is_action_pressed("jump") or Input.is_physical_key_pressed(KEY_E):
		direction += Vector3.UP
	if Input.is_physical_key_pressed(KEY_Q) or Input.is_physical_key_pressed(KEY_CTRL):
		direction += Vector3.DOWN

	var speed := movement_speed
	if Input.is_physical_key_pressed(KEY_SHIFT):
		speed *= boost_multiplier

	if direction != Vector3.ZERO:
		global_position += direction.normalized() * speed * delta


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		_pitch = clampf(_pitch - event.relative.y * mouse_sensitivity, -PI * 0.49, PI * 0.49)
		camera.rotation.x = _pitch
		get_viewport().set_input_as_handled()
