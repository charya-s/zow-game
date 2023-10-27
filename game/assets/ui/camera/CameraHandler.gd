extends Camera2D


# Matches position with the player, following them.
func follow_local_player() -> void:
	global_position = lerp(global_position, Globals.local_player.global_position, 0.7);
