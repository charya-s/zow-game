extends Node


# Entity parameters.
@export var server_address := "167.172.85.190";
@export var server_port := 8915;

# Components and nodes.
@export var _lobby_browser : LobbyBrowser;
@export var _lobby_menu : LobbyMenu;

# Internal variables.
enum MessageTypes {
	ID,
	JOIN,
	USER_CONNECTED,
	USER_DISCONNECTED,
	LOBBY_CREATE_REQUEST,
	LOBBY_LIST_ADD,
	LOBBY_JOIN_REQUEST,
	LOBBY_LEAVE_REQUEST,
	LOBBY_LIST,
	LOBBY_INFO,
	LOBBY_COUNT_UPDATE,
	LOBBY_DESTROYED,
	LOBBY_CHAT_MESSAGE,
	OFFER,
	ANSWER,
	CANDIDATE,
	LOBBY_TRACK_SELECTION,
	LOBBY_READY_STATUS,
}
var _peer := WebSocketMultiplayerPeer.new();
var _rtc_peer := WebRTCMultiplayerPeer.new(); # Actual WebRTC connection itself.
var _self_id := 0;
var _self_name := "";
var _curr_lobby_id := "";
var _curr_host_id := 0;

# On-ready function.
func _ready() -> void:
#	if (!GameManager.is_dedicated_server):
#		print("Connecting to: " + server_address + ":" + str(server_port));
#		_peer.create_client(server_address + ":" + str(server_port));
	
	multiplayer.connected_to_server.connect(_rtc_server_connected);
	multiplayer.peer_connected.connect(_rtc_peer_connected);
	multiplayer.peer_disconnected.connect(_rtc_peer_disconnected);


# Physics process.
func _physics_process(_delta:float) -> void:
	_peer.poll();
	if (_peer.get_available_packet_count() > 0):
		_getPackets();






# Get available packets.
func _getPackets() -> void:
	var packet : PackedByteArray = _peer.get_packet();
	if (packet == null):
		return;
	var message : Dictionary = JSON.parse_string(packet.get_string_from_utf8());
	_parseMessage(message);

# Parse received packets (messages).
func _parseMessage(message:Dictionary) -> void:
	if (message.type == MessageTypes.ID):
		_self_id = message.user_id;
		_setup_rtc_mesh(message.user_id);
		
	if (message.type == MessageTypes.JOIN):
		pass
		
	if (message.type == MessageTypes.USER_CONNECTED):
		_create_rtc_peer(message.user_id);
		
	if (message.type == MessageTypes.USER_DISCONNECTED):
		print("user dc-d: " + str(message.user_id))
		
	if (message.type == MessageTypes.LOBBY_CREATE_REQUEST):
		pass
		
	if (message.type == MessageTypes.LOBBY_LIST_ADD):
		_lobby_browser.add_lobby_row(message.new_lobby); # Whenever a new lobby is created, update the list of lobbies.
		
	if (message.type == MessageTypes.LOBBY_JOIN_REQUEST):
		_self_name = message.self_name;
		_enter_lobby(message.lobby_name, message.host_name);
		
	if (message.type == MessageTypes.LOBBY_LEAVE_REQUEST):
		_exit_lobby();
		
	if (message.type == MessageTypes.LOBBY_LIST):
		_lobby_browser.populate_list(message.lobby_list);
		
	if (message.type == MessageTypes.LOBBY_INFO):
		_curr_lobby_id = message.lobby_id;
		_curr_host_id = message.host_id;
		GameManager.players = JSON.parse_string(message.player_list);
		_lobby_menu.spawn_players();
		_reset_all_ready(); # When someone new joins, reset ready statuses of all players.
		
	if (message.type == MessageTypes.LOBBY_COUNT_UPDATE):
		_lobby_browser.update_player_count(message.lobby_id, message.update_value)
		
	if (message.type == MessageTypes.LOBBY_DESTROYED):
		_lobby_browser.remove_lobby_row(message.lobby_id); # Whenever a lobby is deleted, update the list of lobbies.
		_exit_lobby();
		
	if (message.type == MessageTypes.LOBBY_CHAT_MESSAGE):
		print("CHAT: " + str(message))
		_lobby_menu._add_chat_message(message.sender_name, message.chat_message)
		
	if (message.type == MessageTypes.OFFER):
		if _rtc_peer.has_peer(message.org_peer_id): # Check if we have connected to the original peer.
			_rtc_peer.get_peer(message.org_peer_id).connection.set_remote_description("offer", message.data);
		
	if (message.type == MessageTypes.ANSWER):
		if _rtc_peer.has_peer(message.org_peer_id): # Check if we have connected to the original peer.
			_rtc_peer.get_peer(message.org_peer_id).connection.set_remote_description("answer", message.data);
			
	if (message.type == MessageTypes.CANDIDATE):
		if _rtc_peer.has_peer(message.org_peer_id): # Check if we have connected to the original peer.
			print("Got candidate: " + str(message.org_peer_id) + ". My ID: " + str(message.peer_id));
			_rtc_peer.get_peer(message.org_peer_id).connection.add_ice_candidate(message.mid_name, message.index, message.sdp_name);
		
	if (message.type == MessageTypes.LOBBY_TRACK_SELECTION):	
		_lobby_menu.set_displayed_track(message.track_id);
		
	if (message.type == MessageTypes.LOBBY_READY_STATUS):	
		GameManager.players[str(message.user_id)].ready = int(message.ready_status);
		_lobby_menu._check_all_ready();

