local replicatedStorage = game:GetService("ReplicatedStorage")

local Util = {}

function Util.new(checkFunction, model, name)
    local newHealthbar = replicatedStorage.Assets.HealthBarBillboard:Clone()
    newHealthbar.Parent = model
    newHealthbar.LifeBar.TextLabel.Text = name

    task.spawn(function()
        while model and model.Parent do
            local health, maxhealth = checkFunction()
            local percentage = health / maxhealth
            newHealthbar.LifeBar.bar.Size = UDim2.fromScale(percentage, 0.539)
            newHealthbar.LifeBar.life.Text = math.floor(health) .. "/" .. math.floor(maxhealth)
            task.wait()
        end
    end)
end

return Util