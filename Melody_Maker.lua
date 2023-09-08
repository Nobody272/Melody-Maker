-- Melody Maker LUA Script
-- Version: 1.0.0
-- Author: Nobody_272
-- GitHub: https://github.com/Nobody272/Melody-Maker
-- License: GNU General Public License v3.0
--
-- Description:
-- Melody Maker is a script that adds a variety of features and enhancements to the Fortitude mod for RDR2.
-- This open-source version of the script excludes certain features to comply with the mod's guidelines.
-- 
-- Features:
-- - Scenarios (Male/Female Scenarios)
-- - Advanced Recovery System (Large and Small Infinite Spawning, Sedated, Dead, etc.)
-- - Misc features like Drive to Waypoint, Taxi, and Auto Drive Instructions
-- 
-- Credits:
-- - BravoSix: Assisted with PTFX and cage development
-- - _m.a.n.o.: Provided exploit and PTFX assets
-- - qsilence: Contributed to Chest Recovery System
-- - Koldo: Assisted substantially with AutoDrive
--
-- Installation:
-- Download the LUA script from the GitHub releases tab and place it in the following directory:
-- \Documents\Fortitude\Red Dead Redemption 2\LUA
--
-- Support:
-- For support, reach out to Nobody_272 on Discord or ping in the Fortitude Discord server.
--
local menu_addIntSpinner, natives_entity_getEntityForwardVector, natives_entity_getEntityRotation, natives_entity_setEntityRotation, natives_object_placeObjectOnGroundProperly = menu.addIntSpinner, natives.entity_getEntityForwardVector, natives.entity_getEntityRotation, natives.entity_setEntityRotation, natives.object_placeObjectOnGroundProperly

local natives_graphics_startNetworkedParticleFxNonLoopedAtCoord, natives_graphics_useParticleFxAsset = natives.graphics_startNetworkedParticleFxNonLoopedAtCoord, natives.graphics_useParticleFxAsset

local logger_logCustom, math_cos, math_getDistance, math_getRandomInt, math_pi, math_sin, natives_entity_freezeEntityPosition, natives_entity_setEntityHeading, natives_entity_setEntityInvincible, natives_entity_setEntityVisible, natives_fire_addExplosion, natives_misc_getHeadingFromVector2d, natives_player_getPlayerPedScriptIndex, spawner_deleteObject, spawner_deletePed, spawner_spawnObject, system_getTickCount64, table_insert = logger.logCustom, math.cos, math.getDistance, math.getRandomInt, math.pi, math.sin, natives.entity_freezeEntityPosition, natives.entity_setEntityHeading, natives.entity_setEntityInvincible, natives.entity_setEntityVisible, natives.fire_addExplosion, natives.misc_getHeadingFromVector2d, natives.player_getPlayerPedScriptIndex, spawner.deleteObject, spawner.deletePed, spawner.spawnObject, system.getTickCount64, table.insert

local spawner_spawnPed, string_format, logStatus, pairs, action = spawner.spawnPed, string.format, logStatus, pairs, action

local logger_logError, logger_logInfo, menu_addButton, menu_addSubmenu, menu_addToggleButton, natives_entity_getEntityCoords, natives_entity_getEntityHeading, natives_entity_setEntityHealth, natives_misc_getHashKey, natives_ped_setPedConfigFlag, natives_player_playerPedId, natives_task_taskStartScenarioAtPosition, pcall, ipairs, clearFunction, natives_ped_equipPedOutfitPreset, spawnFunction, system_registerTick, system_unregisterTick, system_yield = logger.logError, logger.logInfo, menu.addButton, menu.addSubmenu, menu.addToggleButton, natives.entity_getEntityCoords, natives.entity_getEntityHeading, natives.entity_setEntityHealth, natives.misc_getHashKey, natives.ped_setPedConfigFlag, natives.player_playerPedId, natives.task_taskStartScenarioAtPosition, pcall, ipairs, clearFunction, natives.ped_equipPedOutfitPreset, spawnFunction, system.registerTick, system.unregisterTick, system.yield

