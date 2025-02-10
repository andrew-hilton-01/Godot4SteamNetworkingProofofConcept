extends Node3D
@export var winAmt : int = 350
var currentScrap : int = 0
func _ready():
	pass


func _on_collection_area_area_entered(area):
	if !is_multiplayer_authority():
		return
	if area and area.is_in_group("Items"):
		if !area.canScrap:
			return
		currentScrap+=area.scrapAmt
		$CollectionArea/Label3D.set_text("current: %d needed to win: %d" % [currentScrap, winAmt])
		if currentScrap >= winAmt:
			$CollectionArea/Label3D.set_text("You win the game!!!!!!!!!!!!!")
			for i in range(%Players.get_children().size()):
				%Players.get_children()[i].take_damage.rpc(1000)

func _on_collection_area_area_exited(area):
	if !is_multiplayer_authority():
		return
	if area and area.is_in_group("Items"):
		if !area.canScrap:
			return
		currentScrap-=area.scrapAmt
		$CollectionArea/Label3D.set_text("current: %d needed to win: %d" % [currentScrap, winAmt])
