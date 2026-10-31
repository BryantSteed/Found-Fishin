class_name Hook
extends RigidBody2D

enum Spool { LOCKED, REELING, FREE }

@export var min_length := 20.0
@export var max_length := 800.0
@export var reel_speed := 150.0
@export var stiffness := 60.0
@export var line_damping := 8.0
@export var water_drag := 0.02

var anchor := Vector2.ZERO
var line_length := 100.0
var spool := Spool.LOCKED
var tension := 0.0   # 0 while slack
var in_water := false

func slack() -> float:
	return line_length - global_position.distance_to(anchor)

func give_slack(amount: float) -> void:
	line_length = minf(line_length + amount, max_length)

func _physics_process(delta: float) -> void:
	var to_anchor := anchor - global_position
	var dist_to_anchor := to_anchor.length()

	match spool:
		Spool.REELING:
			line_length = maxf(line_length - reel_speed * delta, min_length)
		Spool.FREE:
			# Pay out line whenever the hook pulls, so it never goes taut
			line_length = minf(maxf(line_length, dist_to_anchor), max_length)

	# The line only pulls, never pushes
	tension = 0.0
	if dist_to_anchor > line_length:
		var dir_to_anchor := to_anchor / dist_to_anchor
		var stretch := dist_to_anchor - line_length
		# This is the radial velocity coefficient.
		var vel_along := linear_velocity.dot(dir_to_anchor)
		tension = maxf(stretch * stiffness - vel_along * line_damping, 0.0)
		apply_central_force(dir_to_anchor * tension * mass)

	# Quadratic water drag on top of the water Area2D's linear damp
	if in_water:
		var v := linear_velocity
		apply_central_force(-v * v.length() * water_drag * mass)
