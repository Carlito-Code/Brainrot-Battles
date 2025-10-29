local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Configurations
local Brainrots = require(ReplicatedStorage.Configurations.Brainrots)

-- Utilities
local DataService = require(ReplicatedStorage.Utilities.DataService)
local DataTemplate = require(ReplicatedStorage.SharedModules.DataTemplate)
local Signal = require(ReplicatedStorage.Utilities.Signal)
local _CircleUtilities = require(ReplicatedStorage.SharedModules.CircleUtilities)
local BasesService = require(ServerScriptService.Server.Setups.BasesService)

--Assets
local BrainrotFolder = ReplicatedStorage.Assets.Brainrots

-- Functions
local LevelCapFunction = require(ReplicatedStorage.SharedModules.LevelCapFunction)
local MultiplierFunction = require(ReplicatedStorage.SharedModules.MultiplierFunction)
local WaveMultiplierFunction = require(ReplicatedStorage.SharedModules.WaveMultiplierFunction)

local EntityClass = {}
EntityClass.__index = EntityClass

local DistanceToTarget = 5

local Entities = {}

export type BasicClass = {
	id: string,
	health: number,
	multiplier: number,
	name: string,
	isEnemy: boolean,
	model: Model,
	owner: Player,
	target: class,
	currentWave: number,
	diedSignal: Signal.Signal<()>,
	movingCycle: thread?,
	alive: boolean,
	checkingConnection: thread?,
}
export type class = typeof(setmetatable({} :: BasicClass, EntityClass))

function EntityClass.GetTargetsOfId(Player, Id)
	local t = Entities[Player]
	local count = 0
	if t then
		for _, informations: class in t do
			if informations.target and informations.target.id == Id then
				count += 1
			end
		end
	end
	return count
end

function EntityClass.GetEntitiesOfType(Player, Enemy)
	local t = Entities[Player]
	local entities = {}
	for _, informations in t do
		if Enemy then
			if informations.isEnemy then
				table.insert(entities, informations)
			end
		else
			if not informations.isEnemy then
				table.insert(entities, informations)
			end
		end
	end
	return entities
end

function EntityClass.SetEntityMultipliers(player, NewMultiplier)
	if not Entities[player] then
		return
	end
	for _, informations in Entities[player] do
		informations.multiplier = NewMultiplier
	end
end

function EntityClass.ClearEnemyEntities(player)
	if not Entities[player] then
		return
	end
	for _, informations in Entities[player] do
		if informations.isEnemy then
			informations:Clear()
		end
	end
end

function EntityClass.ClearAllEntities(player)
	for _, informations in Entities[player] do
		informations:Clear()
	end
end

function EntityClass.FindClosestEntity(CurrentCf, Player, Enemy)
	local closestEntity = nil
	local closestDistance = math.huge
	for _, entity in EntityClass.GetEntitiesOfType(Player, Enemy) do
		if entity.model and entity.model.PrimaryPart then
			local distance = (entity.model:GetPivot().Position - CurrentCf.Position).Magnitude
			if distance < closestDistance then
				closestEntity = entity
				closestDistance = distance
			end
		end
	end
	return closestEntity, closestDistance
end

function EntityClass:GetData(): DataTemplate.DataBrainrot
	return DataService.server:get(self.owner, { "equipped", self.id })
end

function EntityClass.GetConfigurationData(self: class): Brainrots.Brainrot
	return Brainrots[self.name]
end

function EntityClass.GetMaxedHealth(self: class)
	local startingHealth = self:GetConfigurationData().Health
	if self.isEnemy then
		return startingHealth * WaveMultiplierFunction(self.currentWave)
	else
		return startingHealth * MultiplierFunction(EntityClass:GetData().Level)
	end
end

function EntityClass.AttachCallbackToSignal(self: class, cb)
	self.diedSignal:Connect(cb)
end

function EntityClass.GiveExp(self: class, Amount)
	DataService.server:update(self.owner, { "equipped", self.id }, function(old: DataTemplate.DataBrainrot)
		local clonedData = table.clone(old)
		local newAmount = old.Xp + Amount
		if newAmount >= LevelCapFunction(old.Level) then
			clonedData.Level = clonedData.Level + 1
			clonedData.Xp = 0
		else
			clonedData.Xp = newAmount
		end
		return clonedData
	end)
end

function EntityClass.CanAffordEnergy(self: class, entityName: string): boolean
	local configData = Brainrots[entityName]
	if not configData then
		return false
	end

	local currentEnergy = DataService.server:get(self.owner, { "energy" })
	return currentEnergy >= configData.EnergyCost
end

function EntityClass.ConsumeEnergy(self: class, entityName: string): boolean
	local configData = Brainrots[entityName]
	if not configData then
		return false
	end

	local currentEnergy = DataService.server:get(self.owner, { "energy" })
	if currentEnergy < configData.EnergyCost then
		return false
	end

	DataService.server:update(self.owner, { "energy" }, function(oldEnergy: number)
		return oldEnergy - configData.EnergyCost
	end)

	return true
