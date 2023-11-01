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
	# Only change the track if a new track is requested (prevents resetting the track).
	if $AudioPlayer.stream.resource_path != MusicStates[state]:
		$AudioPlayer.stream = load(MusicStates[state]);
		$AudioPlayer.playing = true;


func stop_music() -> void:
	$AudioPlayer.playing = false;