local LOCAL_PLAYER = natives_player_playerPedId()
local melodyMakerMenuID = menu_addSubmenu('self', 'Melody Maker Male', 'Scenarios and More!')

-- Scenarios for the Melody Maker
local scenarios = {
	{ displayName = 'Piano', hash = 'PROP_HUMAN_PIANO' },
	{ displayName = 'Piano Riverboat', hash = 'PROP_HUMAN_PIANO_RIVERBOAT' },
	{ displayName = 'Piano Sketchy', hash = 'PROP_HUMAN_PIANO_SKETCHY' },
	{ displayName = 'Piano UpperClass', hash = 'PROP_HUMAN_PIANO_UPPERCLASS' },
	{ displayName = 'Concertina', hash = 'PROP_HUMAN_SEAT_BENCH_CONCERTINA' },
	{ displayName = 'Concertina Downbeat', hash = 'PROP_HUMAN_SEAT_BENCH_CONCERTINA_DOWNBEAT' },
	{ displayName = 'Concertina Upbeat', hash = 'PROP_HUMAN_SEAT_BENCH_CONCERTINA_UPBEAT' },
	{ displayName = 'Harmonica', hash = 'PROP_HUMAN_SEAT_BENCH_HARMONICA' },
	{ displayName = 'Harmonica Downbeat', hash = 'PROP_HUMAN_SEAT_BENCH_HARMONICA_DOWNBEAT' },
	{ displayName = 'Harmonica Upbeat', hash = 'PROP_HUMAN_SEAT_BENCH_HARMONICA_UPBEAT' },
	{ displayName = 'Jaw Harp', hash = 'PROP_HUMAN_SEAT_BENCH_JAW_HARP' },
	{ displayName = 'Jaw Harp Downbeat', hash = 'PROP_HUMAN_SEAT_BENCH_JAW_HARP_DOWNBEAT' },
	{ displayName = 'Jaw Harp Upbeat', hash = 'PROP_HUMAN_SEAT_BENCH_JAW_HARP_UPBEAT' },
	{ displayName = 'Mandolin', hash = 'PROP_HUMAN_SEAT_BENCH_MANDOLIN' },
	{ displayName = 'Banjo', hash = 'PROP_HUMAN_SEAT_CHAIR_BANJO' },
	{ displayName = 'Banjo Downbeat', hash = 'PROP_HUMAN_SEAT_CHAIR_BANJO_DOWNBEAT' },
	{ displayName = 'Banjo Upbeat', hash = 'PROP_HUMAN_SEAT_CHAIR_BANJO_UPBEAT' },
	{ displayName = 'Guitar', hash = 'WORLD_HUMAN_SIT_GUITAR' },
	{ displayName = 'Guitar Downbeat', hash = 'WORLD_HUMAN_SIT_GUITAR_DOWNBEAT' },
	{ displayName = 'Guitar Upbeat', hash = 'WORLD_HUMAN_SIT_GUITAR_UPBEAT' },
	{ displayName = 'Trumpet', hash = 'WORLD_HUMAN_TRUMPET' }
}

local function startScenarioForPed(ped, scenarioHash)
	local status, err = pcall(function()
	local coordX, coordY, coordZ = natives_entity_getEntityCoords(ped, true, true)
	natives_task_taskStartScenarioAtPosition(
	ped,
	natives_misc_getHashKey(scenarioHash),
	coordX, coordY, coordZ - 1,
	natives_entity_getEntityHeading(ped),
	-1, 0, 0, "", true, 0
	)
	end)
	if not status then logger_logError("Error starting scenario: " .. err) end
end

local function addScenarioButton(scenario)
	menu_addButton(melodyMakerMenuID, scenario.displayName, "Activate " .. scenario.displayName, function()
	startScenarioForPed(LOCAL_PLAYER, scenario.hash)
	logger_logInfo(scenario.displayName .. ' Activated')
	end)