end

function EntityClass.GetCurrentEnergy(self: class): number
	return DataService.server:get(self.owner, { "energy" })
end

function EntityClass.GetMaxEnergy(self: class): number
	local Configuration = require(ReplicatedStorage.Configurations.Configuration)
	return Configuration.maxEnergy
end

function EntityClass.GetDefenderCount(self: class): number
	local defenderCount = 0
	local playerEntities = Entities[self.owner]
	if playerEntities then
		for _, entity in playerEntities do
			if not entity.isEnemy then
				defenderCount += 1
			end
		end
	end
	return defenderCount
end

function EntityClass.CanSpawnDefender(self: class): boolean
	local maxUnits = DataService.server:get(self.owner, { "maxUnitsOnField" })
	local currentDefenders = self:GetDefenderCount()
	return currentDefenders < maxUnits
end

function EntityClass.TakeDamage(self: class, amount)
	self.health -= amount
	if self.health <= 0 then
		self.diedSignal:Fire()
		self:Clear()
	end
end

function EntityClass.DamageTarget(self: class)
	if self.target then
		local DamageAmount = self:GetDamage()
		self.target:TakeDamage(DamageAmount)
	end
end

function EntityClass.GetAroundPositionsForTarget(self: class)
	if not self.target then
		return nil
	end
	local _EntitiesForTarget = EntityClass.GetTargetsOfId(self.owner, self.target.id)
	-- TODO: implement circle orientation around target
	return self.target.model:GetPivot() * CFrame.new(0, 0, -4)
end

function EntityClass.Restart(self: class, SpawnCf)
	self.model:PivotTo(SpawnCf)
end

function EntityClass.GetDamage(self: class)
	local attackDmg = self:GetConfigurationData().AttackDmg
	if self.isEnemy then
		return attackDmg * WaveMultiplierFunction(self.currentWave)
	else
		return attackDmg * MultiplierFunction(EntityClass:GetData().Level)
	end
end

function EntityClass.TargetTo(self: class, cf: CFrame)
	if not self.model then
		warn("Did you forget to spawn the entity?")
		return
	end
	local humanoid = self.model:FindFirstChildOfClass("Humanoid")
	if humanoid and cf then
		humanoid:MoveTo(cf.Position)
	end
end

function EntityClass.StartMovingCycle(self: class)
	self.movingCycle = task.spawn(function()
		while true do
			if not self.alive then
				break
			end

			local _CurrentTarget = self.target
			self:TargetTo(self:GetAroundPositionsForTarget())
			task.wait(0.15)
		end
	end)
end

function EntityClass.StartCheckingForOpposite(self: class)
	self.checkingConnection = task.spawn(function()
		while true do
			if not self.alive then
				break
			end

			local ClosestEnemy, distance =
				EntityClass.FindClosestEntity(self.model:GetPivot(), self.owner, not self.isEnemy)
			if ClosestEnemy and distance then
				if self.target ~= ClosestEnemy then
					self.target = ClosestEnemy
				end
				if distance <= DistanceToTarget then
					self:DamageTarget()
				end
			else
				-- No enemy found, target opposite base
				local enemyBase = BasesService.getEnemyBase(self.owner)
				if enemyBase and enemyBase.model then
					self.target = enemyBase :: any
					local baseDistance = (enemyBase.model:GetPivot().Position - self.model:GetPivot().Position).Magnitude
					if baseDistance <= DistanceToTarget then
						self:DamageTarget()
					end
				end
			end

			task.wait(0.15)
		end
	end)
end

function EntityClass.Spawn(self: class, spawnCf: CFrame)
	local _data = self:GetData()

	local model = BrainrotFolder:FindFirstChild(self.name):Clone()
	model.Parent = workspace.Entities
	model:PivotTo(spawnCf)

	self.model = model

	self:StartMovingCycle()
	self:StartCheckingForOpposite()

	return model
end

function EntityClass.Clear(self: class)
	if self.model then
		self.model:Destroy()
	end
	self.alive = false
end

function EntityClass.new(Id: string, BrainrotName: string, Owner: Player, IsEnemy: boolean, CurrentWave: boolean): class
	local self: class = setmetatable(
		{
			id = Id,
			alive = true,
			name = BrainrotName,
			isEnemy = IsEnemy,
			owner = Owner,
			target = nil,
			currentWave = CurrentWave,
			diedSignal = Signal.new(),
			checkingConnection = nil,
		} :: BasicClass,
		EntityClass
	)
	self.health = self:GetMaxedHealth()

	if not Entities[Owner] then
		Entities[Owner] = {}
	end

	table.insert(Entities[Owner], self)

	return self
end

return EntityClass
