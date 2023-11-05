extends Control



# Entity paramaters.


# Components and nodes.


# Internal variables.



# On-ready function.
func _ready() -> void:
	_setup_audio();



# Updating the sliders and volumes (in MusicHandler) based on the loaded audio settings.
func _setup_audio() -> void:
	$OptionsPanel/VBoxContainer/MusicVolume/MusicVolumeSlider.value = MusicHandler.audio_settings["volume_music"];
	$OptionsPanel/VBoxContainer/SoundVolume/SoundVolumeSlider.value = MusicHandler.audio_settings["volume_sounds"];
	$OptionsPanel/VBoxContainer/Mute/MuteMusicCheck.button_pressed = bool(MusicHandler.audio_settings["mute_music"]);
	$OptionsPanel/VBoxContainer/Mute/MuteSoundsCheck.button_pressed = bool(MusicHandler.audio_settings["mute_sounds"]);


# Writing to the settings.txt (JSON) file and using the current audio settings.
func _update_settings_file() -> void:
#	var file := FileAccess.open("settings.txt", FileAccess.READ);
#	var settings = file.get_var();
#	file.close();
#	file = FileAccess.open("settings.txt", FileAccess.WRITE);
#	settings["audio_settings"] = MusicHandler.audio_settings;
#	file.store_var(settings);
#	file.close();
	pass
	

# Muting/unmuting music.
func _on_mute_music_check_toggled(button_pressed):
	if button_pressed: 
		MusicHandler.audio_settings["mute_music"] = 1;
		MusicHandler.update_volumes();
		$OptionsPanel/VBoxContainer/MusicVolume/MusicVolumeSlider.editable = false;
	else: 
		MusicHandler.audio_settings["mute_music"] = 0;
		MusicHandler.update_volumes();
		$OptionsPanel/VBoxContainer/MusicVolume/MusicVolumeSlider.editable = true;

# Muting/unmuting sounds.
func _on_mute_sounds_check_toggled(button_pressed):
	if button_pressed: 
		MusicHandler.audio_settings["mute_sounds"] = 1;
		MusicHandler.update_volumes();
		$OptionsPanel/VBoxContainer/SoundVolume/SoundVolumeSlider.editable = false;
	else: 
		MusicHandler.audio_settings["mute_sounds"] = 0;
		MusicHandler.update_volumes();
		$OptionsPanel/VBoxContainer/SoundVolume/SoundVolumeSlider.editable = true;


# Changing the music volume with the slider.
func _on_music_volume_slider_value_changed(value):
	MusicHandler.audio_settings["volume_music"] = value;
	MusicHandler.update_volumes();

# Changing the sounds volume with the slider.
func _on_sound_volume_slider_value_changed(value):
	MusicHandler.audio_settings["volume_sounds"] = value;
	MusicHandler.update_volumes();


# Save the modified settings and exit.
func _on_save_and_exit_pressed():
	_update_settings_file();
	get_parent().get_node("MainOptions").show();
	self.queue_free()



