extends Node3D

func _ready():
	scale *= randf_range(0.9, 1.1)
	rotation_degrees.z = randf_range(-10.0, 10.0)
