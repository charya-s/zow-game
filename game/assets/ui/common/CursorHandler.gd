extends CanvasLayer


# Entity parameters.
@export var _empty_cursor : Texture;

# Components and nodes.


# Internal variables.



# Called when the node enters the scene tree for the first time.
func _ready():
	# Make the system cursor invisible.
	Input.set_custom_mouse_cursor(_empty_cursor, Input.CURSOR_ARROW);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$Cursor.global_position = $Cursor.get_global_mouse_position();
	pass


func _input(event):
	var just_pressed = event.is_pressed() && !event.is_echo();
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and just_pressed:
		$Cursor/Sprite.play("Click");
