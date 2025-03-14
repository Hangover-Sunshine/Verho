@tool
class_name VerhoContainer
extends MarginContainer

@onready var general_container = $Layout/GeneralContainer
@onready var scenes_container:SceneController = $Layout/TabContainer/Scenes
@onready var scene_path = $Layout/TabContainer/Scenes/HBox/ScenePath
@onready var transition_container = $Layout/TabContainer/Transitions

var _has_changed = false

func _ready():
	pass
##

func has_changed() -> bool:
	return true
##

## Get all the data stored as a dictionary. Dictionary is of the form
##	[general/scenes/trans] -> {(based on the earlier type)}
func get_data() -> Dictionary:
	_has_changed = false
	var data:Dictionary = {}
	
#region General Saving
	data["general"] = general_container.get_data()
#endregion
	
#region Scene Saving
	data["scenes"] = scenes_container.get_scene_pairs()
#endregion
	
#region Transition Saving
	data["trans"] = {}
#endregion
	
	return data
##

func set_data(data:Dictionary):
	if scenes_container.load_scene_pairs(data["scenes"]) == false:
		push_warning("VERHO//WARNING: Error attempting to load scenes. Please review it carefully.")
	##
##
