
local myutil = require('myutil')

-- setup --------------------------------------------------
function on_init()
    storage.warned = storage.warned or {}
    storage.players_waiting_for_update = storage.players_waiting_for_update or {}

    storage.reach_current = storage.reach_current or {}
    storage.reach_last = storage.reach_last or {}
    storage.reach_changed_after_death = storage.reach_changed_after_death or {}

    storage.mining_speed_current = storage.mining_speed_current or {}
    storage.mining_speed_last = storage.mining_speed_last or {}
    storage.mining_speed_changed_after_death = storage.mining_speed_changed_after_death or {}
    storage.mining_speed_last_mined = storage.mining_speed_last_mined or {}

    storage.crafting_speed_current = storage.crafting_speed_current or {}
    storage.crafting_speed_last = storage.crafting_speed_last or {}
    storage.crafting_speed_changed_after_death = storage.crafting_speed_changed_after_death or {}

    storage.health_current = storage.health_current or {}
    storage.health_last = storage.health_last or {}
    storage.health_changed_after_death = storage.health_changed_after_death or {}

    storage.player_list = storage.player_list or {}
    for tick = 0, myutil.divisor - 1 do
        storage.player_list[tick] = storage.player_list[tick] or {}
    end
    storage.last_x = storage.last_x or {}
    storage.last_y = storage.last_y or {}
    storage.running_speed_current = storage.running_speed_current or {}
    storage.running_speed_last = storage.running_speed_last or {}
    storage.running_speed_changed_after_death = storage.running_speed_changed_after_death or {}
    storage.running_speed_skip = storage.running_speed_skip or {}

    -- initialize all players' values, in case this mod was added to an ongoing game loaded in single player
    for pi, _ in pairs(game.players) do
        init_player(pi)
    end
end

function on_player_joined_game(event)
    local pi = event['player_index']
    init_player(pi)
end

function init_player(pi)
    myutil.set_default(storage.warned, pi, false)

    myutil.set_default(storage.reach_current, pi, 0)
    myutil.set_default(storage.reach_last, pi, 0)
    myutil.set_default(storage.reach_changed_after_death, pi, true)

    myutil.set_default(storage.mining_speed_current, pi, 0)
    myutil.set_default(storage.mining_speed_last, pi, 0)
    myutil.set_default(storage.mining_speed_changed_after_death, pi, true)
    myutil.set_default(storage.mining_speed_last_mined, pi, 0)

    myutil.set_default(storage.crafting_speed_current, pi, 0)
    myutil.set_default(storage.crafting_speed_last, pi, 0)
    myutil.set_default(storage.crafting_speed_changed_after_death, pi, true)

    myutil.set_default(storage.health_current, pi, 0)
    myutil.set_default(storage.health_last, pi, 0)
    myutil.set_default(storage.health_changed_after_death, pi, 0)

    myutil.set_player_list(pi, true)
    local p = game.players[pi]
    local position = p.position
    if p.character == nil then
        myutil.set_default(storage.last_x, pi, 0)
        myutil.set_default(storage.last_y, pi, 0)
        storage.running_speed_skip[pi] = true
    else
        myutil.set_default(storage.last_x, pi, position.x)
        myutil.set_default(storage.last_y, pi, position.y)
    end
    myutil.set_default(storage.running_speed_current, pi, 0)
    myutil.set_default(storage.running_speed_last, pi, 0)
    myutil.set_default(storage.running_speed_changed_after_death, pi, true)
    myutil.set_default(storage.running_speed_skip, pi, false)
end

function on_player_left_game(event)
    myutil.set_player_list(event['player_index'], nil)
end

