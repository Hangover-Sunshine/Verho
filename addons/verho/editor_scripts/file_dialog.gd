@tool
extends FileDialog

var _curr_ffl:FileFolderLabel

func register_file_folder_label(ffl:FileFolderLabel):
	ffl.open_dialog.connect(_open_dialog)
##

func _open_dialog(ffl:FileFolderLabel):
	popup()
	_curr_ffl = ffl
##

func _on_file_selected(path):
	_curr_ffl.set_file(path)
	_curr_ffl = null
	hide()
##

func _on_canceled():
	_curr_ffl = null
	hide()
##
