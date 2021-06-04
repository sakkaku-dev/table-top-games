extends Node

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
		
	return deck


func create_node(card: PokerCard) -> Node2D:
	var node = card_scene.instance()
	node.poker_card = card
	return node

func get_ui() -> PackedScene:
	return card_scene
