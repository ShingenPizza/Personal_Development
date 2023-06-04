
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

function myutil.split_params(str)
    local res = {}
    local part = 1
    for v in string.gmatch(str, '%S+') do
        res[part] = v
        part = part + 1
    end
    return res
end

function myutil.parse_number(str)
    local val = 0
    local percent_used = false
    local period = false
    local post_period = 0
    for i = 1, #str do
        if percent_used then
            return nil, "Percent character (%) has to be at the end of the value or nowhere."
        end
        local c = str:sub(i, i)
        if c == '%' then
            percent_used = true
        elseif c == '.' then
            if period then
                return nil, "A value cannot have mutiple periods."
            end
            period = true
        elseif c:match('%D') then
            return nil, "A value can consist only of digits, optionally of a period, and optionally of a percent character (%) at the end."
        else
            if period then
                post_period = post_period + 1
                val = val + tonumber(c) / 10 ^ post_period
            else
                val = val * 10 + tonumber(c)
            end
        end
    end
    if percent_used then
        return val / 100
    end
    return val
end

return myutil
