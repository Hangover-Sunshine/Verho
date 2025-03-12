@tool
extends VBoxContainer

const ERROR_FLATBOX = preload("res://addons/verho/resources/themes/error_flatbox.tres")
const WARNING_FLATBOX = preload("res://addons/verho/resources/themes/warning_box.tres")

const ILLEGAL_SURROUNDING_CHARACTERS = [" ", "/", "\\", "*", "|", "<", ">", ":", "?", "."]
const ILLEGAL_INTERNAL_CHARACTERS = ["*", "|", "<", ">", ":", "?", "\\"]

var base_path:String = "res://scenes/"
var component_base_path:Array[String] = ["res:", "scenes"]
var scene_paths:Array[String] = []

func register_location_box(box:LineEdit):
	scene_paths.push_back("")
	box.text_submitted.connect(_on_text_changed.bind(box))
	box.focus_exited.connect(_on_lost_focus.bind(box))
##

## Remove the scene path from memory.
func unregister_location_box(id:int):
	scene_paths.remove_at(id - 1)
##

func _updated_scene_base(new_base:String):
	var old_base = base_path
	base_path = new_base
	
	# Go through all of them and check...
	for sp in range(scene_paths.size()):
		var old_path = old_base + scene_paths[sp]
		
		if base_path == old_path.substr(0, base_path.length()):
			old_path = old_path.substr(base_path.length())
		##
		
		scene_paths[sp] = old_path
		get_child(sp + 1).text = old_path
	##
##

func _on_text_changed(new_string:String, box:LineEdit):
	print(">> Entered >>")
	var id:int = get_children().find(box) - 1
	
	# Nothing's changed, don't process
	if scene_paths[id] == new_string:
		return
	##
	
	# Clear the box in case there's a stylebox there
	box.remove_theme_stylebox_override("normal")
	
	var results = _process_string(new_string, id)
	
	# Update the visuals
	box.text = results[0]
	
	if results[1] != null:
		box.add_theme_stylebox_override("normal", results[1])
	##
##

func _on_lost_focus(box:LineEdit):
	print(">> Lost focus >>")
	var id:int = get_children().find(box) - 1
	
	# If we lose focus before someone after user hits enter, make sure we don't duplicate work
	if box.text == scene_paths[id]:
		return
	##
	
	# Clear the box in case there's a stylebox there
	box.remove_theme_stylebox_override("normal")
	
	var results = _process_string(box.text, id)
	
	# Update the visuals
	box.text = results[0]
	
	if results[1] != null:
		box.add_theme_stylebox_override("normal", results[1])
	##
##

func _process_string(new_string:String, id:int) -> Array:
	# Returns
	var processed:String = new_string
	var warningTheme:StyleBox = null
	
	var scn_proceessed:String
	var res_processed:String
	var use_scn:bool = false
	
	if processed.length() > 0:
		# Sanitize the string before doing anything to it
		processed = _sanitize_string(processed)
		
		# Prepend the base_path if it doesn't exist and we have some string
		if processed.length() > 0:
			var path_components:Array
			var res_base:Array = processed.split("//")
			
			if res_base.size() == 1:
				path_components = processed.split("/")
			else:
				path_components = res_base[1].split("/")
				path_components.push_front(res_base[0])
			##
			
			var constructed_base:String
			
			var index_in_path:int = 0
			for i in range(component_base_path.size()):
				if component_base_path[i] == path_components[index_in_path]:
					# We "found" where the user cut it off!
					# If there's an actual issue, though, that's on them to fix!
					# We don't know their file structure!
					break
				##
				constructed_base += component_base_path[i]
				if i > 0:
					constructed_base += "/"
				else:
					constructed_base += "//"
				##
			##
			
			if constructed_base.length() > 0:
				processed = constructed_base + processed
			##
			
			# Will split into [file/path/thing, "tscn"/"scn"/"res"] or
			#	[file/path/thing]
			var split = processed.split(".", false)
			
			# If the latter, then check if .tscn, .scn, or .res exist at the location
			if split.size() == 1:
				scn_proceessed = processed + ".scn"
				res_processed = processed + ".res"
				processed = processed + ".tscn"
			##
		##
	##
	
	if processed.length() > 0:
		# If the file does not exist, warn the user!
		var tscn_check:bool = FileAccess.file_exists(processed)
		var scn_check:bool = FileAccess.file_exists(scn_proceessed)
		var res_check:bool = FileAccess.file_exists(res_processed)
		
		if tscn_check == false and scn_check == false and res_check == false:
			push_warning("VERHO//WARNING: Unknown scene! Will be removed on export.")
			warningTheme = WARNING_FLATBOX
			processed = processed.substr(0, processed.length() - 5)
		elif tscn_check:
			processed = processed.substr(0, processed.length() - 5)
		elif scn_check:
			processed = scn_proceessed
		else:
			processed = res_processed
		##
		
		# Remove the base path
		processed = processed.substr(base_path.length())
	else:
		push_warning("VERHO//WARNING: Unknown scene! Will be removed on export.")
		warningTheme = WARNING_FLATBOX
	##
	
	# Swap out in the library
	scene_paths[id] = processed
	
	return [processed, warningTheme]
##

func _sanitize_string(str:String) -> String:
	var processed:String = str
	
	# If we have a leading illegal character, remove it
	var start:int = 0
	while processed[start] in ILLEGAL_SURROUNDING_CHARACTERS:
		start += 1
	##
	# Remove the leading / and \
	processed = processed.substr(start)
	
	# If we have an ending illegal character, remove it
	var end:int = processed.length() - 1
	while processed[end] in ILLEGAL_SURROUNDING_CHARACTERS:
		end -= 1
	##
	
	if end != processed.length() - 1:
		processed = processed.substr(0, end + 1)
	##
	
	# Remove all internal white spaces
	processed = processed.replace(" ", "_")
	
	return processed
##
