extends Control
class_name LobbyBrowser

# Entity parameters.


# Components and nodes.
@export var _lobby_info_row : PackedScene;
signal join_lobby_pressed(lobby_id:String);

# Internal variables.


# On-ready function.
func _ready():
	pass
	

# Activates the lobby menu and spawns the players.
func activate_lobby_browser() -> void:
	visible = true;
	

# Deactivates the lobby by deleting all spawned players.
func deactivate_lobby_browser() -> void: 
	visible = false;


# Populate the list of lobbies with a lobby list dict.
func populate_list(lobbies:Dictionary) -> void:
	for lobby_id in lobbies:
		add_lobby_row(lobbies[lobby_id]);


# Adds a new row to the list of lobbies based on the lobby info.
func add_lobby_row(lobby:Dictionary) -> void:
	var info_row : LobbyInfoRow = _lobby_info_row.instantiate();
	info_row.set_info(lobby);
	info_row.connect("join_lobby_pressed", self._join_lobby_pressed);
	$LobbyList/VBoxContainer.add_child(info_row);


# Removes a row from the list of lobbies based on the lobby id.
func remove_lobby_row(lobby_id:String) -> void:
	for lobby in get_tree().get_nodes_in_group("LobbyInfoRows"):
		if lobby.lobby_id == lobby_id:
			lobby.queue_free();


# Update the player count of a specific lobby.
func update_player_count(lobby_id:String, update_value:int):
	for lobby in get_tree().get_nodes_in_group("LobbyInfoRows"):
		if lobby.lobby_id == lobby_id:
			lobby.player_count += update_value;
			lobby.get_node("LobbyPlayerCount").text = str(lobby.player_count) + "/4";

# Called when the join button is pressed on a lobby info row.
func _join_lobby_pressed(lobby_id:String):
	join_lobby_pressed.emit(lobby_id) # Passing the join lobby signal up to the client component.
