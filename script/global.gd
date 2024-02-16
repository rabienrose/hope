extends Node

var player_init_count=3
var atk_dist=100
var map_w=3000
var map_h=3000
var max_spd=2000
var bullet_speed=1000
var max_acc=2000
var rng = RandomNumberGenerator.new()
var player_spd_rate=1.4
var max_group=2
var total_level_count=0
var char_data={
	"ghost":{
		"hp":50,
		"atk":50,
		"range":5,
		"spd":0.8,
		"atk_spd":0.5,
		"sep":1,
		"assist":true,
	},
	"cat":{
		"hp":30,
		"atk":6,
		"range":0.8,
		"spd":1,
		"atk_spd":0.5,
		"sep":10,
		"assist":false,
	},
	"tank":{
		"hp":200,
		"atk":3,
		"range":1.0,
		"spd":1.2,
		"atk_spd":0.5,
		"sep":20,
		"assist":true,
	},
	"axe":{
		"hp":30,
		"atk":50,
		"range":1.5,
		"spd":0.9,
		"atk_spd":0.5,
		"sep":1,
		"assist":true,
	},
	"fish":{
		"hp":50,
		"atk":30,
		"range":5,
		"spd":0.8,
		"atk_spd":1.0,
		"sep":1,
		"assist":true,

	},
	"super":{
		"hp":1000,
		"atk":5,
		"range":2,
		"spd":1,
		"atk_spd":1.5,
		"sep":20,
		"assist":true,
	},

}
# var level_data=[
# 	[{"super":1}],
# ]
var level_data=[
	[
		{"cat":1},
		{"cat":2},
		{"cat":3},
	],
	[
		{"tank":1},
		{"tank":2},
		{"tank":3},
	],
	[
		{"cat":1},
		{"cat":2},
		{"cat":3},
	],

]


func _ready():
	for i in range(0,level_data.size()):
		total_level_count+=level_data[i].size()
