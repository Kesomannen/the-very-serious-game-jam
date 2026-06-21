class_name AgentChaseLogic

extends RefCounted

enum State {
	WATCHING,
	SEARCHING,
	CHASING,
	COOLDOWN,
}

const CHASE_DISTANCE := 7.0
const LAST_SEEN_REACHED_DISTANCE := 1.5
const TAG_COOLDOWN_SECONDS := 1.5
const CLOSENESS_WEIGHT := 1.0
const EXHAUSTED_TARGET_BONUS := 8.0
const LOW_STAMINA_TARGET_BONUS := 3.0
const ISOLATED_TARGET_BONUS := 4.0
const LOW_GROUND_BONUS := 0.5
const CROWD_DISTANCE := 6.0

var current_target: Agent = null
var has_last_seen_position := false
var last_seen_position := Vector3.ZERO
var cooldown_until_msec := 0

func update(agent: Agent) -> void:
	if is_in_cooldown():
		set_cooldown(agent)
		return

	var best_runner := get_best_visible_runner(agent)
	if best_runner != null:
		remember_target(best_runner)
		var target_distance := agent.global_position.distance_to(best_runner.global_position)
		if target_distance <= CHASE_DISTANCE:
			set_chasing(agent, best_runner)
		else:
			set_searching(agent, best_runner.global_position)
		return

	current_target = null
	if has_last_seen_position:
		if agent.global_position.distance_to(last_seen_position) <= LAST_SEEN_REACHED_DISTANCE:
			has_last_seen_position = false
			set_watching(agent)
		else:
			set_searching(agent, last_seen_position)
		return

	set_watching(agent)

func start_tag_cooldown() -> void:
	cooldown_until_msec = Time.get_ticks_msec() + int(TAG_COOLDOWN_SECONDS * 1000.0)
	current_target = null
	has_last_seen_position = false

func is_targeting(agent: Agent, target: Agent) -> bool:
	if is_in_cooldown():
		return false
	return current_target == target or agent.visible_targets().has(target)

func set_watching(agent: Agent) -> void:
	agent.chase_state = State.WATCHING
	agent.state = "WATCHING"
	agent.set_debug_color(Color.RED)
	agent.movement.unsprint()
	agent.set_clamped_movement_target(get_closest_safe_spot(agent))

func set_searching(agent: Agent, target_position: Vector3) -> void:
	agent.chase_state = State.SEARCHING
	agent.state = "SEARCHING"
	agent.set_debug_color(Color.RED)
	agent.movement.unsprint()
	agent.set_clamped_movement_target(target_position)

func set_chasing(agent: Agent, target: Agent) -> void:
	agent.chase_state = State.CHASING
	agent.state = "CHASING"
	agent.set_debug_color(Color.RED)
	agent.movement.sprint()
	agent.set_movement_target(target.global_position)

func set_cooldown(agent: Agent) -> void:
	agent.chase_state = State.COOLDOWN
	agent.state = "TAG_COOLDOWN"
	agent.set_debug_color(Color.RED)
	agent.movement.unsprint()
	agent.set_movement_target(agent.global_position)

func get_best_visible_runner(agent: Agent) -> Agent:
	var best_score := -INF
	var best_runner: Agent = null
	for runner in agent.visible_targets():
		var score := score_target(agent, runner)
		if score > best_score:
			best_score = score
			best_runner = runner

	return best_runner

func score_target(agent: Agent, runner: Agent) -> float:
	var distance := agent.global_position.distance_to(runner.global_position)
	var score := -distance * CLOSENESS_WEIGHT
	if runner.movement.exhausted:
		score += EXHAUSTED_TARGET_BONUS
	elif runner.movement.stamina < runner.movement.max_stamina * 0.35:
		score += LOW_STAMINA_TARGET_BONUS

	if is_isolated(runner):
		score += ISOLATED_TARGET_BONUS

	score += maxf(agent.global_position.y - runner.global_position.y, 0.0) * LOW_GROUND_BONUS
	return score

func is_isolated(runner: Agent) -> bool:
	for other_runner in runner.get_runners():
		if other_runner == runner:
			continue
		if other_runner.global_position.distance_to(runner.global_position) <= CROWD_DISTANCE:
			return false
	return true

func remember_target(target: Agent) -> void:
	current_target = target
	last_seen_position = target.global_position
	has_last_seen_position = true

func is_in_cooldown() -> bool:
	return Time.get_ticks_msec() < cooldown_until_msec

func get_closest_safe_spot(agent: Agent) -> Vector3:
	if agent.manager.safe_spots.is_empty():
		return agent.global_position

	var closest_distance := INF
	var closest_spot: Node3D = null
	for spot in agent.manager.safe_spots:
		var distance := spot.global_position.distance_squared_to(agent.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_spot = spot

	if closest_spot == null:
		return agent.global_position
	return closest_spot.global_position
