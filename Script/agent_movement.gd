class_name AgentMovement

extends RefCounted

func get_desired_velocity(
	agent: Agent,
	navigation_agent: NavigationAgent3D,
	speed: float,
	steering: Vector3
) -> Vector3:
	var next_path_position := navigation_agent.get_next_path_position()
	var path_direction := agent.global_position.direction_to(next_path_position)
	return (path_direction + steering).normalized() * speed
