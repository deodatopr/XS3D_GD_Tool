@tool
extends EditorPlugin

var TextureBatcher
const QUICK_TEXTURE_BATHCER = preload('uid://cwj1co1agaoer')

func _enter_tree():
	TextureBatcher = QUICK_TEXTURE_BATHCER.instantiate()
	
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BR, TextureBatcher)


func _exit_tree():
	remove_control_from_docks(TextureBatcher)
	
	TextureBatcher.queue_free()
