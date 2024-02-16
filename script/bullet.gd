extends Node2D

var fly_dis=0
var range=10
var fly_dir=Vector2(0,0)
var attack=null
var is_enemy=false

func _ready():
	pass

func _physics_process(delta: float) -> void:
	if fly_dis<range:
		fly_dis+=Global.bullet_speed*delta
		position=position + fly_dir*Global.bullet_speed*delta
	else:
		queue_free()

func _on_body_entered(body):
	if is_instance_valid(body) and body.has_method("do_damage"):
		if is_enemy != body.is_enemy:
			body.do_damage(attack, null)
			queue_free()