# Send a message to all players.
func _sendMessageToAll(message:Dictionary) -> void:
	var packet : PackedByteArray = JSON.stringify(message).to_utf8_buffer();
	_peer.put_packet(packet);

# Send a message to a specific player.
func _sendMessageToPlayer(playerId:int, message:Dictionary) -> void:
	var packet : PackedByteArray = JSON.stringify(message).to_utf8_buffer();
	_peer.get_peer(playerId).put_packet(packet);







# Setting up the WebRTC mesh.
func _setup_rtc_mesh(user_id:int):
	_rtc_peer.create_mesh(user_id); # Creates a mesh network for use in multiplayer.
	multiplayer.multiplayer_peer = _rtc_peer; # Ensures all multiplayer functionality goes through the mesh.

# Creating an RTC connection between self and a target peer.
func _create_rtc_peer(peer_id:int) -> void:
	if peer_id == _self_id: # If the peer is self, don't try to connect to them.
		return
	
	# WebRTC CONNECTION peer. Gives info - "this is who this person is, this is how to connect to them".
	var connection_peer := WebRTCPeerConnection.new(); 
	connection_peer.initialize({ # Free Google STUN (Session Traversal Utilities for NAT) server.
		"iceServers": [ { "urls": ["stun:stun.l.google.com:19302"] } ] 
	})
	print("Binding ID: " + str(peer_id) + ". My ID: " + str(_self_id) + ".");
	
	connection_peer.session_description_created.connect(_offer_created.bind(peer_id));
	connection_peer.ice_candidate_created.connect(_ice_candidate_created.bind(peer_id));
	_rtc_peer.add_peer(connection_peer, peer_id); # Associate the connection info with the peer.
	
	# Only send an offer to the host, whose ID is 1????
	if peer_id < _rtc_peer.get_unique_id():
		connection_peer.create_offer(); # Create an offer according to the connection info.

# Remove all RTC connections with peers.
func _remove_rtc_peers() -> void:
	for peer in _rtc_peer.get_peers():
		_rtc_peer.remove_peer(peer);

# Fired when an offer is created by a another peer.
func _offer_created(type:String, data, peer_id:int):
	if !_rtc_peer.has_peer(peer_id):
		return
	
	# "Local Description" is my description of myself and how to connect to me.
	_rtc_peer.get_peer(peer_id).connection.set_local_description(type, data);
	
	if type == "offer":
		_send_offer(peer_id, data);
	elif type == "answer":
		_send_answer(peer_id, data);

# Tell the server to send an offer.
func _send_offer(peer_id:int, data) -> void:
	var message : Dictionary = {
		"type": MessageTypes.OFFER,
		"peer_id": peer_id,
		"org_peer_id": _self_id,
		"data": data,
		"lobby_info": _curr_lobby_id,
	}
	_sendMessageToAll(message)

# Tell the server to send an answer.
func _send_answer(peer_id:int, data) -> void:
	var message : Dictionary = {
		"type": MessageTypes.ANSWER,
		"peer_id": peer_id,
		"org_peer_id": _self_id,
		"data": data,
		"lobby_info": _curr_lobby_id,
	}
	_sendMessageToAll(message)

# Fired when an ICE candidate is created between two peers.
# This is a middleman between two peers who connects them to each other.
func _ice_candidate_created(mid_name:String, index:int, sdp_name:String, peer_id:int):
	var message : Dictionary = {
		"type": MessageTypes.CANDIDATE,
		"peer_id": peer_id,
		"org_peer_id": _self_id,
		"mid_name": mid_name,
		"index": index,
		"sdp_name": sdp_name,
		"lobby_info": _curr_lobby_id,
	}
	_sendMessageToAll(message)





