-- DATA CONTAINER --
local function toAnimationString(s) return "rbxassetid://" .. s end
local Data = {
	Test = {
		DisplayName = "Test",
		AttackAnimation = toAnimationString(0),
		WalkingAnimation = toAnimationString(0),
		AttackDmg = 15,
		Health = 100,
		Rarity = "Common",
		SpawnPrice = 0,
		EnergyCost = 10,
	}
}

export type Brainrot = {
	DisplayName: string,
	AttackAnimation: string,
	WalkingAnimation: string,
	AttackDmg: number,
	Health: number,
	Rarity: string,
	SpawnPrice: number,
	EnergyCost: number,
}

export type Data = typeof(Data)

return Data