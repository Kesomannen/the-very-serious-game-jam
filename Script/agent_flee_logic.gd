class_name AgentFleeLogic

extends RefCounted

enum State {
	WANDER,
	FLEE,
	PANIC,
}

const PANIC_DISTANCE := 4.0
const FLEE_DISTANCE := 12.0
const PANIC_TARGET_MULTIPLIER := 4.0
const WANDER_TARGET_RADIUS_SQUARED := 2.0
const MIN_REPULSE_DISTANCE := 0.001

func update(agent: Agent) -> void:
	var taggers := agent.get_taggers()
	var closest_tagger := agent.get_closest_child(taggers)
	if closest_tagger == null:
		set_wander(agent)
		return

	var distance := agent.global_position.distance_to(closest_tagger.global_position)
	if distance < PANIC_DISTANCE:
		set_panic(agent, closest_tagger)
	elif distance < FLEE_DISTANCE:
		set_flee(agent, taggers)
	else:
		set_wander(agent)

func update_wander_target(agent: Agent) -> void:
	if agent.flee_state == State.WANDER and agent.global_position.distance_squared_to(agent.wander_target) < WANDER_TARGET_RADIUS_SQUARED:
		agent.pick_new_wander_target()

func get_speed(agent: Agent) -> float:
	match agent.flee_state:
		State.WANDER:
			return agent.movement_speed * 0.5
		State.FLEE:
			return agent.movement_speed * 0.8
		State.PANIC:
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
		State.FLEE:
			return repulse * 0.2
		State.PANIC:
			return Vector3.ZERO
		_:
			return repulse

func set_wander(agent: Agent) -> void:
	agent.flee_state = State.WANDER
	agent.state = "WANDER"
	agent.set_debug_color(agent.color)
	agent.set_clamped_movement_target(agent.wander_target)

func set_flee(agent: Agent, taggers: Array[Agent]) -> void:
	agent.flee_state = State.FLEE
	agent.state = "FLEE"
	agent.set_debug_color(agent.color)
	agent.set_clamped_movement_target(get_best_safespot(agent, taggers))

func set_panic(agent: Agent, closest_tagger: Agent) -> void:
	agent.flee_state = State.PANIC
	agent.state = "PANIC"
	agent.set_debug_color(Color.DARK_RED)
	var direction_from_tagger := closest_tagger.global_position - agent.global_position
	agent.set_clamped_movement_target(agent.global_position - direction_from_tagger * PANIC_TARGET_MULTIPLIER)

func get_best_safespot(agent: Agent, taggers: Array[Agent]) -> Vector3:
	if taggers.is_empty() or agent.manager.safe_spots.is_empty():
		return agent.wander_target

	var best: Node3D = null
	var best_score := -INF
	for spot in agent.manager.safe_spots:
		var dist_to_spot := agent.global_position.distance_to(spot.global_position)
		var tagger_dist_to_spot := 0.0
		for tagger in taggers:
			tagger_dist_to_spot += tagger.global_position.distance_to(spot.global_position)
		var score := tagger_dist_to_spot / len(taggers) - dist_to_spot / 5.0
		if score > best_score:
			best_score = score
			best = spot

	if best == null:
		return agent.wander_target
	return best.global_position
