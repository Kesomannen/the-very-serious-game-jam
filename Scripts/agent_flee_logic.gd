class_name AgentFleeLogic

extends RefCounted

enum State {
	WANDER,
	ALERT,
	FLEE,
}

const ALERT_DISTANCE := 12.0
const FLEE_DISTANCE := 4.0
const FLEE_MEMORY_SECONDS := 5.0
const FLEE_TARGET_MULTIPLIER := 4.0
const MIN_REPULSE_DISTANCE := 0.001
const SAFE_SPOT_TRAVEL_WEIGHT := 0.2
const SHAKE_BUDDY_BONUS := 3.0

var flee_until_msec := 0

func update(agent: Agent) -> void:
	var taggers := agent.get_taggers()
	var closest_tagger := agent.get_closest_child(taggers)
	if closest_tagger == null:
		set_wander(agent)
		return

	var distance := agent.global_position.distance_to(closest_tagger.global_position)
	if distance < FLEE_DISTANCE:
		set_flee(agent, closest_tagger, true)
	elif should_keep_fleeing():
		set_flee(agent, closest_tagger, false)
	elif distance < ALERT_DISTANCE:
		set_alert(agent, taggers)
	else:
		set_wander(agent)

func update_wander_target(_agent: Agent) -> void:
	pass

func get_speed(agent: Agent) -> float:
	match agent.flee_state:
		State.WANDER:
			return agent.movement_speed * 0.5
		State.ALERT:
			return agent.movement_speed * 0.8
		State.FLEE:
			return agent.movement_speed * 1.1
		_:
			return agent.movement_speed

func get_steering(agent: Agent) -> Vector3:
	if agent.is_it:
		return Vector3.ZERO

	var repulse := Vector3.ZERO
	for tagger in agent.get_taggers():
		var delta := tagger.global_position - agent.global_position
		var distance := maxf(delta.length(), MIN_REPULSE_DISTANCE)
		repulse += -delta / pow(distance, 1.5)
	repulse.y = 0

	match agent.flee_state:
		State.WANDER:
			return repulse
		State.ALERT:
			return repulse * 0.2
		State.FLEE:
			return Vector3.ZERO
		_:
			return repulse

func set_wander(agent: Agent) -> void:
	agent.flee_state = State.WANDER
	agent.state = "WANDER"
	agent.set_debug_color(agent.color)
	agent.movement.unsprint()
	agent.set_clamped_movement_target(get_high_spot(agent))

func set_alert(agent: Agent, taggers: Array[Agent]) -> void:
	agent.flee_state = State.ALERT
	agent.set_debug_color(Color.WHITE)
	agent.movement.unsprint()

	var high_spot := get_high_spot(agent)
	var shake_target := get_shake_target(agent)
	if shake_target != null and score_target(agent, shake_target.global_position, taggers, SHAKE_BUDDY_BONUS) > score_target(agent, high_spot, taggers):
		agent.state = "ALERT_SHAKE"
		agent.set_clamped_movement_target(shake_target.global_position)
		return

	agent.state = "ALERT_HIGH"
	agent.set_clamped_movement_target(high_spot)

func set_flee(agent: Agent, closest_tagger: Agent, refresh_memory: bool) -> void:
	if refresh_memory:
		flee_until_msec = Time.get_ticks_msec() + int(FLEE_MEMORY_SECONDS * 1000.0)

	agent.flee_state = State.FLEE
	agent.state = "FLEE"
	agent.set_debug_color(Color.DARK_RED)
	agent.movement.sprint()
	var direction_from_tagger := closest_tagger.global_position - agent.global_position
	agent.set_clamped_movement_target(agent.global_position - direction_from_tagger * FLEE_TARGET_MULTIPLIER)

func should_keep_fleeing() -> bool:
	return Time.get_ticks_msec() < flee_until_msec

func get_high_spot(agent: Agent) -> Vector3:
	if agent.manager.safe_spots.is_empty():
		return agent.wander_target

	var best: Node3D = null
	for spot in agent.manager.safe_spots:
		if best == null or spot.global_position.y > best.global_position.y:
			best = spot

	if best == null:
		return agent.wander_target
	return best.global_position

func get_shake_target(agent: Agent) -> Agent:
	var closest_distance := INF
	var closest_runner: Agent = null
	for runner in agent.get_runners():
		if runner == agent:
			continue

		if runner.flee_state == AgentFleeLogic.State.FLEE:
			continue

		var distance := runner.global_position.distance_squared_to(agent.global_position)

		if distance < closest_distance:
			closest_distance = distance
			closest_runner = runner
	return closest_runner

func score_target(agent: Agent, target: Vector3, taggers: Array[Agent], bonus := 0.0) -> float:
	var score := bonus - agent.global_position.distance_to(target) * SAFE_SPOT_TRAVEL_WEIGHT
	for tagger in taggers:
		score += tagger.global_position.distance_to(target) / len(taggers)
	return score
