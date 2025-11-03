local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local DataService = require(ReplicatedStorage.Utilities.DataService).server
local StockShopUtil = require(ServerScriptService.Server.Systems.StockShopUtil)
local Remotes = require(ReplicatedStorage.SharedModules.Remotes)
local BrainrotShop = require(ReplicatedStorage.Configurations.BrainrotShop)
local DataUtil = require("../Systems/DataUtil")

local StockShopSimple = {}

function StockShopSimple.Init()
	StockShopUtil:Load()
end

return StockShopSimple
