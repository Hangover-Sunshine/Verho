@tool
extends VBoxContainer

var box_to_name:Dictionary[TextEdit, String] = {}
var conflicts:Array = []

func register_text_edit(nickbox:TextEdit):
	box_to_name[nickbox] = ""
	nickbox.text_changed.connect(_on_text_set.bind(nickbox))
##

func unregister_text_edit(nickbox:TextEdit):
	box_to_name.erase(nickbox)
	_remove_from_conflicts(nickbox)
##

func _on_text_set(nickbox:TextEdit):
	var new_name:String = nickbox.text
	
	# Check if this is in any prior conflicts
	var exists = conflicts.filter(func(conflict): new_name in conflict)
	if exists.size() > 0:
		var checknb:TextEdit = exists[1] if nickbox == exists[0] else exists[0]
		if checknb.text != new_name:
			_remove_from_conflicts(nickbox)
		##
	##
	
	var prev_name = box_to_name[nickbox]
	box_to_name[nickbox] = new_name
	
	if prev_name != "" and new_name == "":
		push_warning("Verho -- WARNING: Empty names don't make for good nicknames!")
		# TODO: Highlight text edit in yellow
		return
	##
	
	# Check if we're in any conflicts
	var conflicting_boxes:Array[TextEdit]
	for b in box_to_name.keys():
		if b != nickbox and box_to_name[b] == new_name:
			exists = conflicts.filter(func(conflict): b in conflict)
			if exists.size() > 0:
				conflicting_boxes = exists
				break
			else:
				conflicting_boxes.append(b)
			##
		##
	##
	
	if conflicting_boxes.size() > 0:
		conflicting_boxes.append(nickbox)
		conflicts.append(conflicting_boxes)
		push_warning("Verho -- WARNING: Scene nickname %s is duplicated %d times!" %\
						[new_name, conflicting_boxes.size()])
		# TODO: Highlight errors in red
	##
##

func _remove_from_conflicts(nickbox:TextEdit):
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
		
		if conf.size() == 1:
			# TODO: Restore the old theme
			conflicts.remove_at(confID)
			pass
		##
	##
##
