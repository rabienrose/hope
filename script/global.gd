extends Node


var atk_dist=100
var atk_period=1
var map_w=3000
var map_h=3000
var max_spd=2000
var max_acc=2000
var rng = RandomNumberGenerator.new()
var player_spd_rate=1.4
var char_data={
	"ghost":{
		"hp":10,
		"atk":3,
		"range":1,
		"spd":0.8
	},
	"cat":{
		"hp":20,
		"atk":6,
		"range":1,
		"spd":1.1
	},
	"tank":{
		"hp":100,
		"atk":6,
		"range":1.2,
		"spd":1.2
	},
	"axe":{
		"hp":40,
		"atk":30,
		"range":1.5,
		"spd":1
	},
	"fish":{
		"hp":20,
		"atk":30,
		"range":5,
		"spd":1
	},
	"super":{
		"hp":200,
		"atk":50,
		"range":2,
		"spd":1
	},

}
var level_data=[
	{
		"group":{"ghost":3},
		"time":0
	},
	{
		"group":{"ghost":2},
		"time":1
	},
	{
		"group":{"ghost":4},
		"time":2
	},
	{
		"group":{"ghost":5},
		"time":30
	},
	{
		"group":{"cat":2},
		"time":60
	},
	{
		"group":{"cat":3},
		"time":80
	},
	{
		"group":{"cat":4},
		"time":100
	},
	{
		"group":{"cat":5},
		"time":120
	},
]

var battle_time=0

func _ready():
	rng.seed=0