-- reach --------------------------------------------------
function update_reach(pi)
    local p = game.players[pi]

    if storage.reach_changed_after_death[pi] then
        p.character_build_distance_bonus = math.max(p.character_build_distance_bonus - storage.reach_last[pi], 0)
        p.character_item_drop_distance_bonus = math.max(p.character_item_drop_distance_bonus - storage.reach_last[pi], 0)
        p.character_reach_distance_bonus = math.max(p.character_reach_distance_bonus - storage.reach_last[pi], 0)
        p.character_resource_reach_distance_bonus = math.max(p.character_resource_reach_distance_bonus - storage.reach_last[pi], 0)
    else
        storage.reach_changed_after_death[pi] = true
    end

    local new_reach = storage.reach_current[pi]
    if p.mod_settings["Personal_Development-limit-reach"].value and new_reach > p.mod_settings["Personal_Development-reach-limit"].value then
        new_reach = p.mod_settings["Personal_Development-reach-limit"].value
    end
    if settings.global["Personal_Development-global-limit-reach"].value and new_reach > settings.global["Personal_Development-global-reach-limit"].value then
        new_reach = settings.global["Personal_Development-global-reach-limit"].value
    end
    new_reach = math.floor(new_reach)
    storage.reach_last[pi] = new_reach

    p.character_build_distance_bonus = p.character_build_distance_bonus + new_reach
    p.character_item_drop_distance_bonus = p.character_item_drop_distance_bonus + new_reach
    p.character_reach_distance_bonus = p.character_reach_distance_bonus + new_reach
    p.character_resource_reach_distance_bonus = p.character_resource_reach_distance_bonus + new_reach
end

function increase_reach(pi, value)
    local p = game.players[pi]

    storage.reach_current[pi] = storage.reach_current[pi] + value

    if not storage.warned[pi] and storage.reach_current[pi] > 5 then
        p.print({'Personal_Development.warning'})
        storage.warned[pi] = true
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

    if storage.mining_speed_changed_after_death[pi] then
        p.character_mining_speed_modifier = math.max(p.character_mining_speed_modifier - storage.mining_speed_last[pi], 0)
    else
        storage.mining_speed_changed_after_death[pi] = true
    end

    local new_speed = storage.mining_speed_current[pi]
    if p.mod_settings["Personal_Development-limit-mining-speed"].value and new_speed > p.mod_settings["Personal_Development-mining-speed-limit"].value then
        new_speed = p.mod_settings["Personal_Development-mining-speed-limit"].value
    end
    if settings.global["Personal_Development-global-limit-mining-speed"].value and new_speed > settings.global["Personal_Development-global-mining-speed-limit"].value then
        new_speed = settings.global["Personal_Development-global-mining-speed-limit"].value
    end
    storage.mining_speed_last[pi] = new_speed

    p.character_mining_speed_modifier = p.character_mining_speed_modifier + new_speed
end

function on_player_mined_item(event)
    if settings.global["Personal_Development-disable"].value then return end
    local pi = event['player_index']
    local p = game.players[pi]
    if p.character == nil then return end

    if game.tick == storage.mining_speed_last_mined[pi] then return end

    increase_reach(pi, settings.global["Personal_Development-reach-increase"].value)

    storage.mining_speed_current[pi] = storage.mining_speed_current[pi] + settings.global["Personal_Development-mining-speed-increase"].value

    update_mining_speed(pi)

    storage.mining_speed_last_mined[pi] = game.tick
end

-- crafting --------------------------------------------------
function update_crafting_speed(pi)
    local p = game.players[pi]

    if storage.crafting_speed_changed_after_death[pi] then
        p.character_crafting_speed_modifier = math.max(p.character_crafting_speed_modifier - storage.crafting_speed_last[pi], 0)
    else
        storage.crafting_speed_changed_after_death[pi] = true
    end

    local new_speed = storage.crafting_speed_current[pi]
    if p.mod_settings["Personal_Development-limit-crafting-speed"].value and new_speed > p.mod_settings["Personal_Development-crafting-speed-limit"].value then
        new_speed = p.mod_settings["Personal_Development-crafting-speed-limit"].value
    end
    if settings.global["Personal_Development-global-limit-crafting-speed"].value and new_speed > settings.global["Personal_Development-global-crafting-speed-limit"].value then
        new_speed = settings.global["Personal_Development-global-crafting-speed-limit"].value
    end
    storage.crafting_speed_last[pi] = new_speed

    p.character_crafting_speed_modifier = p.character_crafting_speed_modifier + new_speed
end

function on_player_crafted_item(event)
    if settings.global["Personal_Development-disable"].value then return end
    local pi = event['player_index']
    local p = game.players[pi]

    if p.character == nil then return end

    storage.crafting_speed_current[pi] = storage.crafting_speed_current[pi] + settings.global["Personal_Development-crafting-speed-increase"].value

    update_crafting_speed(pi)
