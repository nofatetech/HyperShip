# auth_manager.gd
extends Node

class_name AuthManager

# Signals
signal login_completed(success: bool, data: Dictionary)
signal token_verified(success: bool, data: Dictionary)
signal api_request_completed(endpoint: String, success: bool, data: Dictionary)
signal logout_completed(success: bool, data: Dictionary)

# Authentication state
enum AuthState { UNAUTHENTICATED, AUTHENTICATING, AUTHENTICATED, ERROR }
var auth_state: AuthState = AuthState.UNAUTHENTICATED
var token: String = ""
var user_data: Dictionary = {}
var token_expires: int = 0  # Unix timestamp in seconds

# API Configuration
const API_BASE_URL = "https://innovaciongt1.com/version-test/api/1.1/wf" # "http://127.0.0.1:3000"
const TOKEN_STORAGE_PATH = "user://token.dat"

# Login with username and password
func login_with_credentials(email: String, password: String) -> void:
	print("login_with_credentials", " ", email, " ", password)
	if auth_state == AuthState.AUTHENTICATING:
		return
	auth_state = AuthState.AUTHENTICATING
	
	var url = API_BASE_URL + "/hypership_auth_login"
	print("login_with_credentials url", " ", url)

	#var headers = ["Content-Type: application/json"]
	#var body = JSON.stringify({"email": email, "password": password})
	#_make_request(url, headers, HTTPClient.METHOD_POST, body, _on_login_completed)
	
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	var body = "email=" + email.uri_encode() + "&password=" + password.uri_encode()
	_make_request(url, headers, HTTPClient.METHOD_POST, body, _on_login_completed)
	
	

# Login with existing token
func login_with_token(input_token: String) -> void:
	if auth_state == AuthState.AUTHENTICATING:
		return
	auth_state = AuthState.AUTHENTICATING
	token = input_token
	verify_token()

# Verify token with backend
func verify_token() -> void:
	if token.is_empty() or is_token_expired():
		auth_state = AuthState.UNAUTHENTICATED
		token_verified.emit(false, {})
		return
		
	var url = API_BASE_URL + "/verify_token"
	var headers = get_bearer_headers()
	_make_request(url, headers, HTTPClient.METHOD_GET, "", _on_verify_completed)

# Check authentication status
func check_auth_status() -> void:
	if token.is_empty():
		token = get_stored_token()
	verify_token()

# Logout user with API call
func logout() -> void:
	if auth_state != AuthState.AUTHENTICATED || token.is_empty():
		_clear_auth_state()
		logout_completed.emit(true, {"status": "success", "response": {}})
		return
		
	var url = API_BASE_URL + "/logout"
	var headers = get_bearer_headers()
	_make_request(url, headers, HTTPClient.METHOD_POST, "", _on_logout_completed)

# Make authenticated API request
func make_api_request(endpoint: String, method: int, body: String = "") -> void:
	if auth_state != AuthState.AUTHENTICATED || is_token_expired():
		api_request_completed.emit(endpoint, false, {"error": "Not authenticated or token expired"})
		return
		
	var url = API_BASE_URL + endpoint
	var headers = get_bearer_headers()
	_make_request(url, headers, method, body, _on_api_request_completed.bind(endpoint))

# Helper methods
func get_bearer_headers() -> Array:
	return ["Authorization: Bearer " + token, "Content-Type: application/json"]

func store_token(token_value: String) -> void:
	var file = FileAccess.open(TOKEN_STORAGE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(token_value)
	else:
		printerr("Failed to store token")

func get_stored_token() -> String:
	if !FileAccess.file_exists(TOKEN_STORAGE_PATH):
		return ""
	var file = FileAccess.open(TOKEN_STORAGE_PATH, FileAccess.READ)
	if file:
		return file.get_as_text()
	return ""

func is_authenticated() -> bool:
	return auth_state == AuthState.AUTHENTICATED && !is_token_expired()

func is_token_expired() -> bool:
	if token_expires == 0:
		return false
	return Time.get_unix_time_from_system() > token_expires

func _clear_auth_state() -> void:
	token = ""
	user_data.clear()
	token_expires = 0
	store_token("")
	auth_state = AuthState.UNAUTHENTICATED

# Internal request handler
func _make_request(url: String, headers: Array, method: int, body: String, callback: Callable) -> void:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(callback)
	http_request.request_completed.connect(func(_r, _c, _h, _b): http_request.queue_free())
	var error = http_request.request(url, headers, method, body)
	if error != OK:
		printerr("Request failed: ", error)
		auth_state = AuthState.ERROR

# Response handlers
func _on_login_completed(_result: int, response_code: int, _headers: Array, body: PackedByteArray) -> void:
	var success = false
	var data = {}

	print("_on_login_completed", " ", _result, " ", response_code, " ", body)	

	if response_code == 200:
		var json = JSON.new()
		if json.parse(body.get_string_from_utf8()) == OK:
			data = json.data
			if data.get("status") == "success" and data.has("response"):
				var response = data["response"]
				if response.has("token"):
					token = response["token"]
					user_data["user_id"] = response.get("user_id", "")
					token_expires = Time.get_unix_time_from_system() + response.get("expires", 0)
					store_token(token)
					success = true
					auth_state = AuthState.AUTHENTICATED
			if not success:
				auth_state = AuthState.ERROR
	else:
		auth_state = AuthState.UNAUTHENTICATED
	
	login_completed.emit(success, data)

func _on_verify_completed(_result: int, response_code: int, _headers: Array, body: PackedByteArray) -> void:
	var success = false
	var data = {}
	
	if response_code == 200:
		var json = JSON.new()
		if json.parse(body.get_string_from_utf8()) == OK:
			data = json.data
			if data.get("valid", false):
				success = true
				auth_state = AuthState.AUTHENTICATED
				user_data = data.get("user", {})
			else:
				auth_state = AuthState.UNAUTHENTICATED
	else:
		auth_state = AuthState.UNAUTHENTICATED
		_clear_auth_state()
	
	token_verified.emit(success, data)

func _on_logout_completed(_result: int, response_code: int, _headers: Array, body: PackedByteArray) -> void:
	var success = false
	var data = {}
	
	if response_code == 200:
		var json = JSON.new()
		if json.parse(body.get_string_from_utf8()) == OK:
			data = json.data
			if data.get("status") == "success":
				success = true
				_clear_auth_state()
	else:
		data = {"error": "Logout failed", "code": response_code}
	
	logout_completed.emit(success, data)

func _on_api_request_completed(endpoint: String, _result: int, response_code: int, _headers: Array, body: PackedByteArray) -> void:
	var success = response_code == 200
	var data = {}
	
	if success:
		var json = JSON.new()
		if json.parse(body.get_string_from_utf8()) == OK:
			data = json.data
		else:
			success = false
			data = {"error": "Invalid JSON response"}
	else:
		data = {"error": "Request failed", "code": response_code}
	
	api_request_completed.emit(endpoint, success, data)
