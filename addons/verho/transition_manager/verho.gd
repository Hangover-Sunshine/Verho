extends Control

## Emitted when change_scene() is called to inform other potential systems
## that the currently active level/scene is about to change.
signal load_new_scene(scene_name:String)
## Emitted once a scene is loaded and about to be added to the SceneTree.
signal loaded_scene(scene_name:String)
## Emitted once a scene is added to the SceneTree.
signal added_to_scene(scene_name:String)
## Signal emitted when a transition has finished "going in" -- i.e., the screen is visible.
signal faded_in
## Signal emitted when a transition has finished "going out" -- i.e., the screen is obscured.
signal faded_out

var print_optional_errors:bool = true
var scene_folder_path:String = ""

var _current_transition:BaseTransition
var _default_transition:Array[String] = [ "" ]

## Reference the main scene that everything is contained in, as specified in the
## Project/Project Settings under General/Application/Run.MainScene.
var _main_scene

var _scene_path:String
var _scene_name:String

var _transitions:Dictionary = {}
var _trans_hashcode:int

var _curr_scene:Node

func _init():
	# Transition system will ALWAYS be available to run, not matter what.
	# Otherwise, how do we get out of a paused menu when a player selects "quit"?
	process_mode = Node.PROCESS_MODE_ALWAYS
##

func _ready():
	var root = get_tree().root.get_tree()
	root.node_added.connect(_on_node_added)
	root.node_removed.connect(_on_node_removed)
	
	# Hang on to the reference of _main_scene
	_main_scene = root.current_scene
	
	connect("load_new_scene", _load_new_scene)
	connect("faded_out", _initialize_resource_loader)
	
	# This will be turned on and off at-will when scenes need to be loaded
	set_process(false)
	# This will never be turned on
	set_physics_process(false)
	
	# now let's see if we can't find a global transition bank
	var banks = []
	
	for node in get_tree().root.get_children():
		banks.append_array(node.find_children("*", "TransitionBank"))
	##
	
	for bank in banks:
		_add_bank(bank)
	##
	
	# Grab a ref to the 0th entry -- this might be overridden, but that's on the end user
	_default_transition.append(_transitions[""]["transitions"].keys()[0])
##

func _process(_delta):
	var progress = []
	
	var thread_status:int = ResourceLoader.load_threaded_get_status(_scene_path, progress)
	
	# The following two if-statements are fail-safes because multi-threaded loading is tricky and it's best
	# 	to know what's happening with multi-threading stuff. These should never ever ever ever ever
	#	be touched if we have already loaded the scene, more if something goes wrong DURING loading.
	
	# if it's not done or loaded
	if thread_status == 2:
		print("An error has occured loading ", _scene_name, "!")
		return # stop!
	elif thread_status == 0:
		print("The scene ", _scene_name, " is invalid or not loaded properly!")
		print("Provided path: ", _scene_path)
		return # stop!
	##
	
	progress = progress[0]
	_current_transition.progress = progress
	
	if progress >= 1:
		if (_current_transition.HOLD_FADE_IN == false or _current_transition.finished_out_transition) and\
			_current_transition.finished_loading == false:
			_current_transition.finished_loading = true
		##
		
		if _current_transition.load_level:
			# get the new scene from the resource loader and instantiate it
			var new_scene = ResourceLoader.load_threaded_get(_scene_path).instantiate()
			
			# set the current scene to invisible and turn it off
			if _curr_scene != null:
				_curr_scene.process_mode = Node.PROCESS_MODE_DISABLED
				_curr_scene.visible = false
			##
			
			# inform the prior scene it's time to clean up
			emit_signal("loaded_scene", _scene_name)
			
			# the new scene is our current scene, we don't care what happens with the other one
			_curr_scene = new_scene
			_main_scene.add_child(new_scene)
			
			# inform the prior scene it's time to clean up
			emit_signal("added_scene", _scene_name)
			
			# play the animation player and make sure it knows we're fading in
			# only do this AFTER add_child is done, never before!
			_current_transition.play(BaseTransition.PLAY_DIRECTION.IN)
			
			# stop from coming back here
			set_process(false)
		##
	##
##

