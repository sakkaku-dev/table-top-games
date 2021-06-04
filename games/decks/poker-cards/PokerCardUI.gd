extends CardUI

var poker_card: PokerCard setget set_card

onready var sprite = $AnimContainer/Front/Sprite

func set_card(card: PokerCard):
	if not card:
		print("Cannot show Poker Card without value")
	else:
		sprite.frame_coords = Vector2(card.value, card.suit)

	poker_card = card