# Multiplayer event handlers.
func _rtc_server_connected() -> void:
	print("Connected to RTC Server!");

func _rtc_peer_connected(id:int) -> void:
	print("Connected to RTC Peer: " + str(id));

func _rtc_peer_disconnected(id:int) -> void:
	print("Disconnected from RTC Peer: " + str(id));





# Send request to join a lobby.
func _on_lobby_browser_join_lobby_pressed(lobby_id:String) -> void:
	# Don't create a lobby if the player name is not set.
	if _lobby_browser.get_node("PlayerName").text.length() < 3:
		return
	var message : Dictionary = {
		"type": MessageTypes.LOBBY_JOIN_REQUEST,
		"user_id": _self_id,
		"user_name": _lobby_browser.get_node("PlayerName").text,
		"lobby_id": lobby_id,
	};
	_sendMessageToAll(message);

# Send request to create a new lobby.
func _on_create_lobby_pressed() -> void:
	# Don't create a lobby if the player name and lobby name are not set.
	if _lobby_browser.get_node("PlayerName").text.length() < 3:
		return
	if _lobby_browser.get_node("LobbyName").text.length() < 3:
		return
	
	var message : Dictionary = {
		"type": MessageTypes.LOBBY_CREATE_REQUEST,
		"host_id": _self_id,
		"host_name": _lobby_browser.get_node("PlayerName").text,
		"lobby_name": _lobby_browser.get_node("LobbyName").text,
	};
	_sendMessageToAll(message);

# Go back to the main menu.
func _on_back_btn_pressed() -> void:
	_peer.create_client("127.0.0.1" + ":" + str(server_port));
	pass

# Enter the lobby screen.
func _enter_lobby(lobby_name:String, host_name:String) -> void:
	_lobby_browser.deactivate_lobby_browser();
	_lobby_menu.activate_lobby_menu(lobby_name, host_name, (_self_id == _curr_host_id));

# Send request to leave a lobby.
func _on_leave_lobby_btn_pressed():
	var leave_lobby_message = {
		"type": MessageTypes.LOBBY_LEAVE_REQUEST,
		"user_id": _self_id,
		"lobby_id": _curr_lobby_id,
	}
	_sendMessageToAll(leave_lobby_message);
	
# Exit the lobby screen.
func _exit_lobby() -> void:
	_self_name = "";
	_curr_host_id = 0;
	_curr_lobby_id = "";
	_lobby_menu.deactivate_lobby_menu();
	_lobby_browser.activate_lobby_browser();
	GameManager.players = {};
	_remove_rtc_peers();


# Sending a chat message.
func _on_send_chat_btn_pressed():
	var chat_message = {
		"type": MessageTypes.LOBBY_CHAT_MESSAGE,
		"lobby_id": _curr_lobby_id,
		"sender_name": _self_name,
		"chat_message": _lobby_menu.get_node("Chat/MessageBox").text,
	}
	_sendMessageToAll(chat_message);


# Readying up.
func _on_player_ready_btn_pressed():
	if _self_id == _curr_host_id: # If I'm the host, broadcast the selected map.
		var track_select_message = {
			"type": MessageTypes.LOBBY_TRACK_SELECTION,
			"lobby_id": _curr_lobby_id,
			"track_id": _lobby_menu.selected_track,
		}
		_sendMessageToAll(track_select_message);
		
	GameManager.players[str(_self_id)].ready = GameManager.ReadyStatus.READY;
	var ready_status_message = {
		"type": MessageTypes.LOBBY_READY_STATUS,
		"lobby_id": _curr_lobby_id,
		"user_id": _self_id,
		"ready_status": GameManager.players[str(_self_id)].ready,
	}
	_sendMessageToAll(ready_status_message);
	
# Resetting ready statuses of everyone in the lobby.
func _reset_all_ready() -> void:
	for player in GameManager.players:
		GameManager.players[player].ready = int(GameManager.ReadyStatus.WAITING);


# RPC call to start the game on the selected track.
@rpc("any_peer", "call_local")
func _start_game() -> void:
	var track_scene = load(TrackList.TRACKS[_lobby_menu.selected_track].path).instantiate();
	get_tree().root.add_child(track_scene);
	get_parent().get_parent().queue_free()


func _on_host_start_btn_pressed():
	_start_game.rpc();
