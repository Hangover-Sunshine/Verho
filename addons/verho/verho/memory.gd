class_name VerhoMemory
extends RefCounted

var _mem_size:int = 0
var _transition_memory:Array = []

func initialize(mem_size:int):
	_mem_size = mem_size
##

## Add a key/transition pair to the memory, removing the least used
##	object if necessary.
func add(key:String, trans:VerhoTransition):
	_transition_memory.push_front([key, trans])
	
	# Remove the least used transition at the end of the list
	if len(_transition_memory) > _mem_size:
		_transition_memory.pop_back()
	##
##

## Returns a VerhoTransition object from memory if it exists,
##	otherwise null.
func try_get(key:String) -> VerhoTransition:
	var transition:VerhoTransition = null
	
	var indx = -1
	for i in range(len(_transition_memory)):
		if _transition_memory[i][0] == key:
			transition = _transition_memory[i][1]
			indx = i
			break
		##
	##
	
	# if we have something, put it back into the memory at the front
	if indx >= 0:
		var mem = _transition_memory.pop_at(indx)
		_transition_memory.push_front(mem)
	##
	
	return transition
##
