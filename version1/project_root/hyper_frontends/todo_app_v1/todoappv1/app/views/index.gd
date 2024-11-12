# app/views/index.gd
extends Control

# Import or reference the WebSocketManager instance
var websocket_manager: WebSocketManager

#@onready var tasks_controller = preload("res://app/controllers/tasks_controller.gd").new()
@onready var tasks_controller = $Controllers/TasksController
@onready var task_list = %VBoxContainer
@onready var xauth = $AuthManager

# Assuming task.tscn is in the path `res://app/views/task.tscn`
var TaskScene = preload("res://app/views/task_view.tscn")



func _ready():
	
	#xauth.setup("ws://127.0.0.1:3000/cable")
	xauth.is_authenticated(_on_is_authenticated_completed)


	# Ensure `tasks_controller` is in the scene tree for HTTP requests
	#add_child(tasks_controller)
	
	# Connect the `task_loaded` signal to the local `task_loaded` function
	tasks_controller.task_loaded.connect(self.task_loaded)
	#	
	# Trigger task loading
	tasks_controller.get_tasks()



	# Initialize WebSocketManager with your server's URL
	#websocket_manager = WebSocketManager.new()
	websocket_manager = $WebSocketManager
	#	
	#websocket_manager.setup(WEBSOCKET_URL) # ("ws://127.0.0.1:3000/cable")
	websocket_manager.setup("ws://127.0.0.1:3000/cable?token=123123")
	#
	# Connect signals to handle WebSocket events
	websocket_manager.connect("connected", _on_websocket_connected)
	websocket_manager.connect("connection_error", _on_websocket_connection_error)
	websocket_manager.connect("data_received", _on_websocket_data_received)
	websocket_manager.connect("disconnected", _on_websocket_disconnected)
	#
	websocket_manager.connect_to_server()




#region AUTH
func _on_is_authenticated_completed(_result, _response_code, _headers, _body):
	print("_on_is_authenticated_completed: ", _response_code)
	if _response_code == 200:  # Success response
		var json = JSON.new()
		var error = json.parse(_body.get_string_from_utf8())
		if error == OK:
			var tdata = json.data
	else:
		print("NOT AUTHENTICATED")

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



#region TASKS

func task_loaded(rtask):
	
	## Create a Label or Button to display the task content dynamically
	#var task_label = Label.new()
	#task_label.text = rtask.content
	#task_list.add_child(task_label)  # Add to VBoxContainer for display
	#print("Task loaded and added to list: ", rtask.content)

	# Instance the task.tscn scene
	var task_instance = TaskScene.instantiate()
	
	# Initialize the task instance with rtask data
	task_instance.initialize(rtask)
	
	# Add the instance to the task_list container (VBoxContainer)
	task_list.add_child(task_instance)
	
	print("Task loaded and added to list: ", rtask.content)

func reset_tasks():
	# Clear all existing task nodes in task_list
	for child in task_list.get_children():
		child.queue_free()
	
	# Fetch tasks again from tasks_controller
	tasks_controller.get_tasks()
	pass

func create_task():
	var content = $LineEdit.text
	if content != "":
		#print("create:", content)
		tasks_controller.create_task({"content":content})
		$LineEdit.clear()


func _on_create_button_button_up() -> void:
	websocket_manager.reconnect("ws://127.0.0.1:3000/cable?token=666666")

	create_task()
	reset_tasks()

#endregion TASKS
