extends Node
class_name TrackController;


# Entity parameters.
@export var _spawn_handler : SpawnHandler;
@export var _friction : float = 0.5; # Track friction.
@export var _start_dir : Vector2 = Vector2(-1, 0); # The direction the player faces at the start.
@export var _start_timer : float = 5.0; # 5 seconds of prep before the race starts.

# Components and nodes.
@onready var _main_camera : Camera2D = $MainCamera;
@onready var _timer : Timer = $StartTimer;

# Internal variables.


# # On-ready function.
func _ready():
	_spawn_handler.spawn_players(); # Spawn players and return the local player.
	
	
# Physics process - runs 60 times a second.
func _physics_process(delta) -> void:
	if (Globals.local_player): # If a local player has been chosen, follow them.
		_main_camera.follow_local_player();
