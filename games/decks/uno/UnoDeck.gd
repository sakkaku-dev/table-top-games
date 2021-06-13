extends Deck

class_name UnoDeck

var card_scene = preload("res://games/decks/uno/UnoCardUI.tscn")

func init_deck() -> Array:
	var deck = []
	for type in UnoCard.Colour.values():
		var max_range = 4 if type == UnoCard.Colour.BLACK else 14
		for i in range(0, max_range):
			if type == UnoCard.Colour.BLACK:
				if i == 0: continue
			else:
				if i == 11: continue
			var card = UnoCard.new()
			card.value = i
			card.colour = type
			deck.append(card)
	
	return deck

func get_ui() -> PackedScene:
	return card_scene

func create_from_ref(ref) -> Card:
	var card = UnoCard.new()
	var type = int(ref.substr(0, 1))
	var value = int(ref.substr(1))
	card.colour = type
	card.value = value
	return card

func dummy_card() -> Card:
	return UnoCard.new()
