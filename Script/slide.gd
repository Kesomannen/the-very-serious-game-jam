extends Node3D

func _ready() -> void:
	$StartMarker.position = $Start.position
	$EndMarker.position = $End.position
	$NavigationLink3D.start_position = $Start.position
	$NavigationLink3D.end_position = $End.position

func _on_area_3d_body_entered(body: Node3D) -> void:
	if !body.has_method("on_slide_enter") || !body.has_method("on_slide_exit"):
		return
	
	#print("entering slide:  ", body.name)
	body.on_slide_enter()
	var tween = get_tree().create_tween()
	tween.tween_property(body, "global_position", $End.global_position, 1.0)
	await tween
	body.on_slide_exit()
	#print("exiting slide: ", body.name)
