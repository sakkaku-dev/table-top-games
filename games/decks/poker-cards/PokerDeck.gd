extends Deck

class_name PokerDeck

var card_scene = preload("res://games/decks/poker-cards/PokerCardUI.tscn")

func init_deck() -> Array:
	var deck = []
	for suit in PokerCard.Suit.values():
		for i in range(0, 13):
			var card = PokerCard.new()
			card.value = i
			card.suit = suit
			deck.append(card)
	
	var joker = create_from_ref(str(PokerCard.Suit.CLUB) + "13")
	deck.append(joker)

	joker = create_from_ref(str(PokerCard.Suit.SPADE) + "13")
	deck.append(joker)
	
	return deck

func get_ui() -> PackedScene:
	return card_scene

func create_from_ref(ref) -> Card:
	var card = PokerCard.new()
	var suit = int(ref.substr(0, 1))
	var value = int(ref.substr(1))
	card.suit = suit
	card.value = value
	return card

func dummy_card() -> Card:
	return PokerCard.new()
