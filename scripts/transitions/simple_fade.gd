extends VerhoTransition

func play_transition(direction:VerhoTransition.Direction):
	_direction = direction
	if direction == VerhoTransition.Direction.IN:
		$AnimationPlayer.play("in")
	else:
		$AnimationPlayer.play("out")
	##
##
