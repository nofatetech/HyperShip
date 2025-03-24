extends Node2D


var ARTOPTIONS = [
	#{"slug": "sherlock1", "name":"Sherlock Holmes", "file" : "", "file_web": "https://d1muf25xaso8hp.cloudfront.net/https%3A%2F%2F1148bedfae3ffca0aac85136109396a6.cdn.bubble.io%2Ff1721264898161x869615459746501100%2Fsurviveornot%2520AD%25201.png?w=1024&h=1024&auto=compress&dpr=1.25&fit=max"},

	# from web
	{
		"slug": "jamesbond1",
		"name" : "James Bond1", 
		"file" : "", 
		"file_web": "https://image.lexica.art/full_webp/111fc0a6-8a95-455d-bc70-45eecebcfe20",
	},
	{
		"slug": "jamesbond",
		"name" : "James Bond", 
		"file" : "", 
		"file_web": "https://image.lexica.art/full_webp/6bc9a9a7-4d7d-4ec5-b623-eca854bbe592",
		"credits_url" : "https://lexica.art/prompt/8d64d8a5-1cc7-490e-bc2c-746ce8ac5fb4",
	},
	{
		"slug": "jamesbond",
		"name" : "James Bond", 
		"file" : "", 
		"file_web": "https://image.lexica.art/full_webp/7860824d-24ac-4475-ad07-8013f611159c",
		"credits_url" : "https://lexica.art/prompt/b3e8d8f3-95a0-4c6d-a9e2-a23f920a9c48",
	},
	{
		"slug": "jamesbond",
		"name" : "James Bond", 
		"file" : "", 
		"file_web": "https://image.lexica.art/full_webp/4fb2f475-4593-45df-8712-aac957366ac5",
		"credits_url" : "xxx",
	},




	{
		"slug": "oz",
		"name" : "OZ", 
		"file" : "", 
		"file_web": "https://image.lexica.art/full_webp/31571f74-9f3b-4333-b9d6-ae8946246ccb",
		"credits_url" : "https://lexica.art/prompt/74a09108-4e06-464f-9392-0a9124984555",
	},

	{
		"slug": "oz",
		"name" : "OZ", 
		"file" : "", 
		"file_web": "https://image.lexica.art/full_webp/4f1781cb-f883-41d7-8ae3-b32ce8d09fd1",
		"credits_url" : "https://lexica.art/prompt/f5b12d62-3d24-4467-9890-fb59759fcb50",
	},
	{
		"slug": "oz",
		"name" : "OZ", 
		"file" : "", 
		"file_web": "https://image.lexica.art/full_webp/78b1f898-2b12-4cd8-b1c2-528325269e43",
		"credits_url" : "https://lexica.art/prompt/9d275a28-3c6a-4dfe-bf4a-b20cfafdef1b",
	},




	{
		"slug": "alicewonderland1",
		"name" : "Alice in Wonderland", 
		"file" : "", 
		"file_web": "https://image.lexica.art/full_webp/0ec65fbd-39a4-4e64-8e44-e30bb6b5d60b",
		"credits_url" : "https://lexica.art/prompt/497e914c-2fbf-4e61-8337-5f151d738652",
	},
	{
		"slug": "alicewonderland1",
		"name" : "Alice in Wonderland",  
		"file" : "", 
		"file_web": "https://image.lexica.art/full_webp/23b592c2-dd3c-4d4f-9479-c1961928560d",
		"credits_url" : "https://lexica.art/prompt/feebda8d-9215-4347-92a1-316cdd287767",
	},

	{
		"slug": "alicewonderland1",
		"name" : "Alice in Wonderland", 
		"file" : "", 
		"file_web": "https://lexica.art/prompt/feebda8d-9215-4347-92a1-316cdd287767",
		"credits_url" : "https://lexica.art/prompt/9b0da4e5-e8d6-4425-bcd9-6d93ba23e7d9",
	},






#
	#{
		#"slug": "xxx",
		#"name" : "xxx", 
		#"file" : "", 
		#"file_web": "xxx",
		#"credits_url" : "xxx",
	#},







	{
		"slug": "sherlock1",
		"name" : "Sherlock Holmes 2", 
		"file" : "", 
		"file_web": "https://image.lexica.art/full_webp/30b56090-b8b4-4c7e-accc-59b843e91cb3",
	},

	# local
	{
		"slug": "sherlock1",
		"name" : "Sherlock Holmes 1", 
		"file_web" : "", 
		"file": "res://assets/new2/files/sherlock-4bf2e2f1-15a5-488f-bba9-ec2a34474785.webp",
	},
	{
		"slug": "kingkong1",
		"name" : "King Kong", 
		"file_web" : "", 
		"file": "res://assets/new2/files/kingkong1-be2ce4a2-709f-4b83-9660-2980efb9dbd4.webp",
	},
	{
		"slug": "alicewonderland1",
		"name" : "Alice in Wonderland", 
		"file_web" : "", 
		"file": "res://assets/new2/files/alicewonderland1-f27b2c26-6bad-4688-9153-ef3ae456933a.webp",
	},
	{
		"slug": "SteamboatWillieMouse",
		"name" : "Steamboat Willie Mouse", 
		"file_web" : "", 
		"file": "res://assets/new2/files/willie1.png",
	},

	{
		"slug": "kingkong2",
		"name" : "King Kong", 
		"file_web" : "", 
		"file": "res://assets/new2/files/kingkong2-1479d74d-35cb-4ca5-a7c6-a6453ee9e62f.webp", 
		"credits_url":"https://lexica.art/prompt/bed388f7-0ae0-4104-8c23-f0e13ba5ec4a",
	},
	{
		"slug": "vincent-van-gogh-1",
		"name" : "Vincent Van Gogh", 
		"file_web" : "", 
		"file": "res://assets/new2/files/vangogh1-czNmcy1wcml2YXRlL3Jhd3BpeGVsX2ltYWdlcy93ZWJzaXRlX2NvbnRlbnQvbHIvcGR2YW5nb2doLXRoZS1iZWRyb29tcm9iLmpwZw.jpg",
	},
]


var lives = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
