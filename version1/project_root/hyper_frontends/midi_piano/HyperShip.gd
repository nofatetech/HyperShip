extends Node2D
class_name HyperShip

var url_params: Dictionary = {}


#var websocket_manager: WebSocketManager
#var auth_manager: AuthManager
@onready var auth_manager = $AuthManager
@onready var websocket_manager = $WebSocketManager

#@onready var xauth = $AuthManager

@onready var piano = get_parent()  # HyperShip is a child of Piano node



func get_url_param(param_name: String) -> String:
	return url_params.get(param_name, "") 


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	if OS.has_feature("web"):
		# Get URL parameters using JavaScript
		var js_code = """
		function getUrlParams() {
			return {"a":"b"};
			return Object.fromEntries(new URLSearchParams(window.location.search));
		}
		function getUrlParams2() {
			return {"a2":"b2"};
			const params = new URLSearchParams(window.location.search);
			const result = {};
			for (const [key, value] of params) {
				result[key] = value;
			}
			return result;
		}
		getUrlParams();
		"""
		
		var params = JavaScriptBridge.eval(js_code)
		if params:
			url_params = params
			print("URL Parameters:", url_params)
	else:
		print("Not running in web context")

	# Auth
	# Connect all signals
	auth_manager.login_completed.connect(_on_login_completed)
	auth_manager.token_verified.connect(_on_token_verified)
	auth_manager.logout_completed.connect(_on_logout_completed)
	auth_manager.api_request_completed.connect(_on_api_request_completed)
	
	# Check if we're already authenticated from a previous session
	auth_manager.check_auth_status()
	


	#region AUTH


# UI handlers
func _on_login_button_pressed():
	# Simulate login with test credentials
	var username = "test@example.com"
	var password = "password123"
	auth_manager.login_with_credentials(username, password)
	print("Attempting login with: ", username)

func _on_logout_button_pressed():
	auth_manager.logout()
	print("Attempting logout")

func _on_test_api_button_pressed():
	# Example API call to get user data
	auth_manager.make_api_request("/user/profile", HTTPClient.METHOD_GET)
	print("Making API request")

# Signal handlers
func _on_login_completed(success: bool, data: Dictionary):
	if success:
		print("Login successful!")
		print("Token: ", auth_manager.token)
		print("User ID: ", auth_manager.user_data["user_id"])
		print("Token expires: ", Time.get_datetime_string_from_unix_time(auth_manager.token_expires))
		# Update UI or game state here
	else:
		print("Login failed: ", data.get("error", "Unknown error"))
		# Show error message to user

func _on_token_verified(success: bool, data: Dictionary):
	if success:
		print("Token verified successfully!")
		print("User data: ", auth_manager.user_data)
		# Proceed with authenticated state
	else:
		print("Token verification failed: ", data.get("error", "Unknown error"))
		# Prompt for login if needed
		# auth_manager.login_with_credentials("user", "pass")

func _on_logout_completed(success: bool, data: Dictionary):
	if success:
		print("Logout successful!")
		# Update UI to show logged out state
	else:
		print("Logout failed: ", data.get("error", "Unknown error"))
		# Handle logout failure (maybe retry or force local logout)

func _on_api_request_completed(endpoint: String, success: bool, data: Dictionary):
	if success:
		print("API request to ", endpoint, " succeeded!")
		print("Response data: ", data)
		# Process the API response
	else:
		print("API request to ", endpoint, " failed: ", data.get("error", "Unknown error"))
		# Handle API error (retry, show message, etc.)
	
	# Check authentication status after every API call
	if not auth_manager.is_authenticated():
		print("No longer authenticated - token may have expired")
		# Handle re-authentication if needed

# Example game logic that requires authentication
func do_authenticated_action():
	if auth_manager.is_authenticated():
		# Make an API call with some data
		var request_body = JSON.stringify({"action": "do_something"})
		auth_manager.make_api_request("/game/action", HTTPClient.METHOD_POST, request_body)
	else:
		print("Please log in first!")
		# Show login screen or prompt


	#endregion



	#region WEBSOCKET
	#endregion
	
	# Initialize WebSocketManager
	websocket_manager = $WebSocketManager
	#websocket_manager.setup("ws://127.0.0.1:6001")
	#
	## Connect WebSocket signals to HyperShip handlers
	#websocket_manager.connect("connected", _on_websocket_connected)
	#websocket_manager.connect("connection_error", _on_websocket_connection_error)
	#websocket_manager.connect("data_received", _on_websocket_data_received)
	#websocket_manager.connect("disconnected", _on_websocket_disconnected)
	#
	## Wait for the next frame to ensure Piano is ready
	#await get_tree().process_frame
	#
	## Connect WebSocket signals to Piano handlers
	#if piano:
		#print("Found Piano node, connecting signals...")
		#websocket_manager.connect("connected", piano._on_websocket_connected)
		#websocket_manager.connect("connection_error", piano._on_websocket_error)
		#websocket_manager.connect("data_received", piano._on_websocket_data_received)
		#websocket_manager.connect("disconnected", piano._on_websocket_disconnected)
		#websocket_manager.connect("connection_state_changed", piano._on_connection_state_changed)
	#else:
		#print("Warning: Piano node not found! Node path: ", get_parent().get_path())
	#
	## Connect immediately without waiting for authentication
	##print("[WebSocket] Attempting immediate connection...")
	##websocket_manager.connect_to_server()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#region AUTH
func _on_is_authenticated_completed(_result, _response_code, _headers, _body):
	print("_on_is_authenticated_completed: ", _response_code)
	if _response_code == 200:  # Success response
		var json = JSON.new()
		var error = json.parse(_body.get_string_from_utf8())
		if error == OK:
			var tdata = json.data
			# Send authentication success message
			websocket_manager.send_message({"type": "auth", "status": "success"})
	else:
		print("NOT AUTHENTICATED")
		websocket_manager.send_message({"type": "auth", "status": "failed"})

#endregion AUTH

#region WEBSOCKETS

# Event Handlers
func _on_websocket_connected():
	print("Connected to WebSocket server.")
	# Send a test message
	websocket_manager.send_message({"message": "Hello, Server!"})

func _on_websocket_connection_error():
	print("Failed to connect to WebSocket server.")

func _on_websocket_data_received(data):
	print("Data received from server:", data)

func _on_websocket_disconnected(code, reason, was_clean):
	print("Disconnected from WebSocket server. Code:", code, "Reason:", reason)

#endregion WEBSOCKETS
