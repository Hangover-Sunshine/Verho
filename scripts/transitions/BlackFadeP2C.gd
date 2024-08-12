class_name InputContinueTransition
extends BaseTransition

@onready var animation_player = $AnimationPlayer

var fade_in:bool = false

func _ready():
	super()
	$Label.visible = false
##

func _input(event):
	if $Label.visible and event is InputEventKey or event is InputEventMouseButton:
		load_level = true
	##
##

func _process(_delta):
	if finished_loading and $Label.visible == false:
		$Label.visible = true
		$AP_TextPulse.play("text_pulse")
	##
##

func play(direction:PLAY_DIRECTION, speed_scale:float = 1):
	if direction == PLAY_DIRECTION.IN:
		fade_in = true
		animation_player.play("fade")
		$AP_TextPulse.play("fade_out", 1)
		$AP_TextPulse.speed_scale = speed_scale
		animation_player.speed_scale = speed_scale
	else:
		animation_player.play_backwards("fade")
		animation_player.speed_scale = speed_scale
	##
##

func _on_animation_player_animation_finished(_anim_name):
	if fade_in == false:
		finished_out_transition = true
	##
	
	if fade_in:
		queue_free() # remove self
	##
##
