extends Node2D

@export var hook: Hook
@export var follow_speed := 10.0   # higher = anchor tracks the mouse more tightly

@onready var water_area: Area2D = $WaterArea
@onready var hud: Label = $HUD

func _ready() -> void:
	hook.anchor = Vector2(hook.global_position.x, 0.0)
	water_area.body_entered.connect(_on_water_body_changed.bind(true))
	water_area.body_exited.connect(_on_water_body_changed.bind(false))

func _on_water_body_changed(body: Node2D, entered: bool) -> void:
	if body is Hook:
		body.in_water = entered

func _physics_process(delta: float) -> void:
	# Lateral only: the anchor slides along y = 0, smoothed so mouse flicks don't teleport it
	var x := lerpf(hook.anchor.x, get_global_mouse_position().x, 1.0 - exp(-follow_speed * delta))
	hook.anchor = Vector2(x, 0.0)

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		hook.spool = Hook.Spool.FREE
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		hook.spool = Hook.Spool.REELING
	else:
		hook.spool = Hook.Spool.LOCKED

func _process(_delta: float) -> void:
	hud.text = "length %.0f   slack %.0f   tension %.0f   %s   %s\nLMB reel   RMB free spool   wheel down: throw slack" % [
		hook.line_length, hook.slack(), hook.tension,
		Hook.Spool.keys()[hook.spool], "in water" if hook.in_water else "in air",
	]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		hook.give_slack(25.0)
