extends Node

# Entity parameters.


# Components and nodes.


# Internal variables.
var players : Dictionary = { 1:{"id":1, "name":"kets"} };
var local_player : CharacterBody2D;
var server_ip : String = "127.0.0.1";
var server_port : int = 8910;
var curr_peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new();
var is_dedicated_server : bool = false;
