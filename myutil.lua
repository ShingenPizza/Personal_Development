
local myutil = {}

-- generic --------------------------------------------------
myutil.divisor = 60

-- for setup --------------------------------------------------
function myutil.set_default(set, key, default)
    if set[key] == nil then
        set[key] = default
    end
end

function myutil.set_player_list(pi, val)
    local pidiv = pi % myutil.divisor
    myutil.set_default(global.player_list, pidiv, {})
    global.player_list[pidiv][pi] = val
end

-- for commands --------------------------------------------------
local shortname = 'PD_'
local longname = 'Personal_Development_'
function myutil.command_name(name)
    local resname = shortname .. name
    if commands.commands[resname] then
        return longname .. name
    end
    return resname
end
