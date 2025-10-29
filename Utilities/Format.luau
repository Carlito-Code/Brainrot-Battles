--!strict

local suffixes = {"K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc", "Ud", "Dd", "Td", "Qad", "Qid", "Sxd", "Spd", "Ocd", "Nod", "Vg", "Uvg", "Dvg", "Tvg", "Qavg", "Qivg", "Sxvg", "Spvg", "Ocvg"}

local Module = {}

--[[ 
	Returns the possessive form of a given name.
	If the name ends in "s" (case-insensitive), appends just an apostrophe.
	Otherwise, appends `'s`.
]]
function Module.getPossessiveName(name: string): string
	assert(typeof(name) == "string", "getPossessiveName(): name must be a string")

	local lastCharacter = string.sub(name, -1)
	if lastCharacter:lower() == "s" then
		return name .. "'"
	end

	return name .. "'s"
end

-- Calls tostring() on input and removes all special characters (except for underscores).
function Module.getAttributeSafeString(input: any): string
	return tostring(input):gsub("[^%w_]", "")
end

-- Formats a number into float with a suffix (if applicable).
-- <strong>precision</strong>: Default is 1 decimal place.
function Module.abbreviateNumber(x: number, precision: number?)
	local precision = precision or 1

	if x < 1000 then
		return tostring(x)
	end

	local suffixIndex = math.floor(math.log10(x) / 3)
	local suffix = suffixes[suffixIndex]

	if not suffix then
		return tostring(x)
	end

	local divisor = 10 ^ (suffixIndex * 3)
	local shortValue = x / divisor

	local multiplier = 10 ^ precision
	local roundedValue = math.floor(shortValue * multiplier + 0.5) / multiplier

	-- If rounding pushes the value to 1000, switch to next suffix
	if roundedValue >= 1000 and suffixes[suffixIndex + 1] then
		suffixIndex += 1
		suffix = suffixes[suffixIndex]
		divisor = 10 ^ (suffixIndex * 3)
		roundedValue = math.floor((x / divisor) * multiplier + 0.5) / multiplier
	end

	local formatted = string.format(`%.{precision}f`, roundedValue)
	formatted = formatted:gsub("%.?0+$", "")

	return `{formatted}{suffix}`
end

function Module.removeRichTextTags(input: string): string
	return input:gsub("<[^<>]->", "")
end

-- Formats a number into float with a suffix (if applicable).
-- <strong>precision</strong>: Default is 1 decimal place.
function Module.abbreviateCash(x: number, precision: number?)
	local precision = precision or 1

	if x < 1000 then
		return Module.formatCash(x)
	end

	local suffixIndex = math.floor(math.log10(x) / 3)
	local suffix = suffixes[suffixIndex]

	if not suffix then
		return Module.formatCash(x)
	end

	local divisor = 10 ^ (suffixIndex * 3)
	local shortValue = x / divisor

	local multiplier = 10 ^ precision
	local roundedValue = math.floor(shortValue * multiplier + 0.5) / multiplier

	-- If rounding pushes the value to 1000, switch to next suffix
	if roundedValue >= 1000 and suffixes[suffixIndex + 1] then
		suffixIndex += 1
		suffix = suffixes[suffixIndex]
		divisor = 10 ^ (suffixIndex * 3)
		roundedValue = math.floor((x / divisor) * multiplier + 0.5) / multiplier
	end

	local formatted = string.format(`%.{precision}f`, roundedValue)
	formatted = formatted:gsub("%.?0+$", "")

	return `{formatted}{suffix}`
end

-- Removes all rich text tags from the string, including replacing `\n` breaks with their rich text counterpart.
-- Use this to get an accurate utf8.graphemes count that excludes rich text markup.
function Module.removeTags(str: string): string
	-- replace line break tags (otherwise grapheme loop will miss those linebreak characters)
	str = str:gsub("<br%s*/>", "\n")
	return (str:gsub("<[^<>]->", ""))
end

--[[
	Formats numbers into a 'cash' format.
	100 -> 100
	0.011 -> 0.01
	1000.155 -> 1,000.16
]]
function Module.formatCash(amount: number): string
	assert(typeof(amount) == "number", "FormatCash expects a number")
	-- Round to the nearest cent
	local roundedAmount = math.floor(amount * 100 + 0.5) / 100

	-- Get a two-decimal string
	local formattedString = string.format("%.2f", roundedAmount)

	-- Handle a leading minus-sign
	local isNegative = false
	if formattedString:sub(1, 1) == "-" then
		isNegative = true
		formattedString = formattedString:sub(2)
	end

	-- Split into integer + fractional parts
	local integerPart, fractionalPart =
		formattedString:match("^(%d+)(%.%d%d)$")

	-- Sanity checks in case of unexpected strings
	if not integerPart or not fractionalPart then
		error(`FormatCash failed to parse '{formattedString}'`, 2)
	end

	local integerNumber = tonumber(integerPart)
	if not integerNumber then
		error(`FormatCash invalid integer '{integerPart}'`, 2)
	end

	-- Insert commas, reattach sign, and decide whether to include cents
	local withCommas = Module.formatWithCommas(integerNumber)
	local result = (isNegative and "-" or "") .. withCommas

	if fractionalPart ~= ".00" then
		result = result .. fractionalPart
	end

	return result
