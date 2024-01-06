extends Node

# Entity parameters.
@export var host_port := 8915;


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
var _users := {};
var _lobbies := {};

# On-ready function.
func _ready() -> void:
	# Start server if dedicated server.
	if (GameManager.is_dedicated_server):
		print("Hosting on: " + str(host_port));
		_peer.create_server(host_port);
		
	# Connecting WebSocket events to handler functions.
	_peer.connect("peer_connected", _peer_connected);
	_peer.connect("peer_disconnected", _peer_disconnected);


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
		pass
		
	if (message.type == MessageTypes.JOIN):
		pass
		
	if (message.type == MessageTypes.USER_CONNECTED):
		pass
		
	if (message.type == MessageTypes.USER_DISCONNECTED):
		pass
		
	if (message.type == MessageTypes.LOBBY_CREATE_REQUEST):
		_create_lobby(message.lobby_name, message.host_id, message.host_name, message.character)
		
	if (message.type == MessageTypes.LOBBY_JOIN_REQUEST):
		_join_lobby(message.user_id, message.user_name, message.character, message.lobby_id);
		
	if (message.type == MessageTypes.LOBBY_LEAVE_REQUEST):
		_leave_lobby(message.user_id, message.lobby_id);
		
	if (message.type == MessageTypes.LOBBY_INFO):
		pass
		
	if (message.type == MessageTypes.LOBBY_DESTROYED):
		_destroy_lobby(message.lobby_id);
		
	if (message.type == MessageTypes.LOBBY_CHAT_MESSAGE):
		_send_chat_message(message.lobby_id, message.sender_name, message.chat_message)
		
	if (message.type == MessageTypes.OFFER) || (message.type == MessageTypes.ANSWER) || (message.type == MessageTypes.CANDIDATE):
		print("Original peer: " + str(message.org_peer_id));
		#+ ". Data: " + message.data)
		_sendMessageToPlayer(message.peer_id, message) # Send the offer, answer or candidate to the target peer.
	
	if (message.type == MessageTypes.LOBBY_TRACK_SELECTION):	
		_set_selected_track(message.lobby_id, message.track_id);
		
	if (message.type == MessageTypes.LOBBY_READY_STATUS):	
		_set_ready_status(message.lobby_id, message.user_id, message.ready_status);

# Send a message to all players.
func _sendMessageToAll(message:Dictionary) -> void:
	var packet : PackedByteArray = JSON.stringify(message).to_utf8_buffer();
	_peer.put_packet(packet);

# Send a message to a specific player.
func _sendMessageToPlayer(playerId:int, message:Dictionary) -> void:
	var packet : PackedByteArray = JSON.stringify(message).to_utf8_buffer();
	_peer.get_peer(playerId).put_packet(packet);




# WebSocket event handlers.
func _peer_connected(id:int) -> void:
	print("Peer connected: " + str(id))
	_users[id] = {
		"type": MessageTypes.ID,
		"user_id": id,
	}
	_sendMessageToPlayer(id, _users[id]);
	
	# Return lobby information to the newly connected player.
	var message : Dictionary  = {
		"type": MessageTypes.LOBBY_LIST,
		"lobby_list": _lobbies,
	};
	_sendMessageToPlayer(id, message); 

func _peer_disconnected(id:int) -> void:
	print("Peer disconnected: " + str(id))
	for lobby in _lobbies:
		if _lobbies[lobby].host_id == id:
			_destroy_lobby(lobby);
		elif _lobbies[lobby].players.has(id):
			_leave_lobby(id, lobby);





# Create a lobby.
func _create_lobby(lobby_name:String, host_id:int, host_name:String, character:int) -> void:
	var lobby_id : String = _generate_lobby_id(32); # Generate a 32-character Lobby ID.
	print("Lobby ID: " + lobby_id);
	
	# Create a new Lobby, set the creating user as the host.
	_lobbies[lobby_id] = { "lobby_id":lobby_id, "lobby_name":lobby_name, "host_id":host_id, "host_name":host_name, "players":{} }
	var add_lobby_message := { # Send out new lobby info to all players to add to their list.
		"type": MessageTypes.LOBBY_LIST_ADD,
		"new_lobby": _lobbies[lobby_id],
	}
	_sendMessageToAll(add_lobby_message); # Send info of new lobby to all players.
	_join_lobby(host_id, host_name, character, lobby_id) # Add the host to the lobby as a player themselves.


