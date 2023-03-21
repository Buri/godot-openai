@tool
extends Control

const apiKeyName = "open_ai/api_key"
var lastCode = "# No response yet. Please submit your query first"

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
	print("OpenAI: Querying AI")
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)
	#http_request.request_completed.connect(func (x1,x2,x3,x4): http_request.queue_free())

	var body = JSON.new().stringify({"model": "gpt-3.5-turbo", "messages": [{"role": "user", "content": query}]})
	var error = http_request.request("https://api.openai.com/v1/chat/completions", ["Authorization: Bearer %s" % ProjectSettings.get_setting(apiKeyName), "Content-Type: application/json"], HTTPClient.METHOD_POST, body)
	if error != OK:
		push_error("An error occurred in the HTTP request.")

func _http_request_completed(result, response_code, headers, body):
	print("OpenAI: Parsing reply")
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()

	var code = response.choices[0].message.content
	var source = "@tool\n%s" % code
	lastCode = source
	if %ExecuteImmediately.button_pressed:
		executeCode(source)
	else:
		showCodePopup(source)
	
func showCodePopup(code: String) -> void:
	var popup = load("res://addons/OpenAI/ExecuteWindow.tscn").instantiate()
	add_child(popup)
	popup.offerCode(code)
	popup.execute_code.connect(self.executeCode)
	popup.popup_centered()
	
func executeCode(code: String) -> void:
	lastCode = code
	var exec = GDScript.new()
	exec.source_code = code
	exec.reload()
	print("OpenAI: Executing code")
	print_verbose(code)
	%Executer.set_script(exec)
	if "callMe" in %Executer:
		%Executer.callMe()
	print("OpenAI: Done")


func _on_open_last_pressed():
	showCodePopup(lastCode)


func _on_code_assist_pressed():
	var codeAssist = load("res://addons/OpenAI/copilot.tscn").instantiate()
	add_child(codeAssist)
	codeAssist.show()
