extends Node


const DEFAULT_SCORE: int = 999
const SCORES_PATH = "user://animals.json"


var _level_selected: int = 1
var _level_scores: Dictionary = {}


func set_level_selected(ls: int) -> void:
	_level_selected = ls


func get_level_selected() -> int:
	return _level_selected


func check_and_add(level: String) -> void:
	if _level_scores.has(level) == false:
		_level_scores[level] = DEFAULT_SCORE


func set_level_score(score: int, level: String) -> void:
	check_and_add(level)
	if score < _level_scores[level]:
		_level_scores[level] = score


func get_best_level_score(level: String) -> int:
	check_and_add(level)
	return _level_scores[level]
