class_name Agent

extends CharacterBody3D

@export var movement_speed: float = 10.0
@export var color: Color
@export var manager: Manager
@export var state: String
@export var flee_state := AgentFleeLogic.State.WANDER

@onready var navigation_agent: NavigationAgent3D = get_node("NavigationAgent3D")

var chase_state := AgentChaseLogic.State.WATCHING
var wander_target := Vector3.ZERO

var is_it := false
var sliding := false
var _active := false

var mat: Material

var chase_logic := AgentChaseLogic.new()
var flee_logic := AgentFleeLogic.new()
var movement := AgentMovement.new()
var awareness := AgentAwareness.new()

func _ready() -> void:
	mat = $MeshInstance3D.get_surface_override_material(0).duplicate()
	$MeshInstance3D.set_surface_override_material(0, mat)
	mat.albedo_color = color
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	movement.randomize_stamina()
	pick_new_wander_target()
	update_behavior_state()
	set_active(_active)


func _physics_process(delta: float) -> void:
	if !_active:
		navigation_agent.set_velocity_forced(Vector3.ZERO)
		velocity = Vector3.ZERO
		return
		
	if sliding:
		return

	if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		movement.update(delta, 0.0)
		return
	if navigation_agent.is_navigation_finished():
		movement.update(delta, 0.0)
		return

	flee_logic.update_wander_target(self)

	var steering := flee_logic.get_steering(self)
	var speed := movement_speed
	if not is_it:
		speed = flee_logic.get_speed(self)
	speed = movement.get_modified_speed(speed)
	movement.update(delta, speed)

	var desired_velocity := movement.get_desired_velocity(self, navigation_agent, speed, steering)
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(desired_velocity)
	else:
		_on_velocity_computed(desired_velocity)

func set_movement_target(movement_target: Vector3) -> void:
	navigation_agent.set_target_position(movement_target)

func set_clamped_movement_target(target: Vector3) -> void:
	if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		set_movement_target(target)
		return

	var clamped_target := NavigationServer3D.map_get_closest_point(
		navigation_agent.get_navigation_map(), target
	)
	set_movement_target(clamped_target)

func update_behavior_state() -> void:
	if is_it:
		chase_logic.update(self)
	else:
		flee_logic.update(self)

func get_taggers() -> Array[Agent]:
	return manager.children.filter(func(child): return child.is_it)

func get_runners() -> Array[Agent]:
	return manager.children.filter(func(child): return !child.is_it)

func visible_targets() -> Array[Agent]:
	return awareness.visible_targets(self)

func visible_taggers() -> Array[Agent]:
	return awareness.visible_taggers(self)

func get_closest_child(children: Array[Agent]) -> Agent:
	var closest_distance := INF
	var closest: Agent = null
	for child in children:
		var distance := child.global_position.distance_squared_to(global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest = child
	return closest

func set_debug_color(debug_color: Color) -> void:
	if mat != null:
		mat.albedo_color = debug_color

func on_slide_enter() -> void:
	sliding = true

func on_slide_exit() -> void:
	sliding = false

func _on_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = safe_velocity
	move_and_slide()

func _on_tag_area_body_entered(body: Node3D) -> void:
	if !_active or body is not Agent or body == self or !is_it or body.is_it or chase_logic.is_in_cooldown():
		return

	print(name, " tagged ", body.name)
	body.is_it = true
	chase_logic.start_tag_cooldown()
	body.chase_logic.start_tag_cooldown()
	update_behavior_state()
	body.update_behavior_state()

func _on_timer_timeout() -> void:
	if !_active:
		return
	update_behavior_state()

func pick_new_wander_target() -> void:
	wander_target = Vector3(randf_range(-10, 10), global_position.y, randf_range(-10, 10))

func set_active(active: bool):
	_active = active
	$TagArea.process_mode = Node.PROCESS_MODE_INHERIT if _active else Node.PROCESS_MODE_DISABLED
