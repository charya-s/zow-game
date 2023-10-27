extends RefCounted
class_name Lobby


var host_id : int;
var players := {};

# Initialization function.
func _init(id:int) -> void:
	host_id = id;
	
# Add a new player to the list of players.
func add_player(id:int, player_name:String) -> Dictionary:
	players[id] = {
		"id": id,
		"name": player_name,
		"index": players.size(),
	};
	return players[id];
