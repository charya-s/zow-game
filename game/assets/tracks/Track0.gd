extends TrackController


# Initialization function to set track variables.
func _init():
	friction = 0.5;
	start_dir = Vector2(-1, 0);
	_start_timer = 5;
	lap_count = 1;



# Stop the timer once the countdown ends and the race starts.
func _on_start_timer_timeout():
	race_started = true; # Set race started.
	_timer.stop();





# Increment the checkpoint count for the player if the last checkpoints were reached.
func _on_checkpoint_1_body_entered(body):
	pass_checkpoint(body.name, 1);
	
func _on_checkpoint_2_body_entered(body):
	pass_checkpoint(body.name, 2);

func _on_checkpoint_3_body_entered(body):
	pass_checkpoint(body.name, 3);

func _on_checkpoint_4_body_entered(body):
	pass_checkpoint(body.name, 4);

# Finish line.
func _on_finish_body_entered(body):
	pass_finish_line(body.name);