end

for _, scenario in ipairs(scenarios) do
	addScenarioButton(scenario)
end

local function addButtonClearTasks(title, desc, clearFunction)
	menu_addButton(melodyMakerMenuID, title, desc, function()
	clearFunction(LOCAL_PLAYER, true, true)
	logger_logInfo(desc)
	end)
end

addButtonClearTasks('Clear Tasks (Slow)', 'Stopped any active scenario Slow.', natives.task_clearPedTasks)
addButtonClearTasks('Clear Tasks (Fast)', 'Stopped any active scenario immediately.', natives.task_clearPedTasksImmediately)

-- Female Instrument Scenarios Submenu
local femaleScenariosMenuID = menu_addSubmenu('self', 'Melody Maker Female', 'Instrument scenarios that can only be played by female ped models.')

-- Female Instrument Scenarios for the Menu
local FEMALE_INSTRUMENT_SCENARIOS = {
	{ displayName = 'Piano Female', hash = 'PROP_HUMAN_ABIGAIL_PIANO' },
	{ displayName = 'Fiddle Female', hash = 'PROP_HUMAN_SEAT_BENCH_FIDDLE' }
}

local function startScenarioForPed(ped, scenarioHash)
	local status, err = pcall(function()
	local coordX, coordY, coordZ = natives_entity_getEntityCoords(ped, true, true)
	natives_task_taskStartScenarioAtPosition(
	ped,
	natives_misc_getHashKey(scenarioHash),
	coordX, coordY, coordZ - 1,
	natives_entity_getEntityHeading(ped),
	-1, 0, 0, "", true, 0
	)
	end)
	if not status then logger_logError("Error starting scenario: " .. err) end
end

local function addScenarioButton(menuID, scenario)
	menu_addButton(menuID, scenario.displayName, "Activate " .. scenario.displayName, function()
	startScenarioForPed(LOCAL_PLAYER, scenario.hash)
	logger_logInfo(scenario.displayName .. ' Activated')
	end)
end

for _, scenario in ipairs(FEMALE_INSTRUMENT_SCENARIOS) do
	addScenarioButton(femaleScenariosMenuID, scenario)
end

local function addButtonClearTasks(menuID, title, desc, clearFunction)
	menu_addButton(menuID, title, desc, function()
	clearFunction(LOCAL_PLAYER, true, true)
	logger_logInfo(desc)
	end)
end

addButtonClearTasks(femaleScenariosMenuID, 'Clear Tasks (Slow)', 'Stopped any active scenario Slow.', natives.task_clearPedTasks)
addButtonClearTasks(femaleScenariosMenuID, 'Clear Tasks (Fast)', 'Stopped any active scenario immediately.', natives.task_clearPedTasksImmediately)

-- Advanced Recovery System Submenu
local advancedRecoveryMenuID = menu_addSubmenu('self', 'Advanced Recovery System', 'Manage your recovery features.')

-- Large Dead Animals
largeDeadAnimals = {
	{ hash = 0xDF251C39, variant = 3, flag = 1 }, -- Golden Spirt Bear
	{ hash = 0xDF251C39, variant = 1, flag = 1 }, -- Owiza Bear
	{ hash = 0xDF251C39, variant = 2, flag = 1 }, -- Ridgeback Spirit Bear
	{ hash = 0xC971C4C6, variant = 2, flag = 1 }, -- Patya Bison
	{ hash = 0xC971C4C6, variant = 1, flag = 1 }, -- Winyan Bison
	{ hash = 0xF8FC8F63, variant = 3, flag = 1 }, -- Ruddy Moose
	{ hash = 0xF8FC8F63, variant = 1, flag = 1 }, -- Snowflake Moose
	{ hash = 0xD1641E60, variant = 3, flag = 1 }, -- Inahme Elk
	{ hash = 0xD1641E60, variant = 2, flag = 1 }, -- Ozula Elk
}

