class_name VerhoTransition
extends Control

enum Direction {
	IN,
	OUT
}

signal finished_transition(direction:Direction)

var _direction:Direction

func play_transition(direction:Direction):
	pass
##

# TODO: What parameters are necessary for this to function?
func loading_progress():
	pass
##

func is_finished():
	finished_transition.emit(_direction)
##
