extends Node


var atk_dist=100
var atk_period=1
var map_w=3000
var map_h=3000
var max_spd=1000
var max_acc=1000
var rng = RandomNumberGenerator.new()

func _ready():
	rng.seed=0