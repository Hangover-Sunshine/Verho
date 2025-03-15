class_name VerhoExport
extends EditorExportPlugin

# TODO: Implement a way to convert the plain-text JSON files to a binary blob
#		to make it easier to read for the PC. Stuff it in the verho subfolder
#		it gets exported in the binary.

func _export_begin(_features, _is_debug, path, _flags):
	print("hello! I am being called!")
	print("Printing path to prove: ", path)
##

## Required to be properly loaded when exported, per documentation.
## We're likely last all the time. :)
func _get_name():
	return "Verho"
##
