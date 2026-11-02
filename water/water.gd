extends Node2D

@export var hook: Hook
@export var follow_speed := 10.0   # higher = anchor tracks the mouse more tightly
@export var anchor_y := 0.0         # height the anchor slides along
@export var throw_slack_amount := 25.0

@onready var water_area: Area2D = $WaterArea
@onready var hud: Label = $HUD

func _ready() -> void:
	hook.anchor = Vector2(hook.global_position.x, anchor_y)

func _physics_process(delta: float) -> void:
	# Lateral only: the anchor slides along anchor_y, smoothed so mouse flicks don't teleport it
	var anchor_x := lerpf(hook.anchor.x, get_global_mouse_position().x, 1.0 - exp(-follow_speed * delta))
	hook.anchor = Vector2(anchor_x, anchor_y)

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		hook.spool = Hook.Spool.FREE
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		hook.spool = Hook.Spool.REELING
	else:
		hook.spool = Hook.Spool.LOCKED

func _process(_delta: float) -> void:
	hud.text = "length %.0f   slack %.0f   tension %.0f   %s   %s\nLMB reel   RMB free spool   wheel down: throw slack" % [
		hook.line_length, hook.slack(), hook.tension,
		Hook.Spool.keys()[hook.spool], "in water" if water_area.overlaps_body(hook) else "in air",
	]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		hook.give_slack(throw_slack_amount)
