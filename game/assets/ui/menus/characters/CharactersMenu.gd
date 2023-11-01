extends Control


# Entity parameters.


# Components and nodes.
@export var _spawn_handler : SpawnHandler;

# Internal variables.
var CharNames = {
	GameManager.Characters.BOB: "CharacterBob",
	GameManager.Characters.SKELEBOB: "CharacterSkeleBob",
}

# Called when the node enters the scene tree for the first time.
func _ready():
	# Create a player and spawn them
	GameManager.players["1"] = { 
		"id": 1, 
		"name": "", 
		"index": 0, 
		"ready": GameManager.ReadyStatus.READY, 
		"character": GameManager.selected_char,
	};
	_spawn_handler.spawn_players(false);
	_update_slection_marker();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass




# Portrait buttons.
func _on_character_bob_pressed():
	GameManager.selected_char = GameManager.Characters.BOB;
	GameManager.local_player.update_sprite(int(GameManager.Characters.BOB));
	_update_slection_marker();


func _on_character_skele_bob_pressed():
	GameManager.selected_char = GameManager.Characters.SKELEBOB;
	GameManager.local_player.update_sprite(int(GameManager.Characters.SKELEBOB));
	_update_slection_marker();


# Selection user feedback marker.
func _update_slection_marker():
	$SelectorMenu/SelectionMarker.position.x = $SelectorMenu.get_node(CharNames[GameManager.selected_char]).position.x


func _on_back_btn_pressed():
	var main_menu_scene = load("res://assets/ui/menus/main-menu/MainMenu.tscn").instantiate();
	get_tree().root.add_child(main_menu_scene);
	queue_free()
