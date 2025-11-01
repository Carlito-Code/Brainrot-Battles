local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local DataService = require(ReplicatedStorage.Utilities.DataService)
local Remotes = require(ReplicatedStorage.SharedModules.Remotes)
local InventoryTypes = require(ReplicatedStorage.Types.InventoryTemplate)
local Configuration = require(ReplicatedStorage.Configurations.Configuration)

local DataUtil = require("../Systems/DataUtil")

local InventoryService = {}

function InventoryService.GetNumberOfEquippedBrainrots(player: Player): number
	local equippedBrainrots = DataService.server:get(player, "equipped")
	local equippedCount = 0

	for guid, _ in equippedBrainrots do
		equippedCount += 1
	end

	return equippedCount
end

function InventoryService.Init()
	Remotes.InventoryEntryAdded.OnServerEvent:Connect(function(player)
		local guid, dataBrainrot = DataUtil.AddDataBrainrotToInventory(player, {
			Name = "67",
			Level = 3,
			Xp = 0,
		})

		local entry: InventoryTypes.DataBrainrotInventoryEntry = {
			guid = guid,
			dataBrainrot = dataBrainrot,
		}

		Remotes.InventoryEntryAdded:FireClient(player, entry)
	end)

	Remotes.InventoryEntryEquipped.OnServerEvent:Connect(function(player, guid, oldGuid)
		local newBrainrot = DataUtil.GetDataBrainrotFromSource(player, "inventory", guid)
		if not newBrainrot then
			return
		end

		if oldGuid and oldGuid ~= "" then
			local oldDataBrainrot = DataUtil.GetDataBrainrotFromSource(player, "equipped", oldGuid)
			if not oldDataBrainrot then
				return
			end

			DataUtil.RemoveDataBrainrotFromSource(player, "equipped", oldGuid)
		end

		local numberOfEquippedBrainrots = InventoryService.GetNumberOfEquippedBrainrots(player)

		if numberOfEquippedBrainrots >= Configuration.equippableUnitsMax then
			-- We should only reach this point if the player is attempting to exploit the oldGuid property

			return
		end

		DataUtil.MarkDataBrainrotAsEquipped(player, guid)

		-- Remotes.InventoryEntryEquipped:FireClient(player, dataBrainrot)
	end)

	Remotes.InventoryEnteyUnequipped.OnServerEvent:Connect(function(player, guid)
		local equippedBrainrot = DataUtil.GetDataBrainrotFromSource(player, "equipped", guid)
		if not equippedBrainrot then
			return
		end

		DataUtil.RemoveDataBrainrotFromSource(player, "equipped", guid)
	end)

	Remotes.InventorySpawn.OnServerEvent:Connect(function(player, guid, oldGuid)
		local dataBrainrot = DataUtil.GetDataBrainrotFromSource(player, "inventory", guid)
		if not dataBrainrot then
			return
		end
	end)
end

return InventoryService
