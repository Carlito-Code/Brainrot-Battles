local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local DataService = require(ReplicatedStorage.Utilities.DataService)
local PlotService = require("./PlotService")
local Signals = require(ReplicatedStorage.SharedModules.Signals)

local BrainrotAssets = ReplicatedStorage.Assets.Brainrots

local StandsService = {}
local PlayerStands = {}
local TemplateAdd = {
	[1] = {},
	[2] = {},
	[3] = {},
	[4] = {},
}

local function FindFirstAvailableIndex(Player)
	for i, v in pairs(PlayerStands[Player]) do
		print(i)
		if #v == 0 then
			print("Found")
			return i
		end
	end
end

function StandsService.LoadStand(BrainrotId, Player)
	if not PlayerStands[Player] then
		PlayerStands[Player] = table.clone(TemplateAdd)
	end

	local FirstAvilable = FindFirstAvailableIndex(Player)
	local dataDirectory = { "equipped", BrainrotId }
	local informations = DataService.server:get(Player, dataDirectory)
	if not informations then
		return
	end

	PlayerStands[Player][tonumber(FirstAvilable)] = {
		directory = dataDirectory,
		informations = informations,
	}

	local PlayerPlot = PlotService.getPlot(Player)
	local Container = PlayerPlot:FindFirstChild("BrainrotEquipSpawns")
	if Container then
		local Stand = Container:FindFirstChild(FirstAvilable)
		local brainrot = BrainrotAssets:FindFirstChild(informations.Name)
		print(informations.Name, "is the brainrot model to load for the stand")
		if brainrot then
			local clone: Model = brainrot:Clone()
			clone.Parent = Stand
			clone:PivotTo(Stand.CFrame * CFrame.new(0, clone:GetExtentsSize().Y / 2 + 0.5, 0))
		else
			warn("Brainrot model could not be found")
		end

		DataService.server:getChangedSignal(Player, dataDirectory):Connect(function()
			PlayerStands[Player][FirstAvilable] = {}
		end)
	end
end

function StandsService.EquipBrainrot(Player, BrainrotId)
	DataService.server:update(Player, "inventory", function(old)
		local cloned = table.clone(old)
		local informations = cloned[BrainrotId]
		DataService.server:set(Player, { "quipped", BrainrotId }, informations)
		cloned[BrainrotId] = nil
		return cloned
	end)
	StandsService.LoadStand(BrainrotId, Player)
end

function StandsService.Init()
	Signals.CLAIMED_PLOT:Connect(function(Player, Plot)
		DataService.server:waitForData(Player)
		local currentlyEquipped = DataService.server:get(Player, "equipped")
		for id, informations in currentlyEquipped do
			StandsService.LoadStand(id, Player)
		end
	end)
end

return StandsService
