local replicatedStorage = game:GetService("ReplicatedStorage")
local serverStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local utilities = replicatedStorage.Utilities

local promise = require(utilities.Promise)
require(utilities.ModelTween)

local physics = game:GetService("PhysicsService")

-- Data Dependencies
local DataService = require(replicatedStorage.Utilities.DataService)
local DataTemplate = require(replicatedStorage.SharedModules.DataTemplate)

-- Physics collidables
physics:RegisterCollisionGroup("Chars")
physics:RegisterCollisionGroup("Players")

physics:CollisionGroupSetCollidable("Chars", "Players", false)
physics:CollisionGroupSetCollidable("Chars", "Chars", false)
physics:CollisionGroupSetCollidable("Players", "Players", false)

Players.PlayerAdded:Connect(function(plr: Player)
	plr.CharacterAdded:Connect(function()
		if plr.Character then
			for _, v in pairs(plr.Character:GetDescendants()) do
				if v:IsA("BasePart") then
					v.CollisionGroup = "Players"
				end
			end
		end
	end)
end)

for _, v in pairs(replicatedStorage.Assets.Brainrots:GetDescendants()) do
	if v:IsA("BasePart") then
		v.CollisionGroup = "Chars"
	end
end

DataService.server:init({
	template = DataTemplate.template,
	profileStoreIndex = DataTemplate.version .. "Datastore",
})

local list = ServerScriptService.Server.Setups:GetChildren()
table.sort(list, function(a: ModuleScript, b)
	return a:HasTag("Priority")
end)

for _, v in pairs(list) do
	task.spawn(function()
		promise
			.new(function(resolve, reject)
				if v:IsA("ModuleScript") then
					local sucess, errorMsg = pcall(function()
						local r = require(v)
						print(r)
						if typeof(r["Init"]) == "function" then
							print("Initializing module: " .. v.Name)
							r.Init()
						end
					end)
					if not sucess then
						reject(errorMsg)
						return
					end
					print("Initialized module with name: " .. v.Name)
				end
			end)
			:catch(function(msg)
				for _, v in game.Players:GetPlayers() do
					v:Kick("Internal server error")
				end
			end)
	end)
end

return {}
