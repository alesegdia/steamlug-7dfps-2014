
extends Control

func _ready():
	pass

func _on_goto_test_pressed():
	get_node("/root/scene_switcher").goto_scene("res://test.xscn")

func _on_goto_multi_pressed():
	get_node("/root/scene_switcher").goto_scene("res://lobby_testing.xscn")