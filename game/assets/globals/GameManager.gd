extends Node

# Entity parameters.


# Components and nodes.


# Internal variables.
var players : Dictionary = {};
var local_player : CharacterBody2D;
var server_ip : String = "127.0.0.1";
var server_port : int = 8915;
var is_dedicated_server : bool = false;
var player_ready : ReadyStatus = ReadyStatus.WAITING;
enum ReadyStatus {
	WAITING,
	DISCONNECTED,
	ERROR,
	READY,
}


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
		
