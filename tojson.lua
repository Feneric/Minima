#!/usr/bin/lua
--[[
Convert Minima Lua tables into JSON for more compact storage that uses fewer tokens.
--]]

json = require 'json'

-- For this to work in PICO-8, everything has to be crammed into a single line.
-- PICO-8 also wants embedded apostrophe characters escaped.
-- This returns the full line including the appropriate `json_parse` call so
-- it can be copied and pasted directly in.
function outputStructure(structureName, structure)
  structureJson = string.gsub(json.encode(structure), "'", "\\'")
  print(string.format("%s=json_parse('%s')", structureName, structureJson))
end

-- Our basetypes structure includes all of our objects and our bestiary.
basetypes={
  {
    hp=10,
    armor=1,
    dmg=13,
    dex=8,
    hostile=true,
    terrain={1,2,3,4,5,6,7,8,17,18,22,25,26,27,30,31,33,35},
    moveallowance=1,
    gold=10,
    exp=2,
    chance=1
  },{
    mapnum=0,
    minx=80,
    maxx=128,
    miny=0,
    maxy=64,
    newmonsters=0,
    maxmonsters=0,
    friendly=true
  },{
    mapnum=0,
    dungeon=true,
    startx=1,
    starty=1,
    startz=1,
    startfacing=1,
    minx=1,
    miny=1,
    maxx=9,
    maxy=9,
    newmonsters=25,
    maxmonsters=27,
    friendly=false,
    creatures={},
    songstart=17
  },{
    img=38,
    imgalt=38,
    name="ankh",
    talk={"yes, ankhs can talk.","shrines make good landmarks."}
  },{
    img=70,
    imgalt=70,
    name="ship",
    facingmatters=true,
    facing=2,
    passable=true
  },{
    img=92,
    imgalt=92,
    name="chest",
    sizemod=12,
    passable=true
  },{
    img=39,
    flipimg=true,
    imgseq=12,
    name="fountain",
    sizemod=15,
    passable=true
  },{
    img=27,
    imgalt=27,
    name="ladder up",
    shiftmod=12,
    sizemod=20,
    passable=true
  },{
    img=26,
    imgalt=26,
    name="ladder down",
    shiftmod=-3,
    sizemod=20,
    passable=true
  },{
    name="human",
    img=80,
    armor=0,
    hostile=false,
    gold=5,
    exp=1
  },{
    name="orc",
    chance=8,
    talk={"urg!","grar!"}
  },{
    name="undead",
    dmg=14,
    dex=6,
    gold=5,
    chance=5
  },{
    name="animal",
    dex=10,
    armor=0,
    gold=0,
    chance=3
  },{
    img=82,
    colorsubs={{},{{1,12},{14,2},{15,4}}},
    name="fighter",
    hp=12,
    armor=3,
    dmg=20,
    dex=9,
    talk={"check out these pecs!","i\'m jacked!"}
  },{
    img=90,
    colorsubs={{},{{15,4}}},
    name="guard",
    moveallowance=0,
    hp=85,
    dmg=60,
    armor=12,
    talk={"behave yourself.","i protect good citizens."}
  },{
    img=75,
    flipimg=true,
    colorsubs={{},{{1,4},{4,15},{6,1},{14,13}},{{1,4},{6,5},{14,10}},{{1,4},{4,15},{6,1},{14,3}}},
    name="merchant",
    talk={"buy my wares!","consume!","stuff makes you happy!"}
  },{
    img=81,
    flipimg=true,
    colorsubs={{},{{2,9},{4,15},{13,14}},{{2,10},{4,15},{13,9}},{{2,11},{13,3}}},
    name="lady",
    talk={"pardon me.","well i never."}
  },{
    img=76,
    name="shepherd",
    colorsubs={{},{{6,5},{15,4}},{{6,5}},{{15,4}}},
    talk={"i like sheep.","the open air is nice."}
  },{
    img=78,
    name="jester",
    dex=12,
    talk={"ho ho ho!","ha ha ha!"}
  },{
    img=84,
    name="mage",
    talk={"a mage is always on time.","brain over brawn."}
  },{
    name="ranger",
    flipimg=true,
    colorsubs={{},{{9,11},{1,3},{15,4}},{{9,11},{1,3}},{{15,4}}},
    talk={"i travel the land.","my home is the range."}
  },{
    name="villain",
    armor=1,
    hostile=true,
    gold=15,
    exp=5,
    talk={"stand and deliver!","you shall die!"}
  },{
    name="grocer",
    merch='food'
  },{
    name="armorer",
    merch='armor'
  },{
    name="smith",
    merch='weapons'
  },{
    name="medic",
    merch='hospital'
  },{
    name="barkeep",
    merch='bar'
  },{
    img=96
  },{
    img=102,
    name="troll",
    hp=15,
    dmg=16,
    gold=10,
    exp=4
  },{
    img=104,
    names={"hobgoblin","bugbear"},
    hp=15,
    dmg=14,
    gold=8,
    exp=3
  },{
    img=114,
    names={"goblin","kobold"},
    hp=8,
    dmg=10,
    gold=5,
    exp=1
  },{
    img=118,
    flipimg=true,
    name="ettin",
    hp=20,
    dmg=18,
    exp=6,
    chance=1
  },{
    img=98,
    name="skeleton",
    gold=12
  },{
    img=100,
    names={"zombie","wight","ghoul"},
    hp=10
  },{
    img=123,
    flipimg=true,
    names={"phantom","ghost","wraith"},
    hp=15,
    terrain={1,2,3,4,5,6,7,8,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,33,35},
    exp=7,
    talk={'boooo!','feeear me!'}
  },{
    img=84,
    colorsubs={{},{{2,8},{15,4}}},
    names={"warlock","necromancer","sorcerer"},
    dmg=18,
    exp=10,
    talk={"i hex you!","a curse on you!"}
  },{
    img=88,
    colorsubs={{},{{1,5},{8,2},{4,1},{2,12},{15,4}}},
    names={"rogue","bandit","cutpurse"},
    dex=10,
    thief=true,
    chance=2
  },{
    img=86,
    colorsubs={{},{{1,5},{15,4}}},
    names={"ninja","assassin"},
    poison=true,
    gold=10,
    exp=8,
    talk={"you shall die at my hands.","you are no match for me."}
  },{
    img=106,
    name="giant spider",
    hp=18,
    poison=true,
    gold=8,
    exp=5
  },{
    img=108,
    name="giant rat",
    hp=5,
    dmg=10,
    poison=true,
    eat=true,
    exp=2
  },{
    img=112,
    names={"giant snake","serpent"},
    hp=20,
    poison=true,
    terrain={4,5,6,7},
    exp=6,
    chance=1
  },{
    img=116,
    name="sea serpent",
    hp=45,
    terrain={5,12,13,14,15,25},
    exp=10
  },{
    img=125,
    flipimg=true,
    name="megascorpion",
    hp=12,
    poison=true,
    exp=5,
    chance=1
  },{
    img=122,
    colorsubs={{},{{3,9},{11,10}},{{3,14},{11,15}}},
    flipimg=true,
    names={"slime","jelly","blob"},
    gold=5,
    terrain={17,22,23},
    eat=true,
    exp=2
  },{
    img=94,
    names={"kraken","giant squid"},
    hp=50,
    terrain={12,13,14,15},
    exp=8,
    chance=2
  },{
    img=120,
    flipimg=true,
    name="wisp",
    terrain={4,5,6},
    exp=3
  },{
    img=70,
    colorsubs={{{6,5},{7,6}}},
    flipimg=false,
    name="pirate",
    facingmatters=true,
    facing=1,
    terrain={12,13,14,15},
    exp=8
  },{
    img=119,
    colorsubs={{},{{2,14},{1,4}}},
    flipimg=true,
    names={"gazer","beholder"},
    terrain={17,22},
    exp=4
  },{
    img=121,
    flipimg=true,
    names={"dragon","drake","wyvern"},
    hp=50,
    armor=7,
    dmg=28,
    gold=20,
    exp=17
  },{
    img=110,
    names={"daemon","devil"},
    hp=50,
    armor=3,
    dmg=23,
    terrain={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,22,25,26,27,30,31,33,35},
    gold=25,
    exp=15,
    chance=.25
  },{
    img=92,
    name="mimic",
    moveallowance=0,
    thief=true,
    gold=12,
    terrain={17,22},
    exp=4,
    chance=0
  },{
    img=124,
    flipimg=true,
    name="reaper",
    moveallowance=0,
    armor=5,
    hp=30,
    gold=8,
    terrain={17,22},
    exp=5,
    chance=0
  }
}
-- We want to make a table of named items so we can refer to them easily
-- in the next section in such a way that they automatically get converted
-- to raw numbers for the final PICO-8 version.
thing = {}
for basetypeIdx, basetype in pairs(basetypes) do
  -- We don't always have a name; when we do, use it. If we have a list of
  -- possible ones, use the first.
  local name = basetype.name or (basetype.names and basetype.names[1])
  -- Otherwise just ignore it.
  if name then
    thing[name] = basetypeIdx
  end
