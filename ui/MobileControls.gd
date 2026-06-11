extends CanvasLayer

# ── Joystick tuning ──────────────────────────────────────────────────────────
const BASE_RADIUS    = 65.0   # outer ring radius (screen px)
const KNOB_RADIUS    = 28.0   # draggable knob radius (screen px)
const H_DEAD_ZONE    = 0.18   # fraction of BASE_RADIUS for horizontal dead zone
const JUMP_THRESHOLD = -0.55  # normalised Y to trigger jump  (-1 = full up)

# ── Colors ───────────────────────────────────────────────────────────────────
const BASE_FILL    = Color(1.0, 1.0, 1.0, 0.10)
const BASE_RING    = Color(1.0, 1.0, 1.0, 0.35)
const KNOB_IDLE    = Color(1.0, 1.0, 1.0, 0.50)
const KNOB_ACTIVE  = Color(0.45, 0.85, 1.0, 0.90)

onready var draw_node : Control = $JoystickDraw

# ── State ─────────────────────────────────────────────────────────────────────
var _touch_idx  = -1
var _base       = Vector2.ZERO   # screen-space base centre
var _knob       = Vector2.ZERO   # screen-space knob centre
var _is_active  = false
var _was_up     = false          # rising-edge jump detection

func _ready():
	visible = (OS.get_name() == "iOS" or OS.get_name() == "Android")
	_park_base()

func _park_base():
	# Default resting position — bottom-left corner
	var vp = get_viewport().get_visible_rect().size
	_base = Vector2(BASE_RADIUS + 20.0, vp.y - BASE_RADIUS - 20.0)
	_knob = _base

# ── Input ─────────────────────────────────────────────────────────────────────
func _input(event: InputEvent):
	if event is InputEventScreenTouch:
		if event.pressed and _touch_idx == -1:
			var half_w = get_viewport().get_visible_rect().size.x * 0.5
			if event.position.x < half_w:        # left half of screen only
				_touch_idx = event.index
				_base      = event.position       # floating base follows first touch
				_knob      = event.position
				_is_active = true
				draw_node.update()
		elif not event.pressed and event.index == _touch_idx:
			_release()

	elif event is InputEventScreenDrag and event.index == _touch_idx:
		_move_stick(event.position)

func _move_stick(touch_pos: Vector2):
	var delta  = touch_pos - _base
	var dist   = delta.length()
	var clamped = delta.normalized() * min(dist, BASE_RADIUS)
	_knob = _base + clamped

	var norm = clamped / BASE_RADIUS   # Vector2 in range -1..1

	# ── Horizontal movement ──────────────────────────────────
	if norm.x < -H_DEAD_ZONE:
		MobileInput.move_left  = true
		MobileInput.move_right = false
	elif norm.x > H_DEAD_ZONE:
		MobileInput.move_left  = false
		MobileInput.move_right = true
	else:
		MobileInput.move_left  = false
		MobileInput.move_right = false

	# ── Jump (rising-edge only so it doesn't auto-repeat) ────
	var is_up = norm.y < JUMP_THRESHOLD
	MobileInput.jump = is_up and not _was_up
	_was_up = is_up

	draw_node.update()

func _release():
	_touch_idx = -1
	_is_active = false
	_was_up    = false
	MobileInput.move_left  = false
	MobileInput.move_right = false
	MobileInput.jump       = false
	_park_base()
	draw_node.update()
