local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Remotes = require(ReplicatedStorage.SharedModules.Remotes)
local CreateProximity = require(ReplicatedStorage.SharedModules.CreateProximity)
local CreateCenterPart = require(ReplicatedStorage.SharedModules.CreateCenterPart)

local ProximityHandler = {}
local CACHES = {}

function ProximityHandler.init()
	Remotes.AddProximity.OnClientEvent:Connect(function(
		Container: Model,
		PROXIMITY_PROMPT_TAG: string,
		ExtraArguments: {},
		ActionText: string,
		KeyCode: Enum.KeyCode,
		HoldDuration: number,
		Enabled: boolean
	)
		
		local NewProximity = CreateProximity(CreateCenterPart(Container), ActionText, HoldDuration, KeyCode)
		NewProximity.Enabled = Enabled
		NewProximity.Triggered:Connect(function()
			Remotes.AddProximity:FireServer(Container, PROXIMITY_PROMPT_TAG, ExtraArguments)
		end)
		
		CACHES[PROXIMITY_PROMPT_TAG] = NewProximity
	end)
	
	Remotes.ChangeViewingProximity.OnClientEvent:Connect(function(
		PROXIMITY_PROMPT_TAG: string,
		Bool: boolean
	)
		local cache = CACHES[PROXIMITY_PROMPT_TAG]
		if cache then
			cache.Enabled = Bool
		end
	end)
end

return ProximityHandler