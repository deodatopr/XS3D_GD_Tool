@tool
extends Control

@export var ApplyStandardMat : Button
@export var ApplyShaderMat : Button

var window : Window

func _ready():
	ApplyStandardMat.connect("button_down",_on_apply_standard_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_apply_standard_pressed():
	print("pressed")
	if window != null:
		window.grab_focus()
		
	var dialog = Label.new()
	dialog.text = "Sure you want apply?"
	dialog.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dialog.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	window = ConfirmationDialog.new()
	window.size = Vector2i(200, 100)
	
	EditorInterface.popup_dialog_centered(window)
	
	window.add_child(dialog)
	window.about_to_popup
