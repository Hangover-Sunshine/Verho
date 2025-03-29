@tool
class_name SceneController
extends ScrollContainer

signal edit_occurred

@onready var scene_nickname = $HBox/SceneNickname
@onready var scene_path = $HBox/ScenePath
@onready var add_below = $HBox/AddBelow
@onready var delete = $HBox/Delete
@onready var scene_file_dialog = $SceneFileDialog

var nickname:LineEdit
var location:FileFolderLabel
var add_button:Button
var delete_button:Button

func _ready():
	scene_nickname.edit_occurred.connect(_edit_occurred)
	scene_path.edit_occurred.connect(_edit_occurred)
	
	# Store and hide local variants
	nickname = $HBox/SceneNickname/Nickname.duplicate(0)
	scene_nickname.register_text_edit($HBox/SceneNickname/Nickname, "")
	
	location = $HBox/ScenePath/FileFolderLabel.duplicate(4)
	scene_path.register_location_box($HBox/ScenePath/FileFolderLabel, "")
	scene_file_dialog.register_file_folder_label($HBox/ScenePath/FileFolderLabel)
	
	add_button = $HBox/AddBelow/AddButton.duplicate(0)
	delete_button = $HBox/Delete/DeleteButton.duplicate(0)
	
	for child in add_below.get_children():
		if child is Button:
			child.pressed.connect(_on_add_below_pressed.bind(child))
		##
	##
	
	for child in delete.get_children():
		if child is Button:
			child.pressed.connect(_delete_pressed.bind(child))
		##
	##
##

func _on_add_below_pressed(button:Button):
	var add_below_index:int = add_below.get_children().find(button)
	
	var nickbox:LineEdit = nickname.duplicate(0)
	nickbox.placeholder_text = nickname.placeholder_text
	scene_nickname.get_child(add_below_index).add_sibling(nickbox)
	scene_nickname.register_text_edit(nickbox, "")
	
	var pathbox = location.duplicate(4)
	scene_path.get_child(add_below_index).add_sibling(pathbox)
	scene_path.register_location_box(pathbox, "")
	scene_file_dialog.register_file_folder_label(pathbox)
	
	var add_btn = add_button.duplicate(0)
	add_btn.pressed.connect(_on_add_below_pressed.bind(add_btn))
	button.add_sibling(add_btn)
	
	var delete_btn = delete_button.duplicate(0)
	delete_btn.pressed.connect(_delete_pressed.bind(delete_btn))
	delete_btn.disabled = false
	delete.get_child(add_below_index).add_sibling(delete_btn)
	
	if delete.get_child_count() > 2:
		delete.get_child(1).disabled = false
	##
	
	_edit_occurred()
##

func _delete_pressed(button:Button):
	var delete_button_index:int = delete.get_children().find(button)
	
	var nn = scene_nickname.get_child(delete_button_index)
	var sp = scene_path.get_child(delete_button_index)
	var ab = add_below.get_child(delete_button_index)
	
	scene_nickname.remove_child(nn)
	scene_nickname.unregister_text_edit(nn)
	
	scene_path.remove_child(sp)
	scene_path.unregister_location_box(delete_button_index)
	
	add_below.remove_child(ab)
	delete.remove_child(button)
	
	nn.queue_free()
	sp.queue_free()
	ab.queue_free()
	button.queue_free()
	
	if delete.get_child_count() == 2:
		delete.get_child(1).disabled = true
	##
	
	_edit_occurred()
##

func _edit_occurred():
	edit_occurred.emit()
##

func get_scene_pairs() -> Array:
	var pairs:Array = []
	
	# Just grab them all
	var nicknames:Array = scene_nickname.box_to_name.values()
	for index in range(nicknames.size()):
		var snn:String = nicknames[index]
		var sp:String = scene_path.scene_paths[index]
		pairs.append([snn, sp])
	##
	
	return pairs
##

func load_scene_pairs(data:Array) -> bool:
	if data.size() > 1:
		delete.get_child(1).disabled = false
	##
	
#region Nick Name
	scene_nickname.initialize_value($HBox/SceneNickname/Nickname, data[0][0])
#endregion
	
#region Scene Location
	scene_path.initialize_value($HBox/ScenePath/FileFolderLabel, 0, data[0][1])
#endregion
	
	for index in range(1, data.size()):
#region Nick Name
		var nickbox:LineEdit = nickname.duplicate(0)
		nickbox.placeholder_text = nickname.placeholder_text
		scene_nickname.add_child(nickbox)
		scene_nickname.register_text_edit(nickbox, data[index][0])
#endregion
		
#region Scene Location
		var pathbox = location.duplicate(4)
		scene_path.add_child(pathbox)
		scene_path.register_location_box(pathbox, data[index][1])
		scene_file_dialog.register_file_folder_label(pathbox)
#endregion
		
#region Add Button
		var add_btn = add_button.duplicate(0)
		add_btn.pressed.connect(_on_add_below_pressed.bind(add_btn))
		add_below.add_child(add_btn)
#endregion
		
#region Delete Button
		var delete_btn = delete_button.duplicate(0)
		delete_btn.disabled = false
		delete_btn.pressed.connect(_delete_pressed.bind(delete_btn))
		delete.add_child(delete_btn)
#endregion
	##
	
	return true
##

func _can_drop_data(_pos, data):
	if data["type"] != "files":
		return false
	##
	
	var okay:bool = false
	for f in data["files"]:
		if f.get_extension() in ["tscn", "scn", "res"]:
			okay = true
			break
		##
	##
	
	return okay
##

func _drop_data(_pos, data):
	for f in data["files"]:
		var fname = f.get_file().split(".")[0]
		
		#=====#
		var nickbox:LineEdit = nickname.duplicate(0)
		nickbox.placeholder_text = nickname.placeholder_text
		scene_nickname.add_child(nickbox)
		scene_nickname.register_text_edit(nickbox, "")
		nickbox.text = fname
		nickbox.text_changed.emit(fname)
		#=====#
		
		#=====#
		var pathbox = location.duplicate(4)
		scene_path.add_child(pathbox)
		scene_path.register_location_box(pathbox, f)
		scene_file_dialog.register_file_folder_label(pathbox)
		#=====#
		
		#=====#
		var add_btn = add_button.duplicate(0)
		add_btn.pressed.connect(_on_add_below_pressed.bind(add_btn))
		add_below.add_child(add_btn)
		#=====#
		
		#=====#
		var delete_btn = delete_button.duplicate(0)
		delete_btn.pressed.connect(_delete_pressed.bind(delete_btn))
		delete_btn.disabled = false
		delete.add_child(delete_btn)
		#=====#
	##
	
	_edit_occurred()
##
