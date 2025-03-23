extends Control

enum ErrorSection {
	INIT,
	SUBMIT_SCENE_CHANGE,
	ON_SCENE_CHANGE,
}

## Emitted when change_scene() is called to inform other potential systems
## that the currently active level/scene is about to change.
signal load_new_scene(scene_node)
## Emitted once a scene is loaded and about to be added to the SceneTree.
signal loaded_scene(scene_node)
## Emitted once a scene is added to the SceneTree.
signal added_scene(scene_node)
## Signal emitted when a transition has finished "going in" -- i.e., the screen is visible.
signal faded_in
## Signal emitted when a transition has finished "going out" -- i.e., the screen is obscured.
signal faded_out
## Emitted when an error occurs, in case the user wants to know what/where it was.
signal verho_error(errSec:ErrorSection, err:String)

## Reference the main scene that everything is contained in, as specified in the
## Project/Project Settings under General/Application/Run.MainScene.
var _main_scene

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

## Holder for the path to the transition we've been requested to use.
var _trans_path:String

## The current transition being used
var _current_transition

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
	
	if FileAccess.file_exists("res://addons/verho/resources/verho.json"):
		if FileAccess.file_exists("res://addons/verho/verho/verho.blob"):
			if FileAccess.get_modified_time("res://addons/verho/resources/verho.json") >\
				FileAccess.get_modified_time("res://addons/verho/verho/verho.blob"):
				var json_loader:VerhoJSONLoader = VerhoJSONLoader.new()
				data = json_loader.read_file("res://addons/verho/resources/verho.json")
			else:
				var loader:VerhoLoader = VerhoLoader.new()
				data = loader.read_data("res://addons/verho/verho/verho.blob")
			##
		else:
			var json_loader:VerhoJSONLoader = VerhoJSONLoader.new()
			data = json_loader.read_file("res://addons/verho/resources/verho.json")
		##
	##
	
	#print(">> Finished parsing!")
	#print(data)
	#print("^^ Results ^^")
	
	if data == null:
		verho_error.emit(ErrorSection.INIT, "Unable to load Verho settings, bailing early.")
		push_error("VERHO//ERROR: Unable to load Verho, bailing early.")
		return
	##
	
	_load_after_fade_out = !data["immediate"]
	
	# Preload the transitions into memory... Not part of the scene, just in memory ready to go.
	if data["preload"]:
		pass
	##
	
	for key in data["scenes"].keys():
		_scene_library[key] = data["scenes"][key]
	##
	
	for key in data["trans"].keys():
		_trans_library[key] = data["trans"][key]
	##
	
	var root = get_tree().root.get_tree()
	
	# Hang on to the reference of _main_scene
	_main_scene = root.current_scene
	
	connect("load_new_scene", _load_new_scene)
	connect("faded_out", _initialize_resource_loader)
	
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
		_main_scene.add_child(new_scene)
		
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
		# TODO: replace queue free
		_current_transition.queue_free()
	##
##

func _load_new_scene(scene:String, library:String, transition:String):
	# async loading initialization...
	var error = ResourceLoader.load_threaded_request(_scene_path)
	
	# if there's an error, break out and report -- DO NOT CONTINUE!
	if error:
		push_error("Unable to load scene as a request: %s!" % _scene_path)
		return
	##
	
	# Turn on the process function now that everything is set-up!
	set_process(true)
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

func _initialize_and_fire_transition() -> bool:
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Transitions should always be lightweight and no more than a few KB at max
	var resource:Resource = load(_trans_path)
	
	if resource == null:
		push_error("VERHO//Error: Resource was unable to be loaded!")
		return false
	##
	
	_current_transition = resource.instantiate()
	transition_layer.add_child(_current_transition)
	_fade_out_complete = false
	_current_transition.play_transition(VerhoTransition.Direction.OUT)
	_current_transition.finished_transition.connect(_finished_transition)
	
	return true
##

func _properize_scene_path(path:String) -> String:
	var fixed:String = path
	
	return fixed
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
	
	## TODO: Verify scene_path
	_scene_path = scene_path
	
	## TODO: Verify transition
	_trans_path = transition
	
	# Load and fire the transition
	var res:bool = _initialize_and_fire_transition()
	
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
