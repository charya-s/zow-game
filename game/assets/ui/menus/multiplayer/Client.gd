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
var selfId := 0;

# On-ready function.
func _ready() -> void:
	pass;


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
		selfId = message.userId;
		print("My ID is: " + str(selfId));
	if (message.type == MessageTypes.JOIN):
		pass
	if (message.type == MessageTypes.USER_CONNECTED):
		print("User connected: " + str(message.id))
	if (message.type == MessageTypes.USER_DISCONNECTED):
		pass
	if (message.type == MessageTypes.LOBBY_CREATE_REQUEST):
		pass
	if (message.type == MessageTypes.LOBBY_JOIN_REQUEST):
		pass
	if (message.type == MessageTypes.LOBBY_INFO):
		GameManager.players = JSON.parse_string(message.player_list);
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







# Connecting to a server.	
func _connectToServer(address:String, port:int) -> void:
	_peer.create_client(address + ":" + str(port));
	print("STARTED CLIENT!");


# "StartClient" press - connect to server with the specific address and port.
func _on_start_client_pressed():
	_connectToServer("127.0.0.1", 8915);


func _on_join_lobby_pressed():
	var message : Dictionary = {
		"type": MessageTypes.LOBBY_JOIN_REQUEST,
		"id": selfId,
		"name": "kets",
		"lobby_id": $JoinLobbyId.text,
	};
	_sendMessageToAll(message);


func _on_create_lobby_pressed():
	var message : Dictionary = {
		"type": MessageTypes.LOBBY_CREATE_REQUEST,
		"id": selfId,
		"name": "kets",
	};
	_sendMessageToAll(message);
