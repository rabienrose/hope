extends Node

var player_init_count=4
var atk_dist=100
var atk_period=0.5
var map_w=3000
var map_h=3000
var max_spd=2000
var max_acc=2000
var rng = RandomNumberGenerator.new()
var player_spd_rate=1.4
var char_data={
	"ghost":{
		"hp":20,
		"atk":10,
		"range":5,
		"spd":1.0,
		"atk_spd":0.5,
		"sep":20,
		"assist":true,
	},
	"cat":{
		"hp":30,
		"atk":3,
		"range":1,
		"spd":1,
		"atk_spd":0.5,
		"sep":20,
		"assist":false,
	},
	"tank":{
		"hp":100,
		"atk":3,
		"range":1,
		"spd":1,
		"atk_spd":0.5,
		"sep":50,
		"assist":true,
	},
	"axe":{
		"hp":20,
		"atk":30,
		"range":1.5,
		"spd":0.8,
		"atk_spd":0.5,
		"sep":1,
		"assist":true,
	},
	"fish":{
		"hp":20,
		"atk":30,
		"range":5,
		"spd":1,
		"atk_spd":1.0,
		"sep":50,
		"assist":true,

	},
	"super":{
		"hp":200,
		"atk":50,
		"range":2,
		"spd":1,
		"atk_spd":1.0,
		"sep":50,
		"assist":true,
	},

}
var level_data=[
	{
		"group":{"cat":1, "ghost":1},
		"time":0,
		"color":0
	},
]


func _ready():
	# rng.seed=0
	pass
