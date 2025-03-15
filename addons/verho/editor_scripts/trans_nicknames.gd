@tool
extends VBoxContainer

signal edit_occurred

const ERROR_FLATBOX = preload("res://addons/verho/resources/themes/error_flatbox.tres")
const WARNING_FLATBOX = preload("res://addons/verho/resources/themes/warning_box.tres")

var trans_nicknames:Dictionary[LineEdit, String] = {}
var conflicts:Array = []

func initialize_value(nickbox:LineEdit, value:String):
	trans_nicknames[nickbox] = value
	nickbox.text = value
##

func register_text_edit(nickbox:LineEdit, value:String):
	trans_nicknames[nickbox] = value
	nickbox.text = value
	nickbox.text_changed.connect(_on_text_changed.bind(nickbox))
##

func unregister_text_edit(nickbox:LineEdit):
	trans_nicknames.erase(nickbox)
	_remove_from_conflicts(nickbox)
##

func _on_text_changed(new_string:String, nickbox:LineEdit):
	nickbox.remove_theme_stylebox_override("normal")
	var new_name:String = new_string.to_lower().replace(" ", "_")
	
	# Replace the text
	var cc:int = nickbox.caret_column
	nickbox.text = new_name
	nickbox.caret_column = cc
	
	# Check if this is in any prior conflicts
	var exists:Array
	for conflict in conflicts:
		if nickbox in conflict:
			exists = conflict
			break
		##
	##
	if exists.size() > 0:
		var checknb:LineEdit = exists[1] if nickbox == exists[0] else exists[0]
		if checknb.text != new_name:
			_remove_from_conflicts(nickbox)
		##
	##
	
	var prev_name = trans_nicknames[nickbox]
	trans_nicknames[nickbox] = new_name
	
	if prev_name != "" and new_name == "":
		push_warning("VERHO//WARNING: Empty names don't make for good nicknames!")
		nickbox.add_theme_stylebox_override("normal", WARNING_FLATBOX)
		return
	##
	
	if prev_name != new_name:
		edit_occurred.emit()
	##
	
	# Check if we're in any conflicts
	var conflicting_boxes:Array[LineEdit] = []
	var preexisting:bool = false
	for b in trans_nicknames.keys():
		if b != nickbox and trans_nicknames[b] == new_name:
			for conflict in conflicts:
				if b in conflict:
					exists = conflict
					break
				##
			##
			if exists.size() > 0:
				conflicting_boxes = exists
				preexisting = true
				break
			else:
				conflicting_boxes.append(b)
			##
		##
	##
	
	if conflicting_boxes.size() > 0:
		if preexisting == false:
			conflicting_boxes.append(nickbox)
			conflicts.append(conflicting_boxes)
			for box in conflicting_boxes:
				box.add_theme_stylebox_override("normal", ERROR_FLATBOX)
			##
		elif preexisting:
			nickbox.add_theme_stylebox_override("normal", ERROR_FLATBOX)
			conflicting_boxes.append(nickbox)
		##
		
		push_warning("VERHO//WARNING: Scene nickname '%s' is duplicated %d times!" %\
							[new_name, conflicting_boxes.size()])
	##
##

func _remove_from_conflicts(nickbox:LineEdit):
	var conf:Array = []
	var confID:int = -1
	for conID in range(conflicts.size()):
		if nickbox in conflicts[conID]:
			conf = conflicts[conID]
			confID = conID
			break
		##
	##
	
	if conf.size() > 0:
		# Remove it
		conf.remove_at(conf.find(nickbox))
		nickbox.remove_theme_stylebox_override("normal")
		
		if conf.size() == 1:
			conf[0].remove_theme_stylebox_override("normal")
			conflicts.remove_at(confID)
		##
	##
##
