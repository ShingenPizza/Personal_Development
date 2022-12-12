
local divisor = 60

function set_default(set, key, default)
    if set[key] == nil then
        set[key] = default
    end
end

function set_player_list(pi, val)
    local pidiv = pi % divisor
    set_default(global.player_list, pidiv, {})
    global.player_list[pidiv][pi] = val
end

-- setup --------------------------------------------------
function on_init()
    global.warned = global.warned or {}
    global.players_waiting_for_update = global.players_waiting_for_update or {}

    global.reach_current = global.reach_current or {}
    global.reach_last = global.reach_last or {}
    global.reach_changed_after_death = global.reach_changed_after_death or {}

    global.mining_speed_current = global.mining_speed_current or {}
    global.mining_speed_last = global.mining_speed_last or {}
    global.mining_speed_changed_after_death = global.mining_speed_changed_after_death or {}
    global.mining_speed_last_mined = global.mining_speed_last_mined or {}

    global.crafting_speed_current = global.crafting_speed_current or {}
    global.crafting_speed_last = global.crafting_speed_last or {}
    global.crafting_speed_changed_after_death = global.crafting_speed_changed_after_death or {}

    global.health_current = global.health_current or {}
    global.health_last = global.health_last or {}
    global.health_changed_after_death = global.health_changed_after_death or {}

    global.player_list = global.player_list or {}
    for tick = 0, divisor - 1 do
        global.player_list[tick] = global.player_list[tick] or {}
    end
    global.last_x = global.last_x or {}
    global.last_y = global.last_y or {}
    global.running_speed_current = global.running_speed_current or {}
    global.running_speed_last = global.running_speed_last or {}
    global.running_speed_changed_after_death = global.running_speed_changed_after_death or {}
    global.running_speed_skip = global.running_speed_skip or {}
end

function on_player_joined_game(event)
    local pi = event['player_index']

    set_default(global.warned, pi, false)

    set_default(global.reach_current, pi, 0)
    set_default(global.reach_last, pi, 0)
    set_default(global.reach_changed_after_death, pi, true)

    set_default(global.mining_speed_current, pi, 0)
    set_default(global.mining_speed_last, pi, 0)
    set_default(global.mining_speed_changed_after_death, pi, true)
    set_default(global.mining_speed_last_mined, pi, 0)

    set_default(global.crafting_speed_current, pi, 0)
    set_default(global.crafting_speed_last, pi, 0)
    set_default(global.crafting_speed_changed_after_death, pi, true)

    set_default(global.health_current, pi, 0)
    set_default(global.health_last, pi, 0)
    set_default(global.health_changed_after_death, pi, 0)

    set_player_list(pi, true)
    local position = game.players[pi].position
    set_default(global.last_x, pi, position.x)
    set_default(global.last_y, pi, position.y)
    set_default(global.running_speed_current, pi, 0)
    set_default(global.running_speed_last, pi, 0)
    set_default(global.running_speed_changed_after_death, pi, true)
    set_default(global.running_speed_skip, pi, false)
end

function on_player_left_game(event)
    set_player_list(event['player_index'], nil)
end

-- reach --------------------------------------------------
function update_reach(pi)
    local p = game.players[pi]

    if global.reach_changed_after_death[pi] then
        p.character_build_distance_bonus = math.max(p.character_build_distance_bonus - global.reach_last[pi], 0)
        p.character_item_drop_distance_bonus = math.max(p.character_item_drop_distance_bonus - global.reach_last[pi], 0)
        p.character_reach_distance_bonus = math.max(p.character_reach_distance_bonus - global.reach_last[pi], 0)
        p.character_resource_reach_distance_bonus = math.max(p.character_resource_reach_distance_bonus - global.reach_last[pi], 0)
    else
        global.reach_changed_after_death[pi] = true
    end

    local new_reach = global.reach_current[pi]
    if p.mod_settings["Personal_Development-limit-reach"].value and new_reach > p.mod_settings["Personal_Development-reach-limit"].value then
        new_reach = p.mod_settings["Personal_Development-reach-limit"].value
    end
    if settings.global["Personal_Development-global-limit-reach"].value and new_reach > settings.global["Personal_Development-global-reach-limit"].value then
        new_reach = settings.global["Personal_Development-global-reach-limit"].value
    end
    new_reach = math.floor(new_reach)
    global.reach_last[pi] = new_reach

    p.character_build_distance_bonus = p.character_build_distance_bonus + new_reach
    p.character_item_drop_distance_bonus = p.character_item_drop_distance_bonus + new_reach
    p.character_reach_distance_bonus = p.character_reach_distance_bonus + new_reach
    p.character_resource_reach_distance_bonus = p.character_resource_reach_distance_bonus + new_reach
