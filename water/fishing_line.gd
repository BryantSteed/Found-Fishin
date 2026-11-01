extends Line2D

@export var point_count := 20
@export var hook: Hook
@export var water_area: Area2D   # the rope reads the water surface from this
@export_range(0.0, 1.0) var air_momentum_kept := 0.99     # fraction of motion kept per tick
@export_range(0.0, 1.0) var water_momentum_kept := 0.90
@export var air_gravity := 600.0
@export var water_gravity := 100.0
@export var constraint_iterations := 8   # more = stiffer, less stretchy rope

var rope_points: PackedVector2Array
var prev_rope_points: PackedVector2Array
var water_surface_y := 0.0   # global y of the water area's top edge

func _ready() -> void:
	# Rope points aren't physics bodies, so the area can't detect them; read its top edge instead
	var water_shape := water_area.get_node("CollisionShape2D") as CollisionShape2D
	var water_rect := (water_shape.shape as RectangleShape2D).get_rect()
	water_surface_y = (water_shape.global_transform * water_rect.position).y

	rope_points.resize(point_count)
	prev_rope_points.resize(point_count)
	for i in point_count:
		rope_points[i] = hook.global_position
		prev_rope_points[i] = rope_points[i]

func _physics_process(delta: float) -> void:
	var max_gap_len: float = hook.line_length / (point_count - 1)

	# Verlet integrate: underwater points sink slower and lose more velocity
	for i in range(1, point_count - 1):
		var is_underwater := rope_points[i].y > water_surface_y
		var momentum_kept := water_momentum_kept if is_underwater else air_momentum_kept
		var gravity := water_gravity if is_underwater else air_gravity
		var carried_motion := (rope_points[i] - prev_rope_points[i]) * momentum_kept
		prev_rope_points[i] = rope_points[i]
		rope_points[i] += carried_motion + Vector2(0, gravity) * delta * delta

	# Pin the ends
	rope_points[0] = hook.anchor
	rope_points[point_count - 1] = hook.global_position

	# No gap between neighboring points can exceed max_gap_len, but gaps can shrink (slack)
	for _iter in constraint_iterations:
		for i in point_count - 1:
			var gap := rope_points[i + 1] - rope_points[i]
			var gap_len := gap.length()
			if gap_len > max_gap_len:
				var correction := gap * ((gap_len - max_gap_len) / gap_len)   # full excess
				var is_i_anchor := i == 0
				var is_next_hook := i + 1 == point_count - 1
				# Free pairs split the fix; a pinned point can't move, so its neighbor takes all of it
				if not is_i_anchor and not is_next_hook:
					rope_points[i] += correction * 0.5
					rope_points[i + 1] -= correction * 0.5
				elif not is_i_anchor:
					rope_points[i] += correction
				elif not is_next_hook:
					rope_points[i + 1] -= correction

	# rope_points are global; Line2D draws in local space. affine_inverse handles scale too.
	points = get_global_transform().affine_inverse() * rope_points
