@tool
extends ScrollContainer

signal edit_occurred

@onready var trans_nickname = $HBoxContainer/TransNickname
@onready var trans_location = $HBoxContainer/TransLocation
@onready var add_below = $HBoxContainer/AddBelow
@onready var delete = $HBoxContainer/Delete
@onready var transition_dialog = $TransDialog

var nick_template:LineEdit
var ffl_template:FileFolderLabel
var add_template:Button
var del_template:Button

func _ready():
	trans_nickname.edit_occurred.connect(_edit_occurred)
	trans_location.edit_occurred.connect(_edit_occurred)
	
	nick_template = $HBoxContainer/TransNickname/LineEdit.duplicate(0)
	trans_nickname.register_text_edit($HBoxContainer/TransNickname/LineEdit, "")
	
	ffl_template = $HBoxContainer/TransLocation/FileFolderLabel.duplicate(4)
	trans_location.register_location_box($HBoxContainer/TransLocation/FileFolderLabel, "")
	transition_dialog.register_file_folder_label($HBoxContainer/TransLocation/FileFolderLabel)
	
	add_template = $HBoxContainer/AddBelow/Button.duplicate(0)
	$HBoxContainer/AddBelow/Button.pressed.connect(_on_add_below_pressed.bind($HBoxContainer/AddBelow/Button))
	
	del_template = $HBoxContainer/Delete/Button.duplicate(0)
	$HBoxContainer/Delete/Button.pressed.connect(_delete_pressed.bind($HBoxContainer/Delete/Button))
##

func _on_add_below_pressed(button:Button):
	var add_below_index:int = add_below.get_children().find(button)
	
	var nickbox:LineEdit = nick_template.duplicate(0)
	nickbox.placeholder_text = nick_template.placeholder_text
	trans_nickname.get_child(add_below_index).add_sibling(nickbox)
	trans_nickname.register_text_edit(nickbox, "")
	
	var pathbox = ffl_template.duplicate(4)
	trans_location.get_child(add_below_index).add_sibling(pathbox)
	trans_location.register_location_box(pathbox, "")
	transition_dialog.register_file_folder_label(pathbox)
	
	var add_btn = add_template.duplicate(0)
	add_btn.pressed.connect(_on_add_below_pressed.bind(add_btn))
	button.add_sibling(add_btn)
	
	var delete_btn = del_template.duplicate(0)
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
	
	var nn = trans_nickname.get_child(delete_button_index)
	var sp = trans_location.get_child(delete_button_index)
	var ab = add_below.get_child(delete_button_index)
	
	trans_nickname.remove_child(nn)
	trans_nickname.unregister_text_edit(nn)
	
	trans_location.remove_child(sp)
	trans_location.unregister_location_box(delete_button_index)
	
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

func save_data() -> Array:
	var pairs:Array = []
	
	# Just grab them all
	var nicknames:Array = trans_nickname.trans_nicknames.values()
	for index in range(nicknames.size()):
		var tnn:String = nicknames[index]
		var tp:String = trans_location.trans_paths[index]
		pairs.append([tnn, tp])
	##
	
	return pairs
##

func load_data(data:Array) -> bool:
	if data.size() > 1:
		delete.get_child(1).disabled = false
	##
	
#region Nick Name
	trans_nickname.initialize_value($HBoxContainer/TransNickname/LineEdit, data[0][0])
#endregion
	
#region Scene Location
	trans_location.initialize_value($HBoxContainer/TransLocation/FileFolderLabel, 0, data[0][1])
#endregion
	
	for index in range(1, data.size()):
#region Nick Name
		var nickbox:LineEdit = nick_template.duplicate(0)
		nickbox.placeholder_text = nick_template.placeholder_text
		trans_nickname.add_child(nickbox)
		trans_nickname.register_text_edit(nickbox, data[index][0])
#endregion
		
#region Scene Location
		var pathbox = ffl_template.duplicate(4)
		trans_location.add_child(pathbox)
		trans_location.register_location_box(pathbox, data[index][1])
		transition_dialog.register_file_folder_label(pathbox)
#endregion
		
#region Add Button
		var add_btn = add_template.duplicate(0)
		add_btn.pressed.connect(_on_add_below_pressed.bind(add_btn))
		add_below.add_child(add_btn)
#endregion
		
#region Delete Button
		var delete_btn = del_template.duplicate(0)
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
		if f.get_extension() in ["tscn", "scn"]:
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
		var nickbox:LineEdit = nick_template.duplicate(0)
		nickbox.placeholder_text = nick_template.placeholder_text
		trans_nickname.add_child(nickbox)
		trans_nickname.register_text_edit(nickbox, "")
		nickbox.text = fname
		nickbox.text_changed.emit(fname)
		#=====#
		
		#=====#
		var pathbox = ffl_template.duplicate(4)
		trans_location.add_child(pathbox)
		trans_location.register_location_box(pathbox, f)
		transition_dialog.register_file_folder_label(pathbox)
		#=====#
		
		#=====#
		var add_btn = add_template.duplicate(0)
		add_btn.pressed.connect(_on_add_below_pressed.bind(add_btn))
		add_below.add_child(add_btn)
		#=====#
		
		#=====#
		var delete_btn = del_template.duplicate(0)
		delete_btn.pressed.connect(_delete_pressed.bind(delete_btn))
		delete_btn.disabled = false
		delete.add_child(delete_btn)
		#=====#
	##
	
	_edit_occurred()
##
