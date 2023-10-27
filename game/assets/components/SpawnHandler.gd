extends Node2D
class_name SpawnHandler;


# Entity parameters.
@export var _player_scene : PackedScene; # Player scene for spawning players.
@export var _base_node : Node; # The node to which spawned players are added.


# Spawn players according to the GameManager. Returns the local player as a CharacterBody2D.
func spawn_players():
	var player_index = 0;
	for i in Globals.players: 
		# For each player in GameManager, create a new player scene in the tree.
		var curr_player = _player_scene.instantiate(); 
		curr_player.name = str(Globals.players[i].id); # Set name of player to their ID.
		_base_node.add_child(curr_player); # Add the new player to the base node.
		
		# For each spawn point available, if the index of the player matches its name, move the player there.
		for spawn in get_tree().get_nodes_in_group("PlayerSpawnPoints"):
			if spawn.name == str(player_index):
				curr_player.global_position = spawn.global_position;
				
				# Set the local player to the node that matches the unique multiplayer ID of the local player.
				if curr_player.name == str(multiplayer.get_unique_id()):
					Globals.local_player = curr_player;
				
				
		# Loop through for each player.
		player_index += 1;
