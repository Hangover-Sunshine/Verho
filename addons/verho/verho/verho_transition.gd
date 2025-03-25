class_name VerhoTransition
extends Control

## Which way the transition is currently going. Either it is obscuring the screen (OUT)
##	or unobscuring the screen (IN).
enum Direction {
	## Loading into gameplay.
	IN,
	## Loading out of gameplay.
	OUT
}

signal finished_transition(direction:Direction)

var _direction:Direction
var clean_on_finished:bool = false

func play_transition(direction:Direction):
	pass
##

func loading_progress(percentage:float):
	pass
##

func free_on_finished():
	clean_on_finished = true
##

func is_finished():
	if clean_on_finished:
		queue_free()
		return
	##
	finished_transition.emit(_direction)
##
