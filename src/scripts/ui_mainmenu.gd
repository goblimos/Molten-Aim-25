extends Control
	
func _on_start_button_down() -> void:
	$"AudioDesign/btn-click".play();
	$ui/starting.show();
	$Matching.start();


func _on_matching_timeout() -> void:
		get_tree().change_scene_to_file("res://maps/" + $ui/Maps.text + ".tscn");


# Ui AudioDesign
func _on_start_mouse_entered() -> void:
	$"AudioDesign/btn-hover".play();



func _on_maps_mouse_entered() -> void:
	$"AudioDesign/btn-hover".play();


func _on_maps_item_selected(index: int) -> void:
	$"AudioDesign/btn-click".play();


func _on_maps_item_focused(index: int) -> void:
	$"AudioDesign/btn-hover".play();
