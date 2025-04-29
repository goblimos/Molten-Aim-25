extends CharacterBody3D

@export_group("Movement")
@export var ACCEL := 10
@export var DEACCEL := 30
@export var SPEED := 3.0
@export var SPRINT_MULT := 3
@export var JUMP_VELOCITY := 4.5

@export_group("Sensitivity")
@export var MOUSE_SENSITIVITY := 0.06
@export var STICK_SENSITIVITY := 150

@export_group("Camera")
@export var clamp_max := 1.4
@export var clamp_min := -1.4
@export var bobbing := true
@export var BOB_SPEED := .1
@export var BOB_SIZE := .0025

@export_category("Actions")
@export_group("Move")
@export var move_left_action := "move_left"
@export var move_right_action := "move_right"
@export var move_forward_action := "move_forward"
@export var move_backward_action := "move_backward"
@export var jump_action := "jump"
@export var sprint_action := "sprint"
@export_group("Look")
@export var look_left_action := "look_left"
@export var look_right_action := "look_right"
@export var look_up_action := "look_up"
@export var look_down_action := "look_down"

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera : Camera3D = get_node("Camera3D")
var camera_start_position : Vector3
var dir = Vector3.ZERO
var running = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera_start_position = camera.position

func _input(event):
	# Controls player camera with mouse.
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		camera.rotation.x = camera.rotation.x + clampf(
			deg_to_rad(event.relative.y * MOUSE_SENSITIVITY * -1),
			clamp_min,
			clamp_max,
		)
		self.rotate_y(deg_to_rad(event.relative.x * MOUSE_SENSITIVITY * -1))
	
	else:
		# Release/Grab Mouse for debugging. You can change or replace this.
		if Input.is_action_just_pressed("ui_cancel"):
			if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta):
	# Controls player camera with gamepad
	var look_vector = Input.get_vector(look_right_action,look_left_action,look_down_action,look_up_action)
	#var look_vector = Vector2.ZERO
	#look_vector.x = Input.get_action_strength("look_left") - Input.get_action_strength("look_right")
	#look_vector.y = Input.get_action_strength("look_up") - Input.get_action_strength("look_down")
	
	self.rotate_y(deg_to_rad(look_vector.x) * STICK_SENSITIVITY * delta)
	camera.rotate_x(deg_to_rad(look_vector.y) * STICK_SENSITIVITY * delta)
	camera.rotation.x = clampf(camera.rotation.x, -1.4, 1.4)

func _physics_process(delta):
	var moving = false
	# Add the gravity. Pulls value from project settings.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed(jump_action) and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# This just controls acceleration. Don't touch it.
	var accel
	if dir.dot(velocity) > 0:
		accel = ACCEL
		moving = true
	else:
		accel = DEACCEL
		moving = false


	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector(move_left_action, move_right_action, move_forward_action, move_backward_action)
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)) * accel * delta
	
	# Run if sprint btn pressed and player moving. Once stopped, disable run
	if Input.is_action_just_pressed(sprint_action) or Input.is_action_pressed(sprint_action):
		running = true
	if direction == Vector3.ZERO:
		running = false
	if running:
		direction = direction * SPRINT_MULT

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()
	
	# Push objects
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider(0)
		var inertia = 50
		if collider is RigidBody3D:
			if collider.mass < inertia:
				inertia = collider.mass
			collider.apply_central_impulse(-get_slide_collision(i).get_normal()*inertia)
	
	# Bobbing animation
	if bobbing:
		if velocity and is_on_floor():
			var bob = Vector3.ZERO
			var actual_bob_speed = velocity.length()/(SPEED/2) * BOB_SPEED
			var actual_bob_size = velocity.length()/(SPEED/2) * BOB_SIZE
			bob.y += sin(Engine.get_process_frames() * actual_bob_speed) * actual_bob_size
			bob.x += cos(Engine.get_process_frames() * actual_bob_speed/2) * actual_bob_size * 2
			camera.position += bob
		elif camera.position != camera_start_position:
			camera.position = lerp(camera.position, camera_start_position, 2 * (1/.3) * delta)


func _on_fps_hands_give_damage(obj:Node3D, damage:float, point:Vector3):
	var label := Label3D.new()
	label.text = str(int(damage))
	label.pixel_size = .0015
	label.fixed_size = true
	label.no_depth_test = true
	label.position = point
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	#label.look_at_from_position(point, camera.global_position, Vector3(0,1,0), true)
	
	var timer := Timer.new()
	timer.wait_time = .5
	timer.autostart = true
	timer.connect("timeout", label.queue_free)
	
	get_tree().root.add_child(label)
	label.add_child(timer)


func _on_fps_hands_update_ammo(magazine, inventory_ammo, ammo_type):
	$UI/AmmoLabel.text = str(magazine) +"/"+ str(inventory_ammo) +"\n"+ ammo_type
