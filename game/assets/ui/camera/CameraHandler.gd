extends Camera2D


# Internal variables.
var followed_player : CharacterBody2D;


# Physics process.
func _physics_process(_delta) -> void:
	if (followed_player):
		global_position = lerp(global_position, followed_player.global_position, 0.7);

# Matches position with the player, following them.
func follow_player(player:CharacterBody2D) -> void:
	followed_player = player;

# Follows a random player in GameManager.players that is moving.
func follow_random_player() -> void:
	var rand_index := randi_range(0, get_tree().get_nodes_in_group("Players").size()-1); # Get random player index.
	if get_tree().get_nodes_in_group("Players")[rand_index].can_move == false: 
		follow_random_player(); # If the random player can't move, start over.
	else:  # Else, just set the camera followed player to the random player.
		followed_player = get_tree().get_nodes_in_group("Players")[rand_index];
		

