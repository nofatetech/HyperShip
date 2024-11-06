extends Control

#@onready var content_label = %ContentLabel
#@onready var id_label = $HBoxContainer/IDLabel2
@export var content_label: Label
@export var id_label: Label

# Initialization function to set the content and ID from rtask
func initialize(rtask):
	content_label.text = rtask.content
	id_label.text = str(rtask.id)
	pass