end

-- health --------------------------------------------------
function update_health(pi)
    local p = game.players[pi]

    if storage.health_changed_after_death[pi] then
        p.character_health_bonus = math.max(p.character_health_bonus - storage.health_last[pi], 0)
    else
        storage.health_changed_after_death[pi] = true
    end

    local new_health = storage.health_current[pi]
    if p.mod_settings["Personal_Development-limit-health"].value and new_health > p.mod_settings["Personal_Development-health-limit"].value then
        new_health = p.mod_settings["Personal_Development-health-limit"].value
    end
    if settings.global["Personal_Development-global-limit-health"].value and new_health > settings.global["Personal_Development-global-health-limit"].value then
        new_health = settings.global["Personal_Development-global-health-limit"].value
    end
    storage.health_last[pi] = new_health

    p.character_health_bonus = p.character_health_bonus + new_health
end

function on_entity_damaged(event)
    if settings.global["Personal_Development-disable"].value then return end
    local e = event['entity']
    if e == nil then return end
    local p = e['player']
    if p == nil or p.character == nil then return end
    local pi = p.index

    storage.health_current[pi] = storage.health_current[pi] + settings.global["Personal_Development-health-increase"].value * event['final_damage_amount']
    update_health(pi)
end

-- running --------------------------------------------------
function update_running_speed_inner(pi)
    local p = game.players[pi]

    local new_speed = storage.running_speed_current[pi]
    if p.mod_settings["Personal_Development-limit-running-speed"].value and new_speed > p.mod_settings["Personal_Development-running-speed-limit"].value then
        new_speed = p.mod_settings["Personal_Development-running-speed-limit"].value
    end
    if settings.global["Personal_Development-global-limit-running-speed"].value and new_speed > settings.global["Personal_Development-global-running-speed-limit"].value then
        new_speed = settings.global["Personal_Development-global-running-speed-limit"].value
    end
    storage.running_speed_last[pi] = new_speed

    p.character_running_speed_modifier = p.character_running_speed_modifier + new_speed
end

function update_running_speed(pi)
    local p = game.players[pi]
    p.character_running_speed_modifier = math.max(p.character_running_speed_modifier - storage.running_speed_last[pi], 0)
    update_running_speed_inner(pi)
end

function update_position(pi)
    local p = game.players[pi]
    if p.character == nil then return end

    local pos = p.position
    local x = pos.x
    local y = pos.y

    if p.vehicle ~= nil then
    elseif storage.running_speed_skip[pi] then
        storage.running_speed_skip[pi] = false
    elseif storage.running_speed_changed_after_death[pi] then
        local dx = x - storage.last_x[pi]
        local dy = y - storage.last_y[pi]
        if dx ~= 0 or dy ~= 0 then
            local value = settings.global["Personal_Development-running-speed-increase"].value * math.sqrt(dx * dx + dy * dy) / p.character_running_speed
            storage.running_speed_current[pi] = storage.running_speed_current[pi] + value
            if not storage.warned[pi] and storage.running_speed_current[pi] > 2 then
                p.print({'Personal_Development.warning'})
                storage.warned[pi] = true
            end
            update_running_speed(pi)
        end
    else
        storage.running_speed_changed_after_death[pi] = true
        update_running_speed_inner(pi)
    end
    storage.last_x[pi] = x
    storage.last_y[pi] = y
end

function on_tick(event)
    for pi, _ in pairs(storage.players_waiting_for_update) do
        local p = game.players[pi]
        if p.character ~= nil then
            update_reach(pi)
            update_mining_speed(pi)
            update_crafting_speed(pi)
            update_health(pi)
            update_position(pi)
            storage.players_waiting_for_update[pi] = nil
        end
    end

    if settings.global["Personal_Development-disable"].value then return end

    local tickdiv = game.tick % myutil.divisor

    for pi, _ in pairs(storage.player_list[tickdiv]) do
        update_position(pi)
    end
end

function on_player_driving_changed_state(event)
    if settings.global["Personal_Development-disable"].value then return end
    local pi = event['player_index']
    local p = game.players[pi]
    if p.vehicle == nil then
        storage.running_speed_skip[pi] = true
    end
