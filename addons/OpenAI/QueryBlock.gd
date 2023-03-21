extends Control

signal send_query(query: String)

func isHistory(history: bool) -> void:
	%Query.editable = !history
	%Submit.visible = !history

func _on_submit_pressed():
	send_query.emit(%Query.text)
