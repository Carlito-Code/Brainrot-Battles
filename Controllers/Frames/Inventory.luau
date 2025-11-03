local _Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _TweenService = game:GetService("TweenService")
local _Remotes = require(ReplicatedStorage.SharedModules.Remotes)
local DataService = require(ReplicatedStorage.Utilities.DataService).client
local InventoryTypes = require(ReplicatedStorage.Types.InventoryTemplate)
local Bottom = require(script.Parent.Parent.Setups.GuiController.Bottom)
local ViewportHandler = require(script.Parent.Parent.Setups.ViewportHandler)
local Brainrots = require(ReplicatedStorage.Configurations.Brainrots)

local Inventory = {}

local function setupConnections(frame: Frame)
	-- Initial read for UI bootstrap
	-- local items = DataService:get({ "inventory" }) or {}

	for guid, dataBrainrot in DataService:get({ "inventory" }) do
		Inventory.AddSlot(frame, {
			guid = guid,
			dataBrainrot = dataBrainrot,
		})
	end

	DataService:getChangedSignal({ "inventory" }):Connect(function(newValue)
		for guid, dataBrainrot in newValue do
			if not frame.Container:FindFirstChild(guid) then
				Inventory.AddSlot(frame, {
					guid = guid,
					dataBrainrot = dataBrainrot,
				})
			end
		end
	end)

	DataService:getChangedSignal({ "equipped" }):Connect(function()
		frame.Background.Equipped.Text = "Equipped: " .. Inventory.GetNumberOfEquippedBrainrots() .. "/4"
	end)

	_Remotes.InventoryEntryAdded.OnClientEvent:Connect(function(entry: InventoryTypes.DataBrainrotInventoryEntry)
		Inventory.AddSlot(frame, entry)
	end)

	-- test
	_Remotes.InventoryEntryAdded:FireServer()
end

function Inventory.AddSlot(frame: Frame, entry: InventoryTypes.DataBrainrotInventoryEntry)
	local slot = frame.Container.SlotTemplate:Clone()

	slot.Lvl.Text = "Lvl " .. entry.dataBrainrot.Level
	slot.NameLabel.Text = Brainrots[entry.dataBrainrot.Name].DisplayName

	ViewportHandler.ProcessBrainrotViewport(slot.ViewportFrame, entry.dataBrainrot.Name)

	slot.Background.MouseButton1Click:Connect(function()
		local equippedBrainrot = DataService:get({ "equipped", entry.guid })

		if equippedBrainrot then
			Inventory.UnequipBrainrot(entry.guid)
		else
			Inventory.EquipBrainrot(entry.guid)
		end
	end)

	slot.Name = entry.guid
	slot.Parent = frame.Container
	slot.Visible = true
end

function Inventory.EquipBrainrot(guid: string)
	local player = _Players.LocalPlayer
	local bottomContainer = player.PlayerGui.MainGui.Bottom.Slots
	local slot = Bottom.GetNextEmptySlot(bottomContainer)

	local oldGuid = slot:GetAttribute("BrainrotGUID")

	Bottom.ProcessEquippedBrainrot(guid)

	_Remotes.InventoryEntryEquipped:FireServer(guid, oldGuid)
end

function Inventory.UnequipBrainrot(guid: string)
	local player = _Players.LocalPlayer
	local bottomContainer = player.PlayerGui.MainGui.Bottom
	local slot

	for _, equippedSlot in bottomContainer.Slots:GetChildren() do
		if equippedSlot:GetAttribute("BrainrotGUID") == guid then
			slot = equippedSlot
			break
		end
	end

	if not slot then
		return
	end

	local inventorySlot = player.PlayerGui.MainGui.Frames.Inventory.Container:FindFirstChild(guid)
	inventorySlot.Checkmark.Visible = false

	slot.Level.Text = ""
	slot.EnergyAmount.Text = ""

	slot:SetAttribute("BrainrotGUID", "")

	ViewportHandler.ProcessBrainrotViewport(slot.ViewportFrame, "")

	_Remotes.InventoryEnteyUnequipped:FireServer(guid)
end

-- this should be in a shared module or something but I can't be bothered rn
function Inventory.GetNumberOfEquippedBrainrots(): number
	local equippedBrainrots = DataService:get({ "equipped" })
	local equippedCount = 0

	for guid, _ in equippedBrainrots do
		equippedCount += 1
	end

	return equippedCount
end

function Inventory.Init(FramesContainer: Folder)
	local Frame = FramesContainer:FindFirstChild("Inventory")
	if not Frame then
		return
	end

	Frame.Background.Equipped.Text = "Equipped: " .. Inventory.GetNumberOfEquippedBrainrots() .. "/4"

	setupConnections(Frame)
end

function Inventory.Update(Frame: Frame)
	local items = DataService:get({ "inventory" }) or {}
	-- Frame:SetAttribute("InventoryCount", #items)
	-- TODO: refresh UI from items
end

return Inventory
