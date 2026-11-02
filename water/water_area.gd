extends Area2D

# Gravity and linear damp come from this area's own Inspector properties;
# the engine has no setting for quadratic drag, so it's applied here.
@export var fluid_drag_strength := 0.005   # ½ρ folded into one tuning value

func _physics_process(_delta: float) -> void:
	for body in get_overlapping_bodies():
		var rigid_body := body as RigidBody2D
		if rigid_body == null:
			continue
		# Each body describes its own shape's drag; bodies without one get the default
		var drag_coefficient: float = rigid_body.get("drag_coefficient") if "drag_coefficient" in rigid_body else 1.0
		var velocity := rigid_body.linear_velocity
		rigid_body.apply_central_force(-velocity * velocity.length() * fluid_drag_strength * drag_coefficient * rigid_body.mass)
