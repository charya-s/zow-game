extends Node
class_name MovementHandler



# Entity parameters.
@export var _max_speed : float = 200.0; # Maximum speed in pixels/frame.
@export var _forward_accel : float = 0.025; # Acceleration in pixels/frame2.
@export var _brake_decel : float = 0.05; # Braking deceleration in pixels/frame2.
@export var _reverse_multiplier : float = 0.33; # Reversing speed as a multiplier on _max_speed.
@export var _turn_angle : float = 0.08; # Turning angle in radians.
@export var _friction : float = 0.5; # Friction on the track as a deceleration in pixels/frame2.

# Components and nodes.
@export var move_body : CharacterBody2D; # Body to be moved.


# Internal variables.
var move_dir : Vector2;
var new_velocity := Vector2.ZERO;


# On-ready function.
func _ready() -> void:
	if move_body.get_parent().name.contains("Track"): # If on track, get track variables.
		move_dir = move_body.get_parent().start_dir;
		_friction = move_body.get_parent().friction;


# Accelerate up to _max_speed at a rate of _forward_accel in _move_dir.
func accelerate() -> void:  
	new_velocity = lerp(move_body.velocity, _max_speed * move_dir, _forward_accel);
	move_body.velocity = new_velocity;


# Accelerate down to -_max_speed*_reverse_multiplier at a rate of _brake_decel in _move_dir.
func decelerate() -> void:
	new_velocity = lerp(move_body.velocity, _max_speed * move_dir * -_reverse_multiplier, _brake_decel);
	move_body.velocity = new_velocity;


# Apply friction (*)decelerate to zero) on a curve - friction is greater at lower speeds.
func apply_friction() -> void: 
	new_velocity = lerp(move_body.velocity, Vector2.ZERO, _friction/(move_body.velocity.length()+1));
	move_body.velocity = new_velocity;


# Turn the body by the turning angle in the direction input and returns the new move direction.
func turn(turn_dir:float):
	move_dir = (move_dir + move_dir.rotated(turn_dir * _turn_angle)).normalized();