end

function on_player_toggled_map_editor(event)
    if settings.global["Personal_Development-disable"].value then return end
    local pi = event['player_index']
    storage.running_speed_skip[pi] = true
end

function on_player_changed_surface(event)
    if settings.global["Personal_Development-disable"].value then return end
    local pi = event['player_index']
    storage.running_speed_skip[pi] = true
end

function on_player_died(event)
    if settings.global["Personal_Development-disable"].value then return end
    local pi = event['player_index']
    storage.players_waiting_for_update[pi] = true
    storage.running_speed_changed_after_death[pi] = false
    storage.reach_changed_after_death[pi] = false
    storage.crafting_speed_changed_after_death[pi] = false
    storage.mining_speed_changed_after_death[pi] = false
    storage.health_changed_after_death[pi] = false
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
                storage.players_waiting_for_update[event['player_index']] = true
            end
        end
    else -- runtime-global
        if setting == 'Personal_Development-global-limit-reach' or setting == 'Personal_Development-global-reach-limit' then
            for pi, _ in pairs(game.players) do
                local p = game.players[pi]
                if p.character ~= nil then
                    update_reach(pi)
                else
                    storage.players_waiting_for_update[pi] = true
                end
            end
        elseif setting == 'Personal_Development-global-limit-mining-speed' or setting == 'Personal_Development-global-mining-speed-limit' then
            for pi, _ in pairs(game.players) do
                local p = game.players[pi]
                if p.character ~= nil then
                    update_mining_speed(pi)
                else
                    storage.players_waiting_for_update[pi] = true
                end
            end
        elseif setting == 'Personal_Development-global-limit-crafting-speed' or setting == 'Personal_Development-global-crafting-speed-limit' then
            for pi, _ in pairs(game.players) do
                local p = game.players[pi]
                if p.character ~= nil then
                    update_crafting_speed(pi)
                else
                    storage.players_waiting_for_update[pi] = true
                end
            end
        elseif setting == 'Personal_Development-global-limit-running-speed' or setting == 'Personal_Development-global-running-speed-limit' then
            for pi, _ in pairs(game.players) do
                local p = game.players[pi]
                if p.character ~= nil then
                    update_running_speed(pi)
                else
                    storage.players_waiting_for_update[pi] = true
                end
            end
        elseif setting == 'Personal_Development-global-limit-health' or setting == 'Personal_Development-global-health-limit' then
            for pi, _ in pairs(game.players) do
                local p = game.players[pi]
                if p.character ~= nil then
                    update_health(pi)
                else
                    storage.players_waiting_for_update[pi] = true
                end
            end
        end
    end
end

-- commands --------------------------------------------------
function PD_stats(cmd)
    local pi = cmd['player_index']
    local p = game.players[pi]

    local txt = 'Your bonuses due to the Personal Development mod:'

    local rc = math.floor(storage.reach_current[pi])
    local rl = math.floor(storage.reach_last[pi])
    local reach = 'Reach: ' .. rc
    if rl < rc then
        reach = reach .. ' (limited to ' .. rl .. ')'
    end

    local mining = 'Mining speed: ' .. string.format('%.2f', storage.mining_speed_current[pi] * 100) .. '%'
    if storage.mining_speed_last[pi] < storage.mining_speed_current[pi] then
        mining = mining .. ' (limited to ' .. string.format('%.2f', storage.mining_speed_last[pi] * 100) .. '%)'
    end

    local crafting = 'Crafting speed: ' .. string.format('%.2f', storage.crafting_speed_current[pi] * 100) .. '%'
    if storage.crafting_speed_last[pi] < storage.crafting_speed_current[pi] then
        crafting = crafting .. ' (limited to ' .. string.format('%.2f', storage.crafting_speed_last[pi] * 100) .. '%)'
    end

    local health = 'Health: ' .. string.format('%.2f', storage.health_current[pi])
    if storage.health_last[pi] < storage.health_current[pi] then
        health = health .. ' (limited to ' .. string.format('%.2f', storage.health_last[pi]) .. ')'
    end

    local running = 'Running speed: ' .. string.format('%.2f', storage.running_speed_current[pi] * 100) .. '%'
    if storage.running_speed_last[pi] < storage.running_speed_current[pi] then
        running = running .. ' (limited to ' .. string.format('%.2f', storage.running_speed_last[pi] * 100) .. '%)'
    end
    p.print(txt .. '\n' .. reach .. '\n' .. mining .. '\n' .. crafting .. '\n' .. health .. '\n' .. running)
