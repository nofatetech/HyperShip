extends Node

var websocket_manager: WebSocketManager
var is_authenticated: bool = false
var url_params: Dictionary = {}

func _ready():
	# Initialize WebSocket manager
	websocket_manager = WebSocketManager.new()
	add_child(websocket_manager)
	
	# Check for URL parameters if running in web context
	if OS.has_feature("web"):
		var js_code = """
		function getUrlParams() {
			const params = new URLSearchParams(window.location.search);
			const result = {};
			for (const [key, value] of params) {
				result[key] = value;
			}
			return result;
		}
		getUrlParams();
		"""
		
		var params = JavaScriptBridge.eval(js_code)
		if params:
			url_params = params
			print("URL Parameters:", url_params)
	
	# Connect to WebSocket immediately
	print("Attempting to connect immediately...")
	websocket_manager.connect_to_server()

func get_url_param(param_name: String) -> String:
	return url_params.get(param_name, "") 