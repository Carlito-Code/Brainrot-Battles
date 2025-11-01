return function(parent, actionText, promptDuration, keybind)
	local proximity = Instance.new("ProximityPrompt"); proximity.RequiresLineOfSight = false; proximity.Parent = parent; proximity.ActionText = actionText; proximity.HoldDuration = promptDuration; proximity.KeyboardKeyCode = keybind
	proximity.ObjectText = ""
	return proximity
end