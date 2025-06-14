# item_data.gd
extends Node

var lore_snippets := {
	"bookshelf1": [
		"It smells like dust and ink.",
		#"Some of the spines on these books look worn out.",
		#"Nothing but medical terminology."
	],
	"dogbed1": [
		#"The bed is still warm.",
		#"There are some grey hairs stuck on the cushioning.",
		"You feel a pang of sadness but don't know why."
	],
	"pot1": [
		#"It’s empty now, but the scent lingers.",
		#"You think it held flowers once.",
		"A sterile scent lingers to the pot for some reason."
	]
}

var data := {
	1: [
		{
			"interact": "image1",
			"pos": Vector2(170, 47),
			"text": "A cracked photograph. Someone's missing...",
			"hidden": false,
			"region_rect": Rect2(16, 16, 16, 16),
			"ending_tag": "neutral"  
		},
		{
			"interact": "bookshelf1",
			"spawn_pos": Vector2(120, 101),
			"text": "The pages mention a hospital room.",
			"hidden": true,
			"region_rect": Rect2(0, 48, 16, 16),
			"ending_tag": "secret"
		}
	],
	2: [
		{
			"interact": "dogbed1",
			"spawn_pos": Vector2(600, 100),
			"text": "A dog toy. You remember crying.",
			"hidden": true,
			"region_rect": Rect2(0, 32, 16, 16),
			"ending_tag": "bad"
		},
		{
			"interact": "pot1",
			"spawn_pos": Vector2(712, 102),
			"text": "A letter half-burned: 'We’re sorry, we had to let go.'",
			"hidden": true,
			"region_rect": Rect2(80, 48, 16, 16),
			"ending_tag": "secret"
		}
	],
	3: [
		{
			"interact": "pot2",
			"pos": Vector2(480, 62),
			"text": "A flower pot. A small card says 'Get Well Soon!'. Your name is on it.",
			"hidden": false,
			"region_rect": Rect2(112, 16, 16, 16),
			"ending_tag": "secret"
		},
		{
			"interact": "mirror1",
			"spawn_pos": Vector2(375, 61),
			"text": "A dusty mirror. Your eyes look... wrong.",
			"hidden": true,
			"region_rect": Rect2(112, 112, 32, 48),
			"ending_tag": "secret",
			"use_sprite2": true,
			"unlock_condition": {
				"type": "lore_count",
				"required": 3,
				"names": ["bookshelf1", "dogbed1", "pot1"]
			}
		}
	]
}
