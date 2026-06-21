class_name AgentChaseLogic

extends RefCounted

enum State {
	IDLE,
	CHASE_RUNNER,
}

const SPRINT_TO_TARGET_DISTANCE := 7.0

func update(agent: Agent) -> void:
	var closest_runner := agent.get_closest_child(agent.get_runners())
	if closest_runner == null:
		agent.chase_state = State.IDLE
		agent.state = "CHASE_IDLE"
		agent.set_debug_color(Color.RED)
		agent.movement.unsprint()
		return

	agent.chase_state = State.CHASE_RUNNER
	agent.state = "CHASE_RUNNER"
	agent.set_debug_color(Color.RED)
	if agent.global_position.distance_to(closest_runner.global_position) > SPRINT_TO_TARGET_DISTANCE:
		agent.movement.sprint()
	else:
		agent.movement.unsprint()
	agent.set_movement_target(closest_runner.global_position)
