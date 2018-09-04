#!/usr/bin/lua
--[[
Convert a graphical dungeon into one for Pico-8 Lua

X     = wall block = 3
#     = pit        = 2
~     = under pit  = 1
space = open area  = 0

--]]

--[[dungeons = {
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
        "XXXXXXXXXX",
    },{
        "XXXXXXXXXX",
        "X        X",
        "XX X X X~X",
        "X   X X  X",
        "X X   X  X",
        "X XX XXX X",
        "X   X    X",
        "X XXXX X X",
        "X   #X   X",
        "XXXXXXXXXX",
    },{
        "XXXXXXXXXX",
        "X        X",
        "XXX X  X X",
        "X   XXXX X",
        "X X    X X",
        "X X X XX X",
        "X X X    X",
        "XXX XXXX X",
        "X   ~X   X",
        "XXXXXXXXXX",
    }
}

dungeons = {
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
        "XXXXXXXXXX",
    },{
        "XXXXXXXXXX",
        "X X X  ~ X",
        "X X X XX X",
        "X      X X",
        "X XXXX X X",
        "X X  XXX X",
        "X XX     X",
        "X X#XX XXX",
        "X   X    X",
        "XXXXXXXXXX",
    },{
        "XXXXXXXXXX",
        "X   X    X",
        "X X X XX X",
        "X X   X  X",
        "XXXXX XX X",
        "X     X  X",
        "X XXX  X X",
        "X X~X XX X",
        "X   X X  X",
        "XXXXXXXXXX",
    }
}

dungeons = {
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
        "XXXXXXXXXX",
    },{
        "XXXXXXXXXX",
        "X   X    X",
        "X X X~XX X",
        "X X    XXX",
        "X XXXXXX#X",
        "X    XXX X",
        "X XX     X",
        "X X XX XXX",
        "X X      X",
        "XXXXXXXXXX",
    },{
        "XXXXXXXXXX",
        "X   X    X",
        "X X X XX X",
        "X X   XX X",
        "X X X X ~X",
        "X X X XXXX",
        "X X X  X X",
        "X X X XX X",
        "X        X",
        "XXXXXXXXXX",
    }
}--]]

dungeons = {
   {
        "XXXXXXXXXX",
        "X    X   X",
        "X #X X X#X",
        "XXXX X XXX",
        "X    X X X",
        "X XXXX X X",
        "X  X X X X",
        "X    X X X",
        "X  X     X",
        "XXXXXXXXXX",
    },{
        "XXXXXXXXXX",
        "X    X   X",
        "X ~X X X~X",
        "X XXXX  XX",
        "X X# XX  X",
        "X XX X  XX",
        "X  X X X X",
        "X XX X X#X",
        "X    X   X",
        "XXXXXXXXXX",
    },{
        "XXXXXXXXXX",
        "X    X   X",
        "XX X X XXX",
        "X  X X   X",
        "X X~ XXX X",
        "X XXXX   X",
        "X    X XXX",
        "X X XX X~X",
        "X X#X    X",
        "XXXXXXXXXX",
    }
}

for dungeonIdx, dungeon in pairs(dungeons) do
    print('{')
    table.remove(dungeon, 1)
    table.remove(dungeon)
    for rowIdx, row in pairs(dungeon) do
        local rowNum = 0
        local row = string.sub(row, 2, -2)
        local comma = ''
        for colNum = 1, #row do
            local col = string.sub(row, colNum, colNum)
            rowNum = rowNum * 4
            if col == 'X' then
                rowNum = rowNum + 3
            elseif col == '#' then
                rowNum = rowNum + 2
            elseif col == '~' then
                rowNum = rowNum + 1
            end
            if rowIdx < #dungeon then
                comma = ','
            else
                comma = ''
            end
        end
        print(string.format("   0x%04x%s", rowNum, comma))
    end
    print('}')
end
