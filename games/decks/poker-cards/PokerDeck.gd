extends Node

class_name PokerDeck

func init_deck() -> Array:
	var deck = []
	for suit in PokerCard.Suit.values():
		for i in range(0, 13):
			deck.append(PokerCard.new(i, suit))
		
	return deck
