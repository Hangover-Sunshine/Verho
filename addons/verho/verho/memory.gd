class_name VerhoMemory
extends RefCounted

var _mem_size:int = 0
var MemorySize:int :
	get:
		return _mem_size
	##
##

var _reserved_memory:Dictionary[String, VerhoTransition] = {}
var _transition_memory:Array = []

func initialize(mem_size:int, use_reserved:bool, preloads:Array, callable:Callable,
				lib:Dictionary[String, String]):
	_mem_size = mem_size
	
	if use_reserved:
		for key in preloads:
			var trans:VerhoTransition = load(lib[key]).instantiate()
			trans.finished_transition.connect(callable)
			_reserved_memory[lib[key]] = trans
		##
	else:
		for key in preloads:
			var trans:VerhoTransition = load(lib[key]).instantiate()
			trans.finished_transition.connect(callable)
			_transition_memory.push_back([lib[key], trans])
			if _transition_memory.size() + 1 > _mem_size:
				break
			##
		##
	##
##

## Add a key/transition pair to the memory, removing the least used
##	object if necessary.
func add(key:String, trans:VerhoTransition):
	# Skip if we've already added this one
	if _transition_memory.any(func(x): x[0] == key) or key in _reserved_memory.keys():
		return
	##
	
	trans.InMemory = true
	_transition_memory.push_front([key, trans])
	
	# Remove the least used transition at the end of the list
	if _transition_memory.size() > _mem_size:
		_transition_memory.pop_back()
	##
##

## Returns a VerhoTransition object from memory if it exists,
##	otherwise null.
func try_get(key:String) -> VerhoTransition:
	var transition:VerhoTransition = null
	
	# Grab and bail early if it's in the reserved memory slot
	if key in _reserved_memory.keys():
		return _reserved_memory[key]
	##
	
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
