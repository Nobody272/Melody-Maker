-- Melody Maker LUA Beta Script
-- Version: 1.0.5
-- Author: Nobody_272
-- GitHub: https://github.com/Nobody272/Melody-Maker
-- License: GNU General Public License v3.0
-- License URI: https://www.gnu.org/licenses/gpl-3.0.en.html
-- Male instrument scenarios dictionary
local INSTRUMENT_SCENARIOS = {
	['Piano'] = 'PROP_HUMAN_PIANO',
	['Piano Riverboat'] = 'PROP_HUMAN_PIANO_RIVERBOAT',
	['Piano Sketchy'] = 'PROP_HUMAN_PIANO_SKETCHY',
	['Piano UpperClass'] = 'PROP_HUMAN_PIANO_UPPERCLASS',
	['Concertina'] = 'PROP_HUMAN_SEAT_BENCH_CONCERTINA',
	['Concertina Downbeat'] = 'PROP_HUMAN_SEAT_BENCH_CONCERTINA_DOWNBEAT',
	['Concertina Upbeat'] = 'PROP_HUMAN_SEAT_BENCH_CONCERTINA_UPBEAT',
	['Harmonica'] = 'PROP_HUMAN_SEAT_BENCH_HARMONICA',
	['Harmonica Downbeat'] = 'PROP_HUMAN_SEAT_BENCH_HARMONICA_DOWNBEAT',
	['Harmonica Upbeat'] = 'PROP_HUMAN_SEAT_BENCH_HARMONICA_UPBEAT',
	['Jaw Harp'] = 'PROP_HUMAN_SEAT_BENCH_JAW_HARP',
	['Jaw Harp Downbeat'] = 'PROP_HUMAN_SEAT_BENCH_JAW_HARP_DOWNBEAT',
	['Jaw Harp Upbeat'] = 'PROP_HUMAN_SEAT_BENCH_JAW_HARP_UPBEAT',
	['Mandolin'] = 'PROP_HUMAN_SEAT_BENCH_MANDOLIN',
	['Banjo'] = 'PROP_HUMAN_SEAT_CHAIR_BANJO',
	['Banjo Downbeat'] = 'PROP_HUMAN_SEAT_CHAIR_BANJO_DOWNBEAT',
	['Banjo Upbeat'] = 'PROP_HUMAN_SEAT_CHAIR_BANJO_UPBEAT',
	['Guitar'] = 'WORLD_HUMAN_SIT_GUITAR',
	['Guitar Downbeat'] = 'WORLD_HUMAN_SIT_GUITAR_DOWNBEAT',
	['Guitar Upbeat'] = 'WORLD_HUMAN_SIT_GUITAR_UPBEAT',
	['Trumpet'] = 'WORLD_HUMAN_TRUMPET'
}
-- Spawned ped scenarios dictionary
local SPAWNED_PED_SCENARIOS = {
	['Piano'] = 'PROP_HUMAN_PIANO',
	['Piano Riverboat'] = 'PROP_HUMAN_PIANO_RIVERBOAT',
	['Piano Sketchy'] = 'PROP_HUMAN_PIANO_SKETCHY',
	['Piano UpperClass'] = 'PROP_HUMAN_PIANO_UPPERCLASS',
	['Harmonica'] = 'PROP_HUMAN_SEAT_BENCH_HARMONICA',
	['Harmonica Downbeat'] = 'PROP_HUMAN_SEAT_BENCH_HARMONICA_DOWNBEAT',
	['Harmonica Upbeat'] = 'PROP_HUMAN_SEAT_BENCH_HARMONICA_UPBEAT',
	['Jaw Harp'] = 'PROP_HUMAN_SEAT_BENCH_JAW_HARP',
	['Jaw Harp Downbeat'] = 'PROP_HUMAN_SEAT_BENCH_JAW_HARP_DOWNBEAT',
	['Jaw Harp Upbeat'] = 'PROP_HUMAN_SEAT_BENCH_JAW_HARP_UPBEAT',
	['Guitar'] = 'WORLD_HUMAN_SIT_GUITAR',
	['Guitar Downbeat'] = 'WORLD_HUMAN_SIT_GUITAR_DOWNBEAT',
	['Guitar Upbeat'] = 'WORLD_HUMAN_SIT_GUITAR_UPBEAT',
	['Trumpet'] = 'WORLD_HUMAN_TRUMPET'
}
-- Female instrument scenarios dictionary
local FEMALE_INSTRUMENT_SCENARIOS = {
	['Piano Female'] = 'PROP_HUMAN_ABIGAIL_PIANO',
	['Fiddle Female'] = 'PROP_HUMAN_SEAT_BENCH_FIDDLE'
}
local PIANO_SCENARIOS = {
	'Piano',
	'Piano Riverboat',
	'Piano Sketchy',
	'Piano UpperClass',
	'Piano Female'
}

