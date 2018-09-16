#!/usr/bin/lua
--[[
Convert a graphical dungeon into one for Pico-8 Lua Minima.

X     = wall block = 3
#     = pit        = 2
~     = under pit  = 1
space = open area  = 0

Note that pits and under pits are now ignored by Minima. We're using
them to track location of ladders for ease-of-use, but they don't
really do anything. Likewise periods can be used to map out points
of interest, but they get ignored by this converter.
--]]

dungeons = {
    -- Nibiru
    {
        {
            "XXXXXXXXXX",
            "X        X",
            "X XXXXXX#X",
            "X   X    X",
            "X X   X  X",
            "X XXXXXX X",
            "X X X    X",
            "X X XXXX X",
            "X    X   X",
            "XXXXXXXXXX"
        }, {
            "XXXXXXXXXX",
            "X        X",
            "XX X X X~X",
            "X   X X  X",
            "X X   X  X",
            "X XX XXX X",
            "X   X    X",
            "X XXXX X X",
            "X   #X   X",
            "XXXXXXXXXX"
        }, {
            "XXXXXXXXXX",
            "X#       X",
            "XXX X  X X",
            "X   XXXX X",
            "X X    X X",
            "X X X XX X",
            "X X X    X",
            "XXX XXXX X",
            "X   ~X.  X",
            "XXXXXXXXXX"
        }, {
            "XXXXXXXXXX",
            "X~X X X  X",
            "X X X XX X",
            "X        X",
            "XXX XXXXXX",
            "X        X",
            "XXX XX X X",
            "X   X  X X",
            "X X X XX X",
            "XXXXXXXXXX"
        }
    },
    -- Purgatory
    {
        {
            "XXXXXXXXXX",
            "X   X X# X",
            "X XXX XX X",
            "X   X    X",
            "X X XXX  X",
            "XXX   XX X",
            "X X X    X",
            "X X XXXX X",
            "X   X    X",
            "XXXXXXXXXX"
        }, {
            "XXXXXXXXXX",
            "X X X  ~ X",
            "X X X XX X",
            "X      X X",
            "X XXXX X X",
            "X X  XXX X",
            "X XX     X",
            "X X#XX XXX",
            "X   X    X",
            "XXXXXXXXXX"
        }, {
            "XXXXXXXXXX",
            "X   X    X",
            "X X X XX X",
            "X#X   X  X",
            "XXXXX XX X",
            "X     X. X",
            "X XXX  X X",
            "X X~X XX X",
            "X   X X  X",
            "XXXXXXXXXX"
        }, {
            "XXXXXXXXXX",
            "X        X",
            "XX X X X X",
            "X~ X   X X",
            "XX X X X X",
            "X    X   X",
            "XX X X X X",
            "X  X   X X",
            "XX X X X X",
            "XXXXXXXXXX"
        }
    },
    -- Sheol
    {
        {
            "XXXXXXXXXX",
            "X   X    X",
            "X XXX#X  X",
            "X   XXXX X",
            "X X X    X",
            "X X XXX XX",
            "X X      X",
            "XXXXXXXX X",
            "X        X",
            "XXXXXXXXXX"
        }, {
            "XXXXXXXXXX",
            "X   X    X",
            "X X X~XX X",
            "X X    XXX",
            "X XXXXXX#X",
            "X    XXX X",
            "X XX     X",
            "X X XX XXX",
            "X X      X",
            "XXXXXXXXXX"
        }, {
            "XXXXXXXXXX",
            "X   X    X",
            "X X X XX X",
            "X X   XX X",
            "X X X X ~X",
            "X X X XXXX",
            "X X X .X X",
            "X X X XX X",
            "X   #    X",
            "XXXXXXXXXX"
        }, {
            "XXXXXXXXXX",
            "X        X",
            "X XXX XX X",
            "X X    X X",
            "X X XX X X",
            "X X    X X",
            "X X    X X",
            "X XXXXXX X",
            "X   ~    X",
            "XXXXXXXXXX"
        }
    },
    -- The Upper Levels
    {
        {
            "XXXXXXXXXX",
            "X    X   X",
            "X#XX X X#X",
            "XXXX X XXX",
            "X    X X X",
            "X XXXX X X",
            "X  X X X X",
            "X    X X X",
            "X  X     X",
            "XXXXXXXXXX"
        }, {
            "XXXXXXXXXX",
            "X    X   X",
            "X~XX X X~X",
            "X XXXX  XX",
            "X X# XX  X",
            "X XX X  XX",
            "X  X X X X",
            "X XX X X#X",
            "X    X   X",
            "XXXXXXXXXX"
        }, {
            "XXXXXXXXXX",
            "X    X   X",
            "XX X X XXX",
            "X  X X   X",
            "X X~ XXX X",
            "X XXXX   X",
            "X    X XXX",
            "X X XX X~X",
            "X X#X    X",
            "XXXXXXXXXX"
        }
    }
}

-- Work dungeon by dungeon...
for dungeonIdx, dungeon in pairs(dungeons) do
    -- Floor by floor...
    print("levels={")
    for floorIdx, floor in pairs(dungeon) do
        if floorIdx == 1 then
            print('  {')
        end
        -- We actually ignore the outer edge. It's required to be wall.
        table.remove(floor, 1)
        table.remove(floor)
        -- We turn each row of each floor into a single hex code.
        for rowIdx, row in pairs(floor) do
            local rowNum = 0
            local row = string.sub(row, 2, -2)
            local comma = ''
            for colNum = 1, #row do
                local col = string.sub(row, colNum, colNum)
                rowNum = rowNum * 4
                if col == 'X' then
                    -- it's a wall
                    rowNum = rowNum + 3
                elseif col == '#' then
                    -- it's a pit
                    rowNum = rowNum + 2
                elseif col == '~' then
                    -- it's the underside of a pit
                    rowNum = rowNum + 1
                end
                -- anything that isn't an X, #, or ~ gets ignored.
                if rowIdx < #floor then
                    comma = ','
                end
            end
            print(string.format("    0x%04x%s", rowNum, comma))
        end
        local nextGroupStart = ''
        if floorIdx < #dungeon then
            nextGroupStart = ',{'
        end
        print(string.format('  }%s', nextGroupStart))
    end
    print('}\n')
end
