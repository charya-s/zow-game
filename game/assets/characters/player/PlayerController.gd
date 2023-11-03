extends CharacterBody2D
class_name PlayerController


# Entity parameters.
@export var max_speed : float = 200.0; # Maximum speed in pixels/frame.
@export var forward_accel : float = 0.025; # Acceleration in pixels/frame2.
@export var brake_decel : float = 0.05; # Braking deceleration in pixels/frame2.
@export var reverse_multiplier : float = 0.33; # Reversing speed as a multiplier on _max_speed.
@export var turn_angle : float = 0.08; # Turning angle in radians.

# Internal variables.
var sync_pos : Vector2;
var sync_velocity : int; # Only used for animations.
var sync_dir := Vector2(0, 1); # Only used for animations. Default looking at user.
var Sprites = {
	GameManager.Characters.BOB: "res://assets/characters/sprites/bob_sprite.png",
	GameManager.Characters.SKELEBOB: "res://assets/characters/sprites/skelebob_sprite.png",
	GameManager.Characters.CATBOB: "res://assets/characters/sprites/catbob_sprite.png",
	GameManager.Characters.BOBBEE: "res://assets/characters/sprites/bobbee_sprite.png",
}
var can_move := false;

# On-ready function.
func _ready() -> void:
	$MultiplayerSynchronizer.set_multiplayer_authority(int(str(name))); # Only give mult authority when on track.
	update_sprite(int(GameManager.players[str(name)].character)); # Start on the selected character.
	if (get_parent().name.contains("Track")):
		allow_move(true);


# Physics process - runs 60 times a second.
func _physics_process(_delta:float) -> void:
	if (can_move): # Only get and set the sync variables if on a track.
		# Only move if client is the owner of this player character.
		if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
			_update_sync_variables("set");
			move_and_slide();
		else:
			_update_sync_variables("get");


# Set up the player based on whether they're on a track or not.
func setup_player(is_on_track:bool, player_name:String) -> void:
	$PlayerName.text = player_name;
	if (!is_on_track): # Move the name below the player if not on track.
		$PlayerName.scale = Vector2(0.2, 0.2);
		$PlayerName.position = Vector2(-6, 8);


# Updating the synchronization variables.
func _update_sync_variables(mode:String):
	if mode == "set":
		sync_pos = global_position;
		sync_velocity = velocity.length();
		sync_dir = $Components/MovementHandler.move_dir;
		
	if mode == "get":
		global_position = lerp(global_position, sync_pos, 0.5);


# Update character model (sprite).
func update_sprite(selected_char:int):
	$PlayerSprite.texture = load(Sprites[selected_char]);


# Toggles allowing and disallowing movement.
func allow_move(state:bool) -> void:
	can_move = state;
