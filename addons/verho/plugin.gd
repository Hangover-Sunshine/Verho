@tool
extends EditorPlugin

func _enter_tree():
	add_autoload_singleton("Verho", "transition_manager/verho.tscn")
	
	# Add the TransitionBank
	add_custom_type("TransitionBank", "Node",
					preload("resources/TransitionBank.gd"),
					preload("resources/curtains-white.svg"))
##

func _exit_tree():
	remove_autoload_singleton("Verho")
	remove_custom_type("TransitionBank")
##
