cc.exports.GameData = {
	data = {},
	avData = {}
}

local SPLIT_TAB = {
	monster = 13,
	buff = 15,
	skill = 16,
}

local ACTIVITY_CONFIG = {
	avdailycost = 1,
	avovervaluedgift = 1,
	avtodaydouble = 1,
	avdayvouchsafe = 1,
	avaccumulaterecharge = 1,
	avdailyrecharge = 1
}

local function splitNumber(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(input, delimiter, pos, true) end do
        table.insert(arr, tonumber(string.sub(input, pos, st - 1)))
        pos = sp + 1
    end
    table.insert(arr, tonumber(string.sub(input, pos)))
    return arr
end

local DATA_PATH = 'data/'

local function readGameDataFile(filename,valueTab)
	local relatePath = DATA_PATH .. filename .. ".dat"

	local chunk = cc.FileUtils:getInstance():getStringFromFile(relatePath)
 	if not chunk then
 		error("*** Failed to read data file: " .. filename)
 	end
 	chunk = string.gsub(chunk, "[\r]*", '')
 	local rowDatas = string.split(chunk , '\n')
	local lineIndex = 0 			-- 配置文件行号
	local keyTable = {} 			-- 存储第二行keys的table
	local typeTable = {}			-- 存储第三行数据类型的table
	local valueTable = valueTab or {} 			-- 存储数据的table
	local validReg = "[\t\n\r]*" 				-- 数据格式匹配样式
	local keyReg = "%a*%d*\t" 					-- key格式匹配
	local valReg = '[\128-\254]*[^\t]*\t' 		-- value格式匹配
	local errorMsg = false
	for _, line in pairs (rowDatas) do
		if string.len(line) > 1 then
			lineIndex = lineIndex + 1
			line = string.gsub(line, "[\r\n]*", '')
			repeat
				if line == '' then 
					break
				end
				line = line .. "\t" 	-- 在末尾添加\t适合以上匹配模式
				if lineIndex <= 1 then
					--print('--- Ingore first line ---')
				elseif lineIndex == 2 then 	-- 第二行为keys，其他为数据
					string.gsub(line, valReg, function(key)
						local keyName = string.gsub(key, validReg, '')
						table.insert(keyTable, keyName)
					end)
				elseif lineIndex == 3 then 	-- 第三行为类型，其他为数据
					string.gsub(line, keyReg, function(key)
						local typeName = string.gsub(key, validReg, '')
						table.insert(typeTable, typeName)
					end)
				else
					local keyIndex = 1
					local keyContent = 1
					local secondKeyContent = nil
					local thirdKeyContent = nil
					string.gsub(line, valReg, function(val)
						local realKey = keyTable[keyIndex]
						if realKey then
							local realValue = string.gsub(val, validReg, '')
							if keyIndex == 1 then
								if string.sub(typeTable[keyIndex], 1, 3) == "Int" then
									keyContent = tonumber(realValue)
								else
									keyContent = realValue
								end
							elseif keyIndex == 2 then
								if typeTable[keyIndex] == "Int2" then
									secondKeyContent = tonumber(realValue)
								elseif typeTable[keyIndex] == "String2" then
									secondKeyContent = realValue
								end
							elseif keyIndex == 3 then
								if typeTable[keyIndex] == "Int3" then
									thirdKeyContent = tonumber(realValue)
								elseif typeTable[keyIndex] == "String3" then
									thirdKeyContent = realValue
								end
							end
							if typeTable[keyIndex] == "Int" then
								if realValue == "" then
									errorMsg = true
									realValue = 0
								else
									realValue = tonumber(realValue)
								end
							elseif typeTable[keyIndex] == "Ints" then
								if realValue == "" then
									realValue = {}
								elseif realValue == "nil" then
									realValue = nil
								else
									realValue = splitNumber(realValue, '|')
								end
							elseif typeTable[keyIndex] == "Strings" then
								if realValue == "" then
									realValue = {}
								elseif realValue == "nil" then
									realValue = nil
								else
									realValue = string.split(realValue, '|')
								end
							elseif typeTable[keyIndex] == "Dyadicarray" then
								realValue = string.split(realValue, '|')
								for k, v in pairs(realValue) do
									local value = string.split(v, ',')
									realValue[k] = value
								end
							elseif typeTable[keyIndex] == "Dyadicarraymap" then
								local realValueArr = string.split(realValue, '|')
								realValue = {}
								for k, v in pairs(realValueArr) do
									local value = string.split(v, ':')
									local value2 = string.split(value[2], ',')
									realValue[value[1]] = value2
								end
							elseif typeTable[keyIndex] == "Award" then
								if realValue == "" or realValue == "0" then
									realValue = {}
								else
									local realValueArr = string.split(realValue, ',')
									realValue = {}
									for k, v in pairs(realValueArr) do
					                    local segs = string.split(v, ":")
					                    if #segs == 2 then
					                        local award = string.split(segs[1], ".")
					                        table.insert(award, tonumber(segs[2]))
					                        table.insert(realValue, award)
					                    end
									end
								end
							elseif typeTable[keyIndex] == "Ignore" then
								keyIndex = keyIndex + 1
								return
							end
							valueTable[keyContent] = valueTable[keyContent] or {}
							if thirdKeyContent then
								valueTable[keyContent][secondKeyContent] = valueTable[keyContent][secondKeyContent] or {}
								valueTable[keyContent][secondKeyContent][thirdKeyContent] = valueTable[keyContent][secondKeyContent][thirdKeyContent] or {}
								valueTable[keyContent][secondKeyContent][thirdKeyContent][realKey] = realValue
							elseif secondKeyContent then
								valueTable[keyContent][secondKeyContent] = valueTable[keyContent][secondKeyContent] or {}
								valueTable[keyContent][secondKeyContent][realKey] = realValue
							else
								valueTable[keyContent][realKey] = realValue
							end
							keyIndex = keyIndex + 1
						end
					end)
				end
			until true
		end		
	end -- end of for
	if errorMsg then
		promptmgr:showMessageBox(filename .. "表里的int型数据不能为空！", MESSAGE_BOX_TYPE.MB_OK)
	end
	return valueTable
end

function GameData:purge()
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

	if filename == 'activities' and UserData and UserData:getUserObj() then
		local values = UserData:getUserObj().avconf
		if values then
			self.data[filename] = values
			return self.data[filename]
		end
	end

	if SPLIT_TAB[filename] then
		local values = {}
		for i=0,SPLIT_TAB[filename] do
			values = readGameDataFile(filename..i,values)
		end
		self.data[filename] = values
		return self.data[filename]
	end

	local values = readGameDataFile(filename)
	if UserData and UserData:getUserObj() and UserData:getUserObj().activity_value_key and UserData:getUserObj().activity_value_key[filename] then
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

	self.data[filename] = values
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