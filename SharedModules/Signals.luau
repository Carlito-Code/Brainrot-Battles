-- DATA CONTAINER --
local replicatedStorage = game:GetService("ReplicatedStorage")
local signal = require(replicatedStorage.Utilities.Signal)

local Data = {
	CLAIMED_PLOT = signal.new(),
	
	PLOT_RELEASED = signal.new(),
	
	TREE_ADDED = signal.new()
}

export type Data = typeof(Data)

return Data