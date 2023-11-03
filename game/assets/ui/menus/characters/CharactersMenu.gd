extends Control


# Entity parameters.


# Components and nodes.
@export var _spawn_handler : SpawnHandler;

# Internal variables.
var Chars = {
	GameManager.Characters.BOB: {"name": "CharacterBob", "quote": "I'm Bob! Short for Bobe. Like the baseball player."},
	GameManager.Characters.SKELEBOB: {"name": "CharacterSkeleBob", "quote": "Why was I given no flesh but a voice to scream?"},
	GameManager.Characters.CATBOB: {"name": "CharacterCatBob", "quote": "I'm not a fucking bobcat! Dick..."},
	GameManager.Characters.AMANDA: {"name": "CharacterAmanda", "quote": "Yaaaa I'm Amandaaaa. Waaaw. Is racing tiiiime."},
}

# Called when the node enters the scene tree for the first time.
func _ready():
	# Create a player and spawn them
	GameManager.players[str(multiplayer.get_unique_id())] = { 
		"id": multiplayer.get_unique_id(), 
		"name": "", 
		"index": 0, 
		"ready": GameManager.ReadyStatus.READY,
		"character": GameManager.selected_char,
	};
	_spawn_handler.spawn_players(false, $Player);
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

func _on_character_cat_bob_pressed():
	GameManager.selected_char = GameManager.Characters.CATBOB;
	GameManager.local_player.update_sprite(int(GameManager.Characters.CATBOB));
	_update_slection_marker();

func _on_character_amanda_pressed():
	GameManager.selected_char = GameManager.Characters.AMANDA;
	GameManager.local_player.update_sprite(int(GameManager.Characters.AMANDA));
	_update_slection_marker();

# Selection user feedback marker.
func _update_slection_marker():
	$SelectorMenu/SelectionMarker.position.x = $SelectorMenu.get_node(Chars[GameManager.selected_char].name).position.x
	_set_quote();

# Set the character's quote.
func _set_quote():
	$SpeechBubble/Label.text = Chars[GameManager.selected_char].quote;


func _on_back_btn_pressed():
	var main_menu_scene = load("res://assets/ui/menus/main-menu/MainMenu.tscn").instantiate();
	get_tree().root.add_child(main_menu_scene);
	queue_free()
