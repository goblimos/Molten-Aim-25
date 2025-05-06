extends AudioStreamPlayer

func _ready():
	play(2.0)

func _on_finished() -> void:
	play(2.0);
