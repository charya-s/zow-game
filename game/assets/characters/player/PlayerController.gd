extends CharacterBody2D
class_name PlayerController


# Entity parameters.


# Internal variables.
var is_ready : int = 0;



# On-ready function.
func _ready() -> void:
	if get_parent().name.contains("Track"): # Checks if player is on tracks and performs set up if so.
		_setup_player_track();

# Physics process - runs 60 times a second.
func _physics_process(_delta:float) -> void:
	move_and_slide();


# Runs on ready only if the player is spawned onto a track.
func _setup_player_track():
	$PlayerName.visible = true
