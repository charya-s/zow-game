extends Node

# Internal variables.
var MusicStates = {
	"menu" : "res://assets/other/music/main_menu.wav",
	"track" : "",
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# Update the music played based on the current scene.
func play_music(state:String) -> void:
	# Last node in the root is the loaded scene.
	var curr_scene = get_tree().root.get_children()[get_tree().root.get_children().size()-1];
	$AudioPlayer.stream = load(MusicStates[state]);
	$AudioPlayer.playing = true;


func stop_music() -> void:
	$AudioPlayer.playing = false;