local SEAT_ONLY_SCENARIOS = {
	'Concertina',
	'Concertina Downbeat',
	'Concertina Upbeat',
	'Harmonica',
	'Harmonica Downbeat',
	'Harmonica Upbeat',
	'Jaw Harp',
	'Jaw Harp Downbeat',
	'Jaw Harp Upbeat',
	'Mandolin',
	'Banjo',
	'Banjo Downbeat',
	'Banjo Upbeat',
	'Fiddle Female'
}

local NORMAL_SCENARIOS = {
	'Guitar',
	'Guitar Downbeat',
	'Guitar Upbeat',
	'Trumpet'
}

local LOCAL_PLAYER = natives.player_playerPedId()

-- Function to log the status of the operations
local function logStatus(isSuccessful, scenarioName, errorStr)
	local logFormatStr = isSuccessful and
	'%s scenario started successfully' or
	'Failed to start %s scenario: %s'

	local logFn = isSuccessful and
	logger.logSuccess or
	logger.logError

	logFn(string.format(logFormatStr, scenarioName, errorStr))
end
-- Function to get the hash using natives.misc_getHashKey function
function getHash(scenarioName)
	return natives.misc_getHashKey(scenarioName)
end
-- Function to create buttons for each scenario in the menu
local function createScenarioButtons(subMenu, scenarioDict, callbackFn)
	local scenarioNames = {}
	for scenarioName, _ in pairs(scenarioDict) do
		table.insert(scenarioNames, scenarioName)
	end

	-- Sort the scenario names to maintain the order from the tables
	table.sort(scenarioNames)

	for _, scenarioName in ipairs(scenarioNames) do
		local scenarioHashStr = scenarioDict[scenarioName]
		local scenarioHash = getHash(scenarioHashStr)
		menu.addButton(subMenu, scenarioName, scenarioName, function()
		callbackFn(LOCAL_PLAYER, scenarioName, scenarioHash)
		end)
	end
end
local function isPianoScenario(scenarioName)
	for _, name in ipairs(PIANO_SCENARIOS) do
		if name == scenarioName then
			return true
		end
	end
	return false
end

local function isSeatOnlyScenario(scenarioName)
	for _, name in ipairs(SEAT_ONLY_SCENARIOS) do
		if name == scenarioName then
			return true
		end
	end
	return false
end

local function isNormalScenario(scenarioName)
	for _, name in ipairs(NORMAL_SCENARIOS) do
		if name == scenarioName then
			return true
		end
	end
	return false
end
local function startScenarioCommonLogic(scenarioHash, ped, scenarioName)
	-- Common logic to start the scenario
	logger.logInfo('Starting the scenario')

	local coordX, coordY, coordZ = natives.entity_getEntityCoords(ped, true, true)
	local playerHeading = natives.entity_getEntityHeading(ped) -- Get the player's heading

	-- Initialize the default height to 0.5
	local heightOffset = 0.5

	-- Check if the scenario is a NORMAL_SCENARIO and adjust the height accordingly
	if isNormalScenario(scenarioName) then
		heightOffset = -1
	end

	-- Manually adjust the coordZ value based on height offset
	coordZ = coordZ - heightOffset

	natives.task_taskStartScenarioAtPosition(ped, scenarioHash, coordX, coordY, coordZ, playerHeading, -1, 0, 0, "", true, 0)

	logger.logSuccess('Successfully started scenario')
end

