-- New InF table, primarily used for tweakdata
if not IreNFist then

    _G.IreNFist = {}

    -- Keeps a list of converted cops
    -- This is for the skill that allows you to call converted cops over to revive you
    IreNFist._converts = {}

    -- Heist-specific overrides for assault values
    -- This has to be done because some poorly designed heists like Shacklethorne have assaults that end way too quickly with these tweaks
    -- Default values:
    -- self.besiege.assault.force = {14, 15, 16} -- 14, 16, 18
    -- self.besiege.assault.force_balance_mul = {1, 2, 3, 4} -- 1, 2, 3, 4
    -- 
    -- self.besiege.assault.force_pool = {40, 45, 50} -- originally 150, 175, 225
    -- self.besiege.assault.force_pool_balance_mul = {1, 2, 3, 4} -- originally 1, 2, 3, 4
    -- Spawn delay is optional. If not given, is basically 0.
    IreNFist.bad_heist_overrides = {
        sah = { -- Shacklethorne Auction, lower max cops but increase the assault pool size
            force = { 12, 13, 14 },
            force_balance_mul = { 1, 2, 3, 4 },
            force_pool = { 50, 55, 60 },
            force_pool_balance_mul = { 1, 2, 3, 4 },
            initial_spawn_delay = 30 -- Add a 30 second spawn delay because a literal 0 second response time is dumb
        },
        nmh = { -- No Mercy, same as Shacklethorne Auction
            force = { 12, 13, 14 },
            force_balance_mul = { 1, 2, 3, 4 },
            force_pool = { 50, 55, 60 },
            force_pool_balance_mul = { 1, 2, 3, 4 }
        },
        kenaz = { -- Golden grin casino. Not *actually* a bad heist at all, but the lowered max cop count makes this too easy otherwise
            force = {14, 16, 18},
            force_balance_mul = { 1, 2, 3, 4 },
            force_pool = {45, 50, 55},
            force_pool_balance_mul = { 1, 2, 3, 4 }
        }
    }

    -- Not sure which one of these two names Golden Grin uses, so just override them both.
    IreNFist.bad_heist_overrides.cas = deep_clone(IreNFist.bad_heist_overrides.kenaz)

end

