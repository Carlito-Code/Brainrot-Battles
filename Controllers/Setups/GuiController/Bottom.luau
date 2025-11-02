local Remotes = require(game.ReplicatedStorage.SharedModules.Remotes)
local Configuration = require(game.ReplicatedStorage.Configurations.Configuration)
local DataService = require(game.ReplicatedStorage.Utilities.DataService).client
local BrainrotConfigurations = require(game.ReplicatedStorage.Configurations.Brainrots)
local ViewportHandler = require(script.Parent.Parent.ViewportHandler)

local Bottom = {
	NextEquippableSlot = 1,
}

local spawnDebounceTime = 1
local spawnDebounce = false

function Bottom.ProcessEquippedBrainrot(guid: string)
	local newlyEquippedBrainrot = DataService:get({ "inventory", guid })
	
	local player = game.Players.LocalPlayer
	local bottomContainer = player.PlayerGui.MainGui.Bottom.Slots
	local slot = bottomContainer:FindFirstChild("Slot_" .. Bottom.NextEquippableSlot)

	slot.Level.Text = "Level " .. newlyEquippedBrainrot.Level
	slot.EnergyAmount.Text = BrainrotConfigurations[newlyEquippedBrainrot.Name].EnergyCost

	slot:SetAttribute("BrainrotGUID", guid)

	ViewportHandler.ProcessBrainrotViewport(slot.ViewportFrame, newlyEquippedBrainrot.Name)

	Bottom.NextEquippableSlot += 1

	if Bottom.NextEquippableSlot > 4 then
		Bottom.NextEquippableSlot = 1
	end

	-- Handling this logic here since this function is called when loading the equipped brainrots
	local inventorySlot = player.PlayerGui.MainGui.Frames.Inventory.Container:FindFirstChild(guid)
	if inventorySlot then
		inventorySlot.Checkmark.Visible = true
	end
end

function Bottom.Init(bottomContainer: Frame)
	for _, slot in bottomContainer.Slots:GetChildren() do
		if slot.Name:find("Slot_") then
			slot.MouseButton1Click:Connect(function()
				local slotGuid = slot:GetAttribute("BrainrotGUID")

				if slotGuid and slotGuid ~= "" then
					if not spawnDebounce then
						spawnDebounce = true

						Remotes.SpawnEntity:FireServer(slotGuid)

						task.wait(spawnDebounceTime)
						spawnDebounce = false
					end
				end
			end)
		end
	end

	print("Processing equipped brainrots")
	for guid, _ in DataService:get({ "equipped" }) do
		Bottom.ProcessEquippedBrainrot(guid)
	end
	
	task.spawn(function()
		Bottom.Update(bottomContainer)
	end)
end

function Bottom.Update(bottomContainer: Frame)
	local player = game.Players.LocalPlayer

	while true do
		task.wait(0.25)
		
		if player:GetAttribute("waveInSession") then
			local energyContainer = bottomContainer.EnergySlot
			local defenderCountContainer = bottomContainer.DefenderSlot

			print(player:GetAttribute("defenderCount"))
			energyContainer.EnergyAmount.Text = player:GetAttribute("energy") .. "/" .. Configuration.maxEnergy
			defenderCountContainer.DefenderAmount.Text = player:GetAttribute("defenderCount") .. "/" .. DataService:get({ "maxUnitsOnField" })
		end
	end
end

return Bottom
