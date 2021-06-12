class_name CardHand
extends AbstractStore
# Manage playable cards

signal card_played(refs)


func play_cards(refs, discard_pile: AbstractStore = null) -> void:
	if discard_pile != null:
		move_cards(refs, discard_pile)
	else:
		remove_cards(refs)

	emit_signal("card_played", refs)
