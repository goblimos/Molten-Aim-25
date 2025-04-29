extends Node3D

signal collision(obj:Node3D, damage:float, point:Vector3, collision_normal:Vector3)

var speed : float = 50.0
var damage : float = 10.0
var distance : float = 30.0 # aka range
var collision_mask : int = 1
var direction := Vector3(0, 0, -speed)
var gravity := ProjectSettings.get_setting("physics/3d/default_gravity_vector")
var collided := false

@onready var origin := global_position
@onready var raycast : RayCast3D = $RayCast3D

func _ready() -> void:
	raycast.collision_mask = collision_mask
	$Area3D.collision_mask = collision_mask

func collide(collider:Node3D) -> void:
	if collided: return
	collided = true
	#process_mode = Node.PROCESS_MODE_DISABLED
	damage -= damage/distance*global_position.distance_to(origin)
	
	if raycast.is_colliding():
		collision.emit(collider, damage, raycast.get_collision_point(), raycast.get_collision_normal())
	else:
		collision.emit(collider, damage, global_position, raycast.global_position.normalized())
	
	queue_free()

func _physics_process(delta: float) -> void:
	if raycast.is_colliding():
		collide(raycast.get_collider())
	else:
		if global_position.distance_to(origin) >= distance:
			direction += gravity * (delta*2)
		position += transform.basis * direction * delta

func _on_area_3d_body_entered(body: Node3D) -> void:
	collide(body)