end
-- write out the resulting basetypes & bestiary structure string for copying &
-- pasting into PICO-8 source
outputStructure('basetypes', basetypes)

-- Our maps structure includes all of our communities and dungeons.
-- We can use the thing table defined above to make desired objects explicit.
maps={
  {
    name="saugus",
    enterx=13,
    entery=4,
    startx=92,
    starty=23,
    maxx=105,
    maxy=24,
    signs={
      {xeno=92,yako=19,msg="welcome to saugus!"}
    },
    items={
      {idtype=thing['ankh'],xeno=84,yako=4}
    },
    creatures={
      {idtype=thing['guard'],xeno=89,yako=21},
      {idtype=thing['medic'],xeno=84,yako=9},
      {idtype=thing['armorer'],xeno=95,yako=3},
      {idtype=thing['grocer'],xeno=97,yako=13},
      {idtype=thing['fighter'],xeno=82,yako=21},
      {idtype=thing['ranger'],xeno=101,yako=5},
      {idtype=thing['ranger'],xeno=103,yako=18,talk={"faxon is in a tower.","volcanoes mark it."}},
      {idtype=thing['lady'],xeno=85,yako=16,talk={"poynter has a ship.","poynter is in lynn."}},
      {idtype=thing['guard'],xeno=95,yako=21}
    }
  },{
    name="lynn",
    enterx=17,
    entery=4,
    startx=116,
    starty=23,
    minx=104,
    maxy=24,
    signs={
      {xeno=125,yako=9,msg="marina for members only."}
    },
    items={
      {idtype=thing['ship'],xeno=125,yako=5}
    },
    creatures={
      {idtype=thing['guard'],xeno=118,yako=22},
      {idtype=thing['smith'],xeno=106,yako=1},
      {idtype=thing['barkeep'],xeno=118,yako=2},
      {idtype=thing['grocer'],xeno=107,yako=9},
      {idtype=thing['jester'],xeno=106,yako=16},
      {idtype=thing['medic'],xeno=122,yako=12},
      {idtype=thing['lady'],xeno=106,yako=7,talk={"griswold knows dungeons.","griswold is in salem."}},
      {idtype=thing['merchant'],xeno=119,yako=6,talk={"i\'m rich! i have a yacht!","ho ho! i\'m the best!"}},
      {idtype=thing['guard'],xeno=114,yako=22}
    }
  },{
    name="boston",
    enterx=45,
    entery=19,
    startx=96,
    starty=54,
    miny=24,
    maxx=112,
    maxy=56,
    items={
      {idtype=thing['fountain'],xeno=96,yako=40}
    },
    creatures={
      {idtype=thing['guard'],xeno=94,yako=49},
      {idtype=thing['smith'],xeno=103,yako=39},
      {idtype=thing['armorer'],xeno=92,yako=30},
      {idtype=thing['grocer'],xeno=88,yako=38},
      {idtype=thing['medic'],xeno=100,yako=30},
      {idtype=thing['jester'],xeno=96,yako=44},
      {idtype=thing['fighter'],xeno=83,yako=27},
      {idtype=thing['merchant'],xeno=81,yako=44},
      {idtype=thing['mage'],xeno=104,yako=26,talk={"each shrine has a caretaker.","seek their wisdom."}},
      {idtype=thing['merchant'],xeno=110,yako=40,talk={"i\'ve seen the magic sword.","search south of the shrine."}},
      {idtype=thing['guard'],xeno=105,yako=35,moveallowance=1},
      {idtype=thing['guard'],xeno=98,yako=49}
    }
  },{
    name="salem",
    enterx=7,
    entery=36,
    startx=119,
    starty=62,
    minx=112,
    miny=43,
    items={
      {idtype=thing['ankh'],xeno=116,yako=53}
    },
    creatures={
      {idtype=thing['guard'],xeno=118,yako=63},
      {idtype=thing['smith'],xeno=125,yako=44},
      {idtype=thing['barkeep'],xeno=114,yako=44},
      {idtype=thing['grocer'],xeno=122,yako=51},
      {idtype=thing['lady'],xeno=118,yako=58},
      {idtype=thing['ranger'],xeno=113,yako=50,talk={"faxon is a blight.","daemons work for faxon."}},
      {idtype=thing['fighter'],xeno=123,yako=57,talk={"increase stats in dungeons!","only severe injuries work."}},
      {idtype=thing['guard'],xeno=120,yako=63}
    }
  },{
    name="great misery",
    enterx=27,
    entery=35,
    startx=82,
    starty=59,
    miny=56,
    maxx=103,
    creatures={
      {idtype=thing['grocer'],xeno=93,yako=57},
      {idtype=thing['barkeep'],xeno=100,yako=57},
      {idtype=thing['fighter'],xeno=91,yako=60,talk={"i saw a dragon once.","it was deep in a dungeon."}},
      {idtype=thing['shepherd'],xeno=82,yako=57},
      {idtype=thing['shepherd'],xeno=102,yako=63,talk={"gilly is in boston.","gilly knows of the sword."}}
    }
  },{
    name="western shrine",
    enterx=1,
    entery=28,
    startx=107,
    starty=62,
    minx=103,
    maxx=112,
    miny=56,
    creatures={
      {idtype=thing['mage'],xeno=107,yako=59,talk={"magic serves good or evil.","swords cut both ways."}}
    }
  },{
    name="eastern shrine",
    enterx=49,
    entery=6,
    startx=107,
    starty=62,
    minx=103,
    maxx=112,
    miny=56,
    creatures={
      {idtype=thing['shepherd'],xeno=107,yako=59,talk={"some fountains have secrets.","learn of dungeon fountains."}}
    }
  },{
    name="the dark tower",
    enterx=56,
    entery=44,
    startx=120,
    starty=41,
    minx=112,
    miny=24,
    maxy=43,
    friendly=false,
    newmonsters=35,
    maxmonsters=23,
    songstart=17,
    items={
      {idtype=thing['ladder up'],xeno=117,yako=41,targetmap=12,targetx=3,targety=8,targetz=3},
      {idtype=thing['chest'],xeno=119,yako=37},
      {idtype=thing['chest'],xeno=119,yako=39},
      {idtype=thing['chest'],xeno=120,yako=37},
      {idtype=thing['chest'],xeno=120,yako=38},
      {idtype=thing['chest'],xeno=120,yako=39},
      {idtype=thing['chest'],xeno=121,yako=38},
      {idtype=thing['chest'],xeno=121,yako=39}
    },
    creatures={
      {idtype=thing['reaper'],xeno=119,yako=41},
      {idtype=thing['reaper'],xeno=126,yako=40},
      {idtype=thing['reaper'],xeno=123,yako=38},
      {idtype=thing['reaper'],xeno=113,yako=40},
      {idtype=thing['mimic'],xeno=121,yako=37},
      {idtype=thing['mimic'],xeno=119,yako=38},
      {idtype=thing['slime'],xeno=120,yako=34},
      {idtype=thing['slime'],xeno=118,yako=35},
      {idtype=thing['dragon'],xeno=118,yako=30,propername="faxon",img=126,hp=255,armor=25,dmg=50}
    }
  },{
    name="nibiru",
    enterx=4,
    entery=11,
    starty=8,
    attr='int',
    levels={
      {
        0x0000,
        0x3ffe,
        0x0300,
        0x3030,
        0x3ffc,
        0x3300,
        0x33fc,
        0x00c0
      },{
        0x0000,
        0xcccd,
        0x0330,
        0x3030,
        0x3cfc,
        0x0300,
        0x3fcc,
        0x02c0
      },{
        0x8000,
        0xf30c,
        0x03fc,
        0x300c,
        0x333c,
        0x3300,
        0xf3fc,
        0x01c0
      },{
        0x7330,
        0x333c,
        0x0000,
        0xf3ff,
        0x0000,
        0xf3cc,
        0x030c,
        0x333c
      }
    },
    items={
      {idtype=thing['ladder up'],xeno=1,yako=8,zabo=1},
      {idtype=thing['ladder up'],xeno=8,yako=2,zabo=2},
      {idtype=thing['ladder up'],xeno=4,yako=8,zabo=3},
      {idtype=thing['ladder up'],xeno=1,yako=1,zabo=4},
      {idtype=thing['chest'],xeno=1,yako=8,zabo=4},
      {idtype=thing['chest'],xeno=7,yako=1,zabo=4},
      {idtype=thing['chest'],xeno=3,yako=8,zabo=4},
      {idtype=thing['chest'],xeno=5,yako=8,zabo=4},
      {idtype=thing['chest'],xeno=8,yako=8,zabo=4},
      {idtype=thing['fountain'],xeno=6,yako=8,zabo=3}
    },
    creatures={
      {idtype=thing['dragon'],xeno=8,yako=5,zabo=4},
      {idtype=thing['mimic'],xeno=3,yako=1,zabo=4},
      {idtype=thing['mimic'],xeno=1,yako=5,zabo=4},
      {idtype=thing['mimic'],xeno=5,yako=1,zabo=4},
      {idtype=thing['reaper'],xeno=3,yako=3,zabo=4}
    }
  },{
    name="purgatory",
    enterx=32,
    entery=5,
    attr='str',
    levels={
      {
        0x0338,
        0x3f3c,
        0x0300,
        0x33f0,
        0xf03c,
        0x3300,
        0x33fc,
        0x0300
      },{
        0x3304,
        0x333c,
        0x000c,
        0x3fcc,
        0x30fc,
        0x3c00,
        0x3bcf,
        0x0300
      },{
        0x0300,
        0x333c,
        0xb030,
        0xff3c,
        0x0030,
        0x3f0c,
        0x373c,
        0x0330
      },{
        0x0000,
        0xcccc,
        0x4c0c,
        0xcccc,
        0x00c0,
        0xcccc,
        0x0c0c,
        0xcccc
      }
    },
    items={
      {idtype=thing['ladder up'],xeno=1,yako=1,zabo=1},
      {idtype=thing['ladder up'],xeno=7,yako=1,zabo=2},
      {idtype=thing['ladder up'],xeno=3,yako=7,zabo=3},
      {idtype=thing['ladder up'],xeno=1,yako=3,zabo=4},
      {idtype=thing['chest'],xeno=1,yako=1,zabo=4},
      {idtype=thing['chest'],xeno=1,yako=8,zabo=4},
      {idtype=thing['chest'],xeno=1,yako=7,zabo=4},
      {idtype=thing['chest'],xeno=2,yako=8,zabo=4},
      {idtype=thing['chest'],xeno=8,yako=8,zabo=4},
      {idtype=thing['fountain'],xeno=7,yako=5,zabo=3}
    },
    creatures={
      {idtype=thing['dragon'],xeno=3,yako=5,zabo=4},
      {idtype=thing['mimic'],xeno=1,yako=5,zabo=4},
      {idtype=thing['mimic'],xeno=7,yako=5,zabo=4},
      {idtype=thing['reaper'],xeno=5,yako=3,zabo=4},
      {idtype=thing['reaper'],xeno=5,yako=7,zabo=4}
    }
  },{
    name="sheol",
    enterx=33,
    entery=58,
    attr='dex',
    levels={
      {
        0x0300,
        0x3fb0,
        0x03fc,
        0x3300,
        0x33f3,
        0x3000,
        0xfffc,
        0x0000
      },{
        0x0300,
        0x337c,
        0x300f,
        0x3ffe,
        0x00fc,
        0x3c00,
        0x33cf,
        0x3000
      },{
        0x0300,
        0x333c,
        0x303c,
        0x3331,
        0x333f,
        0x330c,
        0x333c,
        0x0200
      },{
        0x0000,
        0x3f3c,
        0x300c,
        0x33cc,
        0x300c,
        0x300c,
        0x3ffc,
        0x0100
      }
    },
    items={
      {idtype=thing['ladder up'],xeno=1,yako=1,zabo=1},
      {idtype=thing['ladder up'],xeno=5,yako=2,zabo=2},
      {idtype=thing['ladder up'],xeno=8,yako=4,zabo=3},
      {idtype=thing['ladder up'],xeno=4,yako=8,zabo=4},
      {idtype=thing['chest'],xeno=5,yako=5,zabo=4},
      {idtype=thing['chest'],xeno=3,yako=6,zabo=4},
      {idtype=thing['chest'],xeno=4,yako=6,zabo=4},
      {idtype=thing['chest'],xeno=5,yako=6,zabo=4},
      {idtype=thing['chest'],xeno=6,yako=6,zabo=4},
      {idtype=thing['fountain'],xeno=6,yako=6,zabo=3}
    },
    creatures={
      {idtype=thing['dragon'],xeno=3,yako=1,zabo=4},
      {idtype=thing['mimic'],xeno=4,yako=5,zabo=4},
      {idtype=thing['mimic'],xeno=5,yako=2,zabo=4},
      {idtype=thing['reaper'],xeno=3,yako=4,zabo=4},
      {idtype=thing['reaper'],xeno=6,yako=4,zabo=4}
    }
  },{
    name="the upper levels",
    enterx=124,
    entery=26,
    startx=8,
    startz=3,
    mapnum=8,
    levels={
      {
        0x00c0,
        0xbcce,
        0xfccf,
        0x00cc,
        0x3fcc,
        0x0ccc,
        0x00cc,
        0x0c00
      },{
        0x00c0,
        0x7ccd,
        0x3fc3,
        0x38f0,
        0x3cc3,
        0x0ccc,
        0x3cce,
        0x00c0
      },{
        0x00c0,
        0xcccf,
        0x0cc0,
        0x34fc,
        0x3fc0,
        0x00cf,
        0x33cd,
        0x3b00
      }
    },
    items={
      {idtype=thing['ladder down'],xeno=8,yako=1,zabo=3},
      {idtype=thing['ladder down'],xeno=3,yako=8,zabo=3,targetmap=8,targetx=117,targety=41,targetz=0},
      {idtype=thing['ladder up'],xeno=8,yako=7,zabo=3},
      {idtype=thing['ladder up'],xeno=3,yako=4,zabo=3},
      {idtype=thing['ladder up'],xeno=1,yako=2,zabo=2},
      {idtype=thing['ladder up'],xeno=8,yako=2,zabo=2}
    },
    creatures={
      {idtype=thing['daemon'],xeno=4,yako=6,zabo=1},
      {idtype=thing['daemon'],xeno=4,yako=7,zabo=2},
      {idtype=thing['daemon'],xeno=1,yako=7,zabo=3},
      {idtype=thing['reaper'],xeno=6,yako=8,zabo=3},
      {idtype=thing['reaper'],xeno=8,yako=4,zabo=3},
      {idtype=thing['reaper'],xeno=3,yako=1,zabo=3},
      {idtype=thing['reaper'],xeno=6,yako=6,zabo=2},
      {idtype=thing['reaper'],xeno=6,yako=8,zabo=1}
    }
  }
}
-- Map by map...
for mapIdx, map in pairs(maps) do
  -- Only for dungeons...
  if map.levels then
    -- Level by level...
    for levelIdx, level in pairs(map.levels) do
      -- Row by row...
      for rowIdx, row in pairs(level) do
        -- We need to convert values outside PICO-8's range.
        if row > 32767 then
          level[rowIdx] = row - 65536
        end
      end
    end
  end
end
-- write out the resulting maps structure string for copying & pasting
-- into PICO-8 source
outputStructure('maps', maps)
