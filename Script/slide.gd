extends Node3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name != "Agent" && body.name != "Player":
		return;
	print("entering slide:sasa ", body)
	body.on_slide_enter()
	var tween = get_tree().create_tween()
	tween.tween_property(body, "global_position", $End.global_position, 1.0)
	await tween
	body.on_slide_exit()
	print("exiting slide: ", body)
