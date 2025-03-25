class_name VerhoLoader
extends RefCounted

func read_data(file_path:String):
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		
		if file_path.get_extension() == "json":
			return _read_json_data(file)
		else:
			var version:int = file.get_8()
			match version:
				1:
					return _read_data_v1(file)
				_:
					push_error("VERHO//ERROR: Unknown version type detected!")
				##
			##
		##
	##
	
	return {}
##

func _read_data_v1(file) -> Dictionary:
	var results:Dictionary = {}
	
	# bools
	var bools:int = file.get_8()
	results["keep_preloads"] = bools & (1 << 2)
	results["grow"] = bools & (1 << 1)
	results["immediate"] = bools & 1
	
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

func _read_json_data(file) -> Dictionary:
	var json = JSON.new()
	var contents = file.get_as_text()
	var res = json.parse(contents)
	
	if not(res == OK):
		push_error(("VERHO//ERROR: Unable to load file, something went wrong! Please verify " +
			"the location and/or contents of the file..."))
		return {}
	##
	
	return _read_json_data_v1(json.data)
	
	#var version:int = int(json.data["version"])
	#match version:
		#1:
			#return _read_json_data_v1(json.data)
		#_:
			#push_error("VERHO//ERROR: Unknown version type detected!")
			#return {}
		###
	###
##

func _read_json_data_v1(data) -> Dictionary:
	var results = {}
	
	#results["keep_preloads"] = data["general"]["keep_preloads"]
	results["immediate"] = data["general"]["load_immediately"]
	#results["mem_size"] = data["general"]["queue_size"]
	
	results["scenes"] = {}
	for pair in data["scenes"]:
		# skip anything with empty fields, don't save them
		if pair[0] == "" or pair[1] == "":
			continue
		##
		results["scenes"][pair[0]] = pair[1]
	##
	
	results["trans"] = {}
	for pair in data["trans"]:
		# skip anything with empty fields, don't save them
		if pair[0] == "" or pair[1] == "":
			continue
		##
		results["trans"][pair[0]] = pair[1]
	##
	
	#results["preload_trans"] = []
	#for ptrans in data["general"]["preload_trans"]:
		#if not(ptrans in results["trans"].keys()):
			#continue
		###
		#results["preload_trans"].push_back(ptrans)
	##
	
	return results
##
