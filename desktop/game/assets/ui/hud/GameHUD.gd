extends CanvasLayer
class_name GameHUD


# Entity parameters.


# Components and nodes.
@export var _player_list_row : PackedScene;
@export var _leaderboard_row : PackedScene;

# Internal variables.



# On-ready function.
func _ready() -> void:
	_create_player_list()
	

# Physics process.
func _physics_process(_delta:float) -> void:
	_update_speedometer(GameManager.local_player);
	_update_timer(get_parent().get_node("StartTimer"));


# Update the speedometer based on the local player's velocity.
func _update_speedometer(player:CharacterBody2D) -> void:
	$Speedometer/Speed.text = str(int(player.velocity.length()));
	
	# Update the needle frame based on velocity/max_speed. 9 possible frames.
	if (player.velocity.length()/player.max_speed < 0.01):
		$Speedometer/Needle.frame = 0;
	elif (player.velocity.length()/player.max_speed < 0.125):
		$Speedometer/Needle.frame = 1;
	elif (player.velocity.length()/player.max_speed < 0.25):
		$Speedometer/Needle.frame = 2;
	elif (player.velocity.length()/player.max_speed < 0.375):
		$Speedometer/Needle.frame = 3;
	elif (player.velocity.length()/player.max_speed < 0.50):
		$Speedometer/Needle.frame = 4;
	elif (player.velocity.length()/player.max_speed < 0.625):
		$Speedometer/Needle.frame = 5;
	elif (player.velocity.length()/player.max_speed < 0.75):
		$Speedometer/Needle.frame = 6;
	elif (player.velocity.length()/player.max_speed < 0.875):
		$Speedometer/Needle.frame = 7;
	elif (player.velocity.length()/player.max_speed < 0.100):
		$Speedometer/Needle.frame = 8;


# Create player list.
func _create_player_list() -> void:
	for player in GameManager.players:
		var row = _player_list_row.instantiate();
		row.name = str(GameManager.players[player].id);
		row.get_node("Name").text = GameManager.players[player].name; 
		row.get_node("Lap").text = " | Lap 1";
		$PlayerList/VBoxContainer.add_child(row);


# Update the player list panel with the number of laps.
# Called whenever a player finishes a lap.
func update_player_list(player_laps:Dictionary) -> void:
	for row in $PlayerList/VBoxContainer.get_children():
		row.get_node("Lap").text = " | Lap " + str(player_laps[row.name].laps+1); 


# Update UI elements based on track information.
func _update_timer(timer:Timer) -> void:
	if get_node_or_null("StartCountdown") == null: # Cancel update if the countdown has been removed.
		return
		
		
	if timer.time_left == 0: # If the countdown is over, remove the panel.
		$StartCountdown.free();
		return;
		
	$StartCountdown/Label.text = str(ceil(timer.time_left)); # Update the countdown.


# Display/update the leaderboard at the end of the race.
func display_leaderboard(players_finished:Dictionary):
	$Leaderboard.visible = true; # Show the leaderboard.
	$PlayerList.visible = false; # Hide the player list.
	var position = 1; # The list is in order of who finished.
	for player in players_finished:
		var leader_row = _leaderboard_row.instantiate();
		leader_row.get_node("Position").text = str(position);
		leader_row.get_node("Name").text = GameManager.players[players_finished[player].id].name;
		leader_row.get_node("Time").text = convert_to_mmss(players_finished[player].time);
		$Leaderboard/VBoxContainer.add_child(leader_row);
		position += 1; # Incremement position.

# Function to convert a seconds number in float to a MM:SS string.
func convert_to_mmss(time:float) -> String:
	var seconds = int(time) % 60;
	var minutes = int(time/60) % 60;
	return "%02d:%02d" % [minutes, seconds];


# Send player back to the main menu from the leaderboard.
func _on_back_to_menu_pressed():
	var main_menu_scene = load("res://assets/ui/menus/main-menu/MainMenu.tscn").instantiate();
	get_tree().root.add_child(main_menu_scene);
	get_parent().queue_free(); # Remove the track scene from the game.


func _on_button_pressed():
	var main_menu_scene = load("res://assets/ui/menus/main-menu/MainMenu.tscn").instantiate();
	get_tree().root.add_child(main_menu_scene);
	get_parent().queue_free(); # Remove the track scene from the game.
