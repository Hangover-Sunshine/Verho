@tool
class_name VerhoContainer
extends MarginContainer

@onready var general_container = $Layout/GeneralContainer
@onready var scenes_container:SceneController = $Layout/TabContainer/Scenes
@onready var transition_container = $Layout/TabContainer/Transitions
@onready var warning_container = $Layout/GeneralContainer/WarningContainer
@onready var spacer = $Layout/GeneralContainer/Spacer

var _has_changed = false

func _ready():
	scenes_container.edit_occurred.connect(_edit_made)
	transition_container.edit_occurred.connect(_edit_made)
	general_container.edit_occurred.connect(_edit_made)
##

func _edit_made():
	warning_container.show()
	spacer.hide()
	_has_changed = true
##

func has_changed() -> bool:
	return _has_changed
##

## Get all the data stored as a dictionary. Dictionary is of the form
##	[general/scenes/trans] -> {(based on the earlier type)}
func get_data() -> Dictionary:
	_has_changed = false
	warning_container.hide()
	spacer.show()
	
	var data:Dictionary = {}
	
#region General Saving
	data["general"] = general_container.get_data()
#endregion
	
#region Scene Saving
	data["scenes"] = scenes_container.get_scene_pairs()
#endregion
	
#region Transition Saving
	data["trans"] = transition_container.save_data()
#endregion
	
	return data
##

func set_data(data:Dictionary):
	if general_container.load_data(data["general"]) == false:
		push_warning("VERHO//WARNING: Error attempting to base information. Please review the above carefully.")
	##
	
	if scenes_container.load_scene_pairs(data["scenes"]) == false:
		push_warning("VERHO//WARNING: Error attempting to load scenes. Please review the above carefully.")
	##
	
	if transition_container.load_data(data["trans"]) == false:
		push_warning("VERHO//WARNING: Error attempting to transitions. Please review the above carefully.")
	##
##
