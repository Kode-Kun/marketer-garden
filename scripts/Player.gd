extends CharacterBody3D


@export var ground_speed = 15.0
@export var air_speed = 5.0
@export var jump_velocity = 3.5
@export var sensitivity = 0.003
@export var previous_velocity : Vector3
@export var max_velocity_ground = 9.0
@export var max_velocity_air = 10.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
@export var gravity = 9.8
@export var friction = 3.0

@onready var head = $Head
@onready var camera = $Head/Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func accelerate(delta, direction, max_velocity, speed):
	#var proj_vel = Vector3.dot(previous_velocity, direction)
	var proj_vel = previous_velocity.dot(direction)
	var accel_vel = speed * delta

	if proj_vel + accel_vel > max_velocity:
		accel_vel = max_velocity - proj_vel

	return previous_velocity + direction * accel_vel

func move_ground(delta, direction):
	var speed = previous_velocity.length()
	if speed:
		var drop = speed * friction * delta
		previous_velocity *= max(speed - drop, 0) / speed
	return accelerate(delta, direction, max_velocity_ground, ground_speed)

func move_air(delta, direction):
	return accelerate(delta, direction, max_velocity_air, air_speed)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("strafe_left", "strafe_right", "mv_forward", "mv_back")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction and is_on_floor():
		var vel = move_ground(delta, direction)
		velocity.x = vel.x
		velocity.z = vel.z
	elif not is_on_floor():
		var vel = move_air(delta, direction)
		velocity.x = vel.x
		velocity.z = vel.z
	else:
		var vel = move_ground(delta, direction)
		velocity.x = vel.x
		velocity.z = vel.z

	previous_velocity = Vector3(velocity.x, 0, velocity.z)
	move_and_slide()


#func Vector3 accelerate(delta: float, accel_dir: Vector3, prev_vel: Vector3, accelerate: float, max_vel: float):
#	var proj_vel = Vector3.dot(prev_vel, accel_dir)
#	var accel_vel = accelerate * delta
#
#	if prof_vel + accel_vel > max_vel:
#		accel_vel = max_vel - prov_vel
#	return prev_vel + accel_dir * accel_vel
