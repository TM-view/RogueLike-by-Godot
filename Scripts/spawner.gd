extends Node2D
@onready var player = get_node("../Player")
@onready var collision_shape = get_node("../Player/Spawn_Area/CollisionShape2D")
@onready var enemy_scene = preload("res://Scenes/slime.tscn")
@onready var random_box = preload("res://Scenes/random_box.tscn")
@onready var time = $"../Player/Main_UI"
@onready var timer = $Timer

var amount_slime = 0
var amount_mini = 0
var amount_boss = 0
var spawn_timer = [0,0,0]
var count_normal = 0
var count_mini = 0
var count_boss = 0
var count_box = 0
var angle : float

func _ready() :
	timer.timeout.connect(spawn_enemies_forever)
		
func spawn_enemies_forever():
	if player.game_start and !player.game_pause:
		var max_slime = 30 + player.level * 60
		var max_mini = time.minute / 4
		var max_boss = time.minute / 8
		var mul_time = 3 if amount_slime <= max_slime / 2 else 0
		var real_mul = mul_time if 20 - time.minute >= 3 else 0 
		var delay = [20 - time.minute - real_mul, 80 - 13 * (time.minute / 4), 170 - 40 * (time.minute / 6)]
		
		if amount_slime < max_slime and !player.game_pause:
			spawn_timer[0] += 1
			if spawn_timer[0] >= delay[0] :
				spawn_enemy()
				amount_slime += 1
				count_normal += 1
				spawn_timer[0] = 0
					
		if max_mini > 0 and amount_mini < max_mini and !player.game_pause:
			spawn_timer[1] += 1
			if spawn_timer[1] == delay[1] :
				spawn_mini()
				amount_mini += 1
				count_mini += 1
				spawn_timer[1] = 0
					
		if max_boss > 0 and amount_boss < max_boss and !player.game_pause:
			spawn_timer[2] += 1
			if spawn_timer[2] == delay[2] :
				spawn_boss()
				amount_boss += 1
				count_boss += 1
				spawn_timer[2] = 0
		
func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	enemy.position = get_spawn_position()
	enemy.name = "normal_slime_" + str(count_normal)
	add_child(enemy)

func spawn_mini():
	var mini_boss = enemy_scene.instantiate()
	mini_boss.scale.x = 2
	mini_boss.scale.y = 2
	mini_boss.position = get_spawn_position()
	mini_boss.is_mini = true
	mini_boss.name = "mini_slime_" + str(count_mini)
	add_child(mini_boss)

func spawn_boss():
	var boss = enemy_scene.instantiate()
	boss.scale.x = 3
	boss.scale.y = 3
	boss.position = get_spawn_position()
	boss.is_boss = true
	boss.name = "boss_slime_" + str(count_boss)
	add_child(boss)
	
func get_spawn_position():
	var player_pos = player.position
	var area_radius = collision_shape.shape.radius
	var spawn_distance = randf_range(5, 50)

	angle = randf() * TAU
	var offset = Vector2(cos(angle), sin(angle)) * (spawn_distance + area_radius)
	return player_pos + offset

func spawn_box() :
	var box = random_box.instantiate()
	var spawn_area = Vector2(randi_range(279, 2295), randi_range(176, 2040))
	box.position = spawn_area
	box.name = "random_box_" + str(count_box) 
	add_child(box)
