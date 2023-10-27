extends Control

# Entity parameters.
@export var _spawn_handler : SpawnHandler;


# Components and nodes.


# Internal variables.


# # On-ready function.
func _ready():
	_spawn_handler.spawn_players(); # Spawn players and return the local player.
