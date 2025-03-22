# /lib/auth_manager.gd

extends Node

class_name AuthManager

var x_token: String = ""  # Stores the JWT token locally
var x_is_authenticated := false


func save_to_file(content):
	var file = FileAccess.open("user://save_game.dat", FileAccess.WRITE)
	file.store_string(content)

func load_from_file():
	var file = FileAccess.open("user://save_game.dat", FileAccess.READ)
	var content = file.get_as_text()
	return content





# Sends the JWT token to the Rails API for verification
func login_with_token(x_token: String, callback: Callable) -> void:
	#return false
	#self.x_token = x_token
	#if verify_token(x_token):
		#store_token(x_token)
		#return true
	#return false
	verify_token(x_token, callback)

#func _on_login_with_token_completed(_result, _response_code, _headers, _body):
	#print("_on_login_with_token_completed: ", _response_code)
	#if _response_code == 200:  # Success response
		#var json = JSON.new()
		#var error = json.parse(_body.get_string_from_utf8())
		#if error == OK:
			#var tdata = json.data
			#print("_on_is_authenticated_completed OK: ", tdata)
	
# Logs out the user by clearing the stored token
func logout():
	x_token = ""
	store_token("")  # Remove the stored token

# Checks if the user is authenticated by verifying the presence of a valid token
func is_authenticated(callback: Callable) -> void:
	#x_token = "TOKENTKNETKNE"
	#store_token("TOKENTKNETKNE")
	print("is_authenticated? token:", x_token)
	if x_token == "":
		x_token = get_token()
	if x_token != "":
		verify_token(x_token, callback)
	else:
		x_is_authenticated = false
		pass

func _on_is_authenticated_completed(_result, _response_code, _headers, _body):
	print("_on_is_authenticated_completed: ", _response_code)
	if _response_code == 200:  # Success response
		var json = JSON.new()
		var error = json.parse(_body.get_string_from_utf8())
		if error == OK:
			var tdata = json.data
			print("_on_is_authenticated_completed OK: ", tdata)
			#{
			  #"valid": true,
			  #"user_id": 1,
			  #"expires_at": "2024-12-31T23:59:59Z"
			#}
			var tvalid = tdata.get("valid", false)
			if tvalid:
				x_is_authenticated = true
	pass

# Stores the token securely (custom storage method)
func store_token(token: String):
	var file = FileAccess.open("user://token.dat", FileAccess.WRITE)
	file.store_string(token)
	print('stored! ', token)


# Retrieves the stored token from secure storage
func get_token() -> String:
	var file_path = "user://token.dat"
	
	# Check if the file exists
	if !FileAccess.file_exists(file_path):
		# Create the file if it does not exist and write an empty token
		var file = FileAccess.open(file_path, FileAccess.WRITE)
		file.store_string("")  # Store an empty string as the initial content
		file.close()
	
	# Open the file for reading
	var file = FileAccess.open(file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	return content


# Verifies the token with the Rails API
func verify_token(token: String, callback: Callable) -> void:
	var url = "http://127.0.0.1:3000/verify_token"  # Rails endpoint for verification
	var headers = {"Authorization": "Bearer " + token}
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", callback)
	http_request.request(url)
	
	
#func _on_verify_token_completed(result: int, response_code: int, headers: Array, body: PackedByteArray):
	#print("_on_verify_token_completed ", response_code)
	#if response_code == 200:
		#var json = JSON.new()
