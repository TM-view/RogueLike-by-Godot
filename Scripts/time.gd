extends Control

@onready var player = $".."
@onready var slime = $"../../slime"
@onready var on_show = $TextEdit
@onready var timer = $"../Timer"
@onready var switch1 = $Stop/Button
@onready var switch2 = $Con/Button
@onready var pause_menu = $"../Death"
@onready var stop = $Stop
@onready var con = $Con
@onready var tutorial = $Tutorial
@onready var spawner = $"../../Spawner"
@onready var play_again = $"../END/Panel/Again"
@onready var end = $"../END"
@onready var death = $"../Death"
var sec = 0
var minute = 0
var flag = 2

func _ready():
	timer.timeout.connect(_on_timer_timeout)
	switch1.pressed.connect(func(): select_choice(1))
	switch2.pressed.connect(func(): select_choice(2))
	play_again.pressed.connect(func (): select_choice(3))
	
func _on_timer_timeout():
	if !player.game_pause :
		sec += 1
		if player.health < player.max_health : 
			player.health_regen()
		if sec > 59 :
			minute += 1
			sec = 0
			if minute == 20 :
				player.game_pause = true
				end.visible = true
				stop.visible = false
				con.visible = false
				tutorial.visible = false
			if minute % 3 == 0 :
				spawner.spawn_box()
				spawner.count_box += 1
			for child in spawner.get_children() :
				if "slime" in child.name :
					child.update_stat()
		on_show.text = " ".repeat(3) + str(two_digit(minute)) + ":" + str(two_digit(sec))

func two_digit(number):
	return "%02d" % number

func select_choice(index):
	$"../click-sound".play()
	if index == 1 :
		stop.visible = false
		con.visible = true
		player.game_pause = true
		pause_menu.visible = true
		tutorial.visible = false
		$"../chill".stop()
		player.play_sound()
		flag = 1
	elif index == 2 :
		stop.visible = true
		con.visible = false
		player.game_pause = false
		pause_menu.visible = false
		tutorial.visible = true
		$"../chill".play()
		player.play_sound()
		flag = 2
	elif index == 3 :
		death.select_choice(1)
