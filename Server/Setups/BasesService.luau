local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlotService = require(script.Parent.PlotService)
local Signal = require(ReplicatedStorage.Utilities.Signal)
local WaveMultiplierFunction = require(ReplicatedStorage.SharedModules.WaveMultiplierFunction)
local HealthBarUtil = require(ServerScriptService.Server.Systems.HealthBarUtil)

type BaseObject = {
	model: BasePart,
	owner: Player,
	isEnemy: boolean,
	maxHealth: number,
	health: number,
	onDestroyed: any,
	TakeDamage: (self: BaseObject, amount: number) -> (),
	Regenerate: (self: BaseObject, waveNumber: number?) -> (),
}

local DEFAULT_BASE_HEALTH = 1000

local BasesService = {}

local playerBases: { [Player]: { defender: BaseObject, enemy: BaseObject } } = {}

local function makeBaseObject(model: BasePart, owner: Player, isEnemy: boolean, maxHealth: number): BaseObject
	local obj: any = {
		model = model,
		owner = owner,
		isEnemy = isEnemy,
		maxHealth = maxHealth,
		health = maxHealth,
		onDestroyed = Signal.new(),
	}

	function obj:TakeDamage(amount: number)
		self.health -= amount
		if self.health <= 0 then
			self.health = 0
			self.onDestroyed:Fire(self)
			print("Base destroyed")
		end
	end

	function obj:Regenerate(waveNumber: number?)
		if self.isEnemy and waveNumber then
			-- Scale enemy base health with wave multiplier
			self.maxHealth = DEFAULT_BASE_HEALTH * WaveMultiplierFunction(waveNumber)
		else
			-- Defender base uses default health
			self.maxHealth = DEFAULT_BASE_HEALTH
		end
		self.health = self.maxHealth
	end

	return obj :: BaseObject
end

local function findBasePart(parent: Instance, name: string): BasePart?
	local folder = parent:FindFirstChild(name)
	if not folder then
		return nil
	end

	return folder
end

local function setupTowerHealthBar(base: BaseObject, plot: Model, towerFolderName: string, towerName: string)
	local towerFolder = plot:FindFirstChild(towerFolderName)
	if not towerFolder then
		warn("Could not find " .. towerFolderName .. " in plot")
		return
	end

	local healthBarBillboard = towerFolder:FindFirstChild("HealthBarBillboard")
	if not healthBarBillboard then
		warn("Could not find HealthBarBillboard in " .. towerFolderName)
		return
	end

	if not healthBarBillboard:IsA("BillboardGui") then
		warn("HealthBarBillboard in " .. towerFolderName .. " is not a BillboardGui")
		return
	end

	-- Initialize health bar for the tower
	HealthBarUtil.useExisting(function()
		return base.health, base.maxHealth
	end, healthBarBillboard, towerName)
end

function BasesService.getBases(player: Player): (BaseObject, BaseObject)
	local existing = playerBases[player]
	if existing then
		return existing.defender, existing.enemy
	end

	local plot = PlotService.getPlot(player)
	if not plot then
		return nil :: any, nil :: any
	end

	local defenderPart = findBasePart(plot, "HomeBase")
	local enemyPart = findBasePart(plot, "EnemyBase")

	if not defenderPart or not enemyPart then
		warn("Could not find HomeBase or EnemyBase in plot for player " .. player.Name)
		return nil :: any, nil :: any
	end

	local defender = makeBaseObject(defenderPart, player, false, DEFAULT_BASE_HEALTH)
	local enemy = makeBaseObject(enemyPart, player, true, DEFAULT_BASE_HEALTH)

	-- Setup health bars for towers
	setupTowerHealthBar(defender, plot, "HomeTower", "Home Tower")
	setupTowerHealthBar(enemy, plot, "EnemyTower", "Enemy Tower")

	playerBases[player] = { defender = defender, enemy = enemy }
	return defender, enemy
end

function BasesService.getEnemyBase(player: Player): BaseObject
	local _, enemy = BasesService.getBases(player)
	return enemy
end

function BasesService.getDefenderBase(player: Player): BaseObject
	local defender, _ = BasesService.getBases(player)
	return defender
end

function BasesService.regenerateBases(player: Player, waveNumber: number?)
	local existing = playerBases[player]
	if existing then
		existing.defender:Regenerate(waveNumber)
		existing.enemy:Regenerate(waveNumber)
	end
end

function BasesService.Init()
	-- Lazily creates bases on demand via getBases()
end

return BasesService
