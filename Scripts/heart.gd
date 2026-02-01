extends Node2D

@onready var player = get_node("..")

func create_heart():
	var full_heart = player.health / 4
	var fraction_heart = 0 if player.health % 4 == 0 else 1
	var amount_heart = full_heart + fraction_heart
	var start_x = -((amount_heart - 1) * 12) / 2
	
	clear_heart()
	for i in range(full_heart):
		var sprite = Sprite2D.new() 
		sprite.texture = preload("res://Arts/Other/heart/Heart_Red_1.png") 
		sprite.scale = Vector2(1.3,1.3)
		sprite.position = Vector2(start_x + i * 12, -10)  
		add_child(sprite)
	if fraction_heart == 1:
		var sprite = Sprite2D.new() 
		if player.health % 4 == 3 :
			sprite.texture = preload("res://Arts/Other/heart/Heart_Red_2.png") 
		elif player.health % 4 == 2 :
			sprite.texture = preload("res://Arts/Other/heart/Heart_Red_3.png") 
		elif player.health % 4 == 1 :
			sprite.texture = preload("res://Arts/Other/heart/Heart_Red_4.png") 
		sprite.scale = Vector2(1.3,1.3)
		sprite.position = Vector2(start_x + full_heart * 12, -10)  
		add_child(sprite)
		
	$".".visible = true
	await get_tree().create_timer(1.5).timeout 
	$".".visible = false

func clear_heart():
	for child in $".".get_children() :
		child.queue_free()
