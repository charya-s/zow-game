extends Node



# Player information
var players := {}; # List of players connected to the lobby.
var local_player : CharacterBody2D; # Local player.

# Lobby information.
var lobby_name := ""; # Name of connected lobby.
var host_name := ""; # Name of the host.
var host_id := 0; # ID of the host.

# True if launched as a server.
var is_dedicated_server := false; 

# Is the local player ready to start the game? 
enum ReadyStatus {
	WAITING,
	DISCONNECTED,
	ERROR,
	READY,
}

# Available characters.
enum Characters {
	BOB,
}


# Initialization function.
func _init() -> void:
	if "--server" in OS.get_cmdline_args():
		is_dedicated_server = true;


# Physics process.
func _physics_process(_delta:float) -> void:
	# Toggle fullscreen mode.
	if (Input.is_action_just_pressed("fullscreen_toggle")):
		_toggle_fullscreen();


# Toggle fullscreen mode.
func _toggle_fullscreen() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		
