@tool
extends PopupPanel

const apiKeyName = "open_ai/api_key"
var conversation = []
const bootstrap = """Write a Godot Engine script.
- Expect Godot 4
- Use GDScript version 2
- Put any explanation into comments
The task is:
%s"""

func _enter_tree():
	print("Copilot open")
	newPrompt()
	
func newPrompt():
	print("new prompts")
	var prompt: QueryBlock = load("res://addons/OpenAI/QueryBlock.tscn").instantiate()
	prompt.send_query.connect(func (q: String, that: QueryBlock):
		print("Query: %s" % q)
		sendQuery(q)
		that.isHistory(true)
		)
		
	%Prompts.add_child(prompt)

func sendQuery(query: String):
	print("OpenAI: Querying AI")
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(func (result, response_code, headers, body): 
		print("OpenAI: Parsing reply")
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		var response = json.get_data()
		print(response)
		var reply = response.choices[0].message.content
		print(reply)
		conversation.append({"role": "assistant", "content": reply })
		%CodeEdit.text = reply
		newPrompt()
		http_request.queue_free()
	)
	
	if conversation.size() == 0:
		query = "%s\n%s" % [bootstrap, query]
	conversation.append({"role": "user", "content": query})
	
	var body = JSON.new().stringify({"model": "gpt-3.5-turbo", "messages": conversation})
	var error = http_request.request("https://api.openai.com/v1/chat/completions", ["Authorization: Bearer %s" % ProjectSettings.get_setting(apiKeyName), "Content-Type: application/json"], HTTPClient.METHOD_POST, body)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
