local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local DataService = require(ReplicatedStorage.Utilities.DataService)
local PlotService = require("./PlotService")
local Signals = require(ReplicatedStorage.SharedModules.Signals)
local Brainrots = require(ReplicatedStorage.Configurations.Brainrots)

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
		if not v.directory then
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
	local dataDirectory = { "inventory", BrainrotId }
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
		print(informations, "is the informations for the brainrot")
		local brainrot = BrainrotAssets:FindFirstChild(informations.Name)
		print(informations.Name, "is the brainrot model to load for the stand")
		if brainrot then
			local clone: Model = brainrot:Clone()
			clone.Parent = Stand
			clone:PivotTo(Stand.CFrame * CFrame.new(0, clone:GetExtentsSize().Y / 2 + 0.5, 0))

			local brainrotInfo = Brainrots[informations.Name]

			local nameLabelBillboard = ReplicatedStorage.Assets.NameLabelBillboard:Clone()

			nameLabelBillboard.UnitName.Text = brainrotInfo.DisplayName
			nameLabelBillboard.Rarity.Text = brainrotInfo.Rarity
			nameLabelBillboard.Level.Text = "Lvl " .. informations.Level

			local rarityGradient = ReplicatedStorage.Assets.RarityGradients[brainrotInfo.Rarity]:Clone()
			rarityGradient.Parent = nameLabelBillboard.Rarity

			nameLabelBillboard.Adornee = clone.HumanoidRootPart

			local modelSize = clone:GetExtentsSize()
			nameLabelBillboard.ExtentsOffset = Vector3.new(0, modelSize.Y / 2 + 0.5, 0)
			nameLabelBillboard.Parent = clone.HumanoidRootPart

			Stand:SetAttribute("BrainrotGUID", BrainrotId)
		else
			warn("Brainrot model could not be found")
		end

		DataService.server:getChangedSignal(Player, dataDirectory):Connect(function()
			PlayerStands[Player][FirstAvilable] = {}
		end)
	end
end

function StandsService.RemoveStand(Player, Stand)
	Stand:ClearAllChildren()
	Stand:SetAttribute("BrainrotGUID", nil)

	PlayerStands[Player][tonumber(Stand.Name)] = {}
end

-- don't use this function
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
		for id, _ in currentlyEquipped do
			StandsService.LoadStand(id, Player)
		end

		DataService.server:getChangedSignal(Player, "equipped"):Connect(function(newlyEquippedBrainrots)
			local PlayerPlot = PlotService.getPlot(Player)
			local Container = PlayerPlot:FindFirstChild("BrainrotEquipSpawns")

			for _, Stand in Container:GetChildren() do
				local brainrotGUID = Stand:GetAttribute("BrainrotGUID")
				if not newlyEquippedBrainrots[brainrotGUID] then
					StandsService.RemoveStand(Player, Stand)
				end
			end

			for guid, _ in newlyEquippedBrainrots do
				local found = false

				for _, Stand in Container:GetChildren() do
					local standGUID = Stand:GetAttribute("BrainrotGUID")

					if standGUID == guid then
						found = true
						break
					end
				end

				if not found then
					StandsService.LoadStand(guid, Player)
				end
			end
		end)
	end)
end

return StandsService
