class_name Manager

extends Node

@export var children: Array[Agent]
@export var starting_spots: Array[Node3D]
@export var safe_spots: Array[Node3D]

var is_playing = false

signal runner_won(runner: Agent)

func _ready() -> void:
	set_children_active(false)

func _process(delta: float) -> void:
	if !is_playing:
		return
	
	# Check if someone has won
	var runners = children.filter(func(child): return !child.is_it)
	match len(runners):
		0:
			print("No runners left!")
			stop_playing()
		1:
			var winner = runners[0]
			print(winner.name, " won the game!")
			runner_won.emit(winner)
			stop_playing()

func start_playing():
	if is_playing:
		print("Tried to start game while already playing!")
		return
	spawn_children_randomly()
	set_children_active(true)
	is_playing = true
	print("Game started!")

func stop_playing():
	if !is_playing:
		print("Tried to stop game while not playing!")
		return
	set_children_active(false)
	reset_children()
	is_playing = false
	print("Game stopped!")

func spawn_children_randomly():
	var spots_remaining = starting_spots.duplicate()
	for child in children:
		var index = randi_range(0, len(spots_remaining) - 1)
		var spot = spots_remaining.pop_at(index)
		child.position = spot.position

func pick_chaser():
	var index = randi_range(0, len(children) - 1)
	var child = children[index]
	child.is_it = true
	child.set_debug_color(Color.RED)
	print(child.name, " is the chaser")

func set_children_active(active: bool):
	for child in children:
		child.set_active(active)

func reset_children():
	for child in children:
		child.reset()
