class_name VerhoJSONLoader
extends Object

func read_file(file_path):
	var json = JSON.new()
	if FileAccess.file_exists("res://addons/verho/resources/verho.json"):
		var file = FileAccess.open("res://addons/verho/resources/verho.json", FileAccess.READ)
		var contents = file.get_as_text()
		var res = json.parse(contents)
		if not(res == OK):
			push_error(("VERHO//ERROR: Unable to load file, something went wrong! Please verify " +
				"the location and/or contents of the file..."))
			return null
		##
	##
	
	var results = {}
	
	results["grow"] = json.data["general"]["allow_growth"]
	results["immediate"] = json.data["general"]["load_immediately"]
	results["preload"] = json.data["general"]["preload"]
	results["mem_size"] = json.data["general"]["queue_size"]
	
	results["scenes"] = {}
	for pair in json.data["scenes"]:
		# skip anything with empty fields, don't save them
		if pair[0] == "" or pair[1] == "":
			continue
		##
		results["scenes"][pair[0]] = pair[1]
	##
	
	results["trans"] = {}
	for pair in json.data["trans"]:
		# skip anything with empty fields, don't save them
		if pair[0] == "" or pair[1] == "":
			continue
		##
		results["trans"][pair[0]] = pair[1]
	##
	
	results["preload_trans"] = []
	for ptrans in json.data["general"]["preload_trans"]:
		if not(ptrans in results["trans"].keys()):
			continue
		##
		results["preload_trans"].push_back(ptrans)
	##
	
	return results
##
