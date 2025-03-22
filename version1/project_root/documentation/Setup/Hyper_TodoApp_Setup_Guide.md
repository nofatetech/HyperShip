
# Hyper TO-DO List App Setup Guide (Frontend)

This guide provides instructions to set up a basic TO-DO list app frontend using Hyper, connecting to a Rails backend for data storage.

---

## Prerequisites

- **Gotod or Redot Engine** (version 4.3 or higher recommended)
- **GDScript** knowledge (basic scripting in Godot / Redot)
- **Rails backend** following the setup in the [Rails TO-DO List App Setup Guide](Rails_TodoApp_Setup_Guide.md)

---

## Folder Structure

This Hyper project will mirror the Rails structure to ease the developer experience:

```
├── app/
│   ├── controllers/       # GDScript files for handling CRUD actions (e.g., `tasks_controller.gd`)
│   ├── models/            # GDScript files defining data structures (e.g., `task.gd`)
│   └── views/             # Scenes representing various screens (e.g., `index.tscn`, `show.tscn`)
├── config/                # Config files, e.g., API URL for Rails backend
└── assets/                # Images and icons
```

---

## Step-by-Step Setup

### Step 1: Create a New Hyper Project

1. Open Godot / Redot and create a new project named **TodoApp**.
2. Set up the folder structure as shown above within the project.

### Step 2: Define the Task Model

In `app/models/`, create a `task.gd` file for the `Task` model:

```gd
# app/models/task.gd
extends Resource

class_name Task

var id: int = 0
var content: String = ""
```

This script represents a basic task structure with `id` and `content` attributes.

### Step 3: Create HTTP Request Logic

In `app/controllers/`, create a `tasks_controller.gd` script to handle HTTP requests to the Rails backend:

```gd
# app/controllers/tasks_controller.gd
extends Node

var api_url: String = "http://localhost:3000/tasks"

func get_tasks() -> void:
    var request = HTTPRequest.new()
    add_child(request)
    request.request(api_url)

func create_task(content: String) -> void:
    var request = HTTPRequest.new()
    add_child(request)
    request.request(api_url, ["Content-Type: application/json"], HTTPClient.METHOD_POST, JSON.print({"task": {"content": content}}))

func delete_task(task_id: int) -> void:
    var request = HTTPRequest.new()
    add_child(request)
    request.request(api_url + "/" + str(task_id), [], HTTPClient.METHOD_DELETE)

# Connect the "request_completed" signal to process responses if needed
```

### Step 4: Set Up the Main UI

Create the main scene file for displaying tasks.

1. In `app/views/`, create a scene file named `index.tscn`.
2. Add a `VBoxContainer` for listing tasks, a `LineEdit` for task input, and a `Button` to add tasks.

Attach the following script to the main scene:

```gd
# app/views/index.gd
extends Control

@onready var tasks_controller = preload("res://app/controllers/tasks_controller.gd").new()
@onready var task_list = $VBoxContainer

func _ready():
    tasks_controller.get_tasks()

func add_task():
    var content = $LineEdit.text
    if content != "":
        tasks_controller.create_task(content)
        $LineEdit.clear()
```

### Step 5: Define the Config File

In the `config/` folder, create a `config.gd` file with the API URL. Set the Rails backend URL here:

```gd
# config/config.gd
const API_URL = "http://localhost:3000/tasks"
```

### Step 6: Set Up Signals and Responses

1. Connect `HTTPRequest`'s `request_completed` signal to handle data responses.
2. Process JSON data from the backend to create `Task` instances and display them in the `index.tscn`.

```gd
# app/controllers/tasks_controller.gd (Updated)
extends Node

signal task_loaded(task)

var api_url: String = "http://localhost:3000/tasks"

func get_tasks() -> void:
    var request = HTTPRequest.new()
    add_child(request)
    request.connect("request_completed", self, "_on_get_tasks_completed")
    request.request(api_url)

func _on_get_tasks_completed(result, response_code, headers, body):
    var tasks = JSON.parse(body.get_string_from_utf8()).result
    for task_data in tasks:
        var task = Task.new()
        task.id = task_data.id
        task.content = task_data.content
        emit_signal("task_loaded", task)
```

### Step 7: Run and Test the App

1. Run the Godot / Redot Hyper project.
2. Verify that you can add, delete, and display tasks.
3. The app will send HTTP requests to the Rails backend to retrieve and manipulate task data.

---

## Additional Notes

- **Error Handling**: Implement error handling for HTTP responses in `tasks_controller.gd`.
- **UI Enhancements**: Customize UI with additional scenes and styles.
- **Persistent Storage**: Rails backend handles persistence; Hyper app retrieves data on load.

Happy coding!
