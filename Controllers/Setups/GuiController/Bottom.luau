local Remotes = require(game.ReplicatedStorage.SharedModules.Remotes)
local Configuration = require(game.ReplicatedStorage.Configurations.Configuration)
local DataService = require(game.ReplicatedStorage.Utilities.DataService).client

local Bottom = {}

function Bottom.Init(bottomContainer: Frame)
	for _, slot in bottomContainer.Slots:GetChildren() do
		if slot.Name:find("Slot_") then
			slot.MouseButton1Click:Connect(function()
				local slotGuid = slot:GetAttribute("BrainrotGUID")

				if slotGuid and slotGuid ~= "" then
					Remotes.SpawnEntity:FireServer(slotGuid)
				end
			end)
		end
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