# Join a lobby.
func _join_lobby(user_id:int, user_name:String, character:int, lobby_id:String) -> void:
	# Add new user to the players list for the specified lobby.
	_lobbies[lobby_id].players[user_id] = { 
		"id":user_id, 
		"name":user_name, 
		"index": _lobbies[lobby_id].players.size(), 
		"ready": GameManager.ReadyStatus.WAITING, 
		"character": character,
	};

	# Tell everyone to update the count for this lobby by one.
	var lobby_count_message = {
		"type": MessageTypes.LOBBY_COUNT_UPDATE,
		"lobby_id": lobby_id,
		"update_value": 1, # Incredment by one.
	}
	_sendMessageToAll(lobby_count_message)
	
	for p in _lobbies[lobby_id].players: # Loop through the player list and send the player list to each player on it.
		
		# Sends the new user to each player.
		var new_user_info = {
			"type": MessageTypes.USER_CONNECTED,
			"user_id": user_id,
		}
		_sendMessageToPlayer(p, new_user_info); 
		
		# Sends each player to the new user.
		var curr_user_info  = {
			"type": MessageTypes.USER_CONNECTED,
			"user_id": p,
		}
		_sendMessageToPlayer(user_id, curr_user_info); 
		
		# This is done to make sure all players know of all other players to update their GameManagers.
		var player_info_message = { 
			"type": MessageTypes.LOBBY_INFO,
			"lobby_id": lobby_id,
			"host_id": _lobbies[lobby_id].host_id,
			"player_list": JSON.stringify(_lobbies[lobby_id].players), # Stringify to prevent errors.
		};
		_sendMessageToPlayer(p, player_info_message); # Send the full list to each player.
	
	var successful_join_message = { # Send success message back to client.
		"type": MessageTypes.LOBBY_JOIN_REQUEST,
		"self_name": user_name,
		"lobby_name": _lobbies[lobby_id].lobby_name,
		"host_name": _lobbies[lobby_id].host_name,
	}
	_sendMessageToPlayer(user_id, successful_join_message)


# Leave lobby.
func _leave_lobby(user_id:int, lobby_id:String) -> void:
	if user_id == _lobbies[lobby_id].host_id: # If host leaves, destroy lobby.
		_destroy_lobby(lobby_id);
		return
	
	_lobbies[lobby_id].players.erase(user_id);
	
	# Tell everyone to update the count for this lobby by one.
	var lobby_count_message = {
		"type": MessageTypes.LOBBY_COUNT_UPDATE,
		"lobby_id": lobby_id,
		"update_value": -1, # Decrement by one.
	}
	_sendMessageToAll(lobby_count_message)
	
	for p in _lobbies[lobby_id].players: # Loop through the player list and send the player list to each player on it.
		
		# Sends the leaving user to each player.
		var leaving_user_info = {
			"type": MessageTypes.USER_DISCONNECTED,
			"user_id": user_id,
		}
		_sendMessageToPlayer(p, leaving_user_info); 
		
		# This is done to make sure all players know of all other players to update their GameManagers.
		var player_info_message = { 
			"type": MessageTypes.LOBBY_INFO,
			"host_id": _lobbies[lobby_id].host_id,
			"lobby_id": lobby_id,
			"self_name": _lobbies[lobby_id].players[p].name,
			"lobby_name": _lobbies[lobby_id].lobby_name,
			"player_list": JSON.stringify(_lobbies[lobby_id].players), # Stringify to prevent errors.
		};
		if p != user_id:
			_sendMessageToPlayer(p, player_info_message); # Send the full list to each player except leaver.

	var successful_leave_message = { # Send success message back to client.
		"type": MessageTypes.LOBBY_LEAVE_REQUEST,
	}
	_sendMessageToPlayer(user_id, successful_leave_message)


# Destroy a lobby.
func _destroy_lobby(lobby_id:String) -> void:
	if !_lobbies.has(lobby_id):
		return
	_lobbies.erase(lobby_id);
	var remove_lobby_message = {
		"type": MessageTypes.LOBBY_DESTROYED,
		"lobby_id": lobby_id,
	}
	_sendMessageToAll(remove_lobby_message);


# Send chat message to lobby users.
func _send_chat_message(lobby_id:String, sender_name:String, chat_msg:String) -> void:
	for p in _lobbies[lobby_id].players: # Loop through the player list and send the chat message to each player on it. 
		var chat_message = {
			"type": MessageTypes.LOBBY_CHAT_MESSAGE,
			"sender_name": sender_name,
			"chat_message": chat_msg,
		}
		_sendMessageToPlayer(p, chat_message)


# Send selected track information to each player in the lobby.
func _set_selected_track(lobby_id:String, track_id:int) -> void:
	for p in _lobbies[lobby_id].players:
		var selected_track_message = {
			"type": MessageTypes.LOBBY_TRACK_SELECTION,
			"track_id": track_id,
		}
		#if _lobbies[lobby_id].players[p].id !=  _lobbies[lobby_id].host_id:
		_sendMessageToPlayer(p, selected_track_message);


# Send new ready status of specific user to all users within the lobby.
func _set_ready_status(lobby_id:String, user_id:int, ready_status:GameManager.ReadyStatus) -> void:
	_lobbies[lobby_id].players[user_id].ready = ready_status;
	for p in _lobbies[lobby_id].players:
		var ready_status_message = { 
			"type": MessageTypes.LOBBY_READY_STATUS,
			"user_id": user_id,
			"player_index": _lobbies[lobby_id].players[user_id].index,
			"ready_status": ready_status, # Stringify to prevent errors.
		};
		_sendMessageToPlayer(p, ready_status_message); # Send the full list to each player.

# Generate random string of specific size.
func _generate_lobby_id(string_len:int) -> String:
	const CHARACTERS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWYXZ1234567890";
	var result := "";
	for i in range(string_len):
		# Get a random number between 0 and the length of the CHARACTERS list, then use it as an index to get a random character.
		result += CHARACTERS[randi() % CHARACTERS.length()]; 
	return result;
	
	
	



func _on_start_server_pressed():
	_peer.create_server(host_port);
