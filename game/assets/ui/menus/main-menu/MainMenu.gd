extends Control


# Entity parameters.


# Components and nodes.


# Internal variables.


# Menu button handlers.
func _on_singleplayer_pressed():
	pass # Replace with function body.

func _on_multiplayer_pressed():
	var mult_scene = load("res://assets/ui/menus/multiplayer/MultiplayerMenu.tscn").instantiate();
	get_tree().root.add_child(mult_scene);
	self.queue_free()

func _on_characters_pressed():
	pass # Replace with function body.


func _on_options_pressed():
	pass # Replace with function body.

func _on_quit_pressed():
	get_tree().quit();