local function startScenarioForPed(ped, scenarioName, scenarioHash)
	logger.logInfo(string.format('Attempting to start %s scenario: %s', scenarioName, tostring(scenarioHash)))

	if not scenarioHash then
		logger.logError('Scenario hash is nil for scenario name: ' .. scenarioName)
		return
	end

	local status, err = pcall(function()
	local coordX, coordY, coordZ = natives.entity_getEntityCoords(ped, true, true)
	local forwardX, forwardY, forwardZ = natives.entity_getEntityForwardVector(ped)
	local rotX, rotY, rotZ = natives.entity_getEntityRotation(ped, 2)

	local pianoModel = 0x4D6B282C
	local chairModel = 0x511C1D91
	local PianoChairModel = 0xF976349B

	if isPianoScenario(scenarioName) then
		logger.logInfo('Spawning piano prop')
		local spawnOffsetX = forwardX * 0.8  -- Adjust as necessary
		local spawnOffsetY = forwardY * 0.8  -- Adjust as necessary
		local pianoObjectEntityIndex = spawner.spawnObject(pianoModel, coordX + spawnOffsetX, coordY + spawnOffsetY, coordZ, true)
		natives.object_placeObjectOnGroundProperly(pianoObjectEntityIndex, false)
		natives.entity_setEntityRotation(pianoObjectEntityIndex, rotX, rotY, rotZ, 2, true)

		-- Start the scenario immediately after spawning the piano
		startScenarioCommonLogic(scenarioHash, ped)

		-- Add a delay before spawning the chair
		system.yield(1000)

		logger.logInfo('Spawning piano chair prop')
		spawnOffsetX = 0.02  -- Adjust as necessary
		spawnOffsetY = 0.0   -- Adjust as necessary
		local seatObjectEntityIndex = spawner.spawnObject(PianoChairModel, coordX + spawnOffsetX, coordY + spawnOffsetY, coordZ - 1, true)
		natives.object_placeObjectOnGroundProperly(seatObjectEntityIndex, false)
		natives.entity_setEntityRotation(seatObjectEntityIndex, rotX, rotY, rotZ, 2, true)
	elseif isSeatOnlyScenario(scenarioName) then
		logger.logInfo('Spawning seat only')

		-- Start the scenario immediately
		startScenarioCommonLogic(scenarioHash, ped)

		-- Add a delay before spawning the chair
		system.yield(1000)

		spawnOffsetX = 0.02  -- Adjust as necessary
		spawnOffsetY = 0.0   -- Adjust as necessary
		local seatObjectEntityIndex = spawner.spawnObject(chairModel, coordX + spawnOffsetX, coordY + spawnOffsetY, coordZ - 1, true)
		natives.object_placeObjectOnGroundProperly(seatObjectEntityIndex, false)
		natives.entity_setEntityRotation(seatObjectEntityIndex, rotX, rotY, rotZ, 2, true)
	elseif isNormalScenario(scenarioName) then
		logger.logInfo('Normal scenario, no additional props will be spawned')

		-- Start the scenario immediately
		startScenarioCommonLogic(scenarioHash, ped)
	else
		logger.logError('Unknown scenario name: ' .. scenarioName)
		return
	end
	end)

	if not status then
		logger.logError('Failed to start scenario: ' .. tostring(err))
	end
end

-- Function to clear tasks for the ped
function clearTasksForPed()
	local ped = player.getLocalPed()
	natives.task_clearPedTasks(ped, false, false)
end

-- Function to clear tasks for the ped immediately
function clearTasksForPedImmediately()
	local ped = player.getLocalPed()
	natives.task_clearPedTasksImmediately(ped, false, resetCrouch)
end

-- Create submenus
local maleScenarioSubmenuId = menu.addSubmenu('self', 'Male Scenarios', 'Choose a male scenario to start')
local femaleScenarioSubmenuId = menu.addSubmenu('self', 'Female Scenarios', 'Choose a female scenario to start')
local scenarioSpawnerSubmenuId = menu.addSubmenu('self', 'Scenario Spawner (PlaceHolder)', 'Spawn a new scenario')

-- Add buttons to the submenus
createScenarioButtons(maleScenarioSubmenuId, INSTRUMENT_SCENARIOS, startScenarioForPed)
createScenarioButtons(femaleScenarioSubmenuId, FEMALE_INSTRUMENT_SCENARIOS, startScenarioForPed)
createScenarioButtons(scenarioSpawnerSubmenuId, SPAWNED_PED_SCENARIOS, startScenarioForPed)

local clearImmediately = false
local resetCrouch = true

-- Add buttons to clear tasks
menu.addButton(maleScenarioSubmenuId, 'Clear Tasks', '', clearTasksForPed)
menu.addButton(maleScenarioSubmenuId, 'Clear Tasks Immediately', '', clearTasksForPedImmediately)
menu.addButton(femaleScenarioSubmenuId, 'Clear Tasks', '', clearTasksForPed)
menu.addButton(femaleScenarioSubmenuId, 'Clear Tasks Immediately', '', clearTasksForPedImmediately)
menu.addButton(scenarioSpawnerSubmenuId, 'Clear Tasks', '', clearTasksForPed)
menu.addButton(scenarioSpawnerSubmenuId, 'Clear Tasks Immediately', '', clearTasksForPedImmediately)