end
commands.add_command(myutil.command_name('stats'), 'Lists your stats increased by the Personal Development mod.', PD_stats)

function PD_reset(cmd)
    local pi = cmd['player_index']
    local p = game.players[pi]

    if not p.admin then
        game.print('User ' .. p.name .. ' tried to reset Personal Development bonuses')
        return
    end

    for pi, _ in pairs(game.players) do
        local p = game.players[pi]
        storage.reach_current[pi] = 0
        storage.mining_speed_current[pi] = 0
        storage.crafting_speed_current[pi] = 0
        storage.health_current[pi] = 0
        storage.running_speed_current[pi] = 0
        if p.character ~= nil then
            update_reach(pi)
            update_mining_speed(pi)
            update_crafting_speed(pi)
            update_running_speed(pi)
            update_health(pi)
        else
            storage.players_waiting_for_update[pi] = true
        end
    end

    game.print('Personal Development has been reset')
end
commands.add_command(myutil.command_name('reset'), 'Resets the Personal Development mod. (admins only)', PD_reset)

function PD_set(cmd)
    local pi = cmd['player_index']
    local p = game.players[pi]

    if not p.admin then
        game.print("User " .. p.name .. " tried to change Personal Development bonuses.")
        return
    end

    local params = myutil.split_params(cmd['parameter'])

    local params_len = 0
    for i, v in ipairs(params) do
        params_len = params_len + 1
    end

    local pi_to_mod = pi
    local p_to_mod = p
    if params_len == 2 then
    elseif params_len == 3 then
        local found = false
        for i, v in pairs(game.players) do
            if v.name == params[3] then
                found = true
                pi_to_mod = i
                p_to_mod = v
                break
            end
        end
        if not found then
            p.print("Could not find a player with given name.")
            return
        end
    else
        p.print("Invalid number of parameters. This command accepts 2 or 3 parameters.")
        return
    end

    param2num, errmsg = myutil.parse_number(params[2])
    if param2num == nil then
        p.print("Error while parsing value: " .. errmsg)
    end

    if params[1] == 'reach' then
        storage.reach_current[pi_to_mod] = param2num
        if p_to_mod.character ~= nil then
            update_reach(pi_to_mod)
        else
            storage.players_waiting_for_update[pi_to_mod] = true
        end
    elseif params[1] == 'mining_speed' then
        storage.mining_speed_current[pi_to_mod] = param2num
        if p_to_mod.character ~= nil then
            update_mining_speed(pi_to_mod)
        else
            storage.players_waiting_for_update[pi_to_mod] = true
        end
    elseif params[1] == 'crafting_speed' then
        storage.crafting_speed_current[pi_to_mod] = param2num
        if p_to_mod.character ~= nil then
            update_crafting_speed(pi_to_mod)
        else
            storage.players_waiting_for_update[pi_to_mod] = true
        end
    elseif params[1] == 'health' then
        storage.health_current[pi_to_mod] = param2num
        if p_to_mod.character ~= nil then
            update_health(pi_to_mod)
        else
            storage.players_waiting_for_update[pi_to_mod] = true
        end
    elseif params[1] == 'running_speed' then
        storage.running_speed_current[pi_to_mod] = param2num
        if p_to_mod.character ~= nil then
            update_running_speed(pi_to_mod)
        else
            storage.players_waiting_for_update[pi_to_mod] = true
        end
    else
        p.print("invalid bonus type, must be one of: 'reach', 'mining_speed', 'crafting_speed', 'health', 'running_speed'.")
        return
    end

    game.print("Personal Development's " .. params[1] .. " value of " .. p_to_mod.name .. " has been set to " .. params[2])
end
commands.add_command(myutil.command_name('set'), "Sets the Personal Development mod's values. (admin-only)", PD_set)


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
