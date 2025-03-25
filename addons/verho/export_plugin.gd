class_name VerhoExport
extends EditorExportPlugin

## Required to be properly loaded when exported, per documentation.
## We're likely last all the time. :)
func _get_name():
	return "Verho"
##

func _export_begin(_features, _is_debug, _path, _flags):
	if FileAccess.file_exists("res://addons/verho/resources/verho.json"):
		var file = FileAccess.open("res://addons/verho/resources/verho.json", FileAccess.READ)
		var contents = file.get_as_text()
		var json = JSON.new()
		var res = json.parse(contents)
		if not(res == OK):
			push_error("VERHO//ERROR: Error attempting to export the json file!")
			return
		##
		
		# Create a new unextension'd file in verho/verho called verho.blob
		var blob = FileAccess.open("res://addons/verho/verho/verho.blob", FileAccess.WRITE)
		
		# Call a function to save properly
		_save_to_binary_v1(json.data, blob)
	##
##

func _house_keeping(data:Dictionary) -> Array:
	var cleanedTrans:Dictionary[String, String] = {}
	var cleanedScenes:Dictionary[String, String] = {}
	var validPreloads:Array[String] = []
	
	# Only add the first instance of a nickname
	# Only add instances with valid scene directories
	for pair in data["scenes"]:
		if not(pair[0] in cleanedScenes.keys()) and pair[1] != "":
			cleanedScenes[pair[0]] = pair[1]
		elif pair[0] in cleanedScenes.keys():
			push_warning("VERHO-EXPORT//WARNING: Scene Key '%s' has a detected duplicate!" % pair[0])
		elif pair[1] == "":
			push_warning("VERHO-EXPORT//WARNING: Scene Key '%s' has no link!" % pair[0])
		##
	##
	
	# Only add the first instance of a nickname
	# Only add instances with valid scene directories
	for pair in data["trans"]:
		if not(pair[0] in cleanedTrans.keys()) and pair[1] != "":
			cleanedTrans[pair[0]] = pair[1]
		elif pair[0] in cleanedTrans.keys():
			push_warning("VERHO-EXPORT//WARNING: Transition Key '%s' has a detected duplicate!" % pair[0])
		elif pair[1] == "":
			push_warning("VERHO-EXPORT//WARNING: Transition Key '%s' has no link!" % pair[0])
		##
	##
	
	for nn in data["general"]["preload_trans"]:
		if nn in cleanedTrans.keys():
			validPreloads.push_back(nn)
		else:
			push_warning("VERHO-EXPORT//WARNING: Nickname '%s' doesn't exist after pruning!" % nn)
		##
	##
	
	return [validPreloads, cleanedScenes, cleanedTrans]
##

func _save_to_binary_v1(data, blob):
	# Save version -- Inform the loader how to handle this file
	blob.store_8(1)
	
	var cleanedData:Array = _house_keeping(data)
	
	# Push as a blob as:
	#	1) Stuff bools into a single byte
	var bools:int = (int(data["general"]["only_preloads"]) << 2) |\
					(int(data["general"]["allow_growth"]) << 1) | \
					(int(data["general"]["load_immediately"]))
	blob.store_8(bools)
	
	#	2) Queue size should be stored as 4 bytes, but can likely go lower
	blob.store_32(int(data["general"]["queue_size"]))
	
	#	3) Store the cleaned version of preloads, so we get the right number of
	#		strings
	blob.store_8(cleanedData[0].size())
	
	#	4) Convert each string to a series of bytes.
	for nn in cleanedData[0]:
		blob.store_pascal_string(nn)
	##
	
	#	5) Add the scene list
	blob.store_32(cleanedData[1].keys().size())
	for nn in cleanedData[1].keys():
		blob.store_pascal_string(nn)
		blob.store_pascal_string(cleanedData[1][nn])
	##
	
	#	6) Add the transition list
	blob.store_32(cleanedData[2].keys().size())
	for nn in cleanedData[2].keys():
		blob.store_pascal_string(nn)
		blob.store_pascal_string(cleanedData[2][nn])
	##
##
