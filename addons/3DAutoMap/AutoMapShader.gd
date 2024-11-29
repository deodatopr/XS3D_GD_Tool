@tool
extends Control
class_name AutoMapShader

@export var NameTexture : LineEdit
@export var NumDigits : OptionButton
@export var Extension : OptionButton

@export var ExampleName : LineEdit
@export var ExampleDigits : LineEdit
@export var ExampleExtension : LineEdit

@export var AutoMap : AutoMap

@export var ParametersContainer : VBoxContainer

const SHADER_PARAMETER = preload('uid://bacl4oequehqx')

var window : Window
var Textures : Dictionary
var ShaderParameters : Array[ShaderParameter] =[]

func _on_apply_shader_pressed():
	window = AutoMap.ComfirmationWindow(NameTexture, NumDigits, Extension)
	
	if window != null:
		window.connect("confirmed",_applyTextures)
		
func _applyTextures():
	for path in AutoMap.fileSystemSelPath:
		if path.get_extension() == "tres":
			var resource = ResourceLoader.load(path)
			AutoAssingTextures(resource, path.get_file())
			
func AutoAssingTextures(MaterialFile : ShaderMaterial, FileName : String):
	Textures.clear()

	var DigitText : String = ""
	if NumDigits.get_selected_id() > 1:
		DigitText = GetDigitsOfMaterial(FileName, NumDigits.get_selected_id())
	var NameStruct = NameTexture.text + DigitText
	FindTextures("res://", NameStruct)
	
	for Param in ShaderParameters:
		for Suffix in Textures.keys():
			if Param.TextureSuff.text == Suffix:
				MaterialFile.set_shader_parameter(Param.ParameterName.text, Textures[Suffix])
	
func GetDigitsOfMaterial(MaterialName : String, NumUnits : int)->String:
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
				for Param in ShaderParameters:
					if Param.TextureSuff.text == FileSplit[0] and !Textures.has(Param.TextureSuff): 
						Suffix = Param.TextureSuff.text
					
				if ResourceLoader.exists(fullPath) and !Suffix.is_empty():
					var newTexture = ResourceLoader.load(fullPath)
					Textures[Suffix] = newTexture
		
		file_or_dir = dir.get_next()
		
	dir.list_dir_end()	
	
func _on_add_parameter_pressed():
	var newShaderParameter = SHADER_PARAMETER.instantiate()
	newShaderParameter.AutoMapShader = self
	ParametersContainer.add_child(newShaderParameter)
	ShaderParameters.append(newShaderParameter)
	
func _on_reset_standard_pressed():
	var RemoveParameters  = ShaderParameters
	for Param in RemoveParameters:
		Param.queue_free()
	
	ShaderParameters.clear()
