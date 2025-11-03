local Waves = {
	["0-10"] = {
		["BombardiroCrocodilo"] = {
			Min = 2,
			Max = 10,
		},
	},
}

export type Wave = {
	[string]: {
		Min: number,
		Max: number,
	},
}

export type Data = {
	[string]: Wave,
}

return Waves
