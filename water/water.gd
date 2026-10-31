extends Node2D

var line: Line2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var pos := get_global_mouse_position()
	self.line = Line2D.new()
	line.add_point(Vector2(pos.x, 0))
	line.add_point(Vector2(pos.x, pos.y))
	add_child(self.line)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var pos := get_global_mouse_position()
	self.line.clear_points()
	self.line.add_point(Vector2(pos.x, 0))
	line.add_point(pos)
