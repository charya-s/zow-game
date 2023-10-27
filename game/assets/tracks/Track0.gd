extends TrackController


# Initialization function to set track variables.
func _init():
	_friction = 0.5;
	_start_dir = Vector2(-1, 0);
	_start_timer = 5;
