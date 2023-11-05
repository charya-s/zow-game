extends Node

# Internal variables.
var MusicStates = {
	"menu" : "res://assets/other/music/main_menu.wav",
	"track" : "res://assets/other/music/track0.wav",
}
var _min_volume := -30.0; # Maximum volume in dB.
var _max_volume := 0.0; # Maximum volume in dB.

var audio_settings = {
	"mute_music": 0,		# 0 = false.
	"volume_music": 0.5, 	# Fraction of volume range.
	"mute_sounds": 0,		# 0 = false.
	"volume_sounds": 0.5, 	# Fraction of volume range.
}


# Called when the node enters the scene tree for the first time.
func _ready():
	#_load_settings_file();
	pass


# Loading the settings.txt (JSON) file and extract the audio settings.
func _load_settings_file() -> void:
	var file := FileAccess.open("settings.txt", FileAccess.READ);
	audio_settings = file.get_var()["audio_settings"];
	file.close();
	update_volumes();


# Updating the audio options based on saved settings.
func update_volumes() -> void:
	change_music_volume(audio_settings["volume_music"]);
	change_sounds_volume(audio_settings["volume_sounds"]);
	if audio_settings["mute_music"]:
		change_music_volume(0.0);
	if audio_settings["mute_sounds"]:
		change_sounds_volume(0.0);


# Update the music played based on the current scene.
func play_music(state:String) -> void:
	# Only change the track if a new track is requested (prevents resetting the track).
	if $MusicPlayer.stream.resource_path != MusicStates[state]:
		$MusicPlayer.stream = load(MusicStates[state]);
		$MusicPlayer.playing = true;


# Stop playing the current track.
func stop_music() -> void:
	$MusicPlayer.playing = false;


# Change music volume.
func change_music_volume(fraction:float) -> void:
	if fraction == 0.0:
		$MusicPlayer.volume_db = -1000;
		return;
	$MusicPlayer.volume_db = ((_max_volume - _min_volume) * fraction) + _min_volume;


# Change sounds volume.
func change_sounds_volume(fraction:float) -> void:
	pass;
