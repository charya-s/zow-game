extends Node
class_name MovementHandler



# Entity parameters.


# Components and nodes.
@export var move_body : CharacterBody2D; # Body to be moved.


# Internal variables.
var move_dir : Vector2;
var _friction : float;


# On-ready function.
func _ready() -> void:
	if move_body.get_parent().name.contains("Track"): # If on track, get track variables.
		move_dir = move_body.get_parent().start_dir;
		_friction = move_body.get_parent().friction;


# Accelerate up to _max_speed at a rate of _forward_accel in _move_dir.
func accelerate() -> void:  
	var new_velocity = lerp(move_body.velocity, move_body.max_speed * move_dir, move_body.forward_accel);
	move_body.velocity = new_velocity;


# Accelerate down to -_max_speed*_reverse_multiplier at a rate of _brake_decel in _move_dir.
func decelerate() -> void:
	var new_velocity = lerp(move_body.velocity, move_body.max_speed * move_dir * -move_body.reverse_multiplier, move_body.brake_decel);
	move_body.velocity = new_velocity;


# Apply friction (*)decelerate to zero) on a curve - friction is greater at lower speeds.
func apply_friction() -> void: 
	var new_velocity = lerp(move_body.velocity, Vector2.ZERO, _friction/(move_body.velocity.length()+1));
	move_body.velocity = new_velocity;


# Turn the body by the turning angle in the direction input and returns the new move direction.
func turn(turn_dir:float):
	move_dir = (move_dir + move_dir.rotated(turn_dir * move_body.turn_angle)).normalized();
