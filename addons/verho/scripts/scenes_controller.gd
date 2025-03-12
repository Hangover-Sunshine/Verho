@tool
extends ScrollContainer

@onready var scene_nickname = $HBox/SceneNickname
@onready var scene_path = $HBox/ScenePath
@onready var add_below = $HBox/AddBelow
@onready var delete = $HBox/Delete

var nickname:LineEdit
var location:LineEdit
var add_button:Button
var delete_button:Button

func _ready():
	# Store and hide local variants
	nickname = $HBox/SceneNickname/Nickname.duplicate(0)
	scene_nickname.register_text_edit($HBox/SceneNickname/Nickname)
	
	location = $HBox/ScenePath/Location.duplicate(0)
	scene_path.register_location_box($HBox/ScenePath/Location)
	
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
	nickbox.text = ""
	nickbox.placeholder_text = nickname.placeholder_text
	scene_nickname.get_child(add_below_index).add_sibling(nickbox)
	scene_nickname.register_text_edit(nickbox)
	
	var pathbox = location.duplicate(0)
	pathbox.text = ""
	pathbox.placeholder_text = location.placeholder_text
	scene_path.get_child(add_below_index).add_sibling(pathbox)
	
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
##
