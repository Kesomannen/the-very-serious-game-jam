class_name BetManager

extends Node

@onready var manager: Manager = %Manager

func _ready() -> void:
	manager.runner_won.connect(_on_runner_won)
	manager.start_playing()

func _on_runner_won(runner: Agent) -> void:
	await get_tree().create_timer(2.0).timeout
	manager.start_playing()
