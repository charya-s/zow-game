extends HBoxContainer
class_name LobbyInfoRow


signal join_lobby_pressed(lobby_id:String);

var lobby_id : String;
var player_count : int;

# Initialization function.
func set_info(lobby:Dictionary) -> void:
	self.lobby_id = lobby.lobby_id;
	$LobbyName.text = lobby.lobby_name;
	$LobbyHostName.text = lobby.host_name;
	player_count = lobby.players.size();
	$LobbyPlayerCount.text = str(player_count) + "/4";


func _on_join_lobby_btn_pressed():
	join_lobby_pressed.emit(lobby_id); # Emit signal with lobby id when join is pressed.
