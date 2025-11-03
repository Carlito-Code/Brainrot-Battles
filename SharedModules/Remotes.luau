local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TypedRemote = require(ReplicatedStorage.Utilities.TypedRemote)

return {
	GetPlot = TypedRemote.func("GetPlot"),
	AddProximity = TypedRemote.event("AddProximity"),
	ChangeViewingProximity = TypedRemote.event("Change"),
	SpawnEntity = TypedRemote.event("SpawnEntity"),
	StartWaveSystem = TypedRemote.event("StartWaveSystem"),
	StopWaveSystem = TypedRemote.event("StopWaveSystem"),

	PurchaseStarted = TypedRemote.event("PurchaseStarted"),
	PurchaseEnded = TypedRemote.event("PurchaseEnded"),
	PromptPurchase = TypedRemote.func("PromptPurchase"),
	InventoryEntryAdded = TypedRemote.event("InventoryEntryAdded"),
	InventoryEntryEquipped = TypedRemote.event("InventoryEntryEquipped"),
	InventoryEnteyUnequipped = TypedRemote.event("InventoryEntryUnequipped"),
	InventorySpawn = TypedRemote.event("InventorySpawn"),

	ToggleAutoSpawn = TypedRemote.event("ToggleAutoSpawn"),

	PurchaseUnit = TypedRemote.func("PurchaseUnit"),
	StockChanged = TypedRemote.event("StockChanged"),
	GetStock = TypedRemote.func("GetStock"),
}
