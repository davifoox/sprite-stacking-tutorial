extends KinematicBody2D

onready var stacked_sprite = $StackedSprite
onready var collision_shape = $CollisionShape2D

var wheel_base = 30
#var steering_angle = 15
var steering_angle = 30
var engine_power = 400
var friction = -0.9
var drag = -0.001
var braking = -450
var max_speed_reverse = 250
var slip_speed = 400
var traction_fast = 0.1
var traction_slow = 0.7

var acceleration = Vector2.ZERO
var velocity = Vector2.ZERO
var steering_direction

func _physics_process(delta: float) -> void:
	acceleration = Vector2.ZERO
	get_input()
	apply_friction()
	calculate_steering(delta)
	velocity += acceleration * delta
	velocity = move_and_slide(velocity)
	set_sprites_rotation()

func apply_friction():
	if velocity.length() < 5:
		velocity = Vector2.ZERO
	var friction_force = velocity * friction
	var drag_force = velocity * velocity.length() * drag
	acceleration += drag_force + friction_force

func get_input():
	var turn = 0
	if Input.is_action_pressed("steer_right"):
		turn += 1
	if Input.is_action_pressed("steer_left"):
		turn -= 1
	steering_direction = turn * deg2rad(steering_angle)
	if Input.is_action_pressed("accelerate"):
		acceleration = transform.x * engine_power
	if Input.is_action_pressed("brake"):
		acceleration = transform.x * braking
		
func calculate_steering(delta):
	var rear_wheel = position - transform.x * wheel_base/2
	var front_wheel = position + transform.x * wheel_base/2
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steering_direction) * delta
	var new_heading = (front_wheel - rear_wheel).normalized()
	var traction = traction_slow
	if velocity.length() > slip_speed:
		traction = traction_fast
	var d = new_heading.dot(velocity.normalized())
	if d > 0:
		velocity = velocity.linear_interpolate(new_heading * velocity.length(), traction)
	if d < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)
	rotation = new_heading.angle()

func set_sprites_rotation():
#		var rotation_value = deg2rad(velocity.angle()) - deg2rad(90)
		var rotation_value = velocity.angle()
		
		stacked_sprite.set_rotation(rotation_value)
		collision_shape.rotation = deg2rad(rotation)
		print("Rotation Value: " + str(rotation_value))
