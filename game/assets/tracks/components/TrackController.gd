extends Node
class_name TrackController;


# Entity parameters.
@export var friction : float = 0.5; # Track friction.
@export var start_dir : Vector2 = Vector2(-1, 0); # The direction the player faces at the start.
@export var _start_timer : float = 5.0; # 5 seconds of prep before the race starts.
@export var lap_count : int = 3; # How many laps in this track.

# Components and nodes.
@onready var _spawn_handler : SpawnHandler = $Components/SpawnHandler;
@onready var _main_camera : Camera2D = $MainCamera;
@onready var _timer : Timer = $StartTimer;
@onready var _game_hud : GameHUD;

# Internal variables.
var player_laps = {}
var players_finished = {}

# # On-ready function.
func _ready():
	_spawn_handler.spawn_players(true); # Spawn players and return the local player.
	
	# Instantiate the in-game HUD.
	_game_hud = load("res://assets/ui/hud/GameHUD.tscn").instantiate();
	add_child(_game_hud);
	
	# Start the countdown for race start.
	_timer.start(_start_timer);
	
	# Set up the player checkpoint and lap count.
	for player in GameManager.players:
		player_laps[player] = {"id": player, "checkpoints": 0, "laps": 0};
	
	# Have the camera follow the local player.
	_main_camera.follow_player(GameManager.local_player);


# Physics process - runs 60 times a second.
func _physics_process(delta) -> void:
	pass


# Add new reached checkpoint to a player.
func pass_checkpoint(player_id:String, checkpoint:int) -> void:
	if player_laps[player_id].checkpoints == checkpoint-1: # Check if previous checkpoint was hit.
		player_laps[player_id].checkpoints += 1;


# Pass the finish line for a player, resetting checkpoint count.
func pass_finish_line(player_id:String) -> void:
	if player_laps[player_id].checkpoints == 4: 	# Check if the last checkpoint was hit.
		player_laps[player_id].checkpoints = 0; 	# Reset check point count at finish line.
		player_laps[player_id].laps += 1;			# Increment lap count at finish line.
		_game_hud.update_player_list(player_laps);  # Update hud to show lap count.
		
	if player_laps[player_id].laps == lap_count:
		finish_race(player_id);


# Finish the race for a player - stop movement and hide them completely.
func finish_race(player_id:String) -> void:
	players_finished[players_finished.size()] = player_id; # Add the player to the end of the finished list.
	for player in get_tree().get_nodes_in_group("Players"):
		if player.name == player_id:
			player.allow_move(false);
			player.get_node("CollisionShape2D").set_deferred("disabled",true);
			player.hide();
	
	# Set camera to follow a random player if all players are not finished.
	if players_finished.size() != GameManager.players.size():
		_main_camera.follow_random_player();
	else: # Else, if all players are finished, send the finished list to the HUD.
		_game_hud.display_leaderboard(players_finished);
