extends TrackController


# Initialization function to set track variables.
func _init():
	friction = 0.5;
	start_dir = Vector2(-1, 0);
	_start_timer = 5;
