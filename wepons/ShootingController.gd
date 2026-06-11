extends Node

const FIREBALL_SCENE = preload("res://wepons/Fireball.tscn")
const MIN_DRAG_DIST  = 20.0   # screen px — ignore accidental taps

# How much to scale screen-px drag into local game-units for the line preview.
# The game viewport is 492x267 mapped to the window, so screen px ≈ game px
# divided by the stretch scale. We keep it simple: just divide by viewport scale.
const LINE_SCALE = 0.5        # tune this if the line looks too long/short

# Local offset from Player origin to the sprite visual centre.
const PLAYER_CENTRE = Vector2(2.0, -13.0)

onready var player   : KinematicBody2D = get_parent()
onready var aim_line : Node2D          = $AimLine

var _aiming       := false
var _touch_index  := -1
var _drag_start   := Vector2.ZERO
var _drag_current := Vector2.ZERO

# ------------------------------------------------------------------ input
func _input(event):
	# ---- TOUCH ----
	if event is InputEventScreenTouch:
		if event.pressed and not _aiming:
			if not _is_on_hud(event.position):
				_aiming       = true
				_touch_index  = event.index
				_drag_start   = event.position
				_drag_current = event.position
				aim_line.active = true
		elif not event.pressed and event.index == _touch_index:
			_release()

	elif event is InputEventScreenDrag and event.index == _touch_index:
		_drag_current = event.position
		_update_aim_line()

	# ---- MOUSE (desktop) ----
	elif event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed and not _aiming:
			_aiming       = true
			_touch_index  = -1
			_drag_start   = event.position
			_drag_current = event.position
			aim_line.active = true
		elif not event.pressed and _touch_index == -1:
			_release()

	elif event is InputEventMouseMotion and _aiming and _touch_index == -1:
		_drag_current = event.position
		_update_aim_line()

# ------------------------------------------------------------------ helpers
func _update_aim_line():
	# Drag delta in screen pixels → scale down to local game-unit space.
	# Because Camera2D has no rotation, screen direction == world direction.
	var screen_delta = _drag_current - _drag_start
	var vp      = get_viewport()
	var vp_size = vp.get_visible_rect().size
	var game_size = Vector2(
		ProjectSettings.get_setting("display/window/size/width"),
		ProjectSettings.get_setting("display/window/size/height")
	)
	# Scale factor: how many screen pixels per game pixel
	var scale = game_size / vp_size
	# Convert screen delta to game-unit delta, then pass as local offset
	var local_delta = screen_delta * scale
	aim_line.set_aim(local_delta)

func _release():
	if not _aiming:
		return
	_aiming      = false
	_touch_index = -1
	aim_line.active = false
	aim_line.set_aim(Vector2.ZERO)

	var drag_vec = _drag_current - _drag_start
	if drag_vec.length() < MIN_DRAG_DIST:
		return
	_spawn_fireball(drag_vec.normalized())

func _spawn_fireball(screen_dir: Vector2):
	var fb = FIREBALL_SCENE.instance()
	player.get_parent().add_child(fb)
	# Spawn at player sprite centre, pushed forward in fire direction
	fb.global_position = player.global_position + PLAYER_CENTRE + screen_dir * 20.0
	fb.velocity = screen_dir * fb.SPEED

func _is_on_hud(screen_pos: Vector2) -> bool:
	var vp_height = get_viewport().get_visible_rect().size.y
	return screen_pos.y > vp_height - 140.0
