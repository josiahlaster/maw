class_name Player
extends KinematicBody2D

const UP = Vector2(0, -1)
const JOY_AXIS_0 = 0  # Left stick horizontal
const JOY_AXIS_1 = 1  # Left stick vertical
const DEADZONE = 0.2

export var ACCELERATION = 500
export var MAX_SPEED = 10170
export var GRAVITY = 6050.5
export var JUMP_POWER = 7100

enum {
	MOVE,
	JUMP
}

onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")
onready var jump_timer = $JumpTimer

var velocity = Vector2.ZERO
var last_direction = Vector2.ZERO
var state = MOVE
var default_speed = 1

var jumping = false

func _ready():
	print("Connected Joypads: ", Input.get_connected_joypads())

func _physics_process(delta):
	# Jump via button press or stick up
	if (Input.is_action_pressed("jump") or Input.get_joy_axis(0, JOY_AXIS_1) < -0.7) and state != JUMP:
		state = JUMP
		jumping = true
		jump_timer.start()

	match state:
		MOVE:	
			move_state(delta)
		JUMP:	
			jump_state(delta)
	
	velocity.y += GRAVITY * delta
	velocity = move_and_slide(velocity, UP)

func jump_state(delta):
	if jumping:
		velocity.y -= JUMP_POWER * delta
	elif is_on_floor():
		state = MOVE
		velocity = Vector2.ZERO

func move_state(delta):
	if !is_on_floor():
		return

	var input_vector = Vector2.ZERO

	# Try analog input first
	var analog_x = Input.get_joy_axis(0, JOY_AXIS_0)
	if abs(analog_x) > DEADZONE:
		input_vector.x = analog_x
	else:
		# Fallback to D-pad (digital buttons mapped in Input Map)
		input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	input_vector = input_vector.normalized()

	if input_vector != Vector2.ZERO:
		last_direction = input_vector
		velocity = input_vector * MAX_SPEED * delta
	else:
		velocity = Vector2.ZERO

	animation_tree.set("parameters/Idle/blend_position", last_direction.normalized())
	animation_tree.set("parameters/Run/blend_position", last_direction.normalized())

	if velocity != Vector2.ZERO:
		animation_state.travel("Run")
	else:
		animation_state.travel("Idle")

func _on_JumpTimer_timeout():
	jumping = false
