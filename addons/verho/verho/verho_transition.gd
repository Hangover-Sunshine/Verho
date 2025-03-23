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

func play_transition(direction:Direction):
	pass
##

func loading_progress(percentage:float):
	pass
##

func is_finished():
	finished_transition.emit(_direction)
##
