extends Node2D



func _on_gpukillerlobby_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/lobby.tscn");
