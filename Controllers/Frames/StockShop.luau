local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.SharedModules.Remotes)
local Plots = require(script.Parent.Parent.Setups.Plots)
local Animations = require(script.Parent.Parent.Bindings.Animations)
local Brainrots = require(ReplicatedStorage.Configurations.Brainrots)

local StockShop = {}

function StockShop.BuyUnit(UnitName: string)
	-- Remotes.BuyUnit:InvokeServer(UnitName)
end

function StockShop.ShowGui(Container)
	Animations:OpenFrame(Container)
end

function StockShop.HideGui(Container)
	Animations:CloseFrame(Container)
end

function StockShop.LoadUnits(Frame: Frame)
	for name, brainrotConfig in Brainrots do
        local unitFrame = Frame.Units.Unit:Clone()

        unitFrame.Name = name
        unitFrame.Info.Title.Text = brainrotConfig.DisplayName
        unitFrame.Info.Price.Text = brainrotConfig.SpawnPrice

        unitFrame.Visible = true

        unitFrame.Parent = Frame.Units
    end

    Frame.Units.CanvasSize = UDim2.new(0, 0, Frame.Units.UIListLayout.AbsoluteContentSize.Y/Frame.AbsoluteSize.Y + Frame.Units.UIListLayout.Padding.Scale, 0)
    Frame.Units.UIListLayout.Padding = UDim.new(Frame.Units.UIListLayout.Padding.Offset/Frame.Units.AbsoluteCanvasSize.Y, 0)
end

function StockShop.Init(FramesContainer: Folder)
	local Frame = FramesContainer:FindFirstChild("StockShop")

    StockShop.LoadUnits(Frame)
	
    task.spawn(function()
        StockShop.Update(Frame)
    end)
end

function StockShop.Update(Frame: Frame)	
    while true do
        task.wait(0.5)

        local char = Players.LocalPlayer.Character

        if Plots.playerPlot and char:FindFirstChild("HumanoidRootPart") then
            local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local position = humanoidRootPart.Position
                local distance = (position - Plots.playerPlot.StockShopPrompt.Position).Magnitude

                if distance > 10 then
                    StockShop.HideGui(Frame)
                end
            end
        end
    end
end

return StockShop