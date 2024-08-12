extends Node2D

func _on_button_pressed():
	#Verho.emit_signal("load_new_scene", "scenes/Scene2D_1", "", "BlackFade")
	Verho.change_scene("scenes/Scene2D_1", "", "BlackFade")
##
