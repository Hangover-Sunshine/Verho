@tool
class_name FileFolderLabel
extends Label

@export var ValidFormats:PackedStringArray = []

signal open_dialog(label:FileFolderLabel)
signal path_updated(path:String, label:FileFolderLabel)

func _ready():
	gui_input.connect(_on_gui_input)
##

func set_file(file_path:String):
	var old:String = text
	text = file_path
	
	if text.hash() != old.hash() or text != old:
		path_updated.emit(text, self)
	##
##

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1:
			open_dialog.emit(self)
		##
		if event.button_index == 2:
			_clear()
		##
	##
##

func _clear():
	var old = text
	text = ""
	tooltip_text = ""
	
	if text.hash() != old.hash() or text != old:
		path_updated.emit(text, self)
	##
##

func _can_drop_data(_pos, data):
	if data["type"] != "files":
		return false
	##
	
	var okay:bool = false
	for f in data["files"]:
		if f.get_extension() in ValidFormats:
			okay = true
			break
		##
	##
	
	return okay
##

func _drop_data(_pos, data):
	var old = text
	
	if data["files"].size() > 1:
		print_debug("VERHO//NOTE: Only taking the first valid one in the list...")
		for f in data["files"]:
			if f.get_extension() in ValidFormats:
				text = f
				break
			##
		##
	else:
		text = data["files"][0]
	##
	
	tooltip_text = text
	
	if text.hash() != old.hash() or text != old:
		path_updated.emit(text, self)
	##
##
