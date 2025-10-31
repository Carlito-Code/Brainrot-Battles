local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Http = game:GetService("HttpService")

-- Configurations
local Waves = require(ReplicatedStorage.Configurations.Waves)
local Brainrots = require(ReplicatedStorage.Configurations.Brainrots)

local _LevelCapFunction = require(ReplicatedStorage.SharedModules.LevelCapFunction)
local _MultiplierFunction = require(ReplicatedStorage.SharedModules.MultiplierFunction)
local _WaveMultiplierFunction = require(ReplicatedStorage.SharedModules.WaveMultiplierFunction)

local Entity = require(ServerScriptService.Server.Classes.Entity)
local _Signals = require(ReplicatedStorage.SharedModules.Signals)
local DataService = require(ReplicatedStorage.Utilities.DataService)
local BasesService = require(script.Parent.BasesService)
local InventoryService = require(script.Parent.InventoryService)

local PlotService = require("./PlotService")

local WaveHandler = {}

type PlayerRuntime = {
	energy: number,
	currentWave: number,
	regenThread: thread?,
	bases: { defender: any, enemy: any },
}

local PlayerState: { [Player]: PlayerRuntime } = {}

local _IsInWave = {}

local function GetWaveInformations(waveNumber)
	local ChoosenInformations = nil
	local Percentage = nil
	for name, v in pairs(Waves) do
		local start, endWave = table.unpack(string.split(name, "-"))
		if waveNumber < tonumber(endWave) and waveNumber >= tonumber(start) then
			ChoosenInformations = v
			Percentage = start / tonumber(endWave)
		end
	end
	return ChoosenInformations, Percentage
end

function WaveHandler:SpawnWave(player, waveNumber)
	local WaveInformations, Percentage = GetWaveInformations(waveNumber)
	Entity.ClearEnemyEntities(player)

	local PlayerPlot = PlotService.getPlot(player)
	local EnemySpawnLine = PlayerPlot:FindFirstChild("EnemySpawnLine")

	local rng = Random.new()
	local RandomPosition = EnemySpawnLine.Position
		+ Vector3.new(
			rng:NextNumber(-EnemySpawnLine.Size.X / 2, EnemySpawnLine.Size.X / 2),
			0,
			EnemySpawnLine.Size.Z / 2 + 1
		)

	for entityName, informations in pairs(WaveInformations) do
		local Amount = math.clamp(math.round(informations.Max * Percentage), informations.Min, informations.Max)
		for i = 1, Amount do
			local EntityClass = Entity.new(Http:GenerateGUID(), entityName, player, true, waveNumber)
			EntityClass:Spawn(CFrame.new(RandomPosition))
		end
	end
end

function WaveHandler.SpawnDefender(player, guid)
	-- Validate entity name exists in Brainrots configuration
	if not DataService.server:get(player, {"equipped", guid}) then
		return false, "Brainrot not equipped"
	end

	local brainrotData = DataService.server:get(player, {"inventory", guid})

	if brainrotData then
		local entityName = brainrotData.Name
		if not Brainrots[entityName] then
			warn("Invalid entity name: " .. tostring(entityName))
			return false, "Invalid entity name"
		end
	
		-- Runtime energy check
		local state = PlayerState[player]
		if not state then
			return false, "Wave system not started"
		end
		local cost = Brainrots[entityName].EnergyCost or 0
		if state.energy < cost then
			return false, "Not enough energy"
		end
	
		-- Unit limit check
		local maxUnits = DataService.server:get(player, { "maxUnitsOnField" })
		local defenders = Entity.GetEntitiesOfType(player, false)
		if #defenders >= maxUnits then
			return false, "Maximum defenders reached"
		end
	
		-- Consume runtime energy
		state.energy -= cost
	
		-- Get spawn position from HomeSpawnLine
		local PlayerPlot = PlotService.getPlot(player)
		local HomeSpawnLine = PlayerPlot:FindFirstChild("HomeSpawnLine")
		if not HomeSpawnLine then
			warn("Could not find HomeSpawnLine in plot for player " .. player.Name)
			return false, "No spawn line found"
		end
	
		local rng = Random.new()
		local RandomPosition = HomeSpawnLine.Position
			+ Vector3.new(
				rng:NextNumber(-HomeSpawnLine.Size.X / 2, HomeSpawnLine.Size.X / 2),
				0,
				HomeSpawnLine.Size.Z / 2 + 1
			)
	
		-- Create the actual defender entity
		local defenderEntity = Entity.new(guid, entityName, player, false, false)
	
		-- Spawn the defender at the calculated position
		local spawnCf = CFrame.new(RandomPosition)
		defenderEntity:Spawn(spawnCf)
	
		print("Successfully spawned defender " .. entityName .. " for player " .. player.Name)
		return true, "Defender spawned successfully"
	end
