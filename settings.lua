
data:extend({
    { -- REACH
        type = "double-setting",
        name = "Personal_Development-reach-increase",
        setting_type = "runtime-global",
        default_value = 0.01,
        minimum_value = 0,
        order = '010',
    }
    , {
        type = "double-setting",
        name = "Personal_Development-reach-increase-tile-multiplier",
        setting_type = "runtime-global",
        default_value = 0.1,
        minimum_value = 0,
        maximum_value = 1,
        order = '011',
    }
    , {
        type = "double-setting",
        name = "Personal_Development-reach-increase-drop-multiplier",
        setting_type = "runtime-global",
        default_value = 0.1,
        minimum_value = 0,
        maximum_value = 1,
        order = '012',
    }
    , {
        type = "bool-setting",
        name = "Personal_Development-global-limit-reach",
        setting_type = "runtime-global",
        default_value = false,
        order = '015',
    }
    , {
        type = "double-setting",
        name = "Personal_Development-global-reach-limit",
        setting_type = "runtime-global",
        default_value = 20.0,
        minimum_value = 0,
        order = '016',
    }
    , {
        type = "bool-setting",
        name = "Personal_Development-limit-reach",
        setting_type = "runtime-per-user",
        default_value = false,
        order = '015',
    }
    , {
        type = "double-setting",
        name = "Personal_Development-reach-limit",
        setting_type = "runtime-per-user",
        default_value = 20.0,
        minimum_value = 0,
        order = '016',
    }
    , { -- MINING SPEED
        type = "double-setting",
        name = "Personal_Development-mining-speed-increase",
        setting_type = "runtime-global",
        default_value = 0.001,
        minimum_value = 0,
        order = '020',
    }
    , {
        type = "bool-setting",
        name = "Personal_Development-global-limit-mining-speed",
        setting_type = "runtime-global",
        default_value = false,
        order = '025',
    }
    , {
        type = "double-setting",
        name = "Personal_Development-global-mining-speed-limit",
        setting_type = "runtime-global",
        default_value = 1.0,
        minimum_value = 0,
        order = '026',
    }
    , {
        type = "bool-setting",
        name = "Personal_Development-limit-mining-speed",
        setting_type = "runtime-per-user",
        default_value = false,
        order = '025',
    }
    , {
        type = "double-setting",
        name = "Personal_Development-mining-speed-limit",
        setting_type = "runtime-per-user",
        default_value = 1.0,
        minimum_value = 0,
        order = '026',
    }
    , { -- CRAFTING SPEED
        type = "double-setting",
        name = "Personal_Development-crafting-speed-increase",
        setting_type = "runtime-global",
        default_value = 0.001,
        minimum_value = 0,
        order = '030',
    }
    , {
        type = "bool-setting",
        name = "Personal_Development-global-limit-crafting-speed",
        setting_type = "runtime-global",
        default_value = false,
        order = '035',
    }
    , {
        type = "double-setting",
        name = "Personal_Development-global-crafting-speed-limit",
        setting_type = "runtime-global",
        default_value = 10.0,
        minimum_value = 0,
        order = '036',
    }
    , {
        type = "bool-setting",
        name = "Personal_Development-limit-crafting-speed",
        setting_type = "runtime-per-user",
        default_value = false,
        order = '035',
    }
    , {
        type = "double-setting",
        name = "Personal_Development-crafting-speed-limit",
        setting_type = "runtime-per-user",
        default_value = 10.0,
        minimum_value = 0,
        order = '036',
    }
    , { -- HEALTH
        type = "double-setting",
        name = "Personal_Development-health-increase",
        setting_type = "runtime-global",
        default_value = 0.01,
        minimum_value = 0,
        order = '040',
    }
    , {
        type = "bool-setting",
        name = "Personal_Development-global-limit-health",
        setting_type = "runtime-global",
        default_value = false,
        order = '045',
    }
    , {
        type = "double-setting",
        name = "Personal_Development-global-health-limit",
        setting_type = "runtime-global",
        default_value = 750.0,
        minimum_value = 0,
        maximum_value = 4e6,
        order = '046',
    }
    , {
        type = "bool-setting",
        name = "Personal_Development-limit-health",
        setting_type = "runtime-per-user",
        default_value = false,
        order = '045',
    }
    , {
        type = "double-setting",
        name = "Personal_Development-health-limit",
        setting_type = "runtime-per-user",
        default_value = 750.0,
        minimum_value = 0,
        maximum_value = 4e6,
        order = '046',
    }
    , { -- RUNNING SPEED
        type = "double-setting",
        name = "Personal_Development-running-speed-increase",
        setting_type = "runtime-global",
        default_value = 2e-6,
        minimum_value = 0,
        order = '050',
    }
    , {
        type = "bool-setting",
        name = "Personal_Development-global-limit-running-speed",
        setting_type = "runtime-global",
        default_value = false,
        order = '055',
    }
    , {
        type = "double-setting",
        name = "Personal_Development-global-running-speed-limit",
        setting_type = "runtime-global",
        default_value = 4.0,
        minimum_value = 0,
        order = '056',
    }
    , {
        type = "bool-setting",
        name = "Personal_Development-limit-running-speed",
        setting_type = "runtime-per-user",
        default_value = true,
        order = '055',
    }
    , {
        type = "double-setting",
        name = "Personal_Development-running-speed-limit",
        setting_type = "runtime-per-user",
        default_value = 4.0,
        minimum_value = 0,
        order = '056',
    }
    , { -- GENERAL
        type = "bool-setting",
        name = "Personal_Development-disable",
        setting_type = "runtime-global",
        default_value = false,
        order = '100',
    }
})
