class_name AgentMovement

extends RefCounted

const MIN_STAMINA := 3.0
const MAX_STAMINA := 7.0
const STAMINA_DRAIN_PER_SPEED := 0.08
const SPRINT_STAMINA_DRAIN_PER_SECOND := 1.4
const STAMINA_RECOVERY_PER_SECOND := 0.75
const SPRINT_SPEED_MULTIPLIER := 1.45
const EXHAUSTED_SPEED_MULTIPLIER := 0.35
const EXHAUSTION_RECOVERY_PERCENT := 0.4

var max_stamina := MAX_STAMINA
var stamina := MAX_STAMINA
var wants_to_sprint := false
var exhausted := false
var last_speed := 0.0

func randomize_stamina() -> void:
	max_stamina = randf_range(MIN_STAMINA, MAX_STAMINA)
	stamina = max_stamina
	exhausted = false

func update(delta: float, speed: float) -> void:
	last_speed = speed

	if exhausted:
		stamina = minf(stamina + STAMINA_RECOVERY_PER_SECOND * delta, max_stamina)
		if stamina >= max_stamina * EXHAUSTION_RECOVERY_PERCENT:
			exhausted = false
		return

	if speed > 0.0:
		var drain := speed * STAMINA_DRAIN_PER_SPEED
		if is_sprinting():
			drain += SPRINT_STAMINA_DRAIN_PER_SECOND
		stamina = maxf(stamina - drain * delta, 0.0)
		if stamina == 0.0:
			exhausted = true
	else:
		stamina = minf(stamina + STAMINA_RECOVERY_PER_SECOND * delta, max_stamina)
		if exhausted and stamina >= max_stamina * EXHAUSTION_RECOVERY_PERCENT:
			exhausted = false

func sprint() -> void:
	wants_to_sprint = true

func unsprint() -> void:
	wants_to_sprint = false

func is_sprinting() -> bool:
	return wants_to_sprint and not exhausted and stamina > 0.0

func get_modified_speed(base_speed: float) -> float:
	if exhausted:
		return base_speed * EXHAUSTED_SPEED_MULTIPLIER
	if is_sprinting():
		return base_speed * SPRINT_SPEED_MULTIPLIER
	return base_speed

func get_desired_velocity(
	agent: Agent,
	navigation_agent: NavigationAgent3D,
	speed: float,
	steering: Vector3
) -> Vector3:
	var next_path_position := navigation_agent.get_next_path_position()
	var path_direction := agent.global_position.direction_to(next_path_position)
	return (path_direction + steering).normalized() * speed
