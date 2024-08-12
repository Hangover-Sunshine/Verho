class_name FadeProgressBarTransition
extends BaseTransition

@onready var animation_player = $AnimationPlayer

var fade_in:bool = false

func _ready():
	super()
	Verho.connect("loading_progress", _loading_progress)
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
		Verho.emit_signal("faded_out")
		$ProgressBar.visible = true
		$LoadingLabel.visible = true
		finished_out_transition = true
	##
	
	if fade_in:
		queue_free() # remove self
	##
##

func _loading_progress(progress:float):
	$ProgressBar.value = progress * 100
	
	if $ProgressBar.value == 100:
		$ProgressBar.visible = false
		$LoadingLabel.visible = false
		load_level = true
	##
##
