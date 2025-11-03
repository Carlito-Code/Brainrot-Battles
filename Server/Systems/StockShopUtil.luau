local HttpService = game:GetService("HttpService")
local MemoryStoreService = game:GetService("MemoryStoreService")
local NotificationService = game:GetService("NotificationService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local DataUtil = require(script.Parent.DataUtil)
local BrainrotShop = require(ReplicatedStorage.Configurations.BrainrotShop)
local Rng = require("./WeightedRNG")
local dataservice = require(ReplicatedStorage.Utilities.DataService)
local Brainrots = require(ReplicatedStorage.Configurations.Brainrots)
local Percentages = require(ReplicatedStorage.Configurations.Rarities)
local Configuration = require(ReplicatedStorage.Configurations.Configuration)
local Remotes = require(ReplicatedStorage.SharedModules.Remotes)
local TimeBetween = 5 * 60

local StockUtil = {}
local defualt = {}
for brainrotName, _ in Brainrots do
	defualt[brainrotName] = 0
end

local currentStock = {}
local currentTime = nil
local ROLL_AMOUNT = Configuration.stockAmount

function StockUtil.assignAsMaster(): (boolean?, string?)
	local id = game.JobId

	local memorystore = MemoryStoreService:GetHashMap("securitycfg")
	local ok, e = pcall(function()
		return memorystore:UpdateAsync("masterserverid", function(old)
			if old == nil or old == "" then
				return id
			else
				return old
			end
		end, 3888000)
	end)

	if ok == true then
		local isMaster = id == e
		if isMaster == true then
			game:BindToClose(function()
				memorystore:RemoveAsync("masterserverid")
			end)
		end

		return isMaster, e
	else
		warn(`An exception has occurred while running security.assignAsMaster. \n{e}`)
		return
	end
end

local function GetListOfRarity(rarity: string): { string }
	local list = {}
	for brainrotName, informations: Brainrots.Brainrot in Brainrots do
		if informations.Rarity == rarity then
			table.insert(list, brainrotName)
		end
	end
	return list
end

function StockUtil.UpdateStock()
	local memorystore = MemoryStoreService:GetHashMap("securitycfg")
	memorystore:UpdateAsync("roll", function(old)
		local list = table.clone(defualt)
		for i = 1, ROLL_AMOUNT do
			local rarity = Rng.get(Percentages, 1)
			local rarityList = GetListOfRarity(rarity)
			local result = rarityList[math.random(1, #rarityList)]
			list[result] += 1
		end
		currentStock = list
		return list
	end, 3888000)
	local timeVariable = os.time()
	memorystore:SetAsync("lastupd", timeVariable, 3888000)
	currentTime = timeVariable
end

function StockUtil:PurchaseBrainrot(plr, BrainrotName)
	local CurrentPlayerStock = StockUtil:ReturnStockAndTime(plr)
	if CurrentPlayerStock[BrainrotName] and CurrentPlayerStock[BrainrotName] > 0 then
		local price = BrainrotShop[BrainrotName].price
		dataservice.server:update(plr, { "cash" }, function(old)
			local amountToRemove = 0
			if old >= price then
				amountToRemove = price
				DataUtil.AddDataBrainrotToInventory(plr, {
					Name = BrainrotName,
					Level = 0,
					Xp = 0,
				})

				dataservice.server:update(plr, { "Stock", BrainrotName }, function(old)
					return old - 1
				end)
			end
			return old - amountToRemove
		end)
		Remotes.StockChanged:FireClient(plr, StockUtil:ReturnStockAndTime(plr))
	end
end

function StockUtil.GetStock()
	local memorystore = MemoryStoreService:GetHashMap("securitycfg")
	currentStock, currentTime = memorystore:GetAsync("roll"), memorystore:GetAsync("lastupd")

	return currentStock, currentTime
end

function StockUtil:ReturnStockAndTime(plr)
	return dataservice.server:get(plr, { "Stock" }), currentTime
end

function StockUtil:Load()
	local function playerAdded(plr)
		dataservice.server:waitForData(plr)

		if dataservice.server:get(plr, { "LastStockUpdate" }) == currentTime then
			return
		end

		dataservice.server:set(plr, { "LastStockUpdate" }, currentTime)
		dataservice.server:set(plr, { "Stock" }, currentStock)
	end

	Remotes.GetStock.OnServerInvoke = function(plr)
		return StockUtil:ReturnStockAndTime(plr)
	end

	Remotes.PurchaseUnit.OnServerInvoke = function(Plr, UnitName)
		return StockUtil:PurchaseBrainrot(Plr, UnitName)
	end

	-- Player Initialization
	Players.PlayerAdded:Connect(playerAdded)
	for _, v in pairs(Players:GetPlayers()) do
		playerAdded(v)
	end

	if StockUtil.assignAsMaster() then
		StockUtil.UpdateStock()
	else
		StockUtil.GetStock()
	end

	task.spawn(function()
		while task.wait(1) do
			if string.len(os.time() / TimeBetween) == string.len(os.time() // TimeBetween) then
				if StockUtil.assignAsMaster() then
					StockUtil.UpdateStock()
				else
					task.delay(0.5, function()
						StockUtil.GetStock()
					end)
				end

				task.delay(0.5, function()
					for _, v in Players:GetPlayers() do
						playerAdded(v)
					end
					Remotes.StockChanged:FireAllClients(StockUtil.GetStock())
				end)
			end
		end
	end)
end

return StockUtil
