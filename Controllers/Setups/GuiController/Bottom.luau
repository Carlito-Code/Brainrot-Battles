local Remotes = require(game.ReplicatedStorage.SharedModules.Remotes)

local Bottom = {}

function Bottom.Init(bottomContainer: Frame)
    for _, slot in bottomContainer:GetChildren() do
        if slot.Name:find("Slot_") then
            slot.MouseButton1Click:Connect(function()
                local slotGuid = slot:GetAttribute("BrainrotGUID")
                
                if slotGuid and slotGuid ~= "" then
                    Remotes.SpawnEntity:FireServer(slotGuid)
                end
            end)
        end
    end
end

return Bottom