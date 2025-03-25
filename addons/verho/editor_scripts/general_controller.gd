@tool
class_name GeneralController
extends VBoxContainer

signal edit_occurred

@onready var queue_size = $TransitionMemory/QueueSize/LineEdit
@onready var preload_size = $PreloadedTrans/VBoxContainer/HBoxContainer/LineEdit
@onready var nicktainer = $PreloadedTrans/VBoxContainer/ScrollContainer/VBoxContainer

var transition_nicknames:Array = []

func _ready():
	queue_size.text_submitted.connect(_on_numeric_text_submitted.bind(queue_size))
	queue_size.focus_exited.connect(_on_numeric_text_focus_lost.bind(queue_size))
	preload_size.text_submitted.connect(_on_numeric_text_submitted.bind(preload_size))
	preload_size.focus_exited.connect(_on_numeric_text_focus_lost.bind(preload_size))
##

func _on_check_button_pressed():
	edit_occurred.emit()
##

func _on_numeric_text_focus_lost(line_edit):
	var curr_text = line_edit.text
	if line_edit.text.is_valid_int() == false or int(line_edit.text) < 0:
		line_edit.text = "0"
	##
	
	if line_edit == preload_size:
		var new_count:int = int(line_edit.text)
		var count:int = nicktainer.get_child_count()
		var diff = new_count - count
		if count < new_count:
			for i in range(diff):
				var nle = LineEdit.new()
				nle.text_submitted.connect(_on_text_submitted.bind(nle))
				nle.focus_exited.connect(_on_text_submitted.bind(nle.text, nle))
				nicktainer.add_child(nle)
			##
			if transition_nicknames.size() < new_count:
				for i in range(new_count - transition_nicknames.size()):
					transition_nicknames.push_back("")
				##
			##
		elif count > new_count:
			for i in range(count - 1, new_count - 1, -1):
				nicktainer.remove_child(nicktainer.get_child(i))
			##
		##
	##
	
	if curr_text != line_edit.text:
		edit_occurred.emit()
	##
##

func _on_numeric_text_submitted(new_text, line_edit):
	var curr_text = line_edit.text
	if new_text.is_valid_int() == false or int(new_text) < 0:
		line_edit.text = "0"
		new_text = "0"
	##
	
	if line_edit == preload_size:
		var new_count:int = int(new_text)
		var count:int = nicktainer.get_child_count()
		var diff = new_count - count
		if count < new_count:
			for i in range(diff):
				var list_index:int = nicktainer.get_child_count()
				var nle = LineEdit.new()
				
				if list_index < transition_nicknames.size():
					nle.text = transition_nicknames[list_index]
				##
				
				nle.text_submitted.connect(_on_text_submitted.bind(nle))
				nle.focus_exited.connect(_on_text_focus_lost.bind(nle))
				nicktainer.add_child(nle)
			##
			if transition_nicknames.size() < new_count:
				for i in range(new_count - transition_nicknames.size()):
					transition_nicknames.push_back("")
				##
			##
		elif count > new_count:
			for i in range(count - 1, new_count - 1, -1):
				nicktainer.remove_child(nicktainer.get_child(i))
			##
		##
	##
	
	edit_occurred.emit()
##

func _on_text_submitted(new_text, line_edit):
	var indx = nicktainer.get_children().find(line_edit)
	
	var old = transition_nicknames[indx]
	transition_nicknames[indx] = new_text.to_lower().replace(" ", "_")
	
	if old != transition_nicknames[indx]:
		edit_occurred.emit()
	##
##

func _on_text_focus_lost(line_edit):
	var indx = nicktainer.get_children().find(line_edit)
	
	if line_edit.text != transition_nicknames[indx]:
		var old = transition_nicknames[indx]
		transition_nicknames[indx] = line_edit.text.to_lower().replace(" ", "_")
		edit_occurred.emit()
	##
##

func get_data() -> Dictionary:
	#var filtered_names:Array = []
	
	#if int(preload_size.text) < transition_nicknames.size():
		#for i in range(int(preload_size.text)):
			#filtered_names.push_back(transition_nicknames[i])
		###
	#else:
		#filtered_names = transition_nicknames
	##
	
	return { 
		"load_immediately": $ImmediateLoad/CheckButton.button_pressed,
		#"allow_growth": $TransitionMemory/Growable/CheckButton.button_pressed,
		#"keep_preloads": $TransitionMemory/OnlyPreloads/CheckButton.button_pressed,
		#"preload_size": int(preload_size.text),
		#"queue_size": int(queue_size.text),
		#"preload_trans": filtered_names,
	}
##

func load_data(data:Dictionary) -> bool:
	var success:bool = true
	
	$ImmediateLoad/CheckButton.set_pressed_no_signal(data["load_immediately"])
	#$TransitionMemory/OnlyPreloads/CheckButton.set_pressed_no_signal(data["only_preloads"])
	#$TransitionMemory/Growable/CheckButton.set_pressed_no_signal(data["allow_growth"])
	#preload_size.text = str(int(data["preload_size"]))
	#queue_size.text = str(int(data["queue_size"]))
	#transition_nicknames = data["preload_trans"]
	
	#for i in range(data["preload_size"]):
		#var nle = LineEdit.new()
		#nle.text = transition_nicknames[i]
		#nle.text_submitted.connect(_on_text_submitted.bind(nle))
		#nle.focus_exited.connect(_on_text_focus_lost.bind(nle))
		#nicktainer.add_child(nle)
	##
	
	return success
##
