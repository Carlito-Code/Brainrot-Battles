local replicatedStorage = game:GetService("ReplicatedStorage")

local Util = {}

local function getHealthColor(percentage: number): Color3
	if percentage > 0.7 then
		return Color3.fromRGB(0, 255, 0) -- Green
	elseif percentage > 0.4 then
		return Color3.fromRGB(255, 165, 0) -- Orange
	else
		return Color3.fromRGB(255, 0, 0) -- Red
	end
end

local function updateHealthBarColor(bar: Frame, percentage: number)
	local gradient = bar:FindFirstChildOfClass("UIGradient")
	if gradient then
		local color = getHealthColor(percentage)
		gradient.Color = ColorSequence.new(color)
	end
end

function Util.new(checkFunction, model, name)
	local newHealthbar = replicatedStorage.Assets.HealthBarBillboard:Clone()
	newHealthbar.Parent = model
	newHealthbar.LifeBar.TextLabel.Text = name

	task.spawn(function()
		while model and model.Parent do
			local health, maxhealth = checkFunction()
			local percentage = health / maxhealth
			local bar = newHealthbar.LifeBar.bar
			bar.Size = UDim2.fromScale(percentage, 0.539)
			newHealthbar.LifeBar.life.Text = math.floor(health) .. "/" .. math.floor(maxhealth)
			updateHealthBarColor(bar, percentage)
			task.wait()
		end
	end)
end

function Util.useExisting(checkFunction, healthBarBillboard: any, name: string?)
	local lifeBar = healthBarBillboard:FindFirstChild("LifeBar")
	if not lifeBar then
		warn("HealthBarBillboard does not have LifeBar child")
		return
	end

	if name then
		local textLabel = lifeBar:FindFirstChild("TextLabel")
		if textLabel and textLabel:IsA("TextLabel") then
			textLabel.Text = name
		end
	end

	task.spawn(function()
		while healthBarBillboard and healthBarBillboard.Parent do
			local health, maxhealth = checkFunction()
			local percentage = health / maxhealth

			local bar = lifeBar:FindFirstChild("bar")
			if bar then
				bar.Size = UDim2.fromScale(percentage, 0.539)
				updateHealthBarColor(bar, percentage)
			end

			local lifeText = lifeBar:FindFirstChild("life")
			if lifeText and lifeText:IsA("TextLabel") then
				lifeText.Text = math.floor(health) .. "/" .. math.floor(maxhealth)
			end

			task.wait()
		end
	end)
end

return Util
