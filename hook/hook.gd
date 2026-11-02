class_name Hook
extends RigidBody2D

enum Spool { LOCKED, REELING, FREE }

@export var min_line_length := 20.0
@export var max_line_length := 800.0
@export var reel_speed := 150.0
@export var line_stiffness := 60.0
@export var line_damping := 8.0
@export var drag_coefficient := 1.0   # how hard this shape is to drag through fluid
@export var initial_line_length := 100.0

var anchor := Vector2.ZERO
var line_length := 0.0
var spool := Spool.LOCKED
var tension := 0.0   # 0 while slack

func _ready() -> void:
	line_length = initial_line_length

func slack() -> float:
	return line_length - global_position.distance_to(anchor)

func give_slack(amount: float) -> void:
	line_length = minf(line_length + amount, max_line_length)

func _physics_process(delta: float) -> void:
	var to_anchor := anchor - global_position
	var dist_to_anchor := to_anchor.length()

	match spool:
		Spool.REELING:
			line_length = maxf(line_length - reel_speed * delta, min_line_length)
		Spool.FREE:
			# Pay out line whenever the hook pulls, so it never goes taut
			line_length = minf(maxf(line_length, dist_to_anchor), max_line_length)

	# The line only pulls, never pushes
	tension = 0.0
	if dist_to_anchor > line_length:
		var dir_to_anchor := to_anchor / dist_to_anchor
		var stretch := dist_to_anchor - line_length
		# This is the radial velocity coefficient.
		var radial_velocity := linear_velocity.dot(dir_to_anchor)
		tension = maxf(stretch * line_stiffness - radial_velocity * line_damping, 0.0)
		apply_central_force(dir_to_anchor * tension * mass)
