-- Melody Maker
-- Version: 2.6
-- Changelog: added the following to the spawner submenu. Accordion, Accordion Downbeat, Accordion Upbeat, Jaw Harp, Jaw Harp Downbeat, Jaw Harp Upbeat, Mandolin, Banjo, Banjo Downbeat, Banjo Upbeat, Fiddle Female, Piano Female. Added new submenu walking scenarios you can now walk and play scenarios with the Banjo, Guitar, Harmonica, Mandolin, & Trumpet.
-- Todo:
system.setScriptName('~t1~Melody Maker')

-- Initialization
system.registerConstructor(function()
logger.logCustom('<#A020F0>[<b>Melody Maker: <#FFFFFF>Loaded!</#A020F0></b><#A020F0>]')
notifications.alertInfo("Welcome to Melody Maker!", "Version 2.6")
end)

-- Submenu IDs
local spawner_submenu_id = menu.addSubmenu('self', '~t3~Spawner', 'Customize and play animations.')
local male_scenarios_submenu_id = menu.addSubmenu('self', '~t6~Male Scenarios', 'Select and play scenarios for male characters.')
local female_scenarios_submenu_id = menu.addSubmenu('self', '~t5~Female Scenarios', 'Select and play scenarios for female characters.')
local walking_scenarios_submenu_id = menu.addSubmenu('self', '~pa~Walking Scenarios', 'Select and play scenarios while walking.')
local gift_music_maker_submenu_id = menu.addSubmenu('player', '~t6~Gift Music Maker', 'Spawn a ped to play music for them.')

-- Props
local piano_model_hash = 0x4D6B282C
local chair_model_hash = 0x511C1D91
local piano_chair_model_hash = 0xF976349B

-- Position and other stuff
local is_entity_frozen = false
local original_x, original_y, original_z
local adjustment_increment = 1.0
local position_delta = { x = 0, y = 0, z = 0 }

-- Scenario Tables
local male_instrument_scenarios = {
  ['Piano'] = 'PROP_HUMAN_PIANO',
  ['Piano Riverboat'] = 'PROP_HUMAN_PIANO_RIVERBOAT',
  ['Piano Sketchy'] = 'PROP_HUMAN_PIANO_SKETCHY',
  ['Piano UpperClass'] = 'PROP_HUMAN_PIANO_UPPERCLASS',
  ['Accordion'] = 'PROP_HUMAN_SEAT_BENCH_CONCERTINA',
  ['Accordion Downbeat'] = 'PROP_HUMAN_SEAT_BENCH_CONCERTINA_DOWNBEAT',
  ['Accordion Upbeat'] = 'PROP_HUMAN_SEAT_BENCH_CONCERTINA_UPBEAT',
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
  ['Guitar Seat'] = 'PROP_HUMAN_SEAT_CHAIR_GUITAR',
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
  ['Piano Female'] = 'PROP_HUMAN_ABIGAIL_PIANO',
  ['Fiddle Female'] = 'PROP_HUMAN_SEAT_BENCH_FIDDLE',
  ['Accordion'] = 'PROP_HUMAN_SEAT_BENCH_CONCERTINA',
  ['Accordion Downbeat'] = 'PROP_HUMAN_SEAT_BENCH_CONCERTINA_DOWNBEAT',
  ['Accordion Upbeat'] = 'PROP_HUMAN_SEAT_BENCH_CONCERTINA_UPBEAT',
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
  ['Guitar Seat'] = 'PROP_HUMAN_SEAT_CHAIR_GUITAR',
  ['Trumpet'] = 'WORLD_HUMAN_TRUMPET'
}

local instrument_objects = {
  ['Guitar'] = {modelHash = 0x3E966583},
  ['Banjo'] = {modelHash = 0x70E78E69},
  ['Harmonica'] = {modelHash = 0x00D09FDF},
  ['Mandolin'] = {modelHash = 0x50A4871E},
  ['Trumpet'] = {modelHash = 0xAA230611}
}

local walking_scenarios_animations = {
  ['Guitar'] = {
    animDict = "ai_gestures@instruments@guitar@seated@chair@80bpm",
    animName = "picking_fast_lt_0_03"
  },
  ['Harmonica'] = {
    animDict = "ai_gestures@instruments@harmonica@seated@80bpm",
    animName = "down_spine_cen_modulate_03"
  },
  ['Trumpet'] = {
    animDict = "ai_gestures@instruments@trumpet@standing@140bpm",
    animName = "upbeat_high_cen_left_001"
  },
  ['Banjo'] = {
    animDict = "ai_gestures@instruments@banjo@seated@120bpm",
    animName = "spine_0_hand_0_05"
  },
  ['Mandolin'] = {
    animDict = "ai_gestures@instruments@mandolin@seated@120bpm",
    animName = "strum_0_02"
  },
}