-- Small Dead Animals
smallDeadAnimals = {
	{ hash = 0xBB746741, variant = 1, flag = 1 }, -- Moon Beaver
	{ hash = 0xBB746741, variant = 2, flag = 1 }, -- Night Beaver
	{ hash = 0xBB746741, variant = 0, flag = 1 }, -- Zizi Beaver
	{ hash = 0xE1884260, variant = 1, flag = 1 }, -- Chalk Big Horn Ram
	{ hash = 0xE1884260, variant = 2, flag = 1 }, -- Rutile Big Horn Ram
	{ hash = 0xE8CBC01C, variant = 0, flag = 1 }, -- Cogi Boar
	{ hash = 0xE8CBC01C, variant = 2, flag = 1 }, -- Icahi Boar
	{ hash = 0xE8CBC01C, variant = 1, flag = 1 }, -- Wakpa Boar
	{ hash = 0x9770DD23, variant = 2, flag = 1 }, -- Mud Runner Buck
	{ hash = 0x9770DD23, variant = 4, flag = 1 }, -- Shadow Buck
	{ hash = 0xAA89BB8D, variant = 0, flag = 1 }, -- Iguga Cougar
	{ hash = 0xAA89BB8D, variant = 1, flag = 1 }, -- Maza Cougar
	{ hash = 0xB20D360D, variant = 1, flag = 1 }, -- Midnight Paw Coyote
	{ hash = 0xDECA9205, variant = 2, flag = 1 }, -- Cross Fox
	{ hash = 0xDECA9205, variant = 1, flag = 1 }, -- Marble Fox
	{ hash = 0xDECA9205, variant = 0, flag = 1 }, -- Ota Fox
	{ hash = 0xAD02460F, variant = 0, flag = 1 }, -- Emerald Wolf
	{ hash = 0xAD02460F, variant = 2, flag = 1 }, -- Moonstone Wolf
	{ hash = 0xB91BAB89, variant = 1, flag = 1 }, -- Ghost Panther
	{ hash = 0xB91BAB89, variant = 2, flag = 1 }, -- Iwakta Panther
}

-- Sedated Large Animals
sedatedLargeAnimals = {
	{ hash = 0xDF251C39, variant = 3, flag = 580 }, -- Sedated Golden Spirt Bear
	{ hash = 0xDF251C39, variant = 1, flag = 580 }, -- Sedated Owiza Bear
	{ hash = 0xDF251C39, variant = 2, flag = 580 }, -- Sedated Ridgeback Spirit Bear
	{ hash = 0xC971C4C6, variant = 2, flag = 580 }, -- Sedated Patya Bison
	{ hash = 0xC971C4C6, variant = 1, flag = 580 }, -- Sedated Winyan Bison
	{ hash = 0xF8FC8F63, variant = 3, flag = 580 }, -- Sedated Ruddy Moose
	{ hash = 0xF8FC8F63, variant = 1, flag = 580 }, -- Sedated Snowflake Moose
	{ hash = 0xD1641E60, variant = 3, flag = 580 }, -- Sedated Inahme Elk
	{ hash = 0xD1641E60, variant = 2, flag = 580 }, -- Sedated Ozula Elk
}

