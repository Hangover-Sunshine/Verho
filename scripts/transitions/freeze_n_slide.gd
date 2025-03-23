extends VerhoTransition

func play_transition(direction:VerhoTransition.Direction):
	_direction = direction
	if direction == VerhoTransition.Direction.IN:
		$AnimationPlayer.play("in")
	else:
		var img = get_viewport().get_texture().get_image()
		var tex = ImageTexture.create_from_image(img)
		$TextureRect.texture = tex
		$TextureRect.size = get_viewport_rect().size
		$AnimationPlayer.play("out")
	##
##
