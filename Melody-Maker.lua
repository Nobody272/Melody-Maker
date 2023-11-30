-- Melody Maker
-- Version: 2.4
-- Changelog:
-- Todo:
system.setScriptName('~t1~Melody Maker')

-- Initialization
system.registerConstructor(function()
logger.logCustom('<#A020F0>[<b>Melody Maker: <#FFFFFF>Loaded!</#A020F0></b><#A020F0>]')
notifications.alertInfo("Welcome to Melody Maker!", "Version 2.4 - Enjoy playing!")
end)

-- Submenu IDs
local spawner_submenu_id = menu.addSubmenu('self', '~t3~Spawner', 'Customize and play animations.')
local male_scenarios_submenu_id = menu.addSubmenu('self', '~t6~Male Scenarios', 'Select and play scenarios for male characters.')
local female_scenarios_submenu_id = menu.addSubmenu('self', '~t5~Female Scenarios', 'Select and play scenarios for female characters.')

-- Props
local piano_model_hash = 0x4D6B282C
local chair_model_hash = 0x511C1D91
local piano_chair_model_hash = 0xF976349B

-- Position and other stuff
local is_entity_frozen = false
local original_x, original_y, original_z
local adjustment_increment = 1.0

-- Scenario Tables
local male_instrument_scenarios = {
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

local female_instrument_scenarios = {
  ['Piano Female'] = 'PROP_HUMAN_ABIGAIL_PIANO',
  ['Fiddle Female'] = 'PROP_HUMAN_SEAT_BENCH_FIDDLE'
}

local spawner_scenarios = {
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

local piano_scenarios = {
  'Piano',
  'Piano Riverboat',
  'Piano Sketchy',
  'Piano UpperClass',
  'Piano Female'
}

local seat_only_scenarios = {
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

local normal_scenarios = {
  'Guitar',
  'Guitar Downbeat',
  'Guitar Upbeat',
  'Trumpet'
}

local function toggle_entity_freeze(toggle)
  is_entity_frozen = toggle
  local player_ped = player.getLocalPed()
  natives.entity_freezeEntityPosition(player_ped, is_entity_frozen)
  if is_entity_frozen then
    original_x, original_y, original_z = player.getLocalPedCoords()
  end
end

local function update_player_position(delta_x, delta_y, delta_z)
  if is_entity_frozen then
    local player_ped = player.getLocalPed()
    local new_x = original_x + delta_x * adjustment_increment
    local new_y = original_y + delta_y * adjustment_increment
    local new_z = original_z + delta_z * adjustment_increment
    natives.entity_setEntityCoords(player_ped, new_x, new_y, new_z, false, false, false, false)
    natives.entity_placeEntityOnGroundProperly(player_ped, false)
  end
end

-- Advanced Settings
menu.addDivider('self', 'Advanced Settings')

menu.addFloatSpinner('self', '~t1~Adjustment Increment', 'Adjust the increment for position adjustments.', 0.1, 10.0, 1.0, adjustment_increment, function(value)
adjustment_increment = value
end)

menu.addFloatSpinner('self', '~m~Position X', 'Adjust the X coordinate.', -1000.0, 1000.0, 0.1, 0.0, function(delta_x)
update_player_position(delta_x, 0, 0)
end)

menu.addFloatSpinner('self', '~m~Position Y', 'Adjust the Y coordinate.', -1000.0, 1000.0, 0.1, 0.0, function(delta_y)
update_player_position(0, delta_y, 0)
end)

menu.addFloatSpinner('self', '~m~Position Z', 'Adjust the Z coordinate.', -1000.0, 1000.0, 0.1, 0.0, function(delta_z)
update_player_position(0, 0, delta_z)
end)

local function is_piano_scenario(scenario_name)
  for _, name in ipairs(piano_scenarios) do
    if name == scenario_name then
      return true
    end
  end
  return false
end
local function is_seat_only_scenario(scenario_name)
  for _, name in ipairs(seat_only_scenarios) do
    if name == scenario_name then
      return true
    end
  end
  return false
end

local spawned_entities = {}

-- Function to start a scenario for the localplayer
local function start_scenario(scenario_name, scenario_table)
  local player_ped = player.getLocalPed()
  local coordX, coordY, coordZ = natives.entity_getEntityCoords(player_ped, true, true)
  local forwardX, forwardY, _ = natives.entity_getEntityForwardVector(player_ped)
  local rotX, rotY, rotZ = natives.entity_getEntityRotation(player_ped, 2)
  local player_heading = natives.entity_getEntityHeading(player_ped)
  local scenario_hash = natives.misc_getHashKey(scenario_table[scenario_name])
  local height_offset = normal_scenarios[scenario_name] and -1 or 0.5
  natives.ped_setBlockingOfNonTemporaryEvents(player_ped, true)
  natives.entity_placeEntityOnGroundProperly(player_ped, false)
  natives.ped_setPedKeepTask(player_ped, true)

  if is_piano_scenario(scenario_name) then
    local spawnOffsetX = forwardX * 0.8
    local spawnOffsetY = forwardY * 0.8
    local piano = spawner.spawnObject(piano_model_hash, coordX + spawnOffsetX, coordY + spawnOffsetY, coordZ, true)
    natives.object_placeObjectOnGroundProperly(piano, false)
    natives.entity_setEntityRotation(piano, rotX, rotY, rotZ, 2, true)
    natives.entity_freezeEntityPosition(piano, true)
    table.insert(spawned_entities, piano)

    natives.task_taskStartScenarioAtPosition(player_ped, scenario_hash, coordX, coordY, coordZ - height_offset, player_heading, -1, true, true, "", 0.0, false)
    system.yield(1000)

    local chair = spawner.spawnObject(piano_chair_model_hash, coordX + 0.02, coordY + 0.0, coordZ - 1, true)
    natives.object_placeObjectOnGroundProperly(chair, false)
    natives.entity_setEntityRotation(chair, rotX, rotY, rotZ, 2, true)
    natives.entity_freezeEntityPosition(chair, true)
    table.insert(spawned_entities, chair)

  elseif is_seat_only_scenario(scenario_name) then
    natives.task_taskStartScenarioAtPosition(player_ped, scenario_hash, coordX, coordY, coordZ - height_offset, player_heading, -1, true, true, "", 0.0, false)
    system.yield(1000)

    local chair = spawner.spawnObject(chair_model_hash, coordX + 0.02, coordY, coordZ - 1, true)
    natives.object_placeObjectOnGroundProperly(chair, false)
    natives.entity_setEntityRotation(chair, rotX, rotY, rotZ, 2, true)
    natives.entity_freezeEntityPosition(chair, true)
    table.insert(spawned_entities, chair)

  else
    natives.task_taskStartScenarioAtPosition(player_ped, scenario_hash, coordX, coordY, coordZ - height_offset, player_heading, -1, true, false, "", 0.0, false)
  end
end

-- Function to start a scenario for a spawned ped
local function start_scenario_for_spawned_ped(scenario_name, scenario_table)
  local coordX, coordY, coordZ = player.getLocalPedCoords()
  local ped_model_hash = 0x3BF7829E
  local spawned_ped = spawner.spawnPed(ped_model_hash, coordX, coordY, coordZ, true)
  natives.entity_placeEntityOnGroundProperly(spawned_ped, false)
  natives.ped_setPedKeepTask(spawned_ped, true)
  natives.entity_setEntityInvincible(spawned_ped, true)
  natives.ped_setPedConfigFlag(spawned_ped, 61, true)
  natives.ped_setPedCanBeLassoed(spawned_ped, false)
  natives.ped_setPedCanBeTargetted(spawned_ped, false)
  natives.ped_setPedCanRagdoll(spawned_ped, false)
  natives.ped_setBlockingOfNonTemporaryEvents(spawned_ped, true)
  natives.ped_setPedFleeAttributes(spawned_ped, 0, false)
  natives.ped_setPedCombatAttributes(spawned_ped, 17, true)
  natives.ped_setPedLassoHogtieFlag(spawned_ped, 0, false)

  if not spawned_ped then
    logger.logError("Failed to spawn ped for scenario: " .. scenario_name)
    return
  end

  table.insert(spawned_entities, spawned_ped)
  local forwardX, forwardY, _ = natives.entity_getEntityForwardVector(spawned_ped)
  local rotX, rotY, rotZ = natives.entity_getEntityRotation(spawned_ped, 2)
  local ped_heading = natives.entity_getEntityHeading(spawned_ped)
  local scenario_hash = natives.misc_getHashKey(scenario_table[scenario_name])
  local height_offset = normal_scenarios[scenario_name] and -1 or 0.5

  if is_piano_scenario(scenario_name) then
    local spawnOffsetX = forwardX * 0.8
    local spawnOffsetY = forwardY * 0.8
    local piano = spawner.spawnObject(piano_model_hash, coordX + spawnOffsetX, coordY + spawnOffsetY, coordZ, true)
    natives.object_placeObjectOnGroundProperly(piano, false)
    natives.entity_setEntityRotation(piano, rotX, rotY, rotZ, 2, true)
    natives.entity_freezeEntityPosition(piano, true)
    table.insert(spawned_entities, piano)

    natives.task_taskStartScenarioAtPosition(spawned_ped, scenario_hash, coordX, coordY, coordZ - height_offset, ped_heading, -1, true, true, "", 0.0, false)
    system.yield(1000)

    local chair = spawner.spawnObject(piano_chair_model_hash, coordX + 0.02, coordY + 0.0, coordZ - 1, true)
    natives.object_placeObjectOnGroundProperly(chair, false)
    natives.entity_setEntityRotation(chair, rotX, rotY, rotZ, 2, true)
    natives.entity_freezeEntityPosition(chair, true)
    table.insert(spawned_entities, chair)

  elseif is_seat_only_scenario(scenario_name) then
    natives.task_taskStartScenarioAtPosition(spawned_ped, scenario_hash, coordX, coordY, coordZ - height_offset, ped_heading, -1, true, true, "", 0.0, false)
    system.yield(1000)

    local chair = spawner.spawnObject(chair_model_hash, coordX + 0.02, coordY, coordZ - 1, true)
    natives.object_placeObjectOnGroundProperly(chair, false)
    natives.entity_setEntityRotation(chair, rotX, rotY, rotZ, 2, true)
    natives.entity_freezeEntityPosition(chair, true)
    table.insert(spawned_entities, chair)

  else
    natives.task_taskStartScenarioAtPosition(spawned_ped, scenario_hash, coordX, coordY, coordZ - height_offset, ped_heading, -1, true, false, "", 0.0, false)
  end
end

local function delete_spawned_entities()
  for _, entity in ipairs(spawned_entities) do
    spawner.deleteObject(entity)
  end
  spawned_entities = {}
end
menu.addButton('self', '~t4~Delete Spawned entities', 'Delete all spawned entities.', delete_spawned_entities)

menu.addToggleButton('self', '~t2~Toggle Freeze', 'Freeze or unfreeze your character.', is_entity_frozen, toggle_entity_freeze)

menu.addButton('self', '~e~Stop Actions Fast', 'Stop all current actions immediately.', function()
natives.task_clearPedTasksImmediately(player.getLocalPed(), true, false)
end)

menu.addButton('self', '~e~Stop Actions Slow', 'Stop all current actions slowly.', function()
natives.task_clearPedTasks(player.getLocalPed(), true, true)
end)

local function create_scenario_buttons(submenu_id, scenario_dict, is_spawner)
  local sorted_scenarios = {}
  for scenario_name in pairs(scenario_dict) do
    table.insert(sorted_scenarios, scenario_name)
  end
  table.sort(sorted_scenarios)

  for _, scenario_name in ipairs(sorted_scenarios) do
    menu.addButton(submenu_id, scenario_name, 'Play ' .. scenario_name, function()
    if is_spawner then
      start_scenario_for_spawned_ped(scenario_name, scenario_dict)
    else
      start_scenario(scenario_name, scenario_dict)
    end
    end)
  end
end

-- Let there be buttons!
create_scenario_buttons(male_scenarios_submenu_id, male_instrument_scenarios, false)
create_scenario_buttons(female_scenarios_submenu_id, female_instrument_scenarios, false)
create_scenario_buttons(spawner_submenu_id, spawner_scenarios, true)