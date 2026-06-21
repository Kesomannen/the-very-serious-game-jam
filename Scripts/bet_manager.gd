class_name BetManager

extends Node

@export var lineup_point: Node3D
@export var spacing := 0.5
@export var hover_height := 0.1

@onready var manager: Manager = %Manager

func _ready():
	manager.runner_won.connect(_on_runner_won)
	lineup_children()

func _on_runner_won(runner: Agent):
	await get_tree().create_timer(2.0).timeout
	new_round()

func lineup_children():
	var child_count = len(manager.children)
	for i in range(child_count):
		var child: Agent = manager.children[i]
		var offset = (i - child_count / 2 + 0.5) * spacing
		var pos = lineup_point.position + Vector3.RIGHT * offset
		child.position = pos
		child.input_event.connect(_on_child_input_event.bind(child))
		child.mouse_entered.connect(_on_child_mouse_entered.bind(child))
		child.mouse_exited.connect(_on_child_mouse_exited.bind(child))

func new_round():
	for child in manager.children:
		child.input_event.disconnect(_on_child_input_event)
		child.mouse_entered.disconnect(_on_child_mouse_entered)
		child.mouse_exited.disconnect(_on_child_mouse_exited)
	
	manager.pick_chaser()
	manager.start_playing()
	(%Player as Player).enter_scouting()

func _on_child_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int, child: Agent) -> void:
	if event is not InputEventMouseButton:
		return
	print("Placed bet on ", child.name)
	new_round()

func _on_child_mouse_entered(child: Agent):
	child.position.y += hover_height

func _on_child_mouse_exited(child: Agent):
	child.position.y -= hover_height
	