func _load_new_scene(scene:String, library:String, transition:String):
	_current_transition = _select_transition(library, transition).instantiate()
	add_child(_current_transition)
	_current_transition.play(BaseTransition.PLAY_DIRECTION.OUT)
	
	if scene_folder_path != "":
		_scene_path = "res://" + scene_folder_path + scene + ".tscn"
	else:
		_scene_path = "res://" + scene + ".tscn"
	##
	
	_scene_name = scene
	
	# check if we have to wait until the transition is fully done
	if _current_transition.ONLY_LOAD_WHEN_FULLY_OUT:
		return # bail early, don't continue
	##
	
	# async loading initialization...
	var error = ResourceLoader.load_threaded_request(_scene_path)
	
	# if there's an error, break out and report -- DO NOT CONTINUE!
	if error:
		printerr("Unable to load scene as a request: %s!" % _scene_path)
		return
	##
	
	# Turn on the process function now that everything is set-up!
	set_process(true)
##

func _on_node_added(node):
	if node is TransitionBank:
		_add_bank(node)
	##
##

func _on_node_removed(node):
	if not node is TransitionBank:
		return
	##
	
	_remove_bank(node)
##

func _add_bank(bank:TransitionBank):
	if _transitions.has(bank.BANK_NAME) and bank.BANK_NAME != "":
		_transitions[bank.label]['count'] += 1
		return
	elif _transitions.has(bank.BANK_NAME) and bank.BANK_NAME == "":
		if print_optional_errors:
			printerr("Global transition list is already defined!")
		##
		return
	##
	
	# Don't add the bank if there's nothing there, that will make things sad :(
	if bank.TRANSITIONS.size() == 0:
		return
	##
	
	_transitions[bank.BANK_NAME] = {
		"name": bank.BANK_NAME,
		"transitions": _create_internal_trans_reps(bank.TRANSITIONS),
		"count": 1
	}
##

func _create_internal_trans_reps(trans:Array[TransitionResource]) -> Dictionary:
	var res = {}
	
	for t in trans:
		res[t.TRANSITION_NAME] = {
			"scene":t.TRANSITION_SCENE
		}
	##
	
	return res
##

func _remove_bank(bank:TransitionBank):
	if _transitions.has(bank.BANK_NAME) == false:
		return
	##
	
	if _transitions[bank.BANK_NAME]["count"] == 1:
		_transitions.erase(bank.BANK_NAME)
		return
	##
	
	_transitions[bank.BANK_NAME]["count"] = _transitions[bank.BANK_NAME]["count"] - 1
##

func _select_transition(library:String, transition_name:String) -> PackedScene:
	var default = _transitions[_default_transition[0]]["transitions"][_default_transition[1]]["scene"]
	
	# does the library exist?
	if _transitions.has(library) == false:
		if print_optional_errors:
			printerr("Library %s does not exist!" % library)
		##
		return default
	##
	
	# does the transition exist?
	if _transitions[library]["transitions"].has(transition_name) == false or\
		_transitions[library]["transitions"][transition_name] == null:
		if print_optional_errors:
			printerr("Transition %s does not exist in library %s!" % [transition_name, library])
		##
		return default
	##
	
	return _transitions[library]["transitions"][transition_name]["scene"]
##

func _initialize_resource_loader():
	# async loading initialization...
	var error = ResourceLoader.load_threaded_request(_scene_path)
	
	# if there's an error, break out and report -- DO NOT CONTINUE!
	if error:
		printerr("Unable to load scene as a request: %s!" % _scene_path)
		return
	##
	
	# Turn on the process function now that everything is set-up!
	set_process(true)
##

# ============================================================
# PUBLIC METHODS
# ============================================================

## Call to swap out the underlying scene in Main Scene.
func change_scene(new_scene:String, library:String, transition:String, speed:float = 1.0):
	_current_transition = _select_transition(library, transition).instantiate()
	add_child(_current_transition)
	_current_transition.play(BaseTransition.PLAY_DIRECTION.OUT)
	
	if scene_folder_path != "":
		_scene_path = "res://" + scene_folder_path + new_scene + ".tscn"
	else:
		_scene_path = "res://" + new_scene + ".tscn"
	##
	
	_scene_name = new_scene
	
	# check if we have to wait until the transition is fully done
	if _current_transition.ONLY_LOAD_WHEN_FULLY_OUT:
		return # bail early, don't continue
	##
	
	_initialize_resource_loader()
##
