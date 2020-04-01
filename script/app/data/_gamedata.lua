cc.exports.GameData = {
	data = {},
	avData = {}
}

local SPLIT_TAB = {
	monster = 13,
	buff = 15,
	skill = 16
}

local ACTIVITY_CONFIG = {
	avdailycost = 1,
	avovervaluedgift = 1,
	avtodaydouble = 1,
	avdayvouchsafe = 1,
	avaccumulaterecharge = 1,
	avdailyrecharge = 1
}

function GameData:purge()
	local filepath
	for filename, v in pairs(self.data) do
		filepath = "data/" .. filename
		if SPLIT_TAB[filename] then
			for i=0,SPLIT_TAB[filename] do
				if package.loaded[filepath .. i] then
					package.loaded[filepath .. i] = nil
				end
			end
		else
			if package.loaded[filepath] then
				package.loaded[filepath] = nil
			end
		end
	end
	self.data = {}

	for filename, v in pairs(self.avData) do
		filepath = "avdata/" .. filename
		if package.loaded[filepath] then
			package.loaded[filepath] = nil
		end
	end
	self.avData = {}
end

function GameData:purgeActivity()
	if self.data then
		if UserData and UserData:getUserObj() then
		 	local activityNames = UserData:getUserObj().activity_value_key
		 	if activityNames then
				for filenNme, v in pairs(activityNames) do
					if self.data[filenNme] then
						self.data[filenNme] = nil
					end
				end
			end
		end
	end
	if self.data['activities'] then
		self.data['activities'] = nil
	end
	local filepath
	for filename, v in pairs(self.avData) do
		filepath = "avdata/" .. filename
		if package.loaded[filepath] then
			package.loaded[filepath] = nil
		end
	end
	self.avData = {}
end

function GameData:getConfData(filename)
	if ACTIVITY_CONFIG[filename] then
		return self:getActivityData(filename)
	end

	if self.data[filename] then
		return self.data[filename]
	end

	if filename == "activities" and UserData and UserData:getUserObj() then
		local values = UserData:getUserObj().avconf
		if values then
			self.data[filename] = values
			return self.data[filename]
		end
	end

	local filepath = "data/" .. filename
	if package.loaded[filepath] then
		package.loaded[filepath] = nil
	end

	if SPLIT_TAB[filename] then
		local values = {}
		for i=0,SPLIT_TAB[filename] do
			local filepath = "data/" .. filename..i
			if package.loaded[filepath] then
				package.loaded[filepath] = nil
			end
			local tab = require(filepath)
			for k,v in pairs(tab) do
				values[k] = v
			end
		end
		self.data[filename] = values
		return self.data[filename]
	end

	if UserData and UserData:getUserObj() and UserData:getUserObj().activity_value_key and UserData:getUserObj().activity_value_key[filename] then
		local values = require(filepath)
		local activity = UserData:getUserObj().avconf
		local key = UserData:getUserObj().activity_value_key[filename].key
		local stage = tonumber(activity[key].stage)
		local temp = {}
		for k,v in ipairs(values[stage]) do
			if type(v) ~= "string" then
				temp[k] = v
			end
		end
		self.data[filename] = temp
		return self.data[filename]
	end

	self.data[filename] = require(filepath)
	return self.data[filename]
end

function GameData:getActivityData(filename)
	if self.avData[filename] then
		return self.avData[filename]
	end

	local filepath = "avdata/" .. filename
	if package.loaded[filepath] then
		package.loaded[filepath] = nil
	end
	
	if UserData and UserData:getUserObj() and UserData:getUserObj().activity_value_key and UserData:getUserObj().activity_value_key[filename] then
		local values = require(filepath)
		local activity = UserData:getUserObj().avconf
		local key = UserData:getUserObj().activity_value_key[filename].key
		local stage = tonumber(activity[key].stage)
		local temp = {}
		for k,v in ipairs(values[stage]) do
			if type(v) ~= "string" then
				temp[k] = v
			end
		end
		self.avData[filename] = temp
		return self.avData[filename]
	end

	self.avData[filename] = require(filepath)
	return self.avData[filename]
end