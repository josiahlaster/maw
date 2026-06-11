extends Area2D

export var SPEED = 600.0

var velocity := Vector2.ZERO

onready var anim : AnimatedSprite   = $AnimatedSprite
onready var col  : CollisionShape2D = $CollisionShape2D

func _ready():
	# Build a brand-new SpriteFrames with both animations so we never
	# mutate the shared sub-resource from the .tscn file.
	var frames = SpriteFrames.new()

	# ── Fly (looping) ────────────────────────────────────────────────────────
	frames.add_animation("fly")
	frames.set_animation_speed("fly", 12.0)
	frames.set_animation_loop("fly", true)
	for path in [
		"res://wepons/spr_shooting/692db9a0-cf86-45b1-811a-4662301de2be.png",
		"res://wepons/spr_shooting/b1ae6a2b-9cab-4378-b345-36a7b91c806f.png",
		"res://wepons/spr_shooting/b2b01cdc-0ee7-4147-b0fd-b52f12fc7c88.png",
		"res://wepons/spr_shooting/b62ebf2d-9f1d-4204-ae0d-eb5a7ad64c2a.png",
		"res://wepons/spr_shooting/c24bf3b3-7eda-447e-9b72-b07b001131bd.png",
	]:
		frames.add_frame("fly", load(path))

	# ── Splat (one-shot, fast) ────────────────────────────────────────────────
	frames.add_animation("splat")
	frames.set_animation_speed("splat", 30.0)
	frames.set_animation_loop("splat", false)
	for path in [
		"res://wepons/spr_shooting_splat/a4a68122-ec0b-4cac-8032-739a7716cdfb.png",
		"res://wepons/spr_shooting_splat/52e9527a-8237-45c2-a7e2-a9812ee2910f.png",
		"res://wepons/spr_shooting_splat/333a499e-d94f-4064-b573-500715b4d616.png",
		"res://wepons/spr_shooting_splat/4c3b6af0-ac8d-4be5-b535-4748e0bad1d6.png",
	]:
		frames.add_frame("splat", load(path))

	anim.frames = frames
	anim.play("fly")

	# Disable collision for one frame so we don't self-collide on spawn
	monitoring = false
	set_deferred("monitoring", true)

	# Suppress the "return value discarded" warning with explicit assignment
	var _e1 = connect("body_entered", self, "_on_body_entered")
	var _e2 = connect("area_entered",  self, "_on_area_entered")
	var _e3 = anim.connect("animation_finished", self, "_on_anim_finished")

func _physics_process(delta):
	position += velocity * delta
	rotation  = velocity.angle()

func _on_body_entered(_body): _explode()
func _on_area_entered(_area):  _explode()

func _explode():
	if not is_physics_processing():
		return   # already exploding
	set_physics_process(false)
	# Both monitoring changes MUST be deferred when called from a signal
	set_deferred("monitoring", false)
	col.set_deferred("disabled", true)
	velocity = Vector2.ZERO
	rotation = 0.0
	anim.play("splat")

func _on_anim_finished():
	if anim.animation == "splat":
		queue_free()