local piano_scenarios = {
  'Piano',
  'Piano Riverboat',
  'Piano Sketchy',
  'Piano UpperClass',
  'Piano Female'
}

local seat_only_scenarios = {
  'Accordion',
  'Accordion Downbeat',
  'Accordion Upbeat',
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
  'Fiddle Female',
  'Guitar Seat'
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

local function calculate_direction_vectors(heading)
  local radians = math.degreesToRadians(heading)
  local forwardX = math.sin(radians)
  local forwardY = math.cos(radians)
  local rightX = -forwardY
  local rightY = forwardX
  return forwardX, forwardY, rightX, rightY
end

local function update_player_position()
  if is_entity_frozen then
    local player_ped = player.getLocalPed()
    local player_heading = natives.entity_getEntityHeading(player_ped)
    local forwardX, forwardY, rightX, rightY = calculate_direction_vectors(player_heading)

    local new_x = original_x + (forwardX * -position_delta.y + rightX * -position_delta.x) * adjustment_increment
    local new_y = original_y + (forwardY * -position_delta.y + rightY * -position_delta.x) * adjustment_increment
    local new_z = original_z + position_delta.z * adjustment_increment

    natives.entity_setEntityCoords(player_ped, new_x, new_y, new_z, false, false, false, false)
  end
end

-- Advanced Settings
menu.addDivider('self', 'Advanced Settings')

menu.addFloatSpinner('self', '~t1~Adjustment Increment', 'Adjust the increment for position adjustments.', 0.1, 10.0, 1.0, adjustment_increment, function(value)
adjustment_increment = value
end)

menu.addFloatSpinner('self', '~m~Position X', 'Adjust the X coordinate.', -1000.0, 1000.0, 0.1, 0.0, function(delta_x)
position_delta.x = delta_x
update_player_position()
end)

menu.addFloatSpinner('self', '~m~Position Y', 'Adjust the Y coordinate.', -1000.0, 1000.0, 0.1, 0.0, function(delta_y)
position_delta.y = delta_y
update_player_position()
end)

menu.addFloatSpinner('self', '~m~Position Z', 'Adjust the Z coordinate.', -1000.0, 1000.0, 0.1, 0.0, function(delta_z)
position_delta.z = delta_z
update_player_position()
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
local spawned_instruments_and_peds = {}
local spawned_gifted_entities = {}

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
  local is_female_scenario = female_instrument_scenarios[scenario_name] ~= nil
  local ped_model_hash = is_female_scenario and 0x2B769669 or 0x0D7114C9
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

local function load_anim_dict(animDict)
  if not natives.streaming_hasAnimDictLoaded(animDict) then
    natives.streaming_requestAnimDict(animDict)
    while not natives.streaming_hasAnimDictLoaded(animDict) do
      system.yield(0)
    end
  end
end

-- Function to play scenarios while walking
local function play_walking_scenario(scenario_name)
  local player_ped = player.getLocalPed()
  local anim = walking_scenarios_animations[scenario_name]
  local instrument = instrument_objects[scenario_name]
  local coordX, coordY, coordZ = player.getLocalPedCoords()

  local instrument_entity = spawner.spawnObject(instrument.modelHash, coordX, coordY, coordZ, true)
  natives.entity_attachEntityToEntity(instrument_entity, player_ped, natives.entity_getEntityBoneIndexByName(player_ped, "PH_R_Hand"), 0, 0, 0, 0, 0, 0, true, true, true, true, 0, true, true, true)
  table.insert(spawned_instruments_and_peds, instrument_entity)

  load_anim_dict(anim.animDict)
  natives.task_taskPlayAnim(player_ped, anim.animDict, anim.animName, 0.0, 0.0, -1, 31, 0.0, false, 0, false, "", false)

  local invisible_ped = spawner.spawnPed(0x0D7114C9, coordX, coordY + 1, coordZ - 1, true)
  natives.entity_setEntityVisible(invisible_ped, false)
  natives.ped_setPedKeepTask(invisible_ped, true)
  natives.entity_setEntityInvincible(invisible_ped, true)
  natives.ped_setPedConfigFlag(invisible_ped, 61, true)
  natives.ped_setPedCanBeLassoed(invisible_ped, false)
  natives.ped_setPedCanBeTargetted(invisible_ped, false)
  natives.ped_setPedCanRagdoll(invisible_ped, false)
  natives.ped_setBlockingOfNonTemporaryEvents(invisible_ped, true)
  natives.ped_setPedFleeAttributes(invisible_ped, 0, false)
  natives.ped_setPedCombatAttributes(invisible_ped, 17, true)
  natives.ped_setPedLassoHogtieFlag(invisible_ped, 0, false)
  natives.entity_attachEntityToEntity(invisible_ped, player_ped, 0, 0.0, 0.0, 3.0, 0.0, 0.0, 0.0, 0, false, false, false, false, 2, false, false, false)

  local scenario_hash = natives.misc_getHashKey(spawner_scenarios[scenario_name] or male_instrument_scenarios[scenario_name] or female_instrument_scenarios[scenario_name])
  natives.task_taskStartScenarioInPlaceHash(invisible_ped, scenario_hash, -1, false, 0, 0.0, false)

  table.insert(spawned_instruments_and_peds, invisible_ped)
end

-- Function to gift music maker to a target player
local function gift_music_maker(player_idx, scenario_name, scenario_table)
  local target_ped = player.getPed(player_idx)
  local x, y, z = natives.entity_getEntityCoords(target_ped, false, false)

  local is_female_scenario = female_instrument_scenarios[scenario_name] ~= nil
  local ped_model_hash = is_female_scenario and 0x2B769669 or 0x0D7114C9
  local spawned_ped = spawner.spawnPed(ped_model_hash, x, y + 1, z + 1, true)
  natives.entity_setEntityVisible(spawned_ped, false)
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
  natives.entity_attachEntityToEntity(spawned_ped, target_ped, 0, 0.0, 0.0, 3.0, 0.0, 0.0, 0.0, 0, false, false, false, false, 2, false, false, false)

  local scenario_hash = natives.misc_getHashKey(spawner_scenarios[scenario_name] or male_instrument_scenarios[scenario_name] or female_instrument_scenarios[scenario_name])
  natives.task_taskStartScenarioInPlaceHash(spawned_ped, scenario_hash, -1, false, 0, 0.0, false)

  table.insert(spawned_gifted_entities, spawned_ped)
end

local function delete_spawned_entities_and_objects()
  for _, entity in ipairs(spawned_entities) do
    spawner.deleteObject(entity)
  end
  spawned_entities = {}
end

local function delete_spawned_instruments_and_peds()
  for _, entity in ipairs(spawned_instruments_and_peds) do
    spawner.deleteObject(entity)
  end
  spawned_instruments_and_peds = {}
end

local function delete_spawned_gifted_entities()
  for _, entity in ipairs(spawned_gifted_entities) do
    spawner.deleteObject(entity)
  end
  spawned_gifted_entities = {}
end

menu.addButton('self', '~t4~Delete Spawned entities', 'Delete all spawned entities and objects.', delete_spawned_entities_and_objects)
menu.addButton('player', '~t4~Delete Gifted Music Entities', 'Delete all spawned entities for gifted music.', delete_spawned_gifted_entities)

menu.addToggleButton('self', '~t2~Toggle Freeze', 'Freeze or unfreeze your character.', is_entity_frozen, toggle_entity_freeze)

menu.addButton('self', '~e~Stop Actions', 'Stop all current actions slowly.', function()
delete_spawned_instruments_and_peds()
natives.task_clearPedTasks(player.getLocalPed(), true, true)
end)

local function create_scenario_buttons(submenu_id, scenario_dict, is_spawner, is_walking_scenario, is_gift_music_maker)
  local sorted_scenarios = {}
  for scenario_name in pairs(scenario_dict) do
    table.insert(sorted_scenarios, scenario_name)
  end
  table.sort(sorted_scenarios)

  for _, scenario_name in ipairs(sorted_scenarios) do
    if is_walking_scenario then
      menu.addButton(submenu_id, 'Play ' .. scenario_name, 'Play ' .. scenario_name .. ' while walking', function()
      play_walking_scenario(scenario_name)
      end)
    elseif is_gift_music_maker then
      menu.addButton(submenu_id, 'Gift ' .. scenario_name, 'Gift ' .. scenario_name .. ' performance', function(player_idx)
      gift_music_maker(player_idx, scenario_name, scenario_dict)
      end)
    else
      menu.addButton(submenu_id, scenario_name, 'Play ' .. scenario_name, function()
      if is_spawner then
        start_scenario_for_spawned_ped(scenario_name, scenario_dict)
      else
        start_scenario(scenario_name, scenario_dict)
      end
      end)
    end
  end
end

-- Let there be buttons!
create_scenario_buttons(walking_scenarios_submenu_id, walking_scenarios_animations, false, true)
create_scenario_buttons(male_scenarios_submenu_id, male_instrument_scenarios, false)
create_scenario_buttons(female_scenarios_submenu_id, female_instrument_scenarios, false)
create_scenario_buttons(spawner_submenu_id, spawner_scenarios, true)
create_scenario_buttons(gift_music_maker_submenu_id, spawner_scenarios, false, false, true)