extends Deck

class_name UnoDeck

var card_scene = preload("res://games/decks/uno/UnoCardUI.tscn")

func init_deck() -> Array:
	var deck = []
	for type in UnoCard.Colour.values():
		var max_range = 2 if type == UnoCard.Colour.BLACK else 13
		for i in range(0, max_range):
			var copies = 1
			if type == UnoCard.Colour.BLACK:
				copies = 4
			elif i > 0:
				copies = 2
			
			for x in range(0, copies):
				var card = UnoCard.new()
				card.value = i
				card.colour = type
				card.copy = x
				deck.append(card)
	
	return deck

func get_ui() -> PackedScene:
	return card_scene

func create_from_ref(ref) -> Card:
	var card = UnoCard.new()
	var copy = int(ref.substr(0, 1))
	var colour = int(ref.substr(1, 1))
	var value = int(ref.substr(2))
	card.colour = colour
	card.value = value
	card.copy = copy
	return card

func dummy_card() -> Card:
	return UnoCard.new()
