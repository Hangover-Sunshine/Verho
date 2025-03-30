extends Control

enum ErrorSection {
	INIT,
	SUBMIT_SCENE_CHANGE,
	ON_SCENE_CHANGE,
}

## Emitted once a scene is loaded and about to be added to the SceneTree.
signal loaded_scene(scene_node)
## Emitted once a scene is added to the SceneTree.
signal added_scene(scene_node)
## Emitted when a transition has finished "going in" -- i.e., the screen is visible.
signal faded_in
## Emitted when a transition has finished "going out" -- i.e., the screen is obscured.
signal faded_out
## Emitted when an error occurs, in case the user wants to know what/where it was.
signal verho_error(errSec:ErrorSection, err:String)

## Reference the main scene that everything is contained in, as specified in the
## Project/Project Settings under General/Application/Run.MainScene.
var _parent_scene

#region Scenes
## Scene Nickname -> Scene Path
var _scene_library:Dictionary[String, String] = {}

## Holder for the path to the scene we've been requested to load.
var _scene_path:String

## Points to the current scene being displayed.
var _curr_scene:Node
#endregion

#region Transition
@onready var transition_layer = $TransitionHoldingLayer

## Transition Nickname -> Transition Path
var _trans_library:Dictionary[String, String] = {}

## Transition Path -> VerhoTransition object
var _memory:VerhoMemory = null
var _keep_preloads_in_memory:bool = false

## The current transition being used
var _current_transition:VerhoTransition

var _load_after_fade_out:bool = false
var _fade_out_complete:bool = false
#endregion

func _init():
	# Transition system will ALWAYS be available to run, no matter what.
	# Otherwise, how do we get out of a paused menu when a player selects "quit"?
	process_mode = Node.PROCESS_MODE_ALWAYS
##

func _ready():
	var data = null
	
	# First, check if we're in the engine still or in a standalone release
	var loader:VerhoLoader = VerhoLoader.new()
	if OS.has_feature("editor"):
		data = loader.read_data("res://addons/verho/resources/verho.json")
	else:
		data = loader.read_data("res://addons/verho/verho/verho.blob")
	##
	
	if data == null:
		verho_error.emit(ErrorSection.INIT, "Unable to load Verho settings, bailing early.")
		push_error("VERHO//ERROR: Unable to load Verho, bailing early.")
		return
	##
	
	_load_after_fade_out = !data["immediate"]
	
	for key in data["scenes"].keys():
		_scene_library[key] = data["scenes"][key]
	##
	
	for key in data["trans"].keys():
		_trans_library[key] = data["trans"][key]
	##
	
	var root = get_tree().root.get_tree()
	
	# Hang on to the reference of _parent_scene
	_parent_scene = root.current_scene
	
	# This will be turned on and off at-will when scenes need to be loaded
	set_process(false)
	# This will never be turned on
	set_physics_process(false)
##

func _process(_delta):
	var progress = []
	
	var thread_status:int = ResourceLoader.load_threaded_get_status(_scene_path, progress)
	
	# if it's not done or loaded
	if thread_status == 2:
		push_error("An error has occured loading ", _scene_path, "!")
		return # stop!
	elif thread_status == 0:
		push_error("The scene is invalid or not loaded properly! Provided path: ", _scene_path)
		return # stop!
	##
	
	progress = progress[0]
	_current_transition.loading_progress(progress)
	
	if progress >= 1 and _fade_out_complete:
		_fade_out_complete = false
		
		# get the new scene from the resource loader and instantiate it
		var new_scene = ResourceLoader.load_threaded_get(_scene_path).instantiate()
		
		# set the current scene to invisible and turn it off
		if _curr_scene != null:
			_curr_scene.process_mode = Node.PROCESS_MODE_DISABLED
			_curr_scene.visible = false
		##
		
		# we've finished loading the scene
		emit_signal("loaded_scene", new_scene)
		
		# the new scene is our current scene, we don't care what happens with the other one
		_curr_scene = new_scene
		_parent_scene.add_child(new_scene)
		
		# we've added the scene to the child
		emit_signal("added_scene", new_scene)
		
		_current_transition.play_transition(VerhoTransition.Direction.IN)
		
		# Turn off the capture
		mouse_filter = Control.MOUSE_FILTER_PASS
		
		# stop from coming back here
		set_process(false)
	##
##

func _finished_transition(direction:VerhoTransition.Direction):
	if direction == VerhoTransition.Direction.OUT:
		faded_out.emit()
		_fade_out_complete = true
		
		if _load_after_fade_out:
			_initialize_resource_loader()
		##
	else:
		faded_in.emit()
		_current_transition.queue_free()
		_current_transition = null
	##
