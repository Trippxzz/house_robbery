Config = {}


Config.OxTarget = true
Config.JobName = 'police'

Config.RequiredItem = true
Config.ItemRequired = "lockpick"
Config.BlipEnabled = true
Config.CopsRequired = 2
Config.Cooldown = 180 
Config.Lastrob = 0 -- DON'T TOUCH

Config.Ped = {
    Name = "a_m_y_business_03",
    Pos = {x = 166.8932, y = -1284.169, z = 28.35997, h = 80.51255}
    
}

Config.Houses = {
    House1 = {   --you can add as many locations as you want
        Door = vector3(-174.7202, 502.5304, 137.4204),
        Interior = vector3(-174.3378, 497.484, 137.6535), 
        HeadingInt = 191.0619,  --heading for interior 
        LootH = {
            vector3(-170.3029, 496.1262, 137.6536),
            vector3(-170.6799, 482.5876, 137.2442),
            vector3(-167.5402, 488.0954, 133.8438),
            vector3(-174.4345, 493.9098, 130.0436)
        }
    },
    House2 = { 
        Door = vector3(-36.30156, -570.6331, 38.83335), 
        Interior = vector3(-31.4882, -595.133, 80.03), 
        HeadingInt = 311.318,
        LootH = {
            vector3(-27.74033, -581.5154, 79.23),  
            vector3(-39.19651, -589.2886, 78.83),
            vector3(-32.36621, -583.7902, 78.86551), 
            vector3(-12.62623, -596.9193, 79.43) 
        }
    },
    House3 = { 
        Door = vector3(-686.044, 596.1514, 143.6422),
        Interior = vector3(-682.4269, 592.7078, 145.37),  
        HeadingInt = 224.9117,  
        LootH = {
            vector3(-678.1968, 593.1891, 145.3798),   
            vector3(-671.786, 581.1215, 144.9703), 
            vector3(-671.7256, 587.5762, 141.5699),  
            vector3(-680.682, 589.1367, 137.7697)  
        }
    }
}

Config.Loot = {
    badloot = {
        "bread",
        "phone"
    },
    mediumloot = {
        "diamond",
        "weapon_pistol"
    },
    goodloot = {
        "money",
        "black_money"
    }
}

Config.Cant = {
    badloot = {1, 2},
    mediumloot = {1, 2},
    goodloot = {1000, 10000} --For money
}