end

function increase_reach(pi, value)
    local p = game.players[pi]

    global.reach_current[pi] = global.reach_current[pi] + value

    if not global.warned[pi] and global.reach_current[pi] > 5 then
        p.print({'Personal_Development.warning'})
        global.warned[pi] = true
    end

    update_reach(pi)
end

function on_built_entity(event)
    if settings.global["Personal_Development-disable"].value then return end
    local pi = event['player_index']
    local p = game.players[pi]
    if p.character == nil then return end

    increase_reach(pi, settings.global["Personal_Development-reach-increase"].value)
end

function on_player_built_tile(event)
    if settings.global["Personal_Development-disable"].value then return end
    local pi = event['player_index']
    local p = game.players[pi]
    if p.character == nil then return end

    local num = table_size(event['tiles'])

    increase_reach(pi, settings.global["Personal_Development-reach-increase"].value * num * settings.global["Personal_Development-reach-increase-tile-multiplier"].value)
end

function on_player_dropped_item(event)
    if settings.global["Personal_Development-disable"].value then return end
    local pi = event['player_index']
    local p = game.players[pi]
    if p.character == nil then return end

    increase_reach(pi, settings.global["Personal_Development-reach-increase"].value * settings.global["Personal_Development-reach-increase-drop-multiplier"].value)
end

-- reach + mining --------------------------------------------------
function update_mining_speed(pi)
    local p = game.players[pi]

    if global.mining_speed_changed_after_death[pi] then
        p.character_mining_speed_modifier = math.max(p.character_mining_speed_modifier - global.mining_speed_last[pi], 0)
    else
        global.mining_speed_changed_after_death[pi] = true
    end

    local new_speed = global.mining_speed_current[pi]
    if p.mod_settings["Personal_Development-limit-mining-speed"].value and new_speed > p.mod_settings["Personal_Development-mining-speed-limit"].value then
        new_speed = p.mod_settings["Personal_Development-mining-speed-limit"].value
    end
    if settings.global["Personal_Development-global-limit-mining-speed"].value and new_speed > settings.global["Personal_Development-global-mining-speed-limit"].value then
        new_speed = settings.global["Personal_Development-global-mining-speed-limit"].value
    end
    global.mining_speed_last[pi] = new_speed

    p.character_mining_speed_modifier = p.character_mining_speed_modifier + new_speed
end

function on_player_mined_item(event)
    if settings.global["Personal_Development-disable"].value then return end
    local pi = event['player_index']
    local p = game.players[pi]
    if p.character == nil then return end

    if game.tick == global.mining_speed_last_mined[pi] then return end

    increase_reach(pi, settings.global["Personal_Development-reach-increase"].value)

    global.mining_speed_current[pi] = global.mining_speed_current[pi] + settings.global["Personal_Development-mining-speed-increase"].value

    update_mining_speed(pi)

    global.mining_speed_last_mined[pi] = game.tick
end

-- crafting --------------------------------------------------
function update_crafting_speed(pi)
    local p = game.players[pi]

    if global.crafting_speed_changed_after_death[pi] then
        p.character_crafting_speed_modifier = math.max(p.character_crafting_speed_modifier - global.crafting_speed_last[pi], 0)
    else
        global.crafting_speed_changed_after_death[pi] = true
    end

    local new_speed = global.crafting_speed_current[pi]
    if p.mod_settings["Personal_Development-limit-crafting-speed"].value and new_speed > p.mod_settings["Personal_Development-crafting-speed-limit"].value then
        new_speed = p.mod_settings["Personal_Development-crafting-speed-limit"].value
    end
    if settings.global["Personal_Development-global-limit-crafting-speed"].value and new_speed > settings.global["Personal_Development-global-crafting-speed-limit"].value then
        new_speed = settings.global["Personal_Development-global-crafting-speed-limit"].value
    end
    global.crafting_speed_last[pi] = new_speed

    p.character_crafting_speed_modifier = p.character_crafting_speed_modifier + new_speed
end

