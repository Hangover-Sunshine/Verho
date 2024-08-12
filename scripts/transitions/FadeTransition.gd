class_name SimpleFadeTransition
extends BaseTransition

@onready var animation_player = $AnimationPlayer

func _ready():
	super()
	# Nothing happens after, but just to make sure super() is called and in case
	#	I want to modify anything else
##	

func play(direction:PLAY_DIRECTION, duration:float = 1):
	if direction == PLAY_DIRECTION.IN:
		animation_player.play("fade_in", -1, duration)
	else:
		animation_player.play("fade_out", -1, duration)
	##
##

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fade_out":
		load_level = true
		finished_out_transition = true
	##
	if anim_name == "fade_in":
		queue_free() # remove self
	##
##
