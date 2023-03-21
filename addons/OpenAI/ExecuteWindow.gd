@tool
extends PopupPanel

signal execute_code(code: String)

func offerCode(code: String):
	%CodeEdit.text = code

func _on_execute_pressed():
	execute_code.emit(%CodeEdit.text)
	queue_free()

func _on_cancel_pressed():
	queue_free()

