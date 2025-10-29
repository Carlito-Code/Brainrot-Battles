local TweenService = game:GetService("TweenService")

return function(worldPosition: Vector3, radius: number, color: Color3)
	print(worldPosition, radius)
	
	local cylinder = Instance.new("Part")
	cylinder.Size = Vector3.new(.2, 1, 1)
	cylinder.Color = color
	cylinder.Transparency = .5
	cylinder.Anchored = true
	cylinder.CanCollide = false
	cylinder.CanTouch = false
	cylinder.CanQuery = false
	cylinder.Shape = Enum.PartType.Cylinder
	cylinder.Parent = workspace
	
	cylinder:PivotTo(CFrame.new(worldPosition) * CFrame.Angles(0, 0, math.rad(90)))
	
	TweenService:Create(cylinder, TweenInfo.new(.5), {
		Size = Vector3.new(.2, radius*2,radius*2)
	}):Play()
	TweenService:Create(cylinder, TweenInfo.new(2.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
		Transparency = 1;
	}):Play()
	
	task.wait(2.25)
	
	cylinder:Destroy()
end