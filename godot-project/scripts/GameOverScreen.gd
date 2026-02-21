extends Control

@onready var final_score_label = $VBoxContainer/FinalScoreLabel
@onready var high_score_label = $VBoxContainer/HighScoreLabel
@onready var restart_button = $VBoxContainer/RestartButton
@onready var menu_button = $VBoxContainer/MenuButton
@onready var close_button = $VBoxContainer/CloseButton

func _ready():
	final_score_label.text = "Score: " + str(Global.score)
	
	# Display high score
	if Global.score > Global.high_score:
		high_score_label.text = "New High Score: " + str(Global.score)
	else:
		high_score_label.text = "High Score: " + str(Global.high_score)
		
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	close_button.pressed.connect(_on_close_pressed)

func _on_restart_pressed():
	Global.reset_score()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_menu_pressed():
	Global.reset_score()
	get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")

func _on_close_pressed():
	get_tree().quit()