end

-- Formats any number to include commas (if applicable).
function Module.formatWithCommas(num: number): string
	local negative = false
	if num < 0 then
		negative = true
		num = -num
	end

	local str = tostring(num)
	local integer, fractional = str:match("^(%d+)(%.%d+)$")
	if not integer then
		integer = str
		fractional = ""
	end

	local reversed = (integer :: string):reverse()
	local parts = {}
	for i = 1, #reversed, 3 do
		parts[#parts + 1] = reversed:sub(i, i + 2)
	end

	local withCommas = table.concat(parts, ","):reverse()
	if negative then
		withCommas = `-{withCommas}`
	end

	return `{withCommas}{fractional}`
end

-- DEPRECATED, use formatWithCommas() instead
function Module.formatLgInt(value : number)
	warn(`formatLgInt is deprecated and has been replaced by .formatWithCommas()`)
	local valueStr = tostring(value)

	if #valueStr <= 3 then
		return valueStr
	end

	local revStr = string.reverse(valueStr)
	local formatted = ""
	for i = 1, string.len(revStr) do
		formatted = formatted .. string.sub(revStr, i, i)
		if i % 3 == 0 and i ~= string.len(revStr) then
			formatted = formatted .. ","
		end
	end

	formatted = string.reverse(formatted)
	return formatted
end

function Module.nearest2DecimalPlaces(float : number)
	float *= 100
	return (math.floor(float) / 100)
end

--[[
	Formats the duration in seconds to a time string.
	Example: 125 -> 2:05, 3605 -> 1:00:05
	<strong>minUnit</strong>: Default is 'minutes'
]]
function Module.formatTime(seconds: number, minUnit: ("hours" | "minutes" | "seconds")?): string
	assert(typeof(seconds) == "number", "formatTime expects a number")
	local precision = minUnit or "minutes"

	local totalSeconds = math.floor(seconds)
	local hours = math.floor(totalSeconds / 3600)
	local minutes = math.floor((totalSeconds % 3600) / 60)
	local secs = totalSeconds % 60

	local parts = {}

	if precision == "hours" or hours > 0 then
		table.insert(parts, string.format("%02d", hours))
		table.insert(parts, string.format("%02d", minutes))
		table.insert(parts, string.format("%02d", secs))
	elseif precision == "minutes" or minutes > 0 then
		table.insert(parts, tostring(minutes))
		table.insert(parts, string.format("%02d", secs))
	else
		table.insert(parts, tostring(secs))
	end

	return table.concat(parts, ":")
end

--[[
	Formats the duration in seconds to a time string (including milliseconds).
	Example: 125.3559 -> 2:05.356, 3605.15 -> 1:00:05.150
	<strong>precision</strong>: How many decimal places. Any missing spaces will be filled with zeros. Must be value of 0-3.
	<strong>minUnit</strong>: Default is 'minutes'
]]
function Module.formatTimeWithMilliseconds(timeInSeconds: number, precision: number, minUnit: "hours" | "minutes" | "seconds"?): string
	assert(typeof(timeInSeconds) == "number", "Expected number for timeInSeconds")
	assert(typeof(precision) == "number" and precision >= 0 and precision <= 3, "Precision must be between 0 and 3")

	local base = Module.formatTime(timeInSeconds, minUnit)

	if precision == 0 then
		return base
	end

	local factor = 10 ^ precision
	local fraction = timeInSeconds % 1
	local fractionalRounded = math.floor(fraction * factor + 0.5)
	return base .. string.format(`.%0{precision}d`, fractionalRounded)
end

-- Attempts to convert a string to PascalCase
-- Examples:
-- HELLOTHERE -> Hellothere
-- hello_there -> HelloThere
function Module.toPascalCase(input: string): string
	local parts = {}
	-- iterate over runs of letters and digits (ignore underscores, punctuation, etc.)
	for word in string.gmatch(input, "[A-Za-z0-9]+") do
		local firstChar = string.sub(word, 1, 1)
		local rest = string.sub(word, 2)
		-- uppercase the first letter, lowercase the rest
		local capitalized = string.upper(firstChar) .. string.lower(rest)
		table.insert(parts, capitalized)
	end
	return table.concat(parts)
end

-- Get the correspending ordinal suffix for a number returns as a string. It accounts for 11 - 13
-- Examples:
-- 1 -> 1st
-- 11 -> 11th
function Module.getOrdinalString(input: number): string
	local suffix = "th"
	if input % 100 < 11 or input % 100 > 13 then
		local lastDigit = input % 10
		if lastDigit == 1 then
			suffix = "st"
		elseif lastDigit == 2 then
			suffix = "nd"
		elseif lastDigit == 3 then
			suffix = "rd"
		end
	end
	return tostring(input) .. suffix
end

-- Simply adds a space before an uppercase letter
-- Input: HelloWorld
-- Output: Hello World
function Module.addSpaceBeforeUpperCase(input: string): string
	return input:gsub("(%u)", " %1"):gsub("^ ", "")
end

--Separates all strings by uppercase and inserts into a table.
function Module.splitByUppercase(input: string): {string}
	local result = {}
	for word in input:gmatch("[A-Z][^A-Z]*") do
		table.insert(result, word)
	end
	return result
end

return Module