-- Sedated Small Animals
sedatedSmallAnimals = {
	{ hash = 0xBB746741, variant = 1, flag = 580 }, -- Sedated Moon Beaver
	{ hash = 0xBB746741, variant = 2, flag = 580 }, -- Sedated Night Beaver
	{ hash = 0xBB746741, variant = 0, flag = 580 }, -- Sedated Zizi Beaver
	{ hash = 0xE1884260, variant = 1, flag = 580 }, -- Sedated Chalk Big Horn Ram
	{ hash = 0xE1884260, variant = 2, flag = 580 }, -- Sedated Rutile Big Horn Ram
	{ hash = 0xE8CBC01C, variant = 0, flag = 580 }, -- Sedated Cogi Boar
	{ hash = 0xE8CBC01C, variant = 2, flag = 580 }, -- Sedated Icahi Boar
	{ hash = 0xE8CBC01C, variant = 1, flag = 580 }, -- Sedated Wakpa Boar
	{ hash = 0x9770DD23, variant = 2, flag = 580 }, -- Sedated Mud Runner Buck
	{ hash = 0x9770DD23, variant = 4, flag = 580 }, -- Sedated Shadow Buck
	{ hash = 0xAA89BB8D, variant = 0, flag = 580 }, -- Sedated Iguga Cougar
	{ hash = 0xAA89BB8D, variant = 1, flag = 580 }, -- Sedated Maza Cougar
	{ hash = 0xB20D360D, variant = 1, flag = 580 }, -- Sedated Midnight Paw Coyote
	{ hash = 0xDECA9205, variant = 2, flag = 580 }, -- Sedated Cross Fox
	{ hash = 0xDECA9205, variant = 1, flag = 580 }, -- Sedated Marble Fox
	{ hash = 0xDECA9205, variant = 0, flag = 580 }, -- Sedated Ota Fox
	{ hash = 0xAD02460F, variant = 0, flag = 580 }, -- Sedated Emerald Wolf
	{ hash = 0xAD02460F, variant = 2, flag = 580 }, -- Sedated Moonstone Wolf
	{ hash = 0xB91BAB89, variant = 1, flag = 580 }, -- Sedated Ghost Panther
	{ hash = 0xB91BAB89, variant = 2, flag = 580 }, -- Sedated Iwakta Panther
}

local toggleStates = {
	largeDeadAnimals = false,
	smallDeadAnimals = false,
	sedatedLargeAnimals = false,
	sedatedSmallAnimals = false
}

local function spawnAnimalsTick(array, spawnFunction, toggleName)
	for _, animal in ipairs(array) do
		if not toggleStates[toggleName] then break end  -- break out of the loop if the toggle is off

		local pedEntityIndex = spawnFunction(animal.hash, 0.0, 0.0, 0.0, true)
		if pedEntityIndex ~= 0 then
			if animal.variant then
				natives_ped_equipPedOutfitPreset(pedEntityIndex, animal.variant, false)
			end
			if animal.flag then
				natives_ped_setPedConfigFlag(pedEntityIndex, animal.flag, true)
			end
			if animal.flag ~= 580 then
				natives_entity_setEntityHealth(pedEntityIndex, 0, 0)
			end
		end

		system_yield(500)
	end
end


menu_addToggleButton(advancedRecoveryMenuID, "Large Dead Animals", "Toggle the spawning of large dead animals on every tick.", false, function(toggleValue)
toggleStates.largeDeadAnimals = toggleValue
if toggleValue then
	system_registerTick(function() spawnAnimalsTick(largeDeadAnimals, spawner_spawnPed, "largeDeadAnimals") end)
else
	system_unregisterTick(function() spawnAnimalsTick(largeDeadAnimals, spawner_spawnPed, "largeDeadAnimals") end)
end
end)

menu_addToggleButton(advancedRecoveryMenuID, "Small Dead Animals", "Toggle the spawning of small dead animals on every tick.", false, function(toggleValue)
toggleStates.smallDeadAnimals = toggleValue
if toggleValue then
	system_registerTick(function() spawnAnimalsTick(smallDeadAnimals, spawner_spawnPed, "smallDeadAnimals") end)
else
	system_unregisterTick(function() spawnAnimalsTick(smallDeadAnimals, spawner_spawnPed, "smallDeadAnimals") end)
end
end)

