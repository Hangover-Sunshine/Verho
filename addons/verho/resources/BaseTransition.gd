class_name BaseTransition
extends Control

enum PLAY_DIRECTION {
	IN,
	OUT
}

## Whether to immediately fade in to the next scene, or wait. Only set this if you intend
## to have a type of "Press any key to continue..." that is controlled in the extended script.
@export var HOLD_FADE_IN:bool = false

## Whether to begin loading as soon as change_scene() is called.
## If true, then the transition out MUST finish first before loading is allowed to begin.
@export var ONLY_LOAD_WHEN_FULLY_OUT:bool = false

## Set this so the transition knows how far along in the loading process it is.
## Optional use by extendees, but here instead of requiring Signals to be fired every frame.
## This will be given as a number between 0 and 1, inclusive.
var progress:float = 0

## Inform the tranisition system that we are done playing the 'out' transition.
var finished_out_transition:bool = false

## Inform the tranisition system that we are done transitioning and ready to load/add the scene.
var load_level:bool = false

## Informed from the tranisition system that we are done loading the next scene.
var finished_loading:bool = false

func _ready():
	# Will be deleted once the transition process is done, by our self
	mouse_filter = Control.MOUSE_FILTER_STOP
##

func play(_direction:PLAY_DIRECTION, _speed_scale:float = 1):
	pass
##
