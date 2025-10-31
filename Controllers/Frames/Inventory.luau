local _Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _TweenService = game:GetService("TweenService")
local _Remotes = require(ReplicatedStorage.SharedModules.Remotes)
local DataService = require(ReplicatedStorage.Utilities.DataService).client
local BrainrotConfigurations = require(ReplicatedStorage.Configurations.Brainrots)
local InventoryTypes = require(ReplicatedStorage.Types.InventoryTemplate)
local Inventory = {}

local NextEquippableSlot = 1

local function setupConnections(frame: Frame)
	-- Initial read for UI bootstrap
	-- local items = DataService:get({ "inventory" }) or {}

	_Remotes.InventoryEntryAdded.OnClientEvent:Connect(function(entry: InventoryTypes.DataBrainrotInventoryEntry)
		Inventory.AddSlot(frame, entry)
	end)

	-- test
	_Remotes.InventoryEntryAdded:FireServer()
end

function Inventory.AddSlot(frame: Frame, entry: InventoryTypes.DataBrainrotInventoryEntry)
	local slot = frame.Container.SlotTemplate:Clone()

	slot.Lvl.Text = entry.dataBrainrot.Level
	slot.NameLabel.Text = entry.dataBrainrot.Name

	slot.Background.MouseButton1Click:Connect(function()
		Inventory.EquipBrainrot(entry.guid)
	end)

	slot.Name = entry.guid
	slot.Parent = frame.Container
	slot.Visible = true
end

function Inventory.EquipBrainrot(guid: string)
	local player = _Players.LocalPlayer
	local bottomContainer = player.PlayerGui.MainGui.Bottom
	local slot = bottomContainer:FindFirstChild("Slot_" .. NextEquippableSlot)

	local oldGuid = slot:GetAttribute("BrainrotGUID")

	local newlyEquippedBrainrot = DataService:get({ "inventory", guid }) or DataService:get({ "equipped", guid })

	print(newlyEquippedBrainrot, guid)

	slot.Level.Text = "Level " .. newlyEquippedBrainrot.Level
	slot.EnergyAmount.Text = BrainrotConfigurations[newlyEquippedBrainrot.Name].EnergyCost

	slot:SetAttribute("BrainrotGUID", guid)

	_Remotes.InventoryEntryEquipped:FireServer(guid, oldGuid)
end

function Inventory.Init(FramesContainer: Folder)
	local Frame = FramesContainer:FindFirstChild("Inventory")
	if not Frame then
		return
	end

	setupConnections(Frame)
end

function Inventory.Update(Frame: Frame)
	local items = DataService:get({ "inventory" }) or {}
	-- Frame:SetAttribute("InventoryCount", #items)
	-- TODO: refresh UI from items
end

return Inventory