end

function WaveHandler.StartWaveSystem(player: Player)
	local Configuration = require(ReplicatedStorage.Configurations.Configuration)
	local defenderBase, enemyBase = BasesService.getBases(player)
	local state: PlayerRuntime = {
		energy = Configuration.maxEnergy,
		currentWave = 1,
		regenThread = nil,
		bases = { defender = defenderBase, enemy = enemyBase },
	}
	PlayerState[player] = state

	-- Hooks for base destruction
	if defenderBase then
		defenderBase.onDestroyed:Connect(function()
			-- Defender base destroyed: finish round
			BasesService.regenerateBases(player, 1)
			WaveHandler.StopWaveSystem(player)
			if state.regenThread then
				task.cancel(state.regenThread)
			end
			PlayerState[player] = nil
		end)
	end

	if enemyBase then
		enemyBase.onDestroyed:Connect(function()
			-- Enemy base destroyed: advance to next wave and regen defenders
			state.currentWave += 1
			state.energy = Configuration.maxEnergy

			-- Regenerate bases for the new wave
			BasesService.regenerateBases(player, state.currentWave)

			-- Regenerate all current defenders' health
			for _, def in Entity.GetEntitiesOfType(player, false) do
				def.health = def:GetMaxedHealth()
			end

			-- Spawn next wave
			WaveHandler:SpawnWave(player, state.currentWave)
		end)
	end

	-- Start energy regen (runtime only)
	state.regenThread = task.spawn(function()
		while PlayerState[player] == state do
			state.energy = math.min(Configuration.maxEnergy, state.energy + Configuration.energyRegenRate)
			task.wait(Configuration.energyRegenInterval)
		end
	end)

	-- Regenerate bases for the initial wave
	BasesService.regenerateBases(player, state.currentWave)

	-- Spawn initial wave
	WaveHandler:SpawnWave(player, state.currentWave)
end

function WaveHandler.StopWaveSystem(player: Player)
	local state = PlayerState[player]
	if not state then
		return false, "Wave system not running"
	end

	-- Stop energy regeneration
	if state.regenThread then
		task.cancel(state.regenThread)
	end

	-- Clear all entities for this player
	Entity.ClearAllEntities(player)

	-- Remove player state
	PlayerState[player] = nil

	print("Stopped wave system for player " .. player.Name)
	return true, "Wave system stopped"
end

function WaveHandler.Init()
	-- Connect the SpawnEntity remote event
	local Remotes = require(ReplicatedStorage.SharedModules.Remotes)

	Remotes.SpawnEntity.OnServerEvent:Connect(function(player, guid)
		-- local success, message = WaveHandler.SpawnDefender(player, guid)
		WaveHandler.SpawnDefender(player, guid)
		-- You could send feedback to the client here if needed
		-- if not success then
		-- 	warn(message)
		-- 	-- warn("Failed to spawn defender for " .. player.Name .. ": " .. message)
		-- end
	end)

	-- Connect StartWaveSystem remote event
	Remotes.StartWaveSystem.OnServerEvent:Connect(function(player)
		-- Check if player already has a wave system running
		if PlayerState[player] then
			warn("Player " .. player.Name .. " already has a wave system running")
			return
		end

		-- Check if player has a plot
		local plot = PlotService.getPlot(player)
		if not plot then
			warn("Player " .. player.Name .. " does not have a plot")
			return
		end

		-- CHeck if player has a brainrot equipped
		local numEquippedBrainrots = InventoryService.GetNumberOfEquippedBrainrots(player)

		if numEquippedBrainrots == 0 then
			warn("Player " .. player.Name .. " does not have any brainrots equipped")
			return
		end

		-- Start the wave system
		WaveHandler.StartWaveSystem(player)
		print("Started wave system for player " .. player.Name)
	end)

	-- Connect StopWaveSystem remote event
	Remotes.StopWaveSystem.OnServerEvent:Connect(function(player)
		local success, message = WaveHandler.StopWaveSystem(player)
		if not success then
			warn("Failed to stop wave system for " .. player.Name .. ": " .. message)
		end
	end)

	-- Clean up when players leave
	local Players = game:GetService("Players")

	Players.PlayerAdded:Connect(function(player)
		-- task.wait(7)
		-- WaveHandler.StartWaveSystem(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		if PlayerState[player] then
			WaveHandler.StopWaveSystem(player)
		end
	end)
end

return WaveHandler
