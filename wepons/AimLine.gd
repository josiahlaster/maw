extends Node2D

var active        : bool    = false
# End point in THIS node's LOCAL space — set each frame by ShootingController.
var local_target  : Vector2 = Vector2.ZERO

const DOT_RADIUS  = 3.0
const DOT_SPACING = 14.0
const DOT_COLOR   = Color(1.0, 0.55, 0.05, 0.88)
const ARROW_COLOR = Color(1.0, 0.85, 0.15, 1.00)

func _process(_delta):
	# Redraw every frame so the line follows the player as it moves.
	update()

func _draw():
	if not active:
		return

	var from  = Vector2.ZERO     # AimLine is positioned at player sprite centre
	var delta = local_target - from
	var dist  = delta.length()
	if dist < 1.0:
		return
	var unit = delta.normalized()

	# --- Dotted line ---
	var travelled = DOT_RADIUS
	while travelled < dist - 18.0:
		draw_circle(from + unit * travelled, DOT_RADIUS, DOT_COLOR)
		travelled += DOT_SPACING

	# --- Arrow head ---
	var tip  = from + unit * (dist - 2.0)
	var perp = unit.tangent() * 7.0
	var base = tip - unit * 14.0
	draw_colored_polygon(
		PoolVector2Array([tip, base + perp, base - perp]),
		ARROW_COLOR
	)

func set_aim(end_local: Vector2):
	local_target = end_local
