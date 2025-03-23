extends Node2D

func _ready():
	Verho.added_scene.connect(_on_scene_added)
##

func _on_scene_added(scene):
	if scene != self:
		print("delete!")
		queue_free()
	else:
		print("don't delete!")
	##
##

func _on_button_pressed():
	Verho.change_nscene_ntrans("scn", "white_fade")
##

func _on_button_1_pressed():
	Verho.change_nscene("test2", "res://prefabs/shader_fade.tscn")
##

func _on_button_2_pressed():
	Verho.change_scene_ntrans("res://scenes/layer_down/another_layer_down/scn_res.res",
		"freeze_n_slide")
##

func _on_button_3_pressed():
	Verho.change_scene("res://scenes/test1.tscn", "res://prefabs/fade_to_black.tscn")
##
