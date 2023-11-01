extends CanvasLayer
class_name GameHUD


# Entity parameters.


# Components and nodes.
@export var _player_list_row : PackedScene;

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
	var index := 1;
	for player in GameManager.players:
		var row = _player_list_row.instantiate();
		row.text = str(index) + ": " + GameManager.players[player].name; 
		row.name = str(GameManager.players[player].id);
		$PlayerList/VBoxContainer.add_child(row);


# Update UI elements based on track information.
func _update_timer(timer:Timer) -> void:
	if !$StartCountdown: # Cancel update if the countdown has been removed.
		return
		
	if timer.time_left == 0: # If the countdown is over, remove the panel.
		$StartCountdown.free();
		return;
		
	$StartCountdown/Label.text = str(ceil(timer.time_left)); # Update the countdown.
