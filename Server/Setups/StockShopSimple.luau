local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataService = require(ReplicatedStorage.Utilities.DataService).server
local Remotes = require(ReplicatedStorage.SharedModules.Remotes)
local BrainrotShop = require(ReplicatedStorage.Configurations.BrainrotShop)
local DataUtil = require("../Systems/DataUtil")

local StockShopSimple = {}

function StockShopSimple.PurchaseUnit(Player: Player, UnitName: string)
    local price = BrainrotShop[UnitName].price
    local playerCash = DataService:get(Player, { "cash" })

    print(price, playerCash)
    if playerCash < price then
        return false
    end

    DataService:update(Player, { "cash" }, function(old)
        return old - price
    end)

    DataUtil.AddDataBrainrotToInventory(Player, {
        Name = UnitName,
        Level = 1,
        Xp = 0,
    })
    
    return true
end

function StockShopSimple.Init()
    print("Initializing StockShopSimple")
    Remotes.PurchaseUnit.OnServerInvoke = function(Player: Player, UnitName: string)
        return StockShopSimple.PurchaseUnit(Player, UnitName)
    end
end

return StockShopSimple