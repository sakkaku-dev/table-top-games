extends CardUI

onready var sprite = $AnimContainer/Front/Sprite

func set_instance(card):
	if not card:
		print("Cannot show card without value")
	else:
		sprite.frame_coords = Vector2(card.value, card.colour)

	.set_instance(card)