menu_addToggleButton(advancedRecoveryMenuID, "Sedated Large Animals", "Toggle the spawning of sedated large animals on every tick.", false, function(toggleValue)
toggleStates.sedatedLargeAnimals = toggleValue
if toggleValue then
	system_registerTick(function() spawnAnimalsTick(sedatedLargeAnimals, spawner_spawnPed, "sedatedLargeAnimals") end)
else
	system_unregisterTick(function() spawnAnimalsTick(sedatedLargeAnimals, spawner_spawnPed, "sedatedLargeAnimals") end)
end
end)

menu_addToggleButton(advancedRecoveryMenuID, "Sedated Small Animals", "Toggle the spawning of sedated small animals on every tick.", false, function(toggleValue)
toggleStates.sedatedSmallAnimals = toggleValue
if toggleValue then
	system_registerTick(function() spawnAnimalsTick(sedatedSmallAnimals, spawner_spawnPed, "sedatedSmallAnimals") end)
else
	system_unregisterTick(function() spawnAnimalsTick(sedatedSmallAnimals, spawner_spawnPed, "sedatedSmallAnimals") end)
end
end)

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

local function startScenarioForPed(ped, scenarioName, scenarioHash)
	logger.logInfo(string_format('Attempting to start %s scenario: %s', scenarioName, scenarioHash))

	local status, err = pcall(function()
	local coordX, coordY, coordZ = natives.entity_getEntityCoords(ped, true, true)

	natives.task_taskStartScenarioAtPosition(
	ped,
	natives.misc_getHashKey(scenarioHash),
	coordX, coordY, coordZ - 1,
	natives.entity_getEntityHeading(ped),
	-1, 0, 0, "", true, 0
	)
	end)
end

local function spawnPedScenario(scenarioName, scenarioHash)
	local status, err = pcall(function()
	local modelHash = natives.misc_getHashKey('cs_crackpotrobot')
	local ped = spawner_spawnPed(modelHash, 0.0, 0.0, 0.0, true)
	system.yield(1500)
	startScenarioForPed(ped, scenarioName, scenarioHash)
	end)

	logStatus(status, scenarioName, err)
end

local function createScenarioButton(submenu, scenarioTable, action)
	for displayName, scenarioName in pairs(scenarioTable) do
		menu.addButton(submenu, displayName,
		'This plays the ' .. displayName .. ' scenario',
		function()
			action(displayName, scenarioName)
		end
		)
	end
end

-- Adding submenu for the ped spawning scenarios
local pedSpawnerSubmenu = menu.addSubmenu('self', 'Spawner', 'Spawn a ped playing a scenario')
createScenarioButton(pedSpawnerSubmenu, SPAWNED_PED_SCENARIOS, spawnPedScenario)

-- Your Misc submenu
local MiscID = menu_addSubmenu('self', 'Misc', 'Miscellaneous features.')

-- Function to log the credits to the console with colored text
local function logCredits()
	logger.logCustom('<blue>Credits:')
	logger.logCustom('<green>BravoSix')
	logger.logCustom('<green>_m.a.n.o.')
	logger.logCustom('<green>qsilence')
	logger.logCustom('<green>.koldo.')
end

local getWaypointCoords, isWaypointActive, playerPedId, taskVehicleDriveToDestination, getVehiclePedIsIn, clearPedTasks =
natives.map_getWaypointCoords, natives.map_isWaypointActive, natives.player_playerPedId,
natives.task_taskVehicleDriveToDestination, natives.ped_getVehiclePedIsIn, natives.task_clearPedTasks

local function ToggleDriveToWaypoint(toggleValue)
	local player = playerPedId()
	local vehicle = getVehiclePedIsIn(player, false)

	if toggleValue then
		if not isWaypointActive() then
			logger.logError('Please set a waypoint first.')
			return
		end
		if vehicle == 0 then  -- If player isn't in a vehicle.
			logger.logError('Please enter a vehicle first.')
			return
		end

		local wx, wy, wz = getWaypointCoords()
		if wx and wy and wz then
			taskVehicleDriveToDestination(player, vehicle, wx, wy, wz, 30.0, 524564, 6, 8.0, 0.0, false)
		else
			logger.logError('Couldn\'t fetch waypoint coordinates.')
		end
	else
		clearPedTasks(player, true, true)  -- Letting player regain control
	end
