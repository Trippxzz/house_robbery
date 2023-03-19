Config = {}

Config.Ped = {
    Name = "a_m_y_business_03",
    Pos = {x = 166.8932, y = -1284.169, z = 28.35997, h = 80.51255}
    
}

Config.Houses = {
    House1 = {
        Door = vector3(-174.7202, 502.5304, 137.4204),
        Interior = vector3(-174.3378, 497.484, 137.6535), 
        HeadingInt = 191.0619,
        LootH = {
            vector3(-170.3029, 496.1262, 137.6536),
            vector3(-170.6799, 482.5876, 137.2442),
            vector3(-167.5402, 488.0954, 133.8438),
            vector3(-174.4345, 493.9098, 130.0436)
        }
    }
}
Config.OxTarget = true
Config.JobName = 'police'

Config.SkillCheck = {
    difficulty = 'hard', -- easy, medium, hard
    repeatTimes = math.random(5, 10), -- How many times the skill check repeats until finish
}