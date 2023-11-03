extends Control

# Entity parameters.
@export var _spawn_handler : SpawnHandler;


# Components and nodes.


# Internal variables.
var selected_track := 0;



# On-ready function.
func _ready() -> void:
	# Create a player and spawn them
	GameManager.players[str(multiplayer.get_unique_id())] = { 
		"id": multiplayer.get_unique_id(), 
		"name": "", 
		"index": 0, 
		"ready": GameManager.ReadyStatus.READY, 
		"character": GameManager.selected_char,
	};
	_spawn_handler.spawn_players(false, $Player);
	_set_displayed_track(selected_track);


# Physics process.
func _physics_process(_delta:float) -> void:
	if (get_node("Player/1") != null):
		get_node("Player/1").get_node("PlayerName").text = $PlayerName.text;



# Set the track selection displayed track.
func _set_displayed_track(track_id:int) -> void:
	if (track_id < 0 || track_id > TrackList.TRACKS.size()-1): # Avoid underflow and overflow errors.
		return
	selected_track = track_id;
	$MapSelection/TrackName.text = "Track: " + TrackList.TRACKS[track_id].name;
	$MapSelection/TrackThumbnail.texture = load(TrackList.TRACKS[track_id].img_path);

# Scroll up the track list.
func _on_track_left_pressed() -> void: 
	_set_displayed_track(selected_track-1);

# Scroll down the track list.
func _on_track_right_pressed() -> void: 
	_set_displayed_track(selected_track+1);






# Start the game.
func _on_start_btn_pressed():
	if $PlayerName.text.length() < 3:
		$PlayerName.modulate = Color("ff0000");
		$ErrorShake.play("PlayerName");
		return;
		
	GameManager.players["1"].name = $PlayerName.text;
	var track_scene = load(TrackList.TRACKS[selected_track].path).instantiate();
	get_tree().root.add_child(track_scene);
	queue_free();


func _on_back_btn_pressed():
	var main_menu_scene = load("res://assets/ui/menus/main-menu/MainMenu.tscn").instantiate();
	get_tree().root.add_child(main_menu_scene);
	queue_free()
