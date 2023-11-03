extends Control


# Entity parameters.


# Components and nodes.


# Internal variables.



# On-ready function.
func _ready() -> void:
	if (GameManager.is_dedicated_server): # If server, immediately load the mult scene to host.
		var mult_scene = load("res://assets/ui/menus/multiplayer/MultiplayerMenu.tscn").instantiate();
		get_tree().root.add_child.call_deferred(mult_scene);
		self.queue_free()
		
	# Play music.
	MusicHandler.play_music("menu");
	
	# Close any RTC connections.
	multiplayer.multiplayer_peer.close();
	


# Menu button handlers.
func _on_singleplayer_pressed():
	var singl_scene = load("res://assets/ui/menus/singleplayer/SingleplayerMenu.tscn").instantiate();
	GameManager.players = {}; # Reset GameManager's player list.
	get_tree().root.add_child(singl_scene);
	self.queue_free()

func _on_multiplayer_pressed():
	var mult_scene = load("res://assets/ui/menus/multiplayer/MultiplayerMenu.tscn").instantiate();
	GameManager.players = {}; # Reset GameManager's player list.
	get_tree().root.add_child(mult_scene);
	self.queue_free()

func _on_characters_pressed():
	var chars_scene = load("res://assets/ui/menus/characters/CharactersMenu.tscn").instantiate();
	GameManager.players = {}; # Reset GameManager's player list.
	get_tree().root.add_child(chars_scene);
	self.queue_free()

func _on_options_pressed():
	var options_scene = load("res://assets/ui/menus/options/OptionsMenu.tscn").instantiate();
	GameManager.players = {}; # Reset GameManager's player list.
	get_tree().root.add_child(options_scene);
	self.queue_free()

func _on_quit_pressed():
	get_tree().quit();

func _on_patch_notes_pressed():
	OS.shell_open("https://charya-s.github.io/zow-game/pages/PatchPage.html");
