extends Control

@onready var start_button = $VBoxContainer/StartButton
@onready var close_button = $VBoxContainer/CloseButton
@onready var high_score_label = $VBoxContainer/HighScoreLabel
@onready var player_name_input = $VBoxContainer/PlayerNameInput
@onready var instructions_label = $VBoxContainer/InstructionsLabel

func _ready():
	# STEP 1: Initialize high score display to 0 immediately
	if high_score_label:
		high_score_label.text = "High Score: 0"
		high_score_label.visible = true
	
	# Connect buttons
	start_button.pressed.connect(_on_start_pressed)
	close_button.pressed.connect(_on_close_pressed)
	
	# Setup JavaScript listener for storage data
	_setup_js_listener()
	
	# Request data
	_load_data()

func _setup_js_listener():
	# Create a bridge to receive messages from JS
	JavaScriptBridge.eval("""
		if (!window.tapOrDieGodotBridge) {
			window.tapOrDieGodotBridge = {
				onDataLoaded: function(dataStr) {
					// This will be called by the listener
					// We use a trick to call a Godot function
					const node = Engine.get_singleton('Engine').get_main_loop().root.get_node('StartScreen');
					if (node && node.call) {
						node.call('_on_storage_data_loaded', dataStr);
					}
				}
			};
			
			// Add the listener
			window.addEventListener('message', function(event) {
				if (event.data.type === 'applaa-game-data-loaded') {
					const data = event.data.data;
					if (data) {
						// Find the StartScreen node and call the method
						// Since direct node access from JS is tricky, we use a global object approach
						// or simpler: just store it in a global var and poll, but let's try direct call
						// Actually, let's use the eval approach to call the function directly
						// We need to find the node path. Assuming StartScreen is root.
						const root = Engine.get_singleton('Engine').get_main_loop().root;
						const startScreen = root.find_child('StartScreen', true, false);
						if (startScreen) {
							startScreen._on_storage_data_loaded(JSON.stringify(data));
						}
					}
				}
			});
		}
	""")

func _load_data():
	JavaScriptBridge.eval("""
		window.parent.postMessage({ type: 'applaa-game-load-data', gameId: 'tap-or-die' }, '*');
	""")

func _on_storage_data_loaded(data_str: String):
	# STEP 3: Update display with loaded data
	print("Data loaded: " + data_str)
	var json = JSON.new()
	var error = json.parse(data_str)
	if error == OK:
		var data = json.data
		if data.has("highScore"):
			Global.high_score = data.highScore
			if high_score_label:
				high_score_label.text = "High Score: " + str(Global.high_score)
		if data.has("lastPlayerName"):
			Global.player_name = data.lastPlayerName
			if player_name_input:
				player_name_input.text = Global.player_name

func _on_start_pressed():
	if player_name_input and player_name_input.text != "":
		Global.player_name = player_name_input.text
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_close_pressed():
	get_tree().quit()