extends Node

signal score_changed(new_score: int)

var score: int = 0
var high_score: int = 0
var player_name: String = "Player"
var game_id: String = "tap-or-die"

func _ready():
	# Initialize high score display to 0 immediately
	high_score = 0
	load_game_data()

func add_score(points: int):
	score += points
	score_changed.emit(score)

func reset_score():
	score = 0
	score_changed.emit(0)

func load_game_data():
	# Request data from Applaa storage via JavaScriptBridge
	JavaScriptBridge.eval("""
		window.parent.postMessage({ type: 'applaa-game-load-data', gameId: '%s' }, '*');
	""" % game_id)
	
	# Set up listener to receive data
	_setup_storage_listener()

func _setup_storage_listener():
	# This function sets up a JS listener that calls back to GDScript
	JavaScriptBridge.eval("""
		if (!window.tapOrDieStorageListener) {
			window.tapOrDieStorageListener = function(event) {
				if (event.data.type === 'applaa-game-data-loaded') {
					// Call Godot function with the data
					const data = event.data.data;
					if (data) {
						godotBridge.emit_signal('storage_loaded', JSON.stringify(data));
					}
				}
			};
			window.addEventListener('message', window.tapOrDieStorageListener);
		}
	""")
	
	# Connect the signal (we need to define this in a way Godot can receive it)
	# For simplicity in this structure, we'll use a polling or direct eval approach in the screens
	# But ideally, we'd use a JavaScriptObject callback.
	# For this implementation, we will handle the specific loading in the StartScreen where UI exists.

func save_score_to_storage():
	JavaScriptBridge.eval("""
		window.parent.postMessage({ 
			type: 'applaa-game-save-score', 
			gameId: '%s', 
			playerName: '%s', 
			score: %d 
		}, '*');
	""" % [game_id, player_name, score])