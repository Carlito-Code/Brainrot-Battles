local ReplicatedStorage = game:GetService('ReplicatedStorage')
local HttpService = game:GetService('HttpService')
local DataService = require(ReplicatedStorage.Utilities.DataService)
local DataTemplate = require(ReplicatedStorage.SharedModules.DataTemplate)

local DataUtil = {}

DataUtil.WaitForData = function(Player)
	return DataService.server:waitForData(Player)
end

DataUtil.GiveCash = function(Player, Amount)
	DataService.server:update(Player, "cash", function(old)
		return old + Amount
	end)
end

DataUtil.GetCash = function(Player)
	return DataService.server:get(Player, "cash")
end

DataUtil.AddDataBrainrotToInventory = function(Player, Item: DataTemplate.DataBrainrot)
	local guid = HttpService:GenerateGUID(false)

    local newData = DataService.server:update(Player, "inventory", function(sourceMapping: { [string]: DataTemplate.DataBrainrot })
        sourceMapping[guid] = Item

        return sourceMapping
    end)

    return guid, newData[guid]
end

DataUtil.GetDataBrainrotFromSource = function(Player, source: string, guid: string)
	return DataService.server:get(Player, "inventory", guid)
end

DataUtil.RemoveDataBrainrotFromSource = function(Player, source: string, guid: string)
	DataService.server:update(Player, "inventory", function(sourceMapping: { [string]: DataTemplate.DataBrainrot })
		sourceMapping[guid] = nil

		return sourceMapping
	end)
end

DataUtil.MarkDataBrainrotAsEquipped = function(Player, guid: string)
	DataService.server:update(Player, "equipped", function(equippedBrainrots: { [string]: boolean })
		equippedBrainrots[guid] = true

		return equippedBrainrots
	end)
end

return DataUtil