function on_player_crafted_item(event)
    if settings.global["Personal_Development-disable"].value then return end
    local pi = event['player_index']
    local p = game.players[pi]

    if p.character == nil then return end

    global.crafting_speed_current[pi] = global.crafting_speed_current[pi] + settings.global["Personal_Development-crafting-speed-increase"].value

    update_crafting_speed(pi)
end

-- health --------------------------------------------------
function update_health(pi)
    local p = game.players[pi]

    if global.health_changed_after_death[pi] then
        p.character_health_bonus = math.max(p.character_health_bonus - global.health_last[pi], 0)
    else
        global.health_changed_after_death[pi] = true
    end

    local new_health = global.health_current[pi]
    if p.mod_settings["Personal_Development-limit-health"].value and new_health > p.mod_settings["Personal_Development-health-limit"].value then
        new_health = p.mod_settings["Personal_Development-health-limit"].value
    end
    if settings.global["Personal_Development-global-limit-health"].value and new_health > settings.global["Personal_Development-global-health-limit"].value then
        new_health = settings.global["Personal_Development-global-health-limit"].value
    end
    global.health_last[pi] = new_health

    p.character_health_bonus = p.character_health_bonus + new_health
end

function on_entity_damaged(event)
    if settings.global["Personal_Development-disable"].value then return end
    local e = event['entity']
    if e == nil then return end
    local p = e['player']
    if p == nil or p.character == nil then return end
    local pi = p.index

    global.health_current[pi] = global.health_current[pi] + settings.global["Personal_Development-health-increase"].value * event['final_damage_amount']
    update_health(pi)
end

-- running --------------------------------------------------
function update_running_speed_inner(pi)
    local p = game.players[pi]

    local new_speed = global.running_speed_current[pi]
    if p.mod_settings["Personal_Development-limit-running-speed"].value and new_speed > p.mod_settings["Personal_Development-running-speed-limit"].value then
        new_speed = p.mod_settings["Personal_Development-running-speed-limit"].value
    end
    if settings.global["Personal_Development-global-limit-running-speed"].value and new_speed > settings.global["Personal_Development-global-running-speed-limit"].value then
        new_speed = settings.global["Personal_Development-global-running-speed-limit"].value
    end
    global.running_speed_last[pi] = new_speed

    p.character_running_speed_modifier = p.character_running_speed_modifier + new_speed
end

function update_running_speed(pi)
    local p = game.players[pi]
    p.character_running_speed_modifier = math.max(p.character_running_speed_modifier - global.running_speed_last[pi], 0)
    update_running_speed_inner(pi)
end

function update_position(pi)
    local p = game.players[pi]
    if p.character == nil then return end

    local pos = p.position
    local x = pos.x
    local y = pos.y

    if p.vehicle ~= nil then
    elseif global.running_speed_skip[pi] then
        global.running_speed_skip[pi] = false
    elseif global.running_speed_changed_after_death[pi] then
        local dx = x - global.last_x[pi]
        local dy = y - global.last_y[pi]
        if dx ~= 0 or dy ~= 0 then
            local value = settings.global["Personal_Development-running-speed-increase"].value * math.sqrt(dx * dx + dy * dy) / p.character_running_speed
            global.running_speed_current[pi] = global.running_speed_current[pi] + value
            if not global.warned[pi] and global.running_speed_current[pi] > 2 then
                p.print({'Personal_Development.warning'})
                global.warned[pi] = true
            end
            update_running_speed(pi)
        end
    else
        global.running_speed_changed_after_death[pi] = true
        update_running_speed_inner(pi)
    end
    global.last_x[pi] = x
    global.last_y[pi] = y
end

function on_tick(event)
    for pi, _ in pairs(global.players_waiting_for_update) do
        local p = game.players[pi]
        if p.character ~= nil then
            update_reach(pi)
            update_mining_speed(pi)
            update_crafting_speed(pi)
            update_health(pi)
            update_position(pi)
            global.players_waiting_for_update[pi] = nil
        end
    end

    if settings.global["Personal_Development-disable"].value then return end

    local tickdiv = game.tick % divisor

    for pi, _ in pairs(global.player_list[tickdiv]) do
        update_position(pi)
    end
end

function on_player_driving_changed_state(event)
    if settings.global["Personal_Development-disable"].value then return end
    local pi = event['player_index']
    local p = game.players[pi]
    if p.vehicle == nil then
        global.running_speed_skip[pi] = true
    end
