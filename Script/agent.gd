class_name Agent

extends CharacterBody3D

@export var movement_speed: float = 4.0
@export var color: Color
@export var is_it: bool
@export var manager: Manager
@export var state: String

@onready var navigation_agent: NavigationAgent3D = get_node("NavigationAgent3D")

var wander_target = Vector3()
var sliding = false
var mat: Material

func _ready() -> void:
	mat = $MeshInstance3D.get_surface_override_material(0).duplicate()
	$MeshInstance3D.set_surface_override_material(0, mat)
	mat.albedo_color = color
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	pick_new_wander_target()

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func _physics_process(delta):
	if sliding:
		return
	
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	if navigation_agent.is_navigation_finished():
		return

	if state == "WANDER" && position.distance_squared_to(wander_target) < 2:
		pick_new_wander_target()

	var repulse = Vector3()
	if not is_it:
		var taggers = manager.children.filter(func(child): return child.is_it)
		for tagger in taggers:
			var d = tagger.position - position
			repulse += -d / pow(d.length(), 1.5)
		repulse.y = 0
	
	var speed = movement_speed;
	if state == "WANDER":
		repulse *= 1
		speed *= 0.5
	elif state == "FLEE":
		repulse *= 0.2
		speed *= 0.8
	elif state == "PANIC":
		repulse *= 0
		speed *= 1.1

	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position)
	new_velocity = (new_velocity + repulse).normalized() * speed
	
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func recalculate_target():
	if is_it:
		state = ""
		mat.albedo_color = Color.RED
		var closest_runner = get_closest_child(manager.children.filter(func(child): return !child.is_it))
		if closest_runner != null:
			set_movement_target(closest_runner.global_position)
		else:
			print("No target!")
	else:
		var target = get_runner_target()
		target = NavigationServer3D.map_get_closest_point(
			navigation_agent.get_navigation_map(), target
		)
		set_movement_target(target)

func get_runner_target() -> Vector3:
	var taggers = manager.children.filter(func(child): return child.is_it)
	var closest_tagger = get_closest_child(taggers)
	var distance = position.distance_to(closest_tagger.position)

	if distance < 4:
		state = "PANIC"
		mat.albedo_color = Color.DARK_RED
		var dir = closest_tagger.global_position - global_position
		var target = global_position - dir * 4
		return target
	elif distance < 12:
		mat.albedo_color = color
		state = "FLEE"
		return get_best_safespot(taggers)
	else:
		mat.albedo_color = color
		state = "WANDER"
		return wander_target

func get_best_safespot(taggers: Array[Agent]) -> Vector3:
	var best: Node3D = null
	var best_score = -INF
	for spot in manager.safe_spots:
		var dist_to_spot = global_position.distance_to(spot.global_position)
		var tagger_dist_to_spot = 0
		for tagger in taggers:
			tagger_dist_to_spot += tagger.global_position.distance_to(spot.global_position)
		var score = tagger_dist_to_spot / len(taggers) - dist_to_spot / 5.0
		if score > best_score:
			best_score = score
			best = spot
	return best.global_position

func get_closest_child(children: Array[Agent]) -> Agent:
	var closest_distance = INF
	var closest = null
	for child in children:
		var distance = child.position.distance_squared_to(position)
		if distance < closest_distance:
			closest = child
	return closest

func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	move_and_slide()

func on_slide_enter():
	sliding = true

func on_slide_exit():
	sliding = false

func _on_tag_area_body_entered(body: Node3D) -> void:
	if body is not Agent or body == self or !is_it or body.is_it:
		return
	print(name, " tagged ", body.name)
	body.is_it = true

func _on_timer_timeout() -> void:
	recalculate_target()

func pick_new_wander_target():
	wander_target = Vector3(randf_range(-10, 10), global_position.y, randf_range(-10, 10))
