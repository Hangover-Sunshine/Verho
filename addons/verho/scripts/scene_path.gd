@tool
extends VBoxContainer

var scenes:Array[String] = []

func register_location_box(box:LineEdit):
	box.text_changed.connect(_on_text_changed)
##

func unregister_location_box(id:int):
	scenes.remove_at(id - 1)
##

func _on_text_changed(new_string:String):
	pass
##
