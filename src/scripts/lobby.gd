extends Node3D

func _ready() -> void:
	$Cam.play("cam");
	
func _on_start_button_down() -> void:
	$ui/starting.show();
	$Matching.start();


func _on_matching_timeout() -> void:
		get_tree().change_scene_to_file("res://maps/" + $ui/Maps.text + ".tscn");


func _on_cam_animation_finished(anim_name: StringName) -> void:
	$Cam.play("cam");