end

menu.addToggleButton(MiscID, 'Drive to Waypoint', 'Toggle auto-driving to the set waypoint.', false, ToggleDriveToWaypoint)

local function AutoDriveInstructions()
	logger.logCustom('<white>Auto Drive Instructions:')
	logger.logCustom('<white>1. Use only with vehicles.')
	logger.logCustom('<white>2. Ensure you set an active waypoint on a road.')
	logger.logCustom('<white>3. Start from a road or close to one.')
	logger.logCustom('<white>4. Make sure you\'re in a vehicle when activating.')
	logger.logCustom('<white>5. If the AutoDrive is not working then try a different waypoint location.')
end

local L, N, M, P, S = logger, natives, menu, player, system
local logError, logInfo, addButton, getWaypointCoords, isWaypointActive, getHashKey, setPedCanBeKnockedOffVehicle, setPedCombatAbility, setPedCombatStyle, setPedConfigFlag, setPedFleeAttributes, setPedIntoVehicle, setPedKeepTask, playerPedId, taskSetBlockingOfNonTemporaryEvents, taskVehicleDriveToDestination, setVehicleOnGroundProperly, getLocalPedCoords, spawnPed, spawnVehicle, setScriptName, yield = L.logError, L.logInfo, M.addButton, N.map_getWaypointCoords, N.map_isWaypointActive, N.misc_getHashKey, N.ped_setPedCanBeKnockedOffVehicle, N.ped_setPedCombatAbility, N.ped_setPedCombatStyle, N.ped_setPedConfigFlag, N.ped_setPedFleeAttributes, N.ped_setPedIntoVehicle, N.ped_setPedKeepTask, N.player_playerPedId, N.task_taskSetBlockingOfNonTemporaryEvents, N.task_taskVehicleDriveToDestination, N.vehicle_setVehicleOnGroundProperly, P.getLocalPedCoords, spawner.spawnPed, spawner.spawnVehicle, S.setScriptName, S.yield

local function configureDriver(driver)
	local playerGroup = N.player_getPlayerGroup(N.player_playerId())
	taskSetBlockingOfNonTemporaryEvents(driver, true)
	setPedKeepTask(driver, true)
end

local function DriveToWaypoint()
	local x, y, z = getLocalPedCoords()

	if not isWaypointActive() then
		return logError('No Waypoint set.')
	end

	local vehicle = spawnVehicle(0x90C51372, x, y, z, false, true)
	if not vehicle then return logError('Failed to spawn vehicle.') end
	setVehicleOnGroundProperly(vehicle, true)

	local driver = spawnPed(getHashKey('cs_crackpotrobot'), x, y, z, true, false)
	if not driver then return logError('Failed to spawn driver.') end
	setPedIntoVehicle(driver, vehicle, -1)
	configureDriver(driver)

	local coDriver = spawnPed(getHashKey('cs_crackpotrobot'), x, y, z, true, false)
	if not coDriver then return logError('Failed to spawn co-driver.') end
	setPedIntoVehicle(coDriver, vehicle, -2)
	configureDriver(coDriver)

	setPedIntoVehicle(playerPedId(), vehicle, 2)

	yield(100)

	local wx, wy, wz = getWaypointCoords()
	if wx and wy and wz then
		taskSetBlockingOfNonTemporaryEvents(driver, true)
		setPedKeepTask(driver, true)
		taskVehicleDriveToDestination(driver, vehicle, wx, wy, wz, 30.0, 524564, 6, 8.0, 0.0, false)
	else
		logError('Failed to get waypoint coordinates.')
	end
end

addButton(MiscID, 'Spawn Taxi', 'Click this to spawn a taxi with drivers', DriveToWaypoint)

