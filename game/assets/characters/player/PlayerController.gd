extends CharacterBody2D
class_name PlayerController


# Entity parameters.


# Internal variables.


# On-ready function.
func _ready() -> void:
	pass

# Physics process - runs 60 times a second.
func _physics_process(_delta:float) -> void:
	move_and_slide();


# Set up the player based on whether they're on a track or not.
func setup_player(is_on_track:bool, player_name:String) -> void:
	$PlayerName.visible = is_on_track;
	$PlayerName.text = player_name;
