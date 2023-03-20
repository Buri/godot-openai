@tool
extends Control

const apiKeyName = "chat_gpt/api_key"

func _ready():
	if !ProjectSettings.has_setting(apiKeyName):
		ProjectSettings.set_initial_value(apiKeyName, '')
	
func constructAIQuery() -> String:
	var input = %Query.text
	var query = """Write a Godot Engine script.
- It extends Node
- Expect Godot 4
- Use GDScript version 2
- Put all your code into callMe method
- I only need the script body. Don’t add any explanation.
- If you are doing operation on nodes, access them via "get_tree().get_edited_scene_root()"
- If you are doing operation on nodes, set their owner to "get_tree().get_edited_scene_root()"
The task is as follows:
%s""" % input
	return query

func _on_submit_pressed():
	var query = constructAIQuery()
	sendQuery(query)
	
func sendQuery(query: String):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)
	#http_request.request_completed.connect(func (x1,x2,x3,x4): http_request.queue_free())

	var body = JSON.new().stringify({"model": "gpt-3.5-turbo", "messages": [{"role": "user", "content": query}]})
	var error = http_request.request("https://api.openai.com/v1/chat/completions", ["Authorization: Bearer %s" % ProjectSettings.get_setting(apiKeyName), "Content-Type: application/json"], HTTPClient.METHOD_POST, body)
	if error != OK:
		push_error("An error occurred in the HTTP request.")

func _http_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()

	var code = response.choices[0].message.content
	#print(code)
	var exec = GDScript.new()
	exec.source_code = "@tool\n%s" % code
	exec.reload()
	print("ChatGPT: Executing code")
	print_verbose(code)
	print(code)
	%Executer.set_script(exec)
	%Executer.callMe()
	print("ChatGPT: Done")

