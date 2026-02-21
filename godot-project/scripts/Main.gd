extends Control

enum GameState { WAITING, ACTIVE, GAME_OVER }

var state: GameState = GameState.WAITING
var score: int = 0
var time_left: float = 0.0
var reaction_time_min: float = 0.5
var reaction_time_max: float = 2.0
var victory_target: int = 20

@onready var background = $ColorRect
@onready var instruction_label = $InstructionLabel
@onready var score_label = $ScoreLabel
@onready var timer_label = $TimerLabel

# Colors
var color_wait: Color = Color(0.8, 0.2, 0.2) # Red
var color_active: Color = Color(0.2, 0.8, 0.2) # Green

func _ready():
	Global.reset_score()
	set_state(GameState.WAITING)
	start_random_timer()

func _input(event):
	if state == GameState.GAME_OVER:
		return
		
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_select"):
		handle_input()

func handle_input():
	if state == GameState.ACTIVE:
		# Success!
		score += 1
		Global.add_score(1)
		update_ui()
		
		# Check Victory
		if score >= victory_target:
			_victory()
		else:
			set_state(GameState.WAITING)
			start_random_timer()
			
	elif state == GameState.WAITING:
		# Too early!
		_game_over("Too Early!")

func _process(delta):
	if state == GameState.ACTIVE:
		time_left -= delta
		if time_left <= 0:
			_game_over("Too Slow!")

func set_state(new_state: GameState):
	state = new_state
	match state:
		GameState.WAITING:
			background.color = color_wait
			instruction_label.text = "WAIT..."
			instruction_label.modulate = Color.WHITE
		GameState.ACTIVE:
			background.color = color_active
			instruction_label.text = "TAP NOW!"
			instruction_label.modulate = Color.WHITE
		GameState.GAME_OVER:
			background.color = Color.DARK_GRAY
			instruction_label.text = "GAME OVER"

func start_random_timer():
	var wait_time = randf_range(reaction_time_min, reaction_time_max)
	await get_tree().create_timer(wait_time).timeout
	if state == GameState.WAITING:
		set_state(GameState.ACTIVE)
		time_left = 1.0 # Time to react once green

func update_ui():
	score_label.text = "Score: %d / %d" % [score, victory_target]

func _game_over(reason: String):
	state = GameState.GAME_OVER
	instruction_label.text = reason + "\nFinal Score: " + str(score)
	
	# Save score
	Global.save_score_to_storage()
	
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/GameOverScreen.tscn")

func _victory():
	state = GameState.GAME_OVER
	instruction_label.text = "VICTORY!"
	background.color = Color.GOLD
	
	# Save score
	Global.save_score_to_storage()
	
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/VictoryScreen.tscn")