local MemoryStoreService = game:GetService("MemoryStoreService")
local NotificationService = game:GetService("NotificationService")
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

local Rng = require("./WeightedRNG")
local dataservice = require(ReplicatedStorage.Utilities.DataService)
local Brainrots = require(ReplicatedStorage.Configurations.Brainrots)
local Percentages = require(ReplicatedStorage.Configurations.Rarities)
local Configuration = require(ReplicatedStorage.Configurations.Configuration)
local TimeBetween = 5 * 60

local blocks = {}
local defualt = {}
for brainrotName, _ in Brainrots do
	defualt[brainrotName] = 0
end

local currentStock = {}
local currentTime = nil
local ROLL_AMOUNT = Configuration.stockAmount

function blocks.assignAsMaster(): (boolean?, string?)
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

local function GetListOfRarity(rarity: string): {string}
	local list = {}
	for brainrotName, informations: Brainrots.Brainrot in Brainrots do
		if informations.Rarity == rarity then
			table.insert(list, brainrotName)
		end
	end
	return list
end

function blocks.UpdateStock()
	local memorystore = MemoryStoreService:GetHashMap("securitycfg")
	memorystore:UpdateAsync("roll", function(old)
		local list = table.clone(defualt)
		for i = 1, ROLL_AMOUNT do
			local rarity = Rng.get(Percentages)
			local rarityList = GetListOfRarity(rarity)
			local result = rarityList[math.random(1, #rarityList)]
			list[result] += 1
		end
		currentStock = list
		return list
	end, 3888000)
	memorystore:SetAsync("lastupd", os.time(), 3888000)
	currentTime = os.time()
end

function blocks:PurchaseBlock(plr, BlockName)
	local CurrentPlayerStock = blocks:ReturnStockAndTime(plr)
	local CurrentRebirths = dataservice.server:get(plr, { "Rebirths" })

	if
		CurrentPlayerStock[BlockName]
		and CurrentPlayerStock[BlockName] > 0
		and CurrentRebirths >= tonumber(ReplicatedStorage.Blocks:FindFirstChild(BlockName):GetAttribute("Rebirths"))
	then
		dataservice.server:update(plr, { "cash" }, function(old)
			local amountToRemove = 0
			if old > 100 then
				amountToRemove = 100
				dataservice.server:arrayInsert(plr, { "inventory" }, {
					Type = "Other",
					Name = BlockName,
					Rarity = ReplicatedStorage.Blocks[BlockName]:GetAttribute("Rarity"),
				})

				dataservice.server:update(plr, { "Stock", BlockName }, function(old)
					return old - 1
				end)
			end
			return old - amountToRemove
		end)
	end
end

function blocks.GetStock()
	local memorystore = MemoryStoreService:GetHashMap("securitycfg")
	currentStock, currentTime = memorystore:GetAsync("roll"), memorystore:GetAsync("lastupd")
end

function blocks:ReturnStockAndTime(plr)
	return dataservice.server:get(plr, { "Stock" }), currentTime
end

function blocks:Load()
	local function playerAdded(plr)
		dataservice.server:waitForData(plr)

		if dataservice.server:get(plr, { "LastStockUpdate" }) == currentTime then
			return
		end

		dataservice.server:set(plr, { "LastStockUpdate" }, currentTime)
		dataservice.server:set(plr, { "Stock" }, currentStock)
	end
	
	-- Player Initialization
	Players.PlayerAdded:Connect(playerAdded)
	for _, v in pairs(Players:GetPlayers()) do
		playerAdded(v)
	end

	if blocks.assignAsMaster() then
		blocks.UpdateStock()
	else
		blocks.GetStock()
	end

	task.spawn(function()
		while task.wait(1) do
			if string.len(os.time() / TimeBetween) == string.len(os.time() // TimeBetween) then
				require(ReplicatedStorage.NotificationHandler)(nil, "Blocks have been restocked!", true)
				if blocks.assignAsMaster() then
					blocks.UpdateStock()
				else
					task.delay(0.5, function()
						blocks.GetStock()
					end)
				end
			end
		end
	end)
end

return blocks
