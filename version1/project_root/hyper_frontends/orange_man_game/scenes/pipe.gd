extends Area2D

signal hit
signal scored
var xtype = 1
var xtype2 = 0

var hasportal = false

#var ARTOPTIONS = [
	##{"slug": "sherlock1", "file": "res://assets/new2/sherlock-4bf2e2f1-15a5-488f-bba9-ec2a34474785.webp"},
	##{"slug": "sherlock1", "file": "https://image.lexica.art/full_webp/30b56090-b8b4-4c7e-accc-59b843e91cb3"},
	##{"slug": "kingkong1", "file": "res://assets/new2/kingkong1-be2ce4a2-709f-4b83-9660-2980efb9dbd4.webp"},
	#
	##{"slug": "alicewonderland1", "name": "Alice in Wonderland", "file": "res://assets/new2/files/alicewonderland1-f27b2c26-6bad-4688-9153-ef3ae456933a.webp", },
	##{"slug": "sherlock1", "name": "Sherlock Holmes", "file": "res://assets/new2/files/sherlock-4bf2e2f1-15a5-488f-bba9-ec2a34474785.webp"},
	##{"slug": "kingkong1", "name": "King Kong", "file": "res://assets/new2/files/kingkong1-be2ce4a2-709f-4b83-9660-2980efb9dbd4.webp"},
	##{"slug": "SteamboatWillieMouse", "name": "Steamboat Willie Mouse", "file": "res://assets/new2/files/willie1.png", },
#]


func change_xtype2(cycle):
	#$Ticket.visible = true
	print("change_xtype2 " + str(cycle))
	

#func xxx1():
	#$Type2/ArtNode/Artimg3.scale = Vector2(3,3)
	#pass

func _enter_tree():
	xtype = randi_range(1, 2)
	#$Upper.modulate = Color("000000", 1.33)
	#$Lower.modulate = Color("000000", 1.33)
	##$Wall1.modulate = Color("000000", 1.33)
	#$Label.text = "" + str(xtype2)
	$Type1.visible = false
	$Type2.visible = false
	$Type3.visible = false

	var probability_portal = randi_range(1, 10)
	if probability_portal == 1:
		print("!!!!!!!!!!!!!!!!!!!!!!")
		xtype = 1
		hasportal = true
		$PORTALArea2D.visible = true
		$Lower.visible = false
		$Upper.visible = false
		
	



	# enemy
	if xtype == 1:
		$Lower.modulate = Color("fc4a03", 0.33)
		$Upper.modulate = Color("fc4a03", 0.33)
		#$Label.text = "1"
		$Type1.visible = true
		#$Wall1.modulate = Color("000000", 0.66)



	# money
	if xtype == 2:
		$Lower.modulate = Color("000000", 0.33)
		$Upper.modulate = Color("000000", 0.33)
		#$Label.text = "2"
		$Type2.visible = true
		#$Wall1.modulate = Color("000000", 0.66)
		$Type2/ArtNode.visible = true
		$Lower/Zombie1.modulate = Color("ffffff", 0)
		

		$Type2/ArtNode/Artimg3.texture = load("res://assets/new2/files/willie1.png")
		$Type2/ArtNode/Artimg3.modulate = Color("ffffff")
		$Type2/ArtNode/ArtLabel.text = ""
		return

		#$Type3/Artimg1.texture = load("res://assets/1830d263-2743-4ca1-b8db-00ad58816081.webp")
		#$Type2/ArtNode/Artimg3.texture = load("res://assets/new2/kingkong1-be2ce4a2-709f-4b83-9660-2980efb9dbd4.webp")
		var toptionselected = Xglobal.ARTOPTIONS[ randi_range(0,len(Xglobal.ARTOPTIONS)-1) ]

		#$Type2/ArtNode/Artimg3.texture = load(toptionselected["file"])

		var img = Image.new()
		var path = ""
		if toptionselected["file"] != "":
			#path = toptionselected["file"]
			#img.load(path)
			#var tex = ImageTexture.create_from_image(img)
			#$Type2/ArtNode/Artimg3.texture = tex
			
			$Type2/ArtNode/Artimg3.texture = load(toptionselected["file"])
			
			$Type2/ArtNode/Artimg3.modulate = Color("ffffff")
			#print("!!!!!!!",$Type2/ArtNode/Artimg3.transform.apply_scale(Vector2(3,3)))
		else:
			path = toptionselected["file_web"]
			var http_request = HTTPRequest.new()
			add_child(http_request)
			http_request.request_completed.connect(self._http_request_completed)

			# Perform the HTTP request. The URL below returns a PNG image as of writing.
			var error = http_request.request(path)
			if error != OK:
				#print("An error occurred in the HTTP request.")
				push_error("An error occurred in the HTTP request.")

		$Type2/ArtNode/ArtLabel.text = "" + toptionselected["name"]


		
	if xtype == 3:
		$Lower.modulate = Color("000000", 0.99)
		$Upper.modulate = Color("000000", 0.99)
		#$Label.text = "3"
		#var toptionselected = Xglobal.ARTOPTIONS[ randi_range(0,len(Xglobal.ARTOPTIONS)-1) ]
		#$Type3/Art.texture = load(toptionselected["file"])
		#$Type3/ArtLabel.text = "" + toptionselected["slug"]

		$Type3/ArtLabel.text = "333"
		$Type3.visible = true
		#$Wall1.modulate = Color("000000", 0.99)
	#$Upper.modulate = Color("000000", 0.0)
	#$Lower.modulate = Color("000000", 0.0)





# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	print("HTTP Request Completed with response code: %d" % response_code)
	#print("Headers: ", headers)
	
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Error: Image couldn't be downloaded. Try a different image.")
		return

	var content_type = ""
	for header in headers:
		if header.begins_with("Content-Type:"):
			content_type = header.substr(header.find(":") + 2)
			break
	
	print("Content-Type: [%s]" % content_type)
	var image = Image.new()
	var error = OK
	var texture = null
	
	match content_type:
		"image/jpeg":
			error = image.load_jpg_from_buffer(body)
		"image/png":
			error = image.load_png_from_buffer(body)
		"image/webp":
			error = image.load_webp_from_buffer(body)
		_:
			print("Error: Unsupported image format [%s]" % content_type)
			return

	if error != OK:
		push_error("Error: Couldn't load the image. Error code: %d" % error)
	else:
		#texture = ImageTexture.new()
		#texture.create_from_image(image)
		texture = ImageTexture.create_from_image(image)
		$Type2/ArtNode/Artimg3.texture = texture
		$Type2/ArtNode/Artimg3.modulate = Color("ffffff")
		print("Image loaded successfully. Texture size: %s" % str(texture.get_size()))



func _on_body_entered(body):
	if hasportal:
		return
	hit.emit(xtype)
	if xtype == 1:
		$Upper.modulate = Color("fc4a03", 0.77)
		$Lower.modulate = Color("fc4a03", 0.77)
	pass

func _on_score_area_body_entered(body):
	scored.emit(xtype)
	if xtype == 2:
		$Type2/MoneyFountain.visible = false
		pass


func _on_portal_area_2d_body_entered(body: Node2D) -> void:
	if hasportal:
		print("PORTAL GO!!!!")
		OS.shell_open("http://portal.pieter.com")
		return
	
	pass # Replace with function body.
