extends Node

## The current main scene, if there is one already below this.
@export var CURR_MAIN_SCENE:Node
## The starting scene to load.
@export var MAIN_SCENE:String
## Test varible -- immediately transition into the primary scene if true, otherwise "delay."
@export var IMMEDIATE_TRANS:bool = true
## The "delay" as if the game was loading something else, in seconds.
@export var DELAY:float = 5

func _ready():
	# uncomment to get rid of the printed error
	#Verho.default_anim = "BlackFade"
	
	# NOTE: you can hook functions in and wait
	if CURR_MAIN_SCENE != null:
		Verho._curr_scene = CURR_MAIN_SCENE
	if IMMEDIATE_TRANS:
		_transition_to_scene()
	else:
		await get_tree().create_timer(DELAY).timeout
		_transition_to_scene()
	##
##

func _transition_to_scene():
	#Verho.emit_signal("load_new_scene", MAIN_SCENE, "", "BlackFade")
	Verho.change_scene(MAIN_SCENE, "", "BlackFade")
##
