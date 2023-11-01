extends TrackController


# Initialization function to set track variables.
func _init():
	friction = 0.5;
	start_dir = Vector2(-1, 0);
	_start_timer = 5;



# Stop the timer once the countdown ends and the race starts.
func _on_start_timer_timeout():
	_timer.stop();
