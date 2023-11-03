extends Node2D
class_name SpawnHandler;


# Entity parameters.
#@export var _base_node : Node; # The node to which spawned players are added.

# Internal variables.
@onready var _player_scene := load("res://assets/characters/player/Player.tscn"); # The character to spawn.


# Spawn players according to the GameManager. Returns the local player as a CharacterBody2D.
func spawn_players(is_on_track:bool, base_node:Node):
	for i in GameManager.players: 
		# For each player in GameManager, create a new player scene in the tree.
		var curr_player : PlayerController = _player_scene.instantiate(); 
		curr_player.name = str(GameManager.players[i].id); # Set name of player to their ID.
		print("CURR PLAYER NAME: " + curr_player.name)
		curr_player.setup_player(is_on_track, GameManager.players[i].name); # Setup player with is_on_track set to true.
		base_node.add_child(curr_player); # Add the new player to the base node.
		
		# For each spawn point available, if the index of the player matches its name, move the player there.
		for spawn in get_tree().get_nodes_in_group("PlayerSpawnPoints"):
			if spawn.name == str(GameManager.players[i].index):
				curr_player.global_position = spawn.global_position;
				
				# Set the local player to the node that matches the unique multiplayer ID of the local player.
				if curr_player.name == str(multiplayer.get_unique_id()):
					GameManager.local_player = curr_player;
