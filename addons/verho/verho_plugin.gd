@tool
extends EditorPlugin

const MENU = preload("res://addons/verho/menu.tscn")
var menu:MarginContainer

func _enter_tree():
	add_autoload_singleton("Verho", "transition_manager/verho.tscn")
	menu = MENU.instantiate()
	menu.name = "Verho"
	EditorInterface.get_editor_main_screen().add_child(menu)
	_make_visible(false)
##

func _exit_tree():
	remove_autoload_singleton("Verho")
	if menu:
		menu.queue_free()
	##
##

func _has_main_screen():
	return true
##

func _make_visible(visible):
	if menu:
		menu.visible = visible
	##
##

func _get_plugin_name():
	return "Verho"
##

func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
##
