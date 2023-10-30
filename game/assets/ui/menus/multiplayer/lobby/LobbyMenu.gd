extends Control
class_name LobbyMenu

# Entity parameters.
@export var _spawn_handler : SpawnHandler;


# Components and nodes.
var _is_host := false;

# Internal variables.
const PORTRAIT_COLORS = {
		int(GameManager.ReadyStatus.WAITING): "gray", 
		int(GameManager.ReadyStatus.DISCONNECTED): "orange",
		int(GameManager.ReadyStatus.ERROR): "red",
		int(GameManager.ReadyStatus.READY): "green",
	}
	
var selected_track : int;

# On-ready function.
func _ready():
	pass
	


# Activates the lobby menu and spawns the players.
func activate_lobby_menu(lobby_name:String, host_name:String, is_host:bool) -> void:
	visible = true;
	self._is_host = is_host; # For tasks such as map selection.
	$CurrentLobbyInfo/LobbyName.text = lobby_name;
	$CurrentLobbyInfo/HostName.text += host_name;
	$MapSelection/MapSelectionHeading.text = host_name + " is selecting a track:"
	
	if !_is_host:
		$MapSelection/TrackThumbnail/MapSelectors.visible = false;
	set_displayed_track(0); # Display the base track at start.

# Deactivates the lobby by deleting all spawned players.
func deactivate_lobby_menu() -> void:
	for player in get_tree().get_nodes_in_group("Players"):
		player.queue_free();
	visible = false;

# Delete existing players and spawn them again.
func spawn_players() -> void:
	for player in get_tree().get_nodes_in_group("Players"):
		player.free();
	_spawn_handler.spawn_players(false); # Spawn players and return the local player.


# Add chat messages to the message box.
func add_chat_message(sender_name:String, chat_message:String) -> void:
	$Chat/ChatDisplay.text += sender_name + ": " + chat_message + "\n";

# Reset chat message display box.
func reset_chat() -> void:
	$Chat/ChatDisplay.text = "";


# Set the track selection displayed track.
func set_displayed_track(track_id:int) -> void:
	if (track_id < 0 || track_id > TrackList.TRACKS.size()-1): # Avoid underflow and overflow errors.
		return
	selected_track = track_id;
	$MapSelection/TrackName.text = "Track: " + TrackList.TRACKS[track_id].name;
	$MapSelection/TrackThumbnail.texture = load(TrackList.TRACKS[track_id].img_path);

# Scroll up the track list.
func _on_left_pressed() -> void: 
	set_displayed_track(selected_track-1);

# Scroll down the track list.
func _on_right_pressed() -> void: 
	set_displayed_track(selected_track+1);


# Check if all players are ready and prepare to start.
func check_all_ready() -> void:
	var ready_result = 0;
	for player in GameManager.players: # Increment the result value by the ready status.
			ready_result += int(GameManager.players[player].ready);
	
	# If all players are ready, the ready result would match no. of player * value of READY.
	if _is_host:
		if ready_result == GameManager.players.size()*int(GameManager.ReadyStatus.READY):
			$MapSelection/PlayerReadyBtn.visible = false;
			$MapSelection/HostStartBtn.visible = true;
		else:
			$MapSelection/PlayerReadyBtn.visible = true;
			$MapSelection/HostStartBtn.visible = false;


# Change the portrait color at a specific index based on a ready status value.
func change_portrait_color(player_index:int, ready_status:int) -> void:
	$Players.get_node("PlayerPortrait" + str(player_index)).animation = PORTRAIT_COLORS[ready_status];

# Reset all portrait colors to gray.
func reset_portrait_colors() -> void:
	for i in range(4):
		$Players.get_node("PlayerPortrait" + str(i)).animation = PORTRAIT_COLORS[0];
