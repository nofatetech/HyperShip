# app/views/index.gd
extends Control

@onready var tasks_controller = preload("res://app/controllers/tasks_controller.gd").new()
@onready var task_list = %VBoxContainer

# Assuming task.tscn is in the path `res://app/views/task.tscn`
var TaskScene = preload("res://app/views/task_view.tscn")

func _ready():
	# Ensure `tasks_controller` is in the scene tree for HTTP requests
	add_child(tasks_controller)
	
	# Connect the `task_loaded` signal to the local `task_loaded` function
	tasks_controller.task_loaded.connect(self.task_loaded)
	
	# Trigger task loading
	tasks_controller.get_tasks()

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
	create_task()
	reset_tasks()
