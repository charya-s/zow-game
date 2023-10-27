extends Node
class_name MovementHandler



# Entity parameters.
@export var _body : CharacterBody2D; # Body to be moved.
@export var _max_speed : float = 200.0; # Maximum speed in pixels/frame.
@export var _forward_accel : float = 0.025; # Acceleration in pixels/frame2.
@export var _brake_decel : float = 0.05; # Braking deceleration in pixels/frame2.
@export var _reverse_multiplier : float = 0.33; # Reversing speed as a multiplier on _max_speed.
@export var _turn_angle : float = 0.08; # Turning angle in radians.
@export var _friction : float = 0.5; # Friction on the track as a deceleration in pixels/frame2.


# Internal variables.
var _move_dir : Vector2 = Vector2(-1, 0);


# Accelerate up to _max_speed at a rate of _forward_accel in _move_dir.
func accelerate() -> void:  
	_body.velocity = lerp(_body.velocity, _max_speed * _move_dir, _forward_accel);


# Accelerate down to -_max_speed*_reverse_multiplier at a rate of _brake_decel in _move_dir.
func decelerate() -> void:
	_body.velocity = lerp(_body.velocity, _max_speed * _move_dir * -_reverse_multiplier, _brake_decel);


# Apply friction (*)decelerate to zero) on a curve - friction is greater at lower speeds.
func apply_friction() -> void: 
	_body.velocity = lerp(_body.velocity, Vector2.ZERO, _friction/(_body.velocity.length()+1));


# Turn the body by the turning angle in the direction input and returns the new move direction.
func turn(turn_dir:float):
	if (_body.velocity.length() > 0.1 && (turn_dir != 0)): # If moving, turn by the turn angle amount in the direction of turn input.
		_move_dir = (_move_dir + _move_dir.rotated(turn_dir * _turn_angle)).normalized();