-- Old table that I don't wanna refactor right now, holds menu settings but also holds tweakdata for the various weapon categories.
if not InFmenu then
    _G.InFmenu = {}
    InFmenu._path = ModPath
    InFmenu._data_path = SavePath .. 'infsave.txt'
    InFmenu.settings = InFmenu.settings or {
        allpenwalls = true,
        reloadbreaksads = true,
        disable_autoreload = true,
        goldeneye = 1,

        rainbowassault = true,
        skulldozersahoy = 2,
        sanehp = true,
        copfalloff = true,
        copmiss = true,
        enablenewcopvoices = true,
        enablenewcopdomination = true,

        runkick = false,
        kickyeet = 1,
        slidestealth = 2,
        slideloud = 3,
        slidewpnangle = 15,
        wallrunwpnangle = 15,
        dashcontrols = 4,

        txt_wpnname = 2,

        disablefrogmanwarnings = false
    }

    function InFmenu:Save()
        local file = io.open(InFmenu._data_path, 'w+')
        if file then
            file:write(json.encode(InFmenu.settings))
            file:close()
        end
    end
    
    function InFmenu:Load()
        local file = io.open(InFmenu._data_path, 'r')
        if file then
            for k, v in pairs(json.decode(file:read('*all')) or {}) do
                InFmenu.settings[k] = v
            end
            file:close()
        end
    end
    
    InFmenu:Load()
    -- generate save data even if nobody ever touches the mod options menu
    InFmenu:Save()

    -- Tons of tweakdata stuff ahead
    InFmenu.rtable = {}
    InFmenu.rstance = {}
    InFmenu.wpnvalues = {}
    
    -- Stances and recoil
    InFmenu.rtable.lrifle = {
        {0.5, 0.5, -0.2, -0.2},
        {0.6, 0.6, -0.2, -0.2},
        {0.7, 0.7, -0.3, -0.3},
        {0.8, 0.8, -0.3, -0.3},
        {0.9, 0.9, -0.3, -0.3},
        {1.0, 1.0, -0.4, -0.4},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.1, 1.1, -0.5, -0.5},
        {1.2, 1.2, -0.5, 0.5},
        {1.3, 1.3, -0.5, 0.5},
        {1.3, 1.3, -0.2, -0.2}, -- loop
        {1.3, 1.3, 0.1, 0.1},
        {1.3, 1.3, 0.5, 0.5},
        {1.3, 1.3, 0.5, 0.5},
        {1.3, 1.3, 0.5, 0.5},
        {1.3, 1.3, 0.2, 0.2},
        {1.3, 1.3, -0.1, -0.1},
        {1.3, 1.3, -0.5, -0.5},
        {1.3, 1.3, -0.5, -0.5},
        {1.3, 1.3, -0.5, -0.5}
    }
    InFmenu.rtable.carbine = deep_clone(InFmenu.rtable.lrifle)
    
    InFmenu.rtable.hrifle = {
        {0.5, 0.5, -0.2, -0.2},
        {0.6, 0.6, -0.2, -0.2},
        {0.7, 0.7, -0.2, -0.2},
        {0.8, 0.8, -0.2, -0.2},
        {0.9, 0.9, -0.4, -0.4},
        {1.0, 1.0, -0.4, -0.4},
        {1.0, 1.0, -0.4, -0.4},
        {1.2, 1.2, -0.2, -0.2},
        {1.2, 1.2, 0.2, 0.2}, -- loop
        {1.2, 1.2, 0.4, 0.4},
        {1.3, 1.3, 0.5, 0.5},
        {1.3, 1.3, 0.5, 0.5},
        {1.2, 1.2, -0.2, -0.2},
        {1.2, 1.2, -0.4, -0.4},
        {1.3, 1.3, -0.5, -0.5},
        {1.3, 1.3, -0.5, -0.5}
    }
    InFmenu.rtable.mrifle = deep_clone(InFmenu.rtable.hrifle)
    InFmenu.rtable.mcarbine = deep_clone(InFmenu.rtable.hrifle)
    
    InFmenu.rtable.dmr = {
        {1.0, 1.0, 0.2, -0.2},
        {1.0, 1.0, 0.2, -0.2},
        {1.0, 1.0, 0.2, -0.2},
        {1.0, 1.0, 0.2, -0.2},
        {1.0, 1.0, 0.4, -0.4},
        {1.0, 1.0, 0.4, -0.4},
        {1.0, 1.0, 0.4, -0.4},
        {1.2, 1.2, 0.2, -0.2},
        {1.2, 1.2, 0.2, -0.2}, -- loop
        {1.2, 1.2, 0.4, -0.4},
        {1.3, 1.3, 0.5, -0.5},
        {1.3, 1.3, 0.5, -0.5},
        {1.2, 1.2, 0.2, -0.2},
        {1.2, 1.2, 0.4, -0.4},
        {1.3, 1.3, 0.5, -0.5},
        {1.3, 1.3, 0.5, -0.5}
    }
    InFmenu.rtable.ldmr = deep_clone(InFmenu.rtable.dmr)
    
    InFmenu.rtable.shotgun = {
        {1.0, 1.0, 0.35, -0.35},
        {1.0, 1.0, 0.35, -0.35},
        {1.1, 1.1, 0.50, -0.40},
        {1.2, 1.2, 0.70, -0.55},
        {1.3, 1.3, 0.90, -0.60},
        {1.4, 1.4, 1.20, -0.70}
    }
    
    InFmenu.rtable.lmg = {
        {0.6, 0.6, -0.3, -0.3},
        {0.6, 0.6, -0.3, -0.3},
        {0.6, 0.6, -0.3, -0.3},
        {0.6, 0.6, -0.1, -0.1},
        {0.8, 0.8, 0.2, 0.2},
        {0.8, 0.8, 0.4, 0.4},
        {0.8, 0.8, 0.4, 0.4},
        {0.8, 0.8, 0.4, 0.4},
        {1.0, 1.0, -0.2, -0.2}, -- loop
        {1.0, 1.0, -0.2, -0.2},
        {1.0, 1.0, 0.1, 0.1},
        {1.0, 1.0, 0.1, 0.1},
        {1.0, 1.0, 0.5, 0.5},
        {1.0, 1.0, 0.5, 0.5},
        {1.0, 1.0, 0.5, 0.5},
        {1.0, 1.0, 0.5, 0.5},
        {1.0, 1.0, 0.2, 0.2},
        {1.0, 1.0, 0.2, 0.2},
        {1.0, 1.0, -0.1, -0.1},
        {1.0, 1.0, -0.1, -0.1},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5}
    }
    
    InFmenu.rtable.lightpis = {
        {1.0, 1.0, -0.2, -0.2},
        {1.0, 1.0, -0.2, -0.2},
        {1.0, 1.0, -0.2, -0.2},
        {1.0, 1.0, -0.2, 0.2},
        {1.0, 1.0, -0.2, 0.2},
        {1.0, 1.0, -0.1, -0.1}, -- loop
        {1.0, 1.0, 0.0, 0.0},
        {1.0, 1.0, 0.3, 0.3},
        {1.0, 1.0, 0.3, 0.3},
        {1.0, 1.0, 0.3, 0.3},
        {1.0, 1.0, 0.1, 0.1},
        {1.0, 1.0, -0.0, -0.0},
        {1.0, 1.0, -0.3, -0.3},
        {1.0, 1.0, -0.3, -0.3},
        {1.0, 1.0, -0.3, -0.3}
    }
    
    InFmenu.rtable.mediumpis = InFmenu.rtable.lightpis
    
    InFmenu.rtable.heavypis = {
        {1.0, 1.0, -0.2, -0.2},
        {1.0, 1.0, 0.1, 0.1},
        {1.2, 1.2, -0.2, -0.2}, -- loop
        {1.2, 1.2, -0.4, -0.4},
        {1.2, 1.2, -0.2, -0.2},
        {1.2, 1.2, 0.4, 0.4},
        {1.2, 1.2, -0.2, -0.2},
        {1.2, 1.2, -0.4, -0.4}
    }
    InFmenu.rtable.supermediumpis = InFmenu.rtable.heavypis
    
    InFmenu.rtable.shortsmg = InFmenu.rtable.lrifle
    
    InFmenu.rtable.longsmg = InFmenu.rtable.lrifle
    
    --[[
    InFmenu.rtable.akimbo = {
        {2.0, 2.0, 0.7, -0.7},
        {2.0, 2.0, 0.7, -0.7},
        {2.0, 2.0, 0.7, -0.7},
        {2.0, 2.0, 0.7, -0.7},
        {2.0, 2.0, 0.7, -0.7},
        {2.0, 2.0, 0.7, -0.7},
        {2.0, 2.0, 0.5, 0.5}, -- loop
        {2.0, 2.0, 1.2, 0.7},
        {2.0, 2.0, 1.2, 0.7},
        {2.0, 2.0, 1.2, 0.7},
        {2.0, 2.0, 0.5, 0.5},
        {2.0, 2.0, -0.2, -0.2},
        {2.0, 2.0, -1.2, -1.2},
        {2.0, 2.0, -1.2, -1.2},
        {2.0, 2.0, -1.2, -1.2}
    }
    --]]
    
    InFmenu.rtable.minigun = {
        {1.0, 1.0, -0.2, -0.2},
        {1.0, 1.0, -0.2, -0.2},
        {1.0, 1.0, -0.2, -0.2},
        {1.0, 1.0, -0.2, -0.2},
        {1.0, 1.0, -0.2, -0.2},
        {1.0, 1.0, -0.2, -0.2},
        {1.0, 1.0, -0.2, -0.2},
        {1.0, 1.0, -0.2, -0.2},
        {1.0, 1.0, -0.2, -0.2},
        {1.0, 1.0, -0.2, -0.2},
        {1.0, 1.0, -0.3, -0.3},
        {1.0, 1.0, -0.3, -0.3},
        {1.0, 1.0, -0.3, -0.3},
        {1.0, 1.0, -0.3, -0.3},
        {1.0, 1.0, -0.3, -0.3},
        {1.0, 1.0, -0.3, -0.3},
        {1.0, 1.0, -0.3, -0.3},
        {1.0, 1.0, -0.3, -0.3},
        {1.0, 1.0, -0.3, -0.3},
        {1.0, 1.0, -0.3, -0.3},
        {1.0, 1.0, -0.3, -0.3},
        {1.0, 1.0, -0.3, -0.3},
        {1.0, 1.0, -0.3, -0.3},
        {1.0, 1.0, -0.3, -0.3},
        {1.0, 1.0, -0.3, -0.3},
        {1.0, 1.0, -0.4, -0.4},
        {1.0, 1.0, -0.4, -0.4},
        {1.0, 1.0, -0.4, -0.4},
        {1.0, 1.0, -0.4, -0.4},
        {1.0, 1.0, -0.4, -0.4},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, 0.5},
        {1.0, 1.0, -0.5, 0.5},
        {1.0, 1.0, -0.5, 0.5},
        {1.0, 1.0, -0.5, 0.5},
        {1.0, 1.0, -0.5, 0.5},
        {1.0, 1.0, -0.5, 0.5},
        {1.0, 1.0, -0.5, 0.5},
        {1.0, 1.0, -0.5, 0.5},
        {1.0, 1.0, -0.5, 0.5},
        {1.0, 1.0, -0.5, 0.5},
        {1.0, 1.0, -0.2, -0.2}, -- loop
        {1.0, 1.0, -0.2, -0.2},
        {1.0, 1.0, -0.2, -0.2},
        {1.0, 1.0, -0.2, -0.2},
        {1.0, 1.0, -0.2, -0.2},
        {1.0, 1.0, 0.1, 0.1},
        {1.0, 1.0, 0.1, 0.1},
        {1.0, 1.0, 0.1, 0.1},
        {1.0, 1.0, 0.1, 0.1},
        {1.0, 1.0, 0.1, 0.1},
        {1.0, 1.0, 0.5, 0.5},
        {1.0, 1.0, 0.5, 0.5},
        {1.0, 1.0, 0.5, 0.5},
        {1.0, 1.0, 0.5, 0.5},
        {1.0, 1.0, 0.5, 0.5},
        {1.0, 1.0, 0.5, 0.5},
        {1.0, 1.0, 0.5, 0.5},
        {1.0, 1.0, 0.5, 0.5},
        {1.0, 1.0, 0.5, 0.5},
        {1.0, 1.0, 0.5, 0.5},
        {1.0, 1.0, 0.5, 0.5},
        {1.0, 1.0, 0.5, 0.5},
        {1.0, 1.0, 0.5, 0.5},
        {1.0, 1.0, 0.5, 0.5},
        {1.0, 1.0, 0.5, 0.5},
        {1.0, 1.0, 0.2, 0.2},
        {1.0, 1.0, 0.2, 0.2},
        {1.0, 1.0, 0.2, 0.2},
        {1.0, 1.0, 0.2, 0.2},
        {1.0, 1.0, 0.2, 0.2},
        {1.0, 1.0, -0.1, -0.1},
        {1.0, 1.0, -0.1, -0.1},
        {1.0, 1.0, -0.1, -0.1},
        {1.0, 1.0, -0.1, -0.1},
        {1.0, 1.0, -0.1, -0.1},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5},
        {1.0, 1.0, -0.5, -0.5}
    }
    
    InFmenu.rtable.norecoil = {
        {0, 0, 0, 0},
        {0, 0, 0, 0}
    }
    
    InFmenu.rtable.snp = {
        {1.25, 1.25, 1.0, -1.0},
        {1.25, 1.25, 1.0, -1.0}
    }
    
    
    -- recoil by stance
    InFmenu.rstance.lrifle = {
        standing = {1.2, 1.2, 0.8, 0.8},
        crouching = {1.0, 1.0, 0.7, 0.7},
        steelsight = {0.6, 0.6, 0.5, 0.5}
    }
    InFmenu.rstance.carbine = InFmenu.rstance.lrifle
    InFmenu.rstance.hrifle = InFmenu.rstance.lrifle
    InFmenu.rstance.mrifle = InFmenu.rstance.hrifle
    InFmenu.rstance.mcarbine = InFmenu.rstance.hrifle
    
    InFmenu.rstance.shortsmg = kick_mult(InFmenu.rstance.lrifle, 1, 0.8, 1, 0.8, 1, 0.8)
    InFmenu.rstance.longsmg = InFmenu.rstance.shortsmg
    
    InFmenu.rstance.dmr = {
        standing = {1.5, 1.5, 0.8, 0.8},
        crouching = {1.3, 1.3, 0.6, 0.6},
        steelsight = {1.0, 1.0, 0.3, 0.3}
    }
    InFmenu.rstance.ldmr = {
        standing = {1.3, 1.3, 0.7, 0.7},
        crouching = {1.2, 1.2, 0.55, 0.55},
        steelsight = {0.9, 0.9, 0.25, 0.25}
    }
    
    InFmenu.rstance.snp = {
        standing = {1.5, 1.5, 0.8, 0.8},
        crouching = {1.3, 1.3, 0.6, 0.6},
        steelsight = {1.0, 1.0, 0.3, 0.3}
    }
    
    InFmenu.rstance.lightpis = {
        standing = {1.2, 1.2, 1.0, 1.0},
        crouching = {1.0, 1.0, 0.9, 0.9},
        steelsight = {0.5, 0.5, 0.5, 0.5}
    }
    
    InFmenu.rstance.mediumpis = {
        standing = {1.2, 1.2, 1.0, 1.0},
        crouching = {1.0, 1.0, 0.8, 0.8},
        steelsight = {0.7, 0.7, 0.6, 0.6}
    }
    InFmenu.rstance.supermediumpis = deep_clone(InFmenu.rstance.mediumpis)
    
    InFmenu.rstance.heavypis = {
        standing = {3.0, 3.0, 1.6, 1.6},
        crouching = {2.6, 2.6, 1.2, 1.2},
        steelsight = {1.6, 1.6, 0.6, 0.6}
    }
    
    InFmenu.rstance.shotgun = {
        standing = {2.5, 2.5, 2.2, 2.2},
        crouching = {2.3, 2.3, 2.1, 2.1},
        steelsight = {1.8, 1.8, 1.6, 1.6}
    }
    
    InFmenu.rstance.lmg = {
        standing = {1.0, 1.0, 0.4, 0.4},
        crouching = {0.8, 0.8, 0.3, 0.3},
        steelsight = {0.6, 0.6, 0.25, 0.25}
    }
    
    InFmenu.rstance.minigun = {
        standing = {0.28, 0.28, 0.12, 0.12},
        crouching = {0.24, 0.24, 0.11, 0.11},
        steelsight = {0.20, 0.20, 0.10, 0.10}
    }
    --[[
    InFmenu.rstance.minigun = {
        standing = {0.35, 0.35, 0.15, 0.15},
        crouching = {0.30, 0.30, 0.13, 0.13},
        steelsight = {0.25, 0.25, 0.12, 0.12}
    }
    --]]
    
    InFmenu.rstance.one = {
        standing = {1, 1, 1, 1},
        crouching = {1, 1, 1, 1},
        steelsight = {1, 1, 1, 1}
    }
    
    InFmenu.rstance.norecoil = {
        standing = {0, 0, 0, 0},
        crouching = {0, 0, 0, 0},
        steelsight = {0, 0, 0, 0}
    }

    -- Weapon values
    InFmenu.wpnvalues.lrifle = {}
    InFmenu.wpnvalues.lrifle.damage = 55
    InFmenu.wpnvalues.lrifle.spread = 81
    InFmenu.wpnvalues.lrifle.recoil = 71
    InFmenu.wpnvalues.lrifle.armor_piercing_chance = 0.75
    InFmenu.wpnvalues.lrifle.recoil_loop_point = 12
    InFmenu.wpnvalues.lrifle.ammo = 180
    InFmenu.wpnvalues.lrifle_gl = deep_clone(InFmenu.wpnvalues.lrifle)
    InFmenu.wpnvalues.lrifle_gl.ammo = 120
    InFmenu.wpnvalues.mrifle = {}
    InFmenu.wpnvalues.mrifle.damage = 75
    InFmenu.wpnvalues.mrifle.spread = 81
    InFmenu.wpnvalues.mrifle.recoil = 61
    InFmenu.wpnvalues.mrifle.armor_piercing_chance = 0.67
    InFmenu.wpnvalues.mrifle.recoil_loop_point = 9
    InFmenu.wpnvalues.mrifle.ammo = 120
    InFmenu.wpnvalues.mrifle_gl = deep_clone(InFmenu.wpnvalues.mrifle)
    InFmenu.wpnvalues.mrifle_gl.ammo = 80
    InFmenu.wpnvalues.hrifle = {}
    InFmenu.wpnvalues.hrifle.damage = 90
    InFmenu.wpnvalues.hrifle.spread = 81
    InFmenu.wpnvalues.hrifle.recoil = 56
    InFmenu.wpnvalues.hrifle.armor_piercing_chance = 0.75
    InFmenu.wpnvalues.hrifle.recoil_loop_point = 9
    InFmenu.wpnvalues.hrifle.ammo = 120
    InFmenu.wpnvalues.hrifle_gl = deep_clone(InFmenu.wpnvalues.hrifle)
    InFmenu.wpnvalues.hrifle_gl.ammo = 80
    InFmenu.wpnvalues.ldmr = {}
    InFmenu.wpnvalues.ldmr.damage = 120 -- bring this up to 130 if i ever use the tankier death sentence health values
    InFmenu.wpnvalues.ldmr.spread = 81
    InFmenu.wpnvalues.ldmr.recoil = 51
    InFmenu.wpnvalues.ldmr.armor_piercing_chance = 1
    InFmenu.wpnvalues.ldmr.recoil_loop_point = 9
    InFmenu.wpnvalues.ldmr.rof = 600
    InFmenu.wpnvalues.ldmr.ammo = 80
    InFmenu.wpnvalues.dmr = {}
    InFmenu.wpnvalues.dmr.damage = 170
    InFmenu.wpnvalues.dmr.spread = 86
    InFmenu.wpnvalues.dmr.recoil = 41
    InFmenu.wpnvalues.dmr.armor_piercing_chance = 1
    InFmenu.wpnvalues.dmr.recoil_loop_point = 9
    InFmenu.wpnvalues.dmr.rof = 420
    InFmenu.wpnvalues.dmr.ammo = 50

    -- mag presets
    -- output: mag% * reload%
    InFmenu.wpnvalues.reload = {}
    -- 0.5
    InFmenu.wpnvalues.reload.mag_17 = {reload = 200}
    -- 0.6875
    InFmenu.wpnvalues.reload.mag_25 = {reload = 175}
    -- 0.767
    InFmenu.wpnvalues.reload.mag_33 = {reload = 130}
    -- 0.825
    InFmenu.wpnvalues.reload.mag_50 = {reload = 65}
    -- 0.858
    InFmenu.wpnvalues.reload.mag_66 = {reload = 30}
    -- 0.9
    InFmenu.wpnvalues.reload.mag_75 = {reload = 20}
    -- mag100 = 1
    -- 1.1
    InFmenu.wpnvalues.reload.mag_125 = {reload = -12}
    -- 1.1305
    InFmenu.wpnvalues.reload.mag_133 = {reload = -15}
    -- 1.2
    InFmenu.wpnvalues.reload.mag_150 = {reload = -20}
    -- 1.3
    InFmenu.wpnvalues.reload.mag_200 = {reload = -35}
    --
    InFmenu.wpnvalues.reload.mag_250 = {reload = -40}
    -- 1.65
    InFmenu.wpnvalues.reload.mag_300 = {reload = -45}

        -- PISTOLS
    InFmenu.wpnvalues.lightpis = {}
    InFmenu.wpnvalues.lightpis.damage = 55
    InFmenu.wpnvalues.lightpis.spread = 71
    InFmenu.wpnvalues.lightpis.recoil = 71
    InFmenu.wpnvalues.lightpis.armor_piercing_chance = 0.64
    InFmenu.wpnvalues.lightpis.recoil_loop_point = 6
    InFmenu.wpnvalues.lightpis.ammo = 150
    InFmenu.wpnvalues.lightpis.rof = 600
    InFmenu.wpnvalues.mediumpis = {}
    InFmenu.wpnvalues.mediumpis.damage = 85
    InFmenu.wpnvalues.mediumpis.spread = 71
    InFmenu.wpnvalues.mediumpis.recoil = 61
    InFmenu.wpnvalues.mediumpis.armor_piercing_chance = 0.75
    InFmenu.wpnvalues.mediumpis.recoil_loop_point = 6
    InFmenu.wpnvalues.mediumpis.ammo = 80
    InFmenu.wpnvalues.mediumpis.rof = 600
    InFmenu.wpnvalues.supermediumpis = {}
    InFmenu.wpnvalues.supermediumpis.damage = 110
    InFmenu.wpnvalues.supermediumpis.spread = 71
    InFmenu.wpnvalues.supermediumpis.recoil = 51
    InFmenu.wpnvalues.supermediumpis.armor_piercing_chance = 0.75
    InFmenu.wpnvalues.supermediumpis.recoil_loop_point = 3
    InFmenu.wpnvalues.supermediumpis.ammo = 60
    InFmenu.wpnvalues.supermediumpis.rof = 600
    InFmenu.wpnvalues.heavypis = {}
    InFmenu.wpnvalues.heavypis.damage = 170
    InFmenu.wpnvalues.heavypis.spread = 71
    InFmenu.wpnvalues.heavypis.recoil = 46
    InFmenu.wpnvalues.heavypis.armor_piercing_chance = 1
    InFmenu.wpnvalues.heavypis.recoil_loop_point = 3
    InFmenu.wpnvalues.heavypis.ammo = 42
    InFmenu.wpnvalues.heavypis.rof = 300

    -- SUBMACHINE GUNS
    InFmenu.wpnvalues.shortsmg = {}
    InFmenu.wpnvalues.shortsmg.damage = 45
    InFmenu.wpnvalues.shortsmg.spread = 51
    InFmenu.wpnvalues.shortsmg.recoil = 81
    InFmenu.wpnvalues.shortsmg.armor_piercing_chance = 0.60
    InFmenu.wpnvalues.shortsmg.recoil_loop_point = 12
    InFmenu.wpnvalues.shortsmg.ammo = 150
    InFmenu.wpnvalues.longsmg = {}
    InFmenu.wpnvalues.longsmg.damage = 50
    InFmenu.wpnvalues.longsmg.spread = 61
    InFmenu.wpnvalues.longsmg.recoil = 76
    InFmenu.wpnvalues.longsmg.armor_piercing_chance = 0.60 -- not used below
    InFmenu.wpnvalues.longsmg.recoil_loop_point = 12 -- not used below
    InFmenu.wpnvalues.longsmg.ammo = 120
    InFmenu.wpnvalues.carbine = {}
    InFmenu.wpnvalues.carbine.damage = 55
    InFmenu.wpnvalues.carbine.spread = 66
    InFmenu.wpnvalues.carbine.recoil = 71
    InFmenu.wpnvalues.carbine.armor_piercing_chance = 0.75
    InFmenu.wpnvalues.carbine.recoil_loop_point = 12
    InFmenu.wpnvalues.carbine.ammo = 120
    InFmenu.wpnvalues.mcarbine = {}
    InFmenu.wpnvalues.mcarbine.damage = 75
    InFmenu.wpnvalues.mcarbine.spread = 66
    InFmenu.wpnvalues.mcarbine.recoil = 66
    InFmenu.wpnvalues.mcarbine.armor_piercing_chance = 0.67
    InFmenu.wpnvalues.mcarbine.recoil_loop_point = 9
    InFmenu.wpnvalues.mcarbine.ammo = 90
end
