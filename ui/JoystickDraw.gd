extends Control

func _process(_delta):
	# Must call update() every frame — _draw() only fires when update() is called.
	# Without this the joystick never appears or redraws as the knob moves.
	update()

func _draw():
	var mc = get_parent()
	var base = mc._base
	var knob = mc._knob
	var br   = mc.BASE_RADIUS
	var kr   = mc.KNOB_RADIUS

	# Always draw a ghost ring so the player knows where to press
	# (dimmer when idle, full when active)
	var alpha   = 0.55 if mc._is_active else 0.18
	var k_alpha = 0.75 if mc._is_active else 0.30

	# ── Base fill ──────────────────────────────────────────────────────────
	draw_circle(base, br, Color(1, 1, 1, alpha * 0.25))

	# ── Base outer ring ────────────────────────────────────────────────────
	var seg  = 48
	var prev = base + Vector2(br, 0)
	for i in range(1, seg + 1):
		var angle = TAU * i / seg
		var cur   = base + Vector2(cos(angle), sin(angle)) * br
		draw_line(prev, cur, Color(1, 1, 1, alpha), 2.5, true)
		prev = cur

	# ── Inner guide ring (50% radius) ─────────────────────────────────────
	var ir = br * 0.5
	prev = base + Vector2(ir, 0)
	for i in range(1, seg + 1):
		var angle = TAU * i / seg
		var cur   = base + Vector2(cos(angle), sin(angle)) * ir
		draw_line(prev, cur, Color(1, 1, 1, alpha * 0.4), 1.0, true)
		prev = cur

	# ── Knob ──────────────────────────────────────────────────────────────
	var knob_col = Color(0.45, 0.85, 1.0, k_alpha) if mc._is_active \
				 else Color(1.0,  1.0,  1.0, k_alpha)
	draw_circle(knob, kr, knob_col)

	# Knob outline
	prev = knob + Vector2(kr, 0)
	for i in range(1, seg + 1):
		var angle = TAU * i / seg
		var cur   = knob + Vector2(cos(angle), sin(angle)) * kr
		draw_line(prev, cur, Color(1, 1, 1, k_alpha * 0.9), 1.5, true)
		prev = cur