end

function on_player_toggled_map_editor(event)
    if settings.global["Personal_Development-disable"].value then return end
    local pi = event['player_index']
    global.running_speed_skip[pi] = true
end

function on_player_changed_surface(event)
    if settings.global["Personal_Development-disable"].value then return end
    local pi = event['player_index']
    global.running_speed_skip[pi] = true
end

function on_player_died(event)
    if settings.global["Personal_Development-disable"].value then return end
    local pi = event['player_index']
    global.players_waiting_for_update[pi] = true
    global.running_speed_changed_after_death[pi] = false
    global.reach_changed_after_death[pi] = false
    global.crafting_speed_changed_after_death[pi] = false
    global.mining_speed_changed_after_death[pi] = false
    global.health_changed_after_death[pi] = false
end

-- setting change --------------------------------------------------
function on_runtime_mod_setting_changed(event)
    if settings.global["Personal_Development-disable"].value then return end
    local setting_type = event['setting_type']
    local setting = event['setting']

    if setting_type == 'runtime-per-user' then
        local pi = event['player_index']
        local p = game.players[pi]
        if p.character ~= nil then
            if setting == 'Personal_Development-limit-reach' or setting == 'Personal_Development-reach-limit' then
                update_reach(pi)
            elseif setting == 'Personal_Development-limit-mining-speed' or setting == 'Personal_Development-mining-speed-limit' then
                update_mining_speed(pi)
            elseif setting == 'Personal_Development-limit-crafting-speed' or setting == 'Personal_Development-crafting-speed-limit' then
                update_crafting_speed(pi)
            elseif setting == 'Personal_Development-limit-running-speed' or setting == 'Personal_Development-running-speed-limit' then
                update_running_speed(pi)
            elseif setting == 'Personal_Development-limit-health' or setting == 'Personal_Development-health-limit' then
                update_health(pi)
            end
        else
            if setting == 'Personal_Development-limit-reach' or setting == 'Personal_Development-reach-limit'
                    or setting == 'Personal_Development-limit-mining-speed' or setting == 'Personal_Development-mining-speed-limit'
                    or setting == 'Personal_Development-limit-crafting-speed' or setting == 'Personal_Development-crafting-speed-limit'
                    or setting == 'Personal_Development-limit-running-speed' or setting == 'Personal_Development-running-speed-limit'
                    or setting == 'Personal_Development-limit-health' or setting == 'Personal_Development-health-limit' then
                global.players_waiting_for_update[event['player_index']] = true
            end
        end
    else -- runtime-global
        if setting == 'Personal_Development-global-limit-reach' or setting == 'Personal_Development-global-reach-limit' then
            for pi, _ in pairs(game.players) do
                local p = game.players[pi]
                if p.character ~= nil then
                    update_reach(pi)
                else
                    global.players_waiting_for_update[pi] = true
                end
            end
        elseif setting == 'Personal_Development-global-limit-mining-speed' or setting == 'Personal_Development-global-mining-speed-limit' then
            for pi, _ in pairs(game.players) do
                local p = game.players[pi]
                if p.character ~= nil then
                    update_mining_speed(pi)
                else
                    global.players_waiting_for_update[pi] = true
                end
            end
        elseif setting == 'Personal_Development-global-limit-crafting-speed' or setting == 'Personal_Development-global-crafting-speed-limit' then
            for pi, _ in pairs(game.players) do
                local p = game.players[pi]
                if p.character ~= nil then
                    update_crafting_speed(pi)
                else
                    global.players_waiting_for_update[pi] = true
                end
            end
        elseif setting == 'Personal_Development-global-limit-running-speed' or setting == 'Personal_Development-global-running-speed-limit' then
            for pi, _ in pairs(game.players) do
                local p = game.players[pi]
                if p.character ~= nil then
                    update_running_speed(pi)
                else
                    global.players_waiting_for_update[pi] = true
                end
            end
        elseif setting == 'Personal_Development-global-limit-health' or setting == 'Personal_Development-global-health-limit' then
            for pi, _ in pairs(game.players) do
                local p = game.players[pi]
                if p.character ~= nil then
                    update_health(pi)
                else
                    global.players_waiting_for_update[pi] = true
                end
            end
        end
    end
end

