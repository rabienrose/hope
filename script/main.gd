extends Node2D

var time_step=0
var s;
var char_list=["ghost","cat","tank","super","fish","axe"]
var char_count=0

# Called when the node enters the scene tree for the first time.
func _ready():
	s=get_viewport().get_visible_rect().size
	get_node("Panel").size=s


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if char_count>10:
		return
	time_step=time_step+delta
	if time_step>0.2:
		time_step=0
		var ind = randi_range(0,5)
		var char_name=char_list[ind]
		var rand_offset= Vector2(Global.rng.randf_range(100, s[0]-100), Global.rng.randf_range(100, s[1]-100))
		var char_scn_res=load("res://chars/"+char_name+".tscn")
		var char=char_scn_res.instantiate()
		var b_flip=randi_range(0,1)
		char.body.scale.x = -1 if b_flip==1 else 1
		char.only_apperance=true
		char.is_enemy=false
		char.position=rand_offset
		get_node("Panel/CharRoot").add_child(char)
		char.anim_player.play("attack")
		char_count=char_count+1


func _on_button_button_down():
	get_tree().change_scene_to_file("res://game.tscn")

