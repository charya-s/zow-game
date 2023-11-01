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
	

# Menu button handlers.
func _on_singleplayer_pressed():
	var singl_scene = load("res://assets/ui/menus/singleplayer/SingleplayerMenu.tscn").instantiate();
	get_tree().root.add_child(singl_scene);
	self.queue_free()

func _on_multiplayer_pressed():
	var mult_scene = load("res://assets/ui/menus/multiplayer/MultiplayerMenu.tscn").instantiate();
	get_tree().root.add_child(mult_scene);
	self.queue_free()

func _on_characters_pressed():
	pass # Replace with function body.

func _on_options_pressed():
	var options_scene = load("res://assets/ui/menus/options/OptionsMenu.tscn").instantiate();
	get_tree().root.add_child(options_scene);
	self.queue_free()

func _on_quit_pressed():
	get_tree().quit();
