extends Node
class_name CharacterAnimationHandler



# Entity parameters.


# Internal variables.
@export var _anim_body : CharacterBody2D; # The body to be animated.
@export var _anim_tree : AnimationTree; # Animation tree to be updated.


# Physics process - runs 60 times a second. 
func _physics_process(_delta:float) -> void: # Animations are updated constantly.		
	_set_blend_positions(); 
	if _anim_body.get_parent().name.contains("Track"): # Check if main node is a Track.
		_set_track_anims(); # Display track animations if character is on a track.
	else:
		_set_lobby_anims(); # Display lobby animations if character is NOT on a track.
	
		
# Track animations (standing still = Idle, moving = Move).
func _set_track_anims() -> void:
	if (_anim_body.sync_velocity > 0.1):
		_anim_tree.get("parameters/playback").travel("Move");
	else:
		_anim_tree.get("parameters/playback").travel("Idle");


# Lobby animations (ReadyStatus.Waiting = Idle, ReadyStatus.Ready = Move).
func _set_lobby_anims() -> void: 
	# Show lobby animations if player is not on the track.
	_anim_body.get_node("Components/MovementHandler").move_dir = Vector2(0, 1); # Look at the user while in the lobby.
	match GameManager.players[_anim_body.name].ready:
		int(GameManager.ReadyStatus.WAITING): # Waiting.
			_anim_tree.get("parameters/playback").travel("Idle");
		int(GameManager.ReadyStatus.DISCONNECTED): 
			pass;
		int(GameManager.ReadyStatus.ERROR):
			pass;
		int(GameManager.ReadyStatus.READY): # Ready.
			_anim_tree.get("parameters/playback").travel("Move");
		
		
# Setting the blend positions for 2D blend spaces.
func _set_blend_positions() -> void:
	_anim_tree['parameters/Idle/blend_position'] = _anim_body.sync_dir;
	_anim_tree['parameters/Move/blend_position'] = _anim_body.sync_dir;
