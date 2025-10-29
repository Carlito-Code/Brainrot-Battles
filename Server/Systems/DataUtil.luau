local ReplicatedStorage = game:GetService('ReplicatedStorage')
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

return DataUtil