-- commands --------------------------------------------------
local shortname = 'PD_'
local longname = 'Personal_Development_'
function command_name(name)
    local resname = shortname .. name
    if commands.commands[resname] then
        return longname .. name
    end
    return resname
end

function PD_stats(cmd)
    local pi = cmd['player_index']
    local p = game.players[pi]

    local txt = 'Your bonuses due to the Personal Development mod:'

    local rc = math.floor(global.reach_current[pi])
    local rl = math.floor(global.reach_last[pi])
    local reach = 'Reach: ' .. rc
    if rl < rc then
        reach = reach .. ' (limited to ' .. rl .. ')'
    end

    local mining = 'Mining speed: ' .. string.format('%.2f', global.mining_speed_current[pi] * 100) .. '%'
    if global.mining_speed_last[pi] < global.mining_speed_current[pi] then
        mining = mining .. ' (limited to ' .. string.format('%.2f', global.mining_speed_last[pi] * 100) .. '%)'
    end

    local crafting = 'Crafting speed: ' .. string.format('%.2f', global.crafting_speed_current[pi] * 100) .. '%'
    if global.crafting_speed_last[pi] < global.crafting_speed_current[pi] then
        crafting = crafting .. ' (limited to ' .. string.format('%.2f', global.crafting_speed_last[pi] * 100) .. '%)'
    end

    local health = 'Health: ' .. string.format('%.2f', global.health_current[pi])
    if global.health_last[pi] < global.health_current[pi] then
        health = health .. ' (limited to ' .. string.format('%.2f', global.health_last[pi]) .. ')'
    end

    local running = 'Running speed: ' .. string.format('%.2f', global.running_speed_current[pi] * 100) .. '%'
    if global.running_speed_last[pi] < global.running_speed_current[pi] then
        running = running .. ' (limited to ' .. string.format('%.2f', global.running_speed_last[pi] * 100) .. '%)'
    end
    p.print(txt .. '\n' .. reach .. '\n' .. mining .. '\n' .. crafting .. '\n' .. health .. '\n' .. running)
end
commands.add_command(command_name('stats'), 'Lists your stats increased by the Personal Development mod.', PD_stats)

function PD_reset(cmd)
    local pi = cmd['player_index']
    local p = game.players[pi]

    if not p.admin then
        game.print('User ' .. p.name .. ' tried to reset Personal Development bonuses')
        return
    end

    for pi, _ in pairs(game.players) do
        local p = game.players[pi]
        global.reach_current[pi] = 0
        global.mining_speed_current[pi] = 0
        global.crafting_speed_current[pi] = 0
        global.health_current[pi] = 0
        global.running_speed_current[pi] = 0
        if p.character ~= nil then
            update_reach(pi)
            update_mining_speed(pi)
            update_crafting_speed(pi)
            update_running_speed(pi)
            update_health(pi)
        else
            global.players_waiting_for_update[pi] = true
        end
    end

    game.print('Personal Development has been reset')
end
commands.add_command(command_name('reset'), 'Resets the Personal Development mod. (admins only)', PD_reset)


-- setup
script.on_init(on_init)
script.on_event(defines.events.on_player_joined_game, on_player_joined_game)
script.on_event({defines.events.on_player_banned, defines.events.on_player_kicked, defines.events.on_player_left_game}, on_player_left_game)

-- reach
script.on_event(defines.events.on_built_entity, on_built_entity, {{filter='ghost', invert=true}})
script.on_event(defines.events.on_player_built_tile, on_player_built_tile)  -- no filter here yet
script.on_event(defines.events.on_player_dropped_item, on_player_dropped_item)

-- reach + mining
script.on_event(defines.events.on_player_mined_item, on_player_mined_item)

-- crafting
script.on_event(defines.events.on_player_crafted_item, on_player_crafted_item)

-- health
script.on_event(defines.events.on_entity_damaged, on_entity_damaged, {{filter='type', type='character'}})

-- running
script.on_event(defines.events.on_tick, on_tick)
script.on_event(defines.events.on_player_driving_changed_state, on_player_driving_changed_state)
script.on_event(defines.events.on_player_toggled_map_editor, on_player_toggled_map_editor)
script.on_event(defines.events.on_player_changed_surface, on_player_changed_surface)
script.on_event(defines.events.on_player_died, on_player_died)

-- setting change
script.on_event(defines.events.on_runtime_mod_setting_changed, on_runtime_mod_setting_changed)
