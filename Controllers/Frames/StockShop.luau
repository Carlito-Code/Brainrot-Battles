local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Plots = require(script.Parent.Parent.Setups.Plots)
local Animations = require(script.Parent.Parent.Bindings.Animations)
local Brainrots = require(ReplicatedStorage.Configurations.Brainrots)
local ViewportHandler = require(script.Parent.Parent.Setups.ViewportHandler)
local BrainrotShop = require(ReplicatedStorage.Configurations.BrainrotShop)
local Remotes = require(ReplicatedStorage.SharedModules.Remotes)

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

function StockShop.LoadUnits(Frame: Frame, newStock: { [string]: number })
    -- local inventory = DataService:get(Players.LocalPlayer, { "inventory" })
    local unitFrames = {}

    for _, unitFrame in Frame.Units:GetChildren() do
        if unitFrame:IsA("GuiObject") and unitFrame.Visible then
            unitFrame:Destroy()
        end
    end

    Frame.Units.CanvasSize = UDim2.new(0, 0, 0, 0)

	for brainrotName, stockAmount in newStock do
        local unitFrame = Frame.Units.Unit:Clone()

        unitFrame.Name = name
        unitFrame.Info.Title.Text = Brainrots[name].DisplayName
        unitFrame.Info.Price.Text = "$" .. brainrotShopConfig.price

        ViewportHandler.ProcessBrainrotViewport(unitFrame.Icon.ViewportFrame, name)
        unitFrame.Visible = true

        unitFrame.Parent = Frame.Units

        unitFrame:SetAttribute("Price", brainrotShopConfig.price)

        unitFrame.Button.MouseButton1Click:Connect(function()
            print("purchasing unit")
            local success = StockShop.PurchaseUnit(name)

            if success then
                print("Purchase successful")
            else
                print("Purchase failed")
            end
        end)

        table.insert(unitFrames, unitFrame)
    end

    table.sort(unitFrames, function(a, b)
        return a:GetAttribute("Price") < b:GetAttribute("Price")
    end)

    for index, unitFrame in unitFrames do
        unitFrame.LayoutOrder = index
    end

    Frame.Units.CanvasSize = UDim2.new(0, 0, Frame.Units.UIListLayout.AbsoluteContentSize.Y/Frame.AbsoluteSize.Y + Frame.Units.UIListLayout.Padding.Scale, 0)
    Frame.Units.UIListLayout.Padding = UDim.new(Frame.Units.UIListLayout.Padding.Offset/Frame.Units.AbsoluteCanvasSize.Y, 0)
end

function StockShop.PurchaseUnit(UnitName: string)
    return Remotes.PurchaseUnit:InvokeServer(UnitName)
end

function StockShop.Init(FramesContainer: Folder)
	local Frame = FramesContainer:FindFirstChild("StockShop")

    -- Remotes.GetStock.OnClientInvoke = function(newStock)
    --    StockShop.LoadUnits(Frame, newStock)
    -- end

    Remotes.StockChanged.OnClientEvent:Connect(function(Stock)
        StockShop.LoadUnits(Frame, Stock)
    end)

    local initialStock, currentTime = Remotes.GetStock:InvokeServer()
    StockShop.LoadUnits(Frame, initialStock)
	
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