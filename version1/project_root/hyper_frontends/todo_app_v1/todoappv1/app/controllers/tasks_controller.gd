# app/controllers/tasks_controller.gd
extends Node
class_name TasksController

signal task_loaded(task)
signal task_created(task)
signal task_creation_failed(error)

var api_url: String = "http://127.0.0.1:3000/tasks"

var m_tasks = []

func get_tasks() -> void:
	var request = HTTPRequest.new()
	add_child(request)  # Add request as a child to the scene tree for HTTP requests
	request.connect("request_completed", _on_get_tasks_completed)
	request.request(api_url)

func _on_get_tasks_completed(_result, response_code, _headers, body):
	if response_code == 200:  # Success response
		var json = JSON.new()
		var error = json.parse(body.get_string_from_utf8())
		if error == OK:
			var tasks = json.data
			for task_data in tasks:
				var aa = task_data.get("id", 0)
				print("Emitting task_loaded: ", task_data.get("id", 999))
				
				var task = Task.new()
				task.id = task_data.get("id", 0)
				task.content = task_data.get("content", "")
				m_tasks.append(task)
				emit_signal("task_loaded", task)
				
		else:
			print("Error parsing JSON: ", json.error_string)
	else:
		print("Request failed with response code: ", response_code)


# Function to create a new task by sending a POST request
func create_task(task_data: Dictionary) -> void:
	var request = HTTPRequest.new()
	add_child(request)
	request.connect("request_completed", _on_create_task_completed)

	var json = JSON.new()
	
	# Prepare request parameters
	var headers = [
		"Content-Type: application/json",
		"Accept: application/json", # to let rails know to work with json
	]

	# Correctly convert dictionary to JSON string and create payload
	var body = {
		"task": task_data
	}
	body = json.stringify(body)
	
	# Send the POST request
	var error = request.request(api_url, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		print("Failed to send POST request: ", error)
		emit_signal("task_creation_failed", "Request initiation error")
	else:
		print("POST request sent for task creation.")

# Handle the response of the POST request
func _on_create_task_completed(result, response_code, headers, body) -> void:
	if response_code == 201:  # Created
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		if parse_result == OK:
			var task_data = json.data
			var task = Task.new()
			task.id = task_data.get("id", 0)
			task.content = task_data.get("content", "")
			
			m_tasks.append(task)
			emit_signal("task_created", task)
		else:
			print("Error parsing JSON response: ", json.error_string)
			emit_signal("task_creation_failed", json.error_string)
	else:
		print("Task creation failed with response code: ", response_code)
		emit_signal("task_creation_failed", "HTTP Error " + str(response_code))
