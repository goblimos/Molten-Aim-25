extends Node3D

func _ready() -> void:
	$Cam.play("cam");

func _on_cam_animation_finished(anim_name: StringName) -> void:
	$Cam.play("cam");


func _on_gpufriendlylobby_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/lobby2.tscn")
