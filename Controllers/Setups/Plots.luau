local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.SharedModules.Remotes)

local Plots = {
    playerPlot = nil
}

function Plots.Init()
    local plot = Remotes.GetPlot:InvokeServer()

    if plot then
        Plots.playerPlot = plot
    end
end

return Plots
