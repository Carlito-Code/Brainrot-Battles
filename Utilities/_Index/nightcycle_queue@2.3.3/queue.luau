--!strict
--!native
-- based on this originally https://create.roblox.com/docs/luau/queues
-- Services
-- Packages
-- Modules
-- Types
export type Queue<T> = {
	__index: Queue<T>,
	_Queue: { [number]: T },
	_Registry: { [T]: number? },
	IsSorted: boolean,
	new: () -> Queue<T>,
	IsEmpty: (self: Queue<T>) -> boolean,
	Has: (self: Queue<T>, value: T) -> boolean,
	Remove: (self: Queue<T>, value: T) -> (),
	Sort: (self: Queue<T>) -> (),
	CheckPosition: (self: Queue<T>, value: T) -> number?,
	CheckPriority: (self: Queue<T>, value: T) -> number?,
	Add: (self: Queue<T>, value: T, priority: number?) -> (),
	Get: (self: Queue<T>) -> T?,
	GetLength: (self: Queue<T>) -> number,
	Peek: (self: Queue<T>) -> T?,
	Step: (self: Queue<T>, duration: number, processor: (value: T) -> ()) -> (),
}

-- Constants
-- Variables
-- References
-- Private Functions
-- Class

local Queue = {} :: Queue<any>
Queue.__index = Queue

function Queue.new()
	local self: Queue<unknown> = setmetatable({}, Queue) :: any
	self.IsSorted = false
	self._Registry = {}
	self._Queue = {}
	return self
end
-- Check if the queue is empty
function Queue:IsEmpty(): boolean
	return #self._Queue == 0
end

function Queue:Has(value: unknown): boolean
	return self._Registry[value] ~= nil
end

function Queue:GetLength(): number
	return #self._Queue
end

function Queue:Remove(value: unknown): ()
	local index = table.find(self._Queue, value)
	if index then
		table.remove(self._Queue, index)
		self._Registry[value] = nil
	end
end

function Queue:Sort()
	assert(self.IsSorted, `you can only sort queues with IsSorted = true`)
	table.sort(self._Queue, function(a: unknown, b: unknown)
		local aP: number? = self._Registry[a] or 0
		local bP: number? = self._Registry[b] or 0
		assert(aP and bP)
		return aP > bP
	end)
end

function Queue:CheckPosition(value: unknown): number?
	return table.find(self._Queue, value)
end

function Queue:CheckPriority(value: unknown): number?
	return self._Registry[value]
end

-- Add a value to the queue
function Queue:Add(value: unknown, priority: number?)
	if self:Has(value) then
		return
	end
	if priority and not self.IsSorted then
		error(`priority passed to unsorted queue, enabled sorting with queue.IsSorted = true`)
	end
	priority = (priority or 0) :: number
	assert(priority ~= nil)

	self._Registry[value] = priority

	local index: number?

	if self.IsSorted then
		for i, v in ipairs(self._Queue) do
			local nV = self._Queue[i + 1]
			if nV then
				local nP = self._Registry[nV]
				if nP then
					if nP >= priority then
						index = i
						break
					end
				end
			else
				local vP = self._Registry[v]
				if vP then
					if vP < priority then
						index = i
						break
					end
				end
			end
		end
	end

	if index then
		table.insert(self._Queue, index, value)
	else
		table.insert(self._Queue, 1, value)
	end
end

-- Remove a value from the queue
function Queue:Get(): unknown?
	if self:IsEmpty() then
		return nil
	end

	local value = self._Queue[1]
	table.remove(self._Queue, 1)

	self._Registry[value] = nil

	return value
end

-- Check the value next up in the queue without removing it
function Queue:Peek(): unknown?
	return self._Queue[1]
end

-- Run through as many items as you can in the alotted time
function Queue:Step(duration: number, processor: (value: unknown) -> ()): ()
	local start = tick()
	repeat
		local value = self:Get()
		if value ~= nil then
			processor(value)
		end
	until tick() - start >= duration or self:IsEmpty()
end

return Queue
