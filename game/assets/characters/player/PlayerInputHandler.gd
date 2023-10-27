extends Node
class_name PlayerInputHandler


#// Constantly check for input and perform movement.
#        float accelDir = Input.GetAxis("Vertical"); // +1 = accelerating, -1 = braking/reversing.
#        movementHandler.SetVelocity(accelDir, _currDir);
#        float turnDir = Input.GetAxis("Horizontal"); // +1 = left, -1 = right.
#        _currDir = movementHandler.Turn(-turnDir, _currDir); // Turn direction needs to be inverted.

# Entity parameters.
@export var _player : PlayerController;
@export var _movement_handler : MovementHandler;

# Components and nodes.


# Internal variables.


# Physics process - runs 60 times a second.
func _physics_process(_delta:float) -> void:
	if !_player.get_parent().name.contains("Track"): # Don't check for movement if the player is not on a track.
		return
	
	if (Input.get_action_strength("brake") == 1): # Braking takes precedence over accelerating.
		_movement_handler.decelerate();
	elif (Input.get_action_strength("accelerate") == 1):
		_movement_handler.accelerate()
	else:
		_movement_handler.apply_friction();
	var turn_dir : float = Input.get_axis("turn_left", "turn_right"); # +1 = right, -1 = left.
	_movement_handler.turn(turn_dir);
	
	
