extends CanvasLayer

onready var btn_left  = $HBoxContainer/BtnLeft
onready var btn_right = $HBoxContainer/BtnRight
onready var btn_jump  = $BtnJump

func _ready():
	# Show only on touch-capable devices (hidden on desktop; kb/gamepad still work)
	visible = OS.has_touchscreen_ui_hint()

	btn_left.connect("button_down",  self, "_on_left_down")
	btn_left.connect("button_up",    self, "_on_left_up")
	btn_right.connect("button_down", self, "_on_right_down")
	btn_right.connect("button_up",   self, "_on_right_up")
	btn_jump.connect("button_down",  self, "_on_jump_down")
	btn_jump.connect("button_up",    self, "_on_jump_up")

func _on_left_down():  MobileInput.move_left  = true
func _on_left_up():    MobileInput.move_left  = false
func _on_right_down(): MobileInput.move_right = true
func _on_right_up():   MobileInput.move_right = false
func _on_jump_down():  MobileInput.jump       = true
func _on_jump_up():    MobileInput.jump       = false
