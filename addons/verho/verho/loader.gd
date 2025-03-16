class_name VerhoLoader
extends Object

func read_data(file_path):
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		var version:int = file.get_8()
		
		match version:
			1:
				return _read_data_v1(file)
			_:
				assert(false, "VERHO//ERROR: Unknown version type detected!")
			##
		##
	##
	
	return null
##

func _read_data_v1(file) -> Dictionary:
	var results:Dictionary = {}
	
	# bools
	var bools:int = file.get_8()
	results["grow"] = bools & (1 << 2)
	results["immediate"] = bools & (1 << 1)
	results["preload"] = bools & 1
	
	# size of memory for transitions (number of transitions)
	results["mem_size"] = file.get_32()
	
	# get the number of transitions we need to preload
	var count:int = file.get_8()
	results["preload_trans"] = []
	
	for i in range(count):
		results["preload_trans"].push_back(file.get_pascal_string())
	##
	
	count = file.get_32()
	results["scenes"] = {}
	for i in range(count):
		# load first string, then second string, then keep moving on
		var key = file.get_pascal_string()
		var val = file.get_pascal_string()
		results["scenes"][key] = val
	##
	
	count = file.get_32()
	results["trans"] = {}
	for i in range(count):
		# load first string, then second string, then keep moving on
		var key = file.get_pascal_string()
		var val = file.get_pascal_string()
		results["trans"][key] = val
	##
	
	return results
##
