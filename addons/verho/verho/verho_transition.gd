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

## A flag for knowing if the transition should be freed or not.
var _in_memory:bool = false
var InMemory:bool :
	set(value):
		_in_memory = value
	get:
		return _in_memory
	##
## 

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
		if _in_memory == false:
			queue_free()
		else:
			get_parent().remove_child(self)
			clean_on_finished = false
		##
		return
	##
	finished_transition.emit(_direction)
##
