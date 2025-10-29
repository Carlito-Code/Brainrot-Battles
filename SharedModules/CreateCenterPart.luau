return function(model: Model)
	local part = Instance.new("Part"); part.Size = Vector3.one; part.CFrame = model:GetPivot(); part.Transparency = 1; part.Anchored = true; part.CanCollide = false; part.Parent = model
	return part
end