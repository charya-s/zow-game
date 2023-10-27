extends Node

# Internal variables.
enum MessageTypes {
	ID,
	JOIN,
	USER_CONNECTED,
	USER_DISCONNECTED,
	LOBBY_CREATE_REQUEST,
	LOBBY_JOIN_REQUEST,
	LOBBY_INFO,
	OFFER,
	ANSWER,
	CANDIDATE,
	CHECK_IN,
}
var _peer := WebSocketMultiplayerPeer.new();
var _users := {};
var _lobbies := {};

# On-ready function.
func _ready() -> void:
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
		_create_lobby(message.id, message.name)
	if (message.type == MessageTypes.LOBBY_JOIN_REQUEST):
		_join_lobby(message.id, message.name, message.lobby_id);
	if (message.type == MessageTypes.LOBBY_INFO):
		pass
	if (message.type == MessageTypes.OFFER):
		pass
	if (message.type == MessageTypes.ANSWER):
		pass
	if (message.type == MessageTypes.CANDIDATE):
		pass
	if (message.type == MessageTypes.CHECK_IN):	
		pass

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
		"userId": id,
	}
	_sendMessageToPlayer(id, _users[id]);
	

func _peer_disconnected(id:int) -> void:
	print("Peer disconnected: " + str(id))






# Connecting to a server.	
func _startServer(port:int) -> void:
	_peer.create_server(port);
	print("STARTED SERVER!");

# "StartServer" press - start a server on the specified port.
func _on_start_server_pressed():
	_startServer(8915);





# Create a lobby.
func _create_lobby(user_id:int, user_name:String) -> void:
	var lobby_id : String = _generate_lobby_id(32); # Generate a 32-character Lobby ID.
	print("Lobby ID: " + lobby_id)
	_lobbies[lobby_id] = Lobby.new(user_id); # Create a new Lobby, set the creating user as the host.
	_join_lobby(user_id, user_name, lobby_id) # Add the host to the lobby as a player themselves.
	
	
# Join a lobby.
func _join_lobby(user_id:int, user_name:String, lobby_id:String) -> void:
	var player : Dictionary = _lobbies[lobby_id].add_player(user_id, user_name); # Add new user to the players list for the lobby.
	
	for p in _lobbies[lobby_id].players: # Loop through the player list and send the player list to each player on it.
		var player_info_message = { # This is done to make sure all players know of all other players to update their GameManagers.
			"type": MessageTypes.LOBBY_INFO,
			"player_list": JSON.stringify(_lobbies[lobby_id].players) # Stringify to prevent errors.
		};
		_sendMessageToPlayer(p, player_info_message); # Send the full list to each player.
	
	var message : Dictionary  = {
		"type": MessageTypes.USER_CONNECTED,
		"id": user_id, 
		"host_id": _lobbies[lobby_id].host_id,
		"player": _lobbies[lobby_id].players[user_id],
	};
	_sendMessageToPlayer(user_id, message); # Return lobby information to the newly joined player.







# Generate random string of specific size.
func _generate_lobby_id(string_len:int) -> String:
	const CHARACTERS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWYXZ1234567890";
	var result := "";
	for i in range(string_len):
		# Get a random number between 0 and the length of the CHARACTERS list, then use it as an index to get a random character.
		result += CHARACTERS[randi() % CHARACTERS.length()]; 
	
	
	return result;
