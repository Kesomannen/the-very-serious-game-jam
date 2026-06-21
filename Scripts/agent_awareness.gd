class_name AgentAwareness

extends RefCounted

const DEFAULT_VIEW_DISTANCE := 25.0

func visible_targets(agent: Agent) -> Array[Agent]:
	return get_visible_agents(agent, agent.get_runners())

func visible_taggers(agent: Agent) -> Array[Agent]:
	return get_visible_agents(agent, agent.get_taggers())

func get_visible_agents(agent: Agent, candidates: Array[Agent]) -> Array[Agent]:
	var visible: Array[Agent] = []
	for candidate in candidates:
		if is_nearby(agent, candidate):
			visible.append(candidate)
	return visible

func is_nearby(agent: Agent, target: Agent) -> bool:
	return agent.global_position.distance_to(target.global_position) <= DEFAULT_VIEW_DISTANCE
