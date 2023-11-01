extends Node
class_name TrackController;


# Entity parameters.
@export var friction : float = 0.5; # Track friction.
@export var start_dir : Vector2 = Vector2(-1, 0); # The direction the player faces at the start.
@export var _start_timer : float = 5.0; # 5 seconds of prep before the race starts.

# Components and nodes.
@onready var _spawn_handler : SpawnHandler = $Components/SpawnHandler;
@onready var _main_camera : Camera2D = $MainCamera;
@onready var _timer : Timer = $StartTimer;
@onready var _game_hud : GameHUD;

# Internal variables.


# # On-ready function.
func _ready():
	_spawn_handler.spawn_players(true); # Spawn players and return the local player.
	
	# Instantiate the in-game HUD.
	_game_hud = load("res://assets/ui/hud/GameHUD.tscn").instantiate();
	add_child(_game_hud);
	
	# Start the countdown for race start.
	_timer.start(_start_timer);
	
	
# Physics process - runs 60 times a second.
func _physics_process(delta) -> void:
	if (GameManager.local_player): # If a local player has been chosen, follow them.
		_main_camera.follow_local_player();
