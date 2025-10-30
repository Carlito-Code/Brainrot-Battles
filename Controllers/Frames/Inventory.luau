local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Remotes = require(ReplicatedStorage.SharedModules.Remotes)
local Inventory = {}

function Inventory.Init(FramesContainer: Folder)
	local Frame = FramesContainer:FindFirstChild("Inventory")
	if Frame then
		
	end
end

return Inventory