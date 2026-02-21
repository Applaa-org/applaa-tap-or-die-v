extends Control

@onready var message_label = $VBoxContainer/MessageLabel
@onready var score_label = $VBoxContainer/ScoreLabel
@onready var restart_button = $VBoxContainer/RestartButton
@onready var menu_button = $VBoxContainer/MenuButton
@onready var close_button = $VBoxContainer/CloseButton

func _ready():
	message_label.text = "VICTORY!"
	score_label.text = "Final Score: " + str(Global.score)
	
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