menu.addButton(MiscID, 'How to Use Auto Drive', 'View instructions for auto-driving.', AutoDriveInstructions)

-- Add the Credits button to the Misc submenu using the MiscID
menu.addButton(MiscID, 'Credits', 'Click to view credits.', logCredits)

-- Advanced Recovery System Features
local tPed = nil
local spawnedGoldBars = {}
local spawnedMoneyItems = {}
local goldAmount = 1  -- Default value for gold bars
local moneyAmount = 1  -- Default value for money items

-- Spinner to set the gold amount
menu.addIntSpinner(advancedRecoveryMenuID, 'Gold Amount', 'Set the amount of gold in the chest', 1, 100, 1, goldAmount, function(value)
goldAmount = value
end)

-- Spinner to set the money amount
menu.addIntSpinner(advancedRecoveryMenuID, 'Money Amount', 'Set the amount of money in the chest', 1, 100, 1, moneyAmount, function(value)
moneyAmount = value
end)

-- Gold Chest Functionality
local goldOption = menu.addButton(advancedRecoveryMenuID, 'Spawn Gold Chest', 'Spawns a gold chest.', function(pIdx)
local spawnedChest = spawnChestForPlayer(pIdx)
-- Spawn gold bars inside the chest
spawnItemsInsideChest(spawnedChest, 0x2AB28031, goldAmount, spawnedGoldBars)
end)

-- Money Chest Functionality
local moneyOption = menu.addButton(advancedRecoveryMenuID, 'Spawn Money Chest', 'Spawns a money chest.', function(pIdx)
local spawnedChest = spawnChestForPlayer(pIdx)
-- Spawn money items inside the chest
spawnItemsInsideChest(spawnedChest, 0x8BA64C0B, moneyAmount, spawnedMoneyItems)
end)

-- Helper function to spawn a chest in front of a player
function spawnChestForPlayer(pIdx)
	tPed = natives.player_getPlayerPedScriptIndex(pIdx)
	local pX, pY, pZ = natives.entity_getEntityCoords(tPed, true, true)
	local fX, fY, _ = natives_entity_getEntityForwardVector(tPed)

	local chestX, chestY = pX + fX * 2, pY + fY * 2
	local spawnedChest = spawner.spawnObject(0x4E303874, chestX, chestY, pZ, true)
	natives_object_placeObjectOnGroundProperly(spawnedChest, false)
	local pRotX, pRotY, pRotZ = natives_entity_getEntityRotation(tPed, 2)
	natives_entity_setEntityRotation(spawnedChest, pRotX, pRotY, pRotZ, 2, true)

	-- Initiate the PTFX on the chest's location
	local chestPosX, chestPosY, chestPosZ = natives.entity_getEntityCoords(spawnedChest, true, true)

	-- Initiate the PTFX on the chest's location
	natives.graphics_useParticleFxAsset('scr_net_camp')
	natives.graphics_startNetworkedParticleFxNonLoopedAtCoord("scr_net_spirit_animal_fire_react", chestPosX, chestPosY, chestPosZ, 0.0, 0.0, 0.0, 1.0, false, false, false)

	return spawnedChest
end

-- Helper function to spawn items inside a chest
function spawnItemsInsideChest(chest, itemHash, amount, storageTable)
	local chestPosX, chestPosY, chestPosZ = natives.entity_getEntityCoords(chest, true, true)
	local pRotX, pRotY, pRotZ = natives_entity_getEntityRotation(chest, 2)

	local goldOffset = {0}  -- Centered offset for items
	for i = 1, amount do
		for _, offset in ipairs(goldOffset) do
			local item = spawner.spawnObject(itemHash, chestPosX + offset, chestPosY, chestPosZ + 0.25, true)
			natives_entity_setEntityRotation(item, pRotX, pRotY, pRotZ, 2, true)
			table.insert(storageTable, item)
		end
	end
end