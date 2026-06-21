class_name BetManager

extends Node

@export var lineup_point: Node3D
@export var spacing := 0.5
@export var hover_height := 0.1

@onready var manager: Manager = %Manager
@onready var player: Player = %Player

var money := 100.0
var bet: float
var selected_child: Agent

func _ready():
	manager.runner_won.connect(_on_runner_won)
	show_ui(false)
	new_round.call_deferred()

func _on_runner_won(runner: Agent):
	if runner == selected_child:
		print("You won the bet!")
		money += bet * 2
	else:
		print("You lost the bet!")
	await get_tree().create_timer(5.0).timeout
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
	selected_child = null
	player.enter(Player.State.Betting)
	manager.pick_chaser()
	lineup_children()

func start_round():
	show_ui(false)
	
	for child in manager.children:
		child.input_event.disconnect(_on_child_input_event)
		child.mouse_entered.disconnect(_on_child_mouse_entered)
		child.mouse_exited.disconnect(_on_child_mouse_exited)
	
	manager.pick_chaser()
	manager.start_playing()
	player.enter(Player.State.Scouting)

func _on_child_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int, child: Agent) -> void:
	if event is not InputEventMouseButton or selected_child != null || child.is_it:
		return
	selected_child = child
	print("Placed bet on ", child.name)
	show_ui(true)

func _on_child_mouse_entered(child: Agent):
	if selected_child != null || child.is_it:
		return
	child.position.y += hover_height

func _on_child_mouse_exited(child: Agent):
	if selected_child != null || child.is_it:
		return
	child.position.y -= hover_height

func show_ui(show: bool):
	$BetUI.visible = show
	if show:
		$BetUI/Slider.max_value = money
		$BetUI/Slider.value = money / 2

func _on_slider_value_changed(value: float) -> void:
	$BetUI/Amount.text = "$" + str(value) + "/$" + str(money)

func _on_button_pressed() -> void:
	bet = $BetUI/Slider.value
	money -= bet
	start_round()
