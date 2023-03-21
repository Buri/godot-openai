@tool
extends Control
class_name QueryBlock

signal send_query(query: String, this: QueryBlock)

func isHistory(history: bool) -> void:
	%Query.editable = !history
	%Submit.visible = !history

func _on_submit_pressed():
	if %Query.text.length() == 0:
		return
	print("HGAHA")
	%Submit.text = "Generating"
	%Submit.disabled = true
	send_query.emit(%Query.text, self)
	
