-- Services
local TweenService = game:GetService('TweenService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local CreateProximity = require(ReplicatedStorage.SharedModules.CreateProximity)

-- Dependencies
local typed = require(ReplicatedStorage.Utilities.TypedRemote)

local tweenevent = typed.event("tweenevent")

local SmartTween = {}

local modeltweens = {}
local tweens = {}

local endingdelays = {}

function SmartTween.ModelTween(model, tweeinfo, goal)
	if modeltweens[model] then
		modeltweens[model](goal, tweeinfo)
		return
	end
	
	local cframeValue = Instance.new('CFrameValue')
	if cframeValue then
		cframeValue.Value = model:GetPivot()
		cframeValue:GetPropertyChangedSignal('Value'):Connect(function()
			model:PivotTo(cframeValue.Value)
		end)
		local tween = TweenService:Create(cframeValue, tweeinfo, {Value = goal})
		tween:Play()
		local currenconnection = nil
		local function attachtotween(tween: Tween)
			if currenconnection then
				currenconnection:Disconnect()
			end
			
			currenconnection = tween.Completed:Connect(function()
				tween:Destroy()
				cframeValue:Destroy()
				model:Destroy()
			end)
		end
		attachtotween(tween)
		modeltweens[model] = function(newgoal, tweeinfo: TweenInfo)
			if newgoal then
				local newtween = TweenService:Create(cframeValue, tweeinfo, {Value = newgoal})
				newtween:Play()
				attachtotween(newtween)
				tween:Destroy()
			end
		end
	end
end

local function PackTweenInfo(TI : TweenInfo) : table
	return {
		TI.Time,
		TI.EasingStyle,
		TI.EasingDirection,
		TI.RepeatCount,
		TI.Reverses,
		TI.DelayTime,
	}
end

local function CreatePartMiddle(newasset)
	local new = Instance.new("Part")
	new.Size = Vector3.new(1,1,1)
	new.Position = newasset:GetPivot().Position
	new.Transparency = 1
	new.CanCollide = false
	new.Anchored = true
	new.Name = "center"
	new.Parent = newasset
	return new
end

function SmartTween.Tween(asset: BasePart | Model, tweeninfo: TweenInfo, goal: Vector3 | CFrame, info, onfinish: () -> (), plr)
	if RunService:IsServer() then
		if onfinish then
			if endingdelays[asset] then
				task.cancel(endingdelays[asset])
			end
			
			endingdelays[asset] = task.delay(tweeninfo.Time, function()
				onfinish()
			end)
		end
		
		tweenevent:FireClient(plr, asset, PackTweenInfo(tweeninfo), goal, info)
		return
	end
	
	if info then
		local clone = CreatePartMiddle(asset)
		local event: RemoteEvent, center = table.unpack(info), clone
		local proximity = CreateProximity(center, "Purchase egg", 0, Enum.KeyCode.E)
		proximity.Triggered:Connect(function()
			event:FireServer()
		end)
	end
	
	tweeninfo = TweenInfo.new(table.unpack(tweeninfo))
	
	if asset:IsA("Model") then
		SmartTween.ModelTween(asset, tweeninfo, goal)
		return
	end
	
	local Tween = TweenService:Create(asset, tweeninfo, goal)
	Tween:Play()
	
	Tween.Completed:Connect(function()
		Tween:Destroy()
	end)
end

if RunService:IsClient() then
	tweenevent.OnClientEvent:Connect(SmartTween.Tween)
end

return SmartTween
