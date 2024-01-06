extends Control


# Entity paramaters.


# Components and nodes.
@onready var _general_options = load("res://assets/ui/menus/options/options_panels/GeneralOptions.tscn");
@onready var _audio_options = load("res://assets/ui/menus/options/options_panels/AudioOptions.tscn");
@onready var _video_options = load("res://assets/ui/menus/options/options_panels/VideoOptions.tscn");
@onready var _credits_options = load("res://assets/ui/menus/options/options_panels/CreditsOptions.tscn");

# Internal variables.



func _on_audio_button_pressed():
	var audio_options = _audio_options.instantiate();
	add_child(audio_options);
	$MainOptions.hide();

 



func _on_back_btn_pressed():
	var main_menu_scene = load("res://assets/ui/menus/main-menu/MainMenu.tscn").instantiate();
	get_tree().root.add_child(main_menu_scene);
	queue_free()