##

func _initialize_resource_loader() -> bool:
	# async loading initialization...
	var error = ResourceLoader.load_threaded_request(_scene_path)
	
	# if there's an error, break out and report -- DO NOT CONTINUE!
	if error:
		push_error("Unable to load scene as a request: %s!" % _scene_path)
		return false
	##
	
	# Turn on the process function now that everything is set-up!
	set_process(true)
	
	return true
##

func _initialize_and_fire_transition(transition:String) -> bool:
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# If it's not null yet, tell the last one to free itself quietly!
	if _current_transition != null:
		_current_transition.finished_transition.disconnect(_finished_transition)
		_current_transition.free_on_finished()
	##
	
	# Transitions should always be lightweight and no more than a few KB at max
	var resource:Resource = load(transition)
	
	if resource == null:
		push_error("VERHO//Error: Transition was unable to be loaded!")
		return false
	##
	
	_current_transition = resource.instantiate()
	
	transition_layer.add_child(_current_transition)
	_current_transition.finished_transition.connect(_finished_transition)
	_current_transition.clean_on_finished = false
	_fade_out_complete = false
	_current_transition.play_transition(VerhoTransition.Direction.OUT)
	
	return true
##

# ============================================================
# PUBLIC METHODS
# ============================================================

## Call to swap out the underlying scene in Main Scene. This method expects both
##	`scene_path` and `transition` to be paths. If res:// is not supplied, then
##	the function assumes that the whole base path is missing so it will be prepended.
##	If `transition` is empty, then Verho uses the default transition.
func change_scene(scene_path:String, transition:String = "") -> bool:
	if scene_path == "":
		push_error("VERHO//Error: You have provided an empty string for a scene!")
		return false
	##
	
	if not("res://" in scene_path):
		scene_path = "res://" + scene_path
	##
	_scene_path = scene_path
	
	if not("res://" in transition):
		transition = "res://" + transition
	##
	# Load and fire the transition
	var res:bool = _initialize_and_fire_transition(transition)
	
	if _load_after_fade_out == false:
		res = res && _initialize_resource_loader()
	##
	
	return res
##

## Change scene, assuming you are using nicknames transitions. Scenes are expected to be
##	fully qualified.
func change_scene_ntrans(new_scene:String, transition:String = "") -> bool:
	if new_scene == "":
		push_error("VERHO//Error: You have provided an empty string for a scene!")
		return false
	##
	
	var trans:String = ""
	if transition != "":
		if not(transition in _trans_library.keys()):
			push_error("VERHO//Error: Nickname '%s' does not exist in 
						the transition library!" % transition)
			return false
		##
		
		trans = _trans_library[transition]
	##
	
	return change_scene(new_scene, trans)
##

## Change scene, assuming you are using nicknames for scenes. Transitions are expected to be
##	fully qualified.
func change_nscene(new_scene:String, transition:String = "") -> bool:
	if new_scene == "":
		push_error("VERHO//Error: You have provided an empty string for a scene!")
		return false
	##
	
	if not(new_scene in _scene_library.keys()):
		push_error("VERHO//Error: Nickname '%s' is non-existant!" % new_scene)
		return false
	##
	
	return change_scene(_scene_library[new_scene], transition)
##

## Change scene, assuming you are using nicknames for transitions and scenes.
func change_nscene_ntrans(new_scene:String, transition:String = "") -> bool:
	if new_scene == "":
		push_error("VERHO//Error: You have provided an empty string for a scene!")
		return false
	##
	
	if not(new_scene in _scene_library.keys()):
		push_error("VERHO//Error: Nickname '%s' is non-existant!" % new_scene)
		return false
	##
	
	var trans:String = ""
	if transition != "":
		if not(transition in _trans_library.keys()):
			push_error("VERHO//Error: Nickname '%s' does not exist in the transition library!" % transition)
			return false
		##
		
		trans = _trans_library[transition]
	##
	
	return change_scene(_scene_library[new_scene], trans)
##

## Sets the parent node Verho should add loaded scenes. NULL sets it to the base main scene. Only
##	set this if you want Verho to load to your not-main scene, such as instancing sub-zones or
##	combat scenes or the like.
func set_loaded_scene_parent(node:Node = null):
	if node == null:
		_parent_scene = get_tree().root.get_tree().current_scene
	elif node.is_inside_tree():
		_parent_scene = node
	else:
		push_error("VERHO//Error: Unable to use the provided node %s as it is not part of the scene tree!" % node.name)
	##
##
