class_name BaseTransition
extends Control

enum PLAY_DIRECTION {
	IN,
	OUT
}

## Whether to immediately fade in to the next scene, or wait. Only set this if you intend
## to have a type of "Press any key to continue..." that is controlled in the extended script.
@export var HOLD_FADE_IN:bool = false

## Whether or not the transition should hang on to the mouse
@export var CAPTURE_MOUSE:bool = true

## Whether to begin loading as soon as change_scene() is called or the load_new_scene signal
## is emitted. If true, then the transition out MUST finish first before loading is allowed to begin.
@export var ONLY_LOAD_WHEN_FULLY_OUT:bool = false

## Inform the PortaTransitionSystem that we are done playing the 'out' transition.
var finished_out_transition:bool = false

## Inform the PortaTransitionSystem that we are done transitioning and ready to load/add the scene.
var load_level:bool = false

## Informed from the PortaTransitionSystem that we are done loading the next scene.
var finished_loading:bool = false

func _ready():
	if CAPTURE_MOUSE:
		mouse_filter = Control.MOUSE_FILTER_STOP
	##
##

func play(_direction:PLAY_DIRECTION, _duration:float = 1):
	pass
##
