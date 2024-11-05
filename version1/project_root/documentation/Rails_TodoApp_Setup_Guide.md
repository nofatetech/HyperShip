
# Rails TO-DO List App Setup Guide

This guide provides step-by-step instructions to set up a basic TO-DO list Rails application.

---

## Prerequisites

- **Ruby** (version 2.7 or higher)
- **Rails** (version 6.0 or higher)
- **SQLite3** (for development database)
- **Node.js** and **Yarn** (for JavaScript dependencies)

### Step 1: Install Rails

If Rails isn't installed, run the following command to install it:

```bash
gem install rails
```

### Step 2: Create a New Rails Application

Run the following command to create a new Rails app:

```bash
rails new TodoApp --database=sqlite3
cd TodoApp
```

### Step 3: Generate Task Model

Use Rails generator to create a `Task` model with a `content` field (to store the task description).

```bash
rails generate model Task content:text
```

This will create:
- A migration file in `db/migrate/`
- The `Task` model in `app/models/task.rb`

Run the migration to create the `tasks` table in the database:

```bash
rails db:migrate
```

### Step 4: Generate Tasks Controller

Generate a controller for tasks to handle CRUD operations.

```bash
rails generate controller Tasks
```

This will create:
- A controller file in `app/controllers/tasks_controller.rb`
- Views directory in `app/views/tasks/`

### Step 5: Define Routes

Open `config/routes.rb` and define RESTful routes for tasks:

```ruby
Rails.application.routes.draw do
  resources :tasks
end
```

### Step 6: Implement Controller Actions

Edit `app/controllers/tasks_controller.rb` to add actions for basic CRUD operations:

```ruby
class TasksController < ApplicationController
  def index
    @tasks = Task.all
  end

  def show
    @task = Task.find(params[:id])
  end

  def new
    @task = Task.new
  end

  def create
    @task = Task.new(task_params)
    if @task.save
      redirect_to tasks_path, notice: 'Task was successfully created.'
    else
      render :new
    end
  end

  def edit
    @task = Task.find(params[:id])
  end

  def update
    @task = Task.find(params[:id])
    if @task.update(task_params)
      redirect_to tasks_path, notice: 'Task was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @task = Task.find(params[:id])
    @task.destroy
    redirect_to tasks_path, notice: 'Task was successfully deleted.'
  end

  private

  def task_params
    params.require(:task).permit(:content)
  end
end
```

### Step 7: Create Views for Tasks

In `app/views/tasks/`, create the following view files:

- `index.html.erb`: Displays all tasks.
- `show.html.erb`: Displays a single task.
- `new.html.erb`: Form to create a new task.
- `edit.html.erb`: Form to edit an existing task.

#### Example: `index.html.erb`

```erb
<h1>To-Do List</h1>

<%= link_to 'New Task', new_task_path %>

<ul>
  <% @tasks.each do |task| %>
    <li>
      <%= link_to task.content, task_path(task) %>
      <%= link_to 'Edit', edit_task_path(task) %>
      <%= link_to 'Delete', task_path(task), method: :delete, data: { confirm: 'Are you sure?' } %>
    </li>
  <% end %>
</ul>
```

### Step 8: Start the Rails Server

Run the following command to start the server:

```bash
rails server
```

Visit `http://localhost:3000/tasks` in your browser to access the TO-DO list app.

---

## Additional Notes

- This setup uses SQLite3 for the database. For production, you may need to configure a different database (e.g., PostgreSQL).
- To make the app accessible as an API backend, you can add JSON responses to each action or use Rails' `respond_to` method.
  
---

## API Endpoints (for Godot frontend use)

If you'd like to use this as a backend for a Godot frontend app, here are the basic endpoints:

- `GET /tasks` - Fetch all tasks.
- `POST /tasks` - Create a new task.
- `GET /tasks/:id` - Fetch a specific task.
- `PUT /tasks/:id` - Update a task.
- `DELETE /tasks/:id` - Delete a task.

You can add `respond_to :json` in each controller action for JSON responses if needed.

Happy coding!
