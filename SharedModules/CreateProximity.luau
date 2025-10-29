return function(parent, objectText, promptDuration, keybind)
	local proximity = Instance.new("ProximityPrompt"); proximity.RequiresLineOfSight = false; proximity.Parent = parent; proximity.ObjectText = objectText; proximity.HoldDuration = promptDuration; proximity.KeyboardKeyCode = keybind
	return proximity
end