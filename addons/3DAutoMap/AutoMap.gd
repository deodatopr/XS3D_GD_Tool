@tool
extends Control

@export var ApplyStandardMat : Button
@export var ApplyShaderMat : Button
@export var BaseColor : CheckBox
@export var Roughness : CheckBox
@export var Metallic : CheckBox
@export var Normal : CheckBox
@export var Emission : CheckBox
@export var Occlusion : CheckBox
@export var NameTexture : LineEdit
@export var NumMaterials : OptionButton
@export var Extension : OptionButton
@export var SuffBC : LineEdit
@export var SuffR : LineEdit
@export var SuffM : LineEdit
@export var SuffN : LineEdit
@export var SuffE : LineEdit
@export var SuffO : LineEdit

var window : Window
var Textures : Dictionary
var fileSystemSelPath :PackedStringArray

func _ready():
	ApplyStandardMat.connect("button_down",_on_apply_standard_pressed)

func _on_apply_standard_pressed():
	#print("pressed")
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
	
	window.connect("confirmed",_applayTextures)
	
func _applayTextures():
	fileSystemSelPath.clear()
	
	fileSystemSelPath = EditorInterface.get_selected_paths()
	
	for path in fileSystemSelPath:
		if path.get_extension() == "tres":
			var resource = ResourceLoader.load(path)
			AutoAssingTextures(resource, path.get_file())

func AutoAssingTextures(MaterialFile : StandardMaterial3D, FileName : String):
	Textures.clear()
	
	var NameStruct = NameTexture.text + ("" if NumMaterials.get_selected_id() <= 1 else GetNumberOfMaterial(FileName, 2 if NumMaterials.get_selected_id() == 2 else 3))
	FindTextures("res://", NameStruct)
	
	print(Textures)
	if BaseColor.button_pressed:
		MaterialFile.albedo_texture = Textures[SuffBC.text]
	if Roughness.button_pressed:
		MaterialFile.roughness_texture = Textures[SuffR.text]
	if Metallic.button_pressed:
		MaterialFile.metallic_texture = Textures[SuffM.text]
	if Normal.button_pressed:
		MaterialFile.normal_enabled = true
		MaterialFile.normal_texture = Textures[SuffN.text]
	if Emission.button_pressed:
		MaterialFile.emission_enabled = true
		MaterialFile.emission_texture = Textures[SuffE.text]
	if Occlusion.button_pressed:
		MaterialFile.ao_enabled = true
		MaterialFile.ao_texture = Textures[SuffO.text]
	
func GetNumberOfMaterial(MaterialName : String, NumUnits : int)->String:
	return MaterialName.split(".")[0].right(NumUnits)
	
func FindTextures(path : String, nameStruct : String):
	var dir = DirAccess.open(path)
	
	if DirAccess.get_open_error() != OK:
		print("Failed to open directory: ", path)
		return
		
	dir.list_dir_begin()
	
	var file_or_dir = dir.get_next()
	while file_or_dir != "":
		if file_or_dir.begins_with("."):
			file_or_dir = dir.get_next()
			continue
		
		var fullPath = path.path_join(file_or_dir)
		if dir.current_is_dir():
			FindTextures(fullPath, nameStruct)
		else:
			if file_or_dir.contains(nameStruct) and file_or_dir.get_extension().to_upper() == Extension.get_item_text(Extension.get_selected_id()):
				var FileSplit = file_or_dir.erase(0, nameStruct.length()).split(".")
				var Suffix : String
				if FileSplit[0] == SuffBC.text:
					Suffix = SuffBC.text
				elif FileSplit[0] == SuffR.text:
					Suffix = SuffR.text
				elif FileSplit[0] == SuffM.text:
					Suffix = SuffM.text
				elif FileSplit[0] == SuffN.text:
					Suffix = SuffN.text
				elif FileSplit[0] == SuffE.text:
					Suffix = SuffE.text
				elif FileSplit[0] == SuffO.text:
					Suffix = SuffO.text
					
				if ResourceLoader.exists(fullPath):
					var newTexture = ResourceLoader.load(fullPath)
					Textures[Suffix] = newTexture
		
		file_or_dir = dir.get_next()
		
	dir.list_dir_end()
	
	
