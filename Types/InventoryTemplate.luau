local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataTemplate = require(ReplicatedStorage.SharedModules.DataTemplate)

local InventoryTemplate = {}

export type DataBrainrotInventoryEntry = {
    guid: string,
    dataBrainrot: DataTemplate.DataBrainrot,
}

return InventoryTemplate