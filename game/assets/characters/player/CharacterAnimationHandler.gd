extends Node
class_name CharacterAnimationHandler



# Entity parameters.
@export var _character : CharacterBody2D; # Character body to be animated.
@export var _movement_handler : MovementHandler; # Movement handler belonging to the body to be animated (for direction).
@export var _anim_tree : AnimationTree; # Animation tree to be updated.


# Internal variables.


# Physics process - runs 60 times a second. 
func _physics_process(_delta:float) -> void: # Animations are updated constantly.
	_set_blend_positions();
	if _character.get_parent().name.contains("Track"):
		_set_track_anims();
	else:
		_set_lobby_anims();
	
		
# Track animations (still = Idle, moving = Move).
func _set_track_anims() -> void:
	if (_character.velocity.length() > 0.1):
		_anim_tree.get("parameters/playback").travel("Move");
	else:
		_anim_tree.get("parameters/playback").travel("Idle");


# Lobby animations (waiting = Idle, ready = Move).
func _set_lobby_anims() -> void: 
	# Show lobby animations if player is not on the track.
	_movement_handler._move_dir = Vector2(0, 1); # Look at the user.
	match _character.is_ready:
		0: # Waiting.
			_anim_tree.get("parameters/playback").travel("Idle");
		1: 
			pass;
		2:
			pass;
		3: # Ready.
			_anim_tree.get("parameters/playback").travel("Move");
		
		
# Setting the blend positions for 2D blend spaces.
func _set_blend_positions() -> void:
	_anim_tree['parameters/Idle/blend_position'] = _movement_handler._move_dir;
	_anim_tree['parameters/Move/blend_position'] = _movement_handler._move_dir;
