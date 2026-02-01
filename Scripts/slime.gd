extends CharacterBody2D
@onready var target = get_tree().root.get_node_or_null("world/Player")
@onready var spawner = get_tree().root.get_node_or_null("world/Spawner")
@onready var time = get_tree().root.get_node_or_null("world/Player/Main_UI")
@onready var heart = get_tree().root.get_node_or_null("world/Player/Heart")
@onready var world = get_tree().root.get_node_or_null("world")
@onready var hit_box = $CollisionShape2D
@onready var slime_size = $AnimatedSprite2D
@onready var slime_area = $Area_Taken
@onready var player_atk_box = get_tree().root.get_node_or_null("world/Player/Area_Hit")
@onready var player_hurt_box = get_tree().root.get_node_or_null("world/Player/Hurt_Area")
var health : int = 20 
var max_health : int
var attack : int 
var speed : int
var dir = "right"
var alive = true
var taken = false
var health_update = false
var base = 20
var is_mini = false
var is_boss = false
var knockback : int = 1
var set_health = false
var multi_exp : int = 0
var angle : float
var change_angle : bool = true

func _ready() :
	update_stat()
	slime_area.area_entered.connect(_on_hit_box_area_entered)
	
func _physics_process(delta):
	if !target.game_pause:
		if alive :
			enemy_move(delta)
			enemy_animation()
	else :
		play_anim(dir)

func _on_hit_box_area_entered(area: Area2D):
	if area.name == "Hurt_Area" :
		hit_player()
	if area.name == "Area_Hit" and !taken:
		player_taken(self)
	if area.name == "Area_Taken" :
		move_and_slide()
		
func update_stat() :
	if change_angle :
		change_angle = false
		angle = spawner.angle
	if is_mini :
		attack = 2 + time.minute / 6
		max_health = 40 + time.minute * 3
		speed = 4
		if !set_health :
			health = max_health
			set_health = true
		knockback = 2
	elif is_boss :
		attack = 4 + time.minute / 8
		max_health = 80 + time.minute * 4
		speed = 5
		if !set_health :
			health = max_health
			set_health = true
		knockback = 3
	else :
		attack = 1 + time.minute / 5
		max_health = 20 + time.minute * 2 
		speed = 3
		if !set_health :
			health = max_health
			set_health = true
		knockback = 1
	
func enemy_move(_delta):
	if target:
		var direction = (target.position - self.position).normalized()
		var rotated_direction = direction.rotated(angle)
		velocity = rotated_direction / speed
		var collision = move_and_collide(velocity)
		if collision :
			var collider = collision.get_collider()
			if "slime" in collider.name :
				if is_boss :
					collider.position += collision.get_normal() * -8
				elif is_mini :
					collider.position += collision.get_normal() * -4
				else :
					move_and_slide()
					hit_box.visible = false
					await get_tree().create_timer(0.15).timeout
					hit_box.visible = true

func enemy_animation():
	if target :
		var Pdirect = target.position.x
		var Edirect = position.x
		
		if Edirect < Pdirect :
			dir = "right"
		elif Edirect > Pdirect :
			dir = "left"
			
		play_anim(dir)

func play_anim(movement):
	var anim = self.get_node("AnimatedSprite2D")
	if target.game_pause:
		if movement == "right":
			anim.flip_h = false
		elif movement == "left":
			anim.flip_h = true
			
		anim.play("side_idle")
		anim.frame = 0
	else :
		if alive :
			if !taken :
				if movement == "right":
					anim.flip_h = false
				elif movement == "left":
					anim.flip_h = true
				anim.play("side_walk")
			else :
				if movement == "right":
					anim.flip_h = false
				elif movement == "left":
					anim.flip_h = true
				for i in range(3) :
					anim.play("side_taken")
					anim.frame = i
					await get_tree().create_timer(0.5).timeout
		else :
			if movement == "right":
				anim.flip_h = false
			elif movement == "left":
				anim.flip_h = true
			for i in range(4) :
				anim.play("death")
				anim.frame = i + 1
				await get_tree().create_timer(0.5).timeout
				
func hit_player() :
	target.taken_damage(attack)
	if target.health > 0 :
		if position.x > target.position.x and position.y > target.position.y :
			target.position.x -= 5 
			target.position.y -= 5 
		elif position.x > target.position.x and position.y < target.position.y :
			target.position.x -= 5 
			target.position.y += 5 
		elif position.x < target.position.x and position.y > target.position.y :
			target.position.x += 5 
			target.position.y -= 5 
		elif position.x < target.position.x and position.y < target.position.y :
			target.position.x += 5 
			target.position.y += 5 
		elif position.x == target.position.x and position.y < target.position.y :
			target.position.y += 5 
		elif position.x == target.position.x and position.y > target.position.y :
			target.position.y -= 5 
		elif position.x > target.position.x and position.y == target.position.y :
			target.position.x -= 5 
		elif position.x < target.position.x and position.y == target.position.y :
			target.position.x += 5 
	
func player_taken(obj):
	taken = true
	var slime_anim = obj.get_node_or_null("AnimatedSprite2D")
	obj.health -= target.attack
	if health <= 0 :
		$"slime-death".play()
		obj.slime_area.collision_layer = 0
		obj.slime_area.collision_mask = 0
		if dir == "right" :
			slime_anim.play("death")
		else :
			slime_anim.flip_h = true
			slime_anim.play("death")
		alive = false
		if is_mini :
			target.experience += (4 + time.minute / 5) + (multi_exp * 2)
			spawner.amount_mini -= 1
		elif is_boss :
			target.experience += (16 + time.minute / 10) + (multi_exp * 4)
			spawner.amount_boss -= 1
		else :
			target.experience += (1 + time.minute / 2.5) + multi_exp 
			spawner.amount_slime -= 1
		
		await get_tree().create_timer(0.8).timeout
		queue_free()
	else :
		slime_size.modulate = Color.from_rgba8(255,121,142)
		$"slime-taken".play()
		await get_tree().create_timer(0.1).timeout 
		slime_size.modulate = Color.from_rgba8(255,255,255)
		if target.position.x > obj.position.x and target.position.y > obj.position.y :
			obj.position.x -= 5 * knockback
			obj.position.y -= 5 * knockback
		elif target.position.x > obj.position.x and target.position.y < obj.position.y :
			obj.position.x -= 5 * knockback
			obj.position.y += 5 * knockback
		elif target.position.x < obj.position.x and target.position.y > obj.position.y :
			obj.position.x += 5 * knockback
			obj.position.y -= 5 * knockback
		elif target.position.x < obj.position.x and target.position.y < obj.position.y :
			obj.position.x += 5 * knockback
			obj.position.y += 5 * knockback
		elif target.position.x == obj.position.x and target.position.y < obj.position.y :
			obj.position.y += 5 * knockback
		elif target.position.x == obj.position.x and target.position.y > obj.position.y :
			obj.position.y -= 5 * knockback
		elif target.position.x > obj.position.x and target.position.y == obj.position.y :
			obj.position.x -= 5 * knockback
		elif target.position.x < obj.position.x and target.position.y == obj.position.y :
			obj.position.x += 5 * knockback
		
		var rate : float
		rate = randf_range(0.0,100.0)
		if target.life_steal >= rate :
			target.health += target.attack / 10
			heart.create_heart()
	taken = false

func boombastic() :
	for child in spawner.get_children() :
		if "normal" in child.name :
			child.queue_free()
