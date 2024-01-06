extends Node
class_name PlayerInputHandler


# Entity parameters.


# Components and nodes.
@export var _player : PlayerController;
@export var _movement_handler : MovementHandler;
@export var _multi_sync : MultiplayerSynchronizer;

# Internal variables.


# Physics process - runs 60 times a second.
func _physics_process(_delta:float) -> void:
	if !_player.can_move: # Don't check for movement if the player is not on a track.
		return
		
	if  _player.get_parent().get_node("StartTimer").time_left != 0:	 # Don't check for movement if race hasn't started.
		return
		
	# Only take inputs if client is the owner of this player character.
	if _multi_sync.get_multiplayer_authority() != multiplayer.get_unique_id():
		return
	
	if (Input.get_action_strength("brake") == 1): # Braking takes precedence over accelerating.
		_movement_handler.decelerate();
	elif (Input.get_action_strength("accelerate") == 1):
		_movement_handler.accelerate()
	else:
		_movement_handler.apply_friction();
		
	var turn_dir : float = Input.get_axis("turn_left", "turn_right"); # +1 = right, -1 = left.
	if (_player.velocity.length() > 0.1) && (turn_dir != 0): # Only turn if moving.
		_movement_handler.turn(turn_dir);
	
	
