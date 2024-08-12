class_name WhiteFadeTransition
extends BaseTransition

@onready var animation_player = $AnimationPlayer

var fade_in:bool = false

func _ready():
	super()
	# Nothing happens after, but just to make sure super() is called and in case
	#	I want to modify anything else
##	

func play(direction:PLAY_DIRECTION, speed_scale:float = 1):
	if direction == PLAY_DIRECTION.IN:
		fade_in = true
		animation_player.play("fade")
		animation_player.speed_scale = speed_scale
	else:
		animation_player.play_backwards("fade")
		animation_player.speed_scale = speed_scale
	##
##

func _on_animation_player_animation_finished(_anim_name):
	if fade_in == false:
		load_level = true
	##
	if fade_in:
		queue_free() # remove self
	##
##
