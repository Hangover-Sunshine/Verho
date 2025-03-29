@tool
extends EditorPlugin

const HR_FILE:String = "res://addons/verho/resources/verho.json"
const MENU = preload("res://addons/verho/resources/menu.tscn")
const EXPORT_PLUGIN = preload("res://addons/verho/export_plugin.gd")

var menu:VerhoContainer
var export
var data:Dictionary

func _enter_tree():
	export = EXPORT_PLUGIN.new()
	add_export_plugin(export)
	add_autoload_singleton("Verho", "verho/verho.tscn")
	
	menu = MENU.instantiate()
	menu.name = "Verho"
	EditorInterface.get_editor_main_screen().add_child(menu)
	_make_visible(false)
	
#region Load From Disk
	if FileAccess.file_exists(HR_FILE):
		var file = FileAccess.open(HR_FILE, FileAccess.READ)
		var contents = file.get_as_text()
		var json = JSON.new()
		var res = json.parse(contents)
		if not(res == OK):
			push_error(("VERHO//ERROR: Unable to load %s, something went wrong! Please verify " +
				"the location and/or contents of the file...") % [HR_FILE])
			return
		##
		menu.set_data(json.data)
	else:
		#region Save To Disk
		_save_to_disk(menu.get_data())
		#endregion
	##
#endregion
##

func _exit_tree():
	remove_autoload_singleton("Verho")
	remove_export_plugin(export)
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
	return load("res://addons/verho/resources/verho-small.png")
##

func _get_state():
	if menu.has_changed():
		data = menu.get_data()
#region Save To Disk
		_save_to_disk(data)
#endregion
	##
	
	return data
##

func _save_to_disk(data):
	var jstring:String = JSON.stringify(data)
	var file_loc = FileAccess.open(HR_FILE, FileAccess.WRITE)
	file_loc.store_line(jstring)
	file_loc.flush()
	file_loc.close()
##
