@tool
extends VBoxContainer

signal edit_occurred

const WARNING_FLATBOX = preload("res://addons/verho/resources/themes/warning_box.tres")

var trans_paths:Array[String] = []

func register_location_box(box:FileFolderLabel, value:String):
	trans_paths.push_back(value)
	if value != "":
		box.text = value
	##
	box.path_updated.connect(_on_text_changed)
##

func initialize_value(box:FileFolderLabel, id:int, value:String):
	box.text = value
	trans_paths[id] = value
##

## Remove the scene path from memory.
func unregister_location_box(id:int):
	trans_paths.remove_at(id - 1)
##

func _on_text_changed(new_string:String, box:FileFolderLabel):
	box.remove_theme_stylebox_override("normal")
	var id:int = get_children().find(box) - 1
	
	# Nothing's changed, don't process
	if trans_paths[id] == new_string:
		return
	##
	
	trans_paths[id] = new_string
	edit_occurred.emit()
	
	if new_string == "":
		push_warning("VERHO//WARNING: This reference will be removed on export!")
		box.add_theme_stylebox_override("normal", WARNING_FLATBOX)
	##
##
