extends Line2D

@export var segments := 20
@export var hook: Hook
@export var water_y := 150.0   # surface height in global coords

var pts: PackedVector2Array
var prev: PackedVector2Array

func _ready() -> void:
	pts.resize(segments)
	prev.resize(segments)
	for i in segments:
		pts[i] = hook.global_position
		prev[i] = pts[i]

func _physics_process(delta: float) -> void:
	var seg_len: float = hook.line_length / (segments - 1)

	# Verlet integrate: underwater points sink slower and lose more velocity
	for i in range(1, segments - 1):
		var under := pts[i].y > water_y
		var damp := 0.90 if under else 0.99
		var grav := 100.0 if under else 600.0
		var vel := (pts[i] - prev[i]) * damp
		prev[i] = pts[i]
		pts[i] += vel + Vector2(0, grav) * delta * delta

	# Pin the ends
	pts[0] = hook.anchor
	pts[segments - 1] = hook.global_position

	# Segments can't stretch past seg_len, but can go slack
	for _iter in 8:
		for i in segments - 1:
			var d := pts[i + 1] - pts[i]
			var l := d.length()
			if l > seg_len:
				var corr := d * (0.5 * (l - seg_len) / l)
				if i != 0:
					pts[i] += corr
				if i + 1 != segments - 1:
					pts[i + 1] -= corr

	points = pts * get_global_transform()
