--// Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--// Data
local Signals = require(ReplicatedStorage.SharedModules.Signals)

--// Utilities
local DataUtil = require("../Systems/DataUtil")

local DataInitializer = {}

function DataInitializer.Init()
	Signals.CLAIMED_PLOT:Connect(function(plr, plot)
		
	end)
end

return DataInitializer