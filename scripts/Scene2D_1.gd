extends Node2D

func _ready():
	Verho.connect("loaded_scene", _loaded_scene)
##

func _loaded_scene(scene_name):
	if scene_name != name:
		queue_free()
	##
##

func _on_scene_2_button_black_pressed():
	Verho.emit_signal("load_new_scene", "scenes/Scene2D_2", "", "BlackFade")
##

func _on_scene_2_button_white_pressed():
	Verho.emit_signal("load_new_scene", "scenes/Scene2D_2", "", "WhiteFade")
##

func _on_scene_2_button_dissolve_pressed():
	Verho.emit_signal("load_new_scene", "scenes/Scene2D_2", "", "DissolveFade")
##

func _on_scene_2_button_p_2c_pressed():
	Verho.emit_signal("load_new_scene", "scenes/Scene2D_2", "", "Fade_P2C")
##

func _on_scene_3_button_black_pressed():
	Verho.emit_signal("load_new_scene", "scenes/ReallyBigScene2D", "", "BlackFade")
##

func _on_scene_3_button_loading_pressed():
	Verho.emit_signal("load_new_scene", "scenes/ReallyBigScene2D", "", "FadeProgessBar")
##

func _on_scene_3_button_loading_p_2c_pressed():
	Verho.emit_signal("load_new_scene", "scenes/ReallyBigScene2D", "", "Fade_ProgessBar_P2C")
##
