extends Node2D

func _ready():
	Verho.connect("loaded_scene", _loaded_scene)
##

func _loaded_scene(scene_name):
	if scene_name != name:
		queue_free()
	##
##

func _on_button_pressed():
	Verho.emit_signal("load_new_scene", "scenes/Scene2D_1", "", "BlackFade")
##
