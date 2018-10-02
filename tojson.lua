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
    ar=1,
    dmg=13,
    dex=8,
    hos=1,
    t={1,2,3,4,5,6,7,8,17,18,22,25,26,27,30,31,33,35},
    mva=1,
    gp=10,
    exp=2,
    ch=1
  },{
    mn=0,
    mnx=80,
    mxx=128,
    mny=0,
    mxy=64,
    newm=0,
    mxm=0,
    fri=1
  },{
    mn=0,
    dg=1,
    sx=1,
    sy=1,
    sz=1,
    sf=1,
    mnx=1,
    mny=1,
    mxx=9,
    mxy=9,
    newm=25,
    mxm=27,
    fri=false,
    c={},
    ss=17
  },{
    i=38,
    ia=38,
    n="ankh",
    d={"yes, ankhs can talk.","shrines make good landmarks."}
  },{
    i=70,
    ia=70,
    n="ship",
    fm=1,
    f=2,
    p=1
  },{
    i=92,
    ia=92,
    n="chest",
    shm=-2,
    szm=11,
    p=1
  },{
    i=39,
    fi=1,
    iseq=12,
    n="fountain",
    shm=-2,
    szm=14,
    p=1
  },{
    i=27,
    ia=27,
    n="ladder up",
    shm=12,
    szm=20,
    p=1
  },{
    i=26,
    ia=26,
    n="ladder down",
    shm=-3,
    szm=20,
    p=1
  },{
    i=80,
    ar=0,
    hos=false,
    gp=5,
    exp=1
  },{
    n="orc",
    ch=8,
    d={"urg!","grar!"}
  },{
    dmg=14,
    dex=6,
    gp=5,
    ch=5
  },{
    dex=10,
    ar=0,
    gp=0,
    ch=3
  },{
    i=82,
    cs={{},{{1,12},{14,2},{15,4}}},
    n="fighter",
    hp=12,
    ar=3,
    dmg=20,
    dex=9,
    d={"check out these pecs!","i\'m jacked!"}
  },{
    i=90,
    cs={{},{{15,4}}},
    n="guard",
    mva=0,
    hp=85,
    dmg=60,
    ar=12,
    d={"behave yourself.","i protect good citizens."}
  },{
    i=75,
    fi=1,
    cs={{},{{1,4},{4,15},{6,1},{14,13}},{{1,4},{6,5},{14,10}},{{1,4},{4,15},{6,1},{14,3}}},
    n="merchant",
    d={"consume!","stuff makes you happy!"}
  },{
    i=81,
    fi=1,
    cs={{},{{2,9},{4,15},{13,14}},{{2,10},{4,15},{13,9}},{{2,11},{13,3}}},
    n="lady",
    d={"pardon me.","well i never."}
  },{
    i=76,
    n="shepherd",
    cs={{},{{6,5},{15,4}},{{6,5}},{{15,4}}},
    d={"i like sheep.","the open air is nice."}
  },{
    i=78,
    n="jester",
    dex=12,
    d={"ho ho ho!","ha ha ha!"}
  },{
    i=84,
    ac={{9,6},{8,13},{10,12}},
    n="mage",
    d={"a mage is always on time.","brain over brawn."}
  },{
    n="ranger",
    fi=1,
    cs={{},{{9,11},{1,3},{15,4}},{{9,11},{1,3}},{{15,4}}},
    d={"i travel the land.","my home is the range."}
  },{
    n="villain",
    ar=1,
    hos=1,
    gp=15,
    exp=5,
    d={"stand and deliver!","you shall die!"}
  },{
    n="grocer",
    mch='food'
  },{
    n="armorer",
    mch='armor'
  },{
    n="smith",
    mch='weapons'
  },{
    n="medic",
    mch='hospital'
  },{
    n="guildkeeper",
    mch='guild'
  },{
    n="barkeep",
    mch='bar'
  },{
    i=96
  },{
    i=102,
    n="troll",
    hp=15,
    dmg=16,
    gp=10,
    exp=4
  },{
    i=104,
    ns={"hobgoblin","bugbear"},
    hp=15,
    dmg=14,
    gp=8,
    exp=3
  },{
    i=114,
    ns={"goblin","kobold"},
    hp=8,
    dmg=10,
    gp=5,
    exp=1
  },{
    i=118,
    fi=1,
    n="ettin",
    hp=20,
    dmg=18,
    exp=6,
    ch=1
  },{
    i=98,
    n="skeleton",
    gp=12
  },{
    i=100,
    ns={"zombie","wight","ghoul"},
    hp=10
  },{
    i=123,
    fi=1,
    ns={"phantom","ghost","wraith"},
    hp=15,
    t={1,2,3,4,5,6,7,8,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,33,35},
    exp=7,
    d={'boooo!','feeear me!'}
  },{
    i=84,
    cs={{},{{2,8},{15,4}}},
    ac={{9,6},{8,13},{10,12}},
    ns={"warlock","necromancer","sorcerer"},
    dmg=18,
    exp=10,
    d={"i hex you!","a curse on you!"}
  },{
    i=88,
    cs={{},{{1,5},{8,2},{4,1},{2,12},{15,4}}},
    ns={"rogue","bandit","cutpurse"},
    dex=10,
    th=1,
    ch=2
  },{
    i=86,
    cs={{},{{1,5},{15,4}}},
    ns={"ninja","assassin"},
    po=1,
    gp=10,
    exp=8,
    d={"you shall die at my hands.","you are no match for me."}
  },{
    i=106,
    n="giant spider",
    hp=18,
    po=1,
    gp=8,
    exp=5
  },{
    i=108,
    n="giant rat",
    hp=5,
    dmg=10,
    po=1,
    eat=1,
    exp=2
  },{
    i=112,
    ns={"giant snake","serpent"},
    hp=20,
    po=1,
    t={4,5,6,7},
    exp=6,
    ch=1
  },{
    i=116,
    n="sea serpent",
    hp=45,
    t={5,12,13,14,15,25},
    exp=10
  },{
    i=125,
    fi=1,
    n="megascorpion",
    hp=12,
    po=1,
    exp=5,
    ch=1
  },{
    i=122,
    cs={{},{{3,9},{11,10}},{{3,14},{11,15}}},
    fi=1,
    ns={"slime","jelly","blob"},
    gp=5,
    t={17,22,23},
    eat=1,
    exp=2
  },{
    i=94,
    ns={"kraken","giant squid"},
    hp=50,
    t={12,13,14,15},
    exp=8,
    ch=2
  },{
    i=120,
    fi=1,
    n="wisp",
    t={4,5,6},
    exp=3
  },{
    i=70,
    cs={{{6,5},{7,6}}},
    fi=false,
    n="pirate",
    fm=1,
    f=1,
    t={12,13,14,15},
    exp=8
  },{
    i=119,
    cs={{},{{2,14},{1,4}}},
    fi=1,
    ns={"gazer","beholder"},
    t={17,22},
    exp=4
  },{
    i=121,
    fi=1,
    ns={"dragon","drake","wyvern"},
    ac={{9,6},{8,13},{10,12}},
    hp=50,
    ar=7,
    dmg=28,
    gp=20,
    exp=17
  },{
    i=110,
    ns={"daemon","devil"},
    ac={{9,10},{8,9},{10,7}},
    hp=50,
    ar=3,
    dmg=23,
    t={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,22,25,26,27,30,31,33,35},
    gp=25,
    exp=15,
    ch=.25
  },{
    i=92,
    n="mimic",
    mva=0,
    th=1,
    gp=12,
    t={17,22},
    exp=4,
    ch=0
  },{
    i=124,
    fi=1,
    n="reaper",
    mva=0,
    ar=5,
    hp=30,
    gp=8,
    t={17,22},
    exp=5,
    ch=0
  }
}
-- We want to make a table of nd i so we can refer to them easily
-- in the next section in such a way that they automatically get converted
-- to raw numbers for the final PICO-8 version.
thing = {}
for basetypeIdx, basetype in pairs(basetypes) do
  -- We don't always have a n; when we do, use it. If we have a list of
  -- possible ones, use the first.
  local n = basetype.n or (basetype.ns and basetype.ns[1])
  -- Otherwise just ignore it.
  if n then
    thing[n] = basetypeIdx
  end
end
-- write out the resulting basetypes & bestiary structure string for copying &
-- pasting into PICO-8 source
outputStructure('basetypes', basetypes)
-- copying is easier with a blank line between
print()

-- Our maps structure includes all of our communities and dungeons.
-- We can use the thing table defined above to make desired objects explicit.
maps={
  {
    n="saugus",
    ex=13,
    ey=4,
    sx=92,
    sy=23,
    mxx=105,
    mxy=24,
    signs={
      {x=92,y=19,msg="welcome to saugus!"}
    },
    i={
      {id=thing['ankh'],x=84,y=4}
    },
    c={
      {id=thing['guard'],x=89,y=21},
      {id=thing['medic'],x=84,y=9},
      {id=thing['armorer'],x=95,y=3},
      {id=thing['grocer'],x=97,y=13},
      {id=thing['fighter'],x=82,y=21},
      {id=thing['ranger'],x=101,y=5},
      {id=thing['mage'],x=84,y=5,d={"the secret room is key.","the way must be clear."}},
      {id=thing['ranger'],x=103,y=18,d={"faxon is in a tower.","volcanoes mark it."}},
      {id=thing['lady'],x=85,y=16,d={"poynter has a ship.","poynter is in lynn."}},
      {id=thing['guard'],x=95,y=21}
    }
  },{
    n="lynn",
    ex=17,
    ey=4,
    sx=116,
    sy=23,
    mnx=104,
    mxy=24,
    signs={
      {x=125,y=9,msg="marina for members only."}
    },
    i={
      {id=thing['ship'],x=125,y=5}
    },
    c={
      {id=thing['guard'],x=118,y=22},
      {id=thing['smith'],x=106,y=1},
      {id=thing['barkeep'],x=118,y=2},
      {id=thing['grocer'],x=107,y=9},
      {id=thing['jester'],x=106,y=16},
      {id=thing['medic'],x=122,y=12},
      {id=thing['fighter'],x=105,y=4,d={"i\'ve seen faxon\'s tower.","south of the eastern shrine."}},
      {id=thing['lady'],x=106,y=7,d={"griswold knows dungeons.","griswold is in salem."}},
      {id=thing['merchant'],x=119,y=6,d={"i\'m rich! i have a yacht!","ho ho! i\'m the best!"}},
      {id=thing['guard'],x=114,y=22}
    }
  },{
    n="boston",
    ex=45,
    ey=19,
    sx=96,
    sy=54,
    mny=24,
    mxx=112,
    mxy=56,
    i={
      {id=thing['fountain'],x=96,y=40}
    },
    c={
      {id=thing['guard'],x=94,y=49},
      {id=thing['smith'],x=103,y=39},
      {id=thing['armorer'],x=92,y=30},
      {id=thing['grocer'],x=88,y=38},
      {id=thing['medic'],x=100,y=30},
      {id=thing['jester'],x=96,y=44},
      {id=thing['fighter'],x=83,y=27,d={"zanders has good tools.","be prepared!"}},
      {id=thing['merchant'],x=81,y=44},
      {id=thing['mage'],x=104,y=26,d={"each shrine has a caretaker.","seek their wisdom."}},
      {id=thing['merchant'],x=110,y=40,d={"i\'ve seen the magic sword.","search south of the shrine."}},
      {id=thing['guard'],x=105,y=35,mva=1},
      {id=thing['guard'],x=98,y=49}
    }
  },{
    n="salem",
    ex=7,
    ey=36,
    sx=119,
    sy=62,
    mnx=112,
    mny=43,
    i={
      {id=thing['ankh'],x=116,y=53}
    },
    c={
      {id=thing['guard'],x=118,y=63},
      {id=thing['guildkeeper'],x=125,y=44},
      {id=thing['barkeep'],x=114,y=44},
      {id=thing['grocer'],x=122,y=51},
      {id=thing['lady'],x=118,y=58},
      {id=thing['ranger'],x=113,y=50,d={"faxon is a blight.","daemons serve faxon."}},
      {id=thing['fighter'],x=123,y=57,d={"increase stats in dungeons!","only severe injuries work."}},
      {id=thing['guard'],x=120,y=63}
    }
  },{
    n="great misery",
    ex=27,
    ey=35,
    sx=82,
    sy=59,
    mny=56,
    mxx=103,
    c={
      {id=thing['grocer'],x=93,y=57},
      {id=thing['barkeep'],x=100,y=57},
      {id=thing['fighter'],x=91,y=60,d={"even faxon has fears.","lalla knows who to see."}},
      {id=thing['shepherd'],x=82,y=57},
      {id=thing['shepherd'],x=102,y=63,d={"gilly is in boston.","gilly knows of the sword."}}
    }
  },{
    n="western shrine",
    ex=1,
    ey=28,
    sx=107,
    sy=62,
    mnx=103,
    mxx=112,
    mny=56,
    c={
      {id=thing['mage'],x=107,y=59,d={"magic serves good or evil.","swords cut both ways."}}
    }
  },{
    n="eastern shrine",
    ex=49,
    ey=6,
    sx=107,
    sy=62,
    mnx=103,
    mxx=112,
    mny=56,
    c={
      {id=thing['shepherd'],x=107,y=59,d={"some fountains have secrets.","know when to be humble."}}
    }
  },{
    n="the dark tower",
    ex=56,
    ey=44,
    sx=120,
    sy=41,
    mnx=112,
    mny=24,
    mxy=43,
    fri=false,
    newm=35,
    mxm=23,
    ss=17,
    i={
      {id=thing['ladder up'],x=117,y=41,tm=12,tx=3,ty=8,tz=3},
      {id=thing['chest'],x=119,y=37},
      {id=thing['chest'],x=119,y=39},
      {id=thing['chest'],x=120,y=37},
      {id=thing['chest'],x=120,y=38},
      {id=thing['chest'],x=120,y=39},
      {id=thing['chest'],x=121,y=38},
      {id=thing['chest'],x=121,y=39}
    },
    c={
      {id=thing['reaper'],x=119,y=41},
      {id=thing['reaper'],x=126,y=40},
      {id=thing['reaper'],x=123,y=38},
      {id=thing['reaper'],x=113,y=40},
      {id=thing['mimic'],x=121,y=37},
      {id=thing['mimic'],x=119,y=38},
      {id=thing['slime'],x=120,y=34},
      {id=thing['slime'],x=118,y=35},
      {id=thing['dragon'],x=118,y=30,pn="faxon",i=126,hp=255,ar=25,dmg=50}
    }
  },{
    n="nibiru",
    ex=4,
    ey=11,
    sy=8,
    attr='int',
    l={
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
    i={
      {id=thing['ladder up'],x=1,y=8,z=1},
      {id=thing['ladder up'],x=8,y=2,z=2},
      {id=thing['ladder up'],x=4,y=8,z=3},
      {id=thing['ladder up'],x=1,y=1,z=4},
      {id=thing['chest'],x=1,y=8,z=4},
      {id=thing['chest'],x=7,y=1,z=4},
      {id=thing['chest'],x=3,y=8,z=4},
      {id=thing['chest'],x=5,y=8,z=4},
      {id=thing['chest'],x=8,y=8,z=4},
      {id=thing['fountain'],x=6,y=8,z=3}
    },
    c={
      {id=thing['dragon'],x=8,y=5,z=4},
      {id=thing['mimic'],x=3,y=1,z=4},
      {id=thing['mimic'],x=1,y=5,z=4},
      {id=thing['mimic'],x=5,y=1,z=4},
      {id=thing['reaper'],x=3,y=3,z=4}
    }
  },{
    n="purgatory",
    ex=32,
    ey=5,
    attr='str',
    l={
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
    i={
      {id=thing['ladder up'],x=1,y=1,z=1},
      {id=thing['ladder up'],x=7,y=1,z=2},
      {id=thing['ladder up'],x=3,y=7,z=3},
      {id=thing['ladder up'],x=1,y=3,z=4},
      {id=thing['chest'],x=1,y=1,z=4},
      {id=thing['chest'],x=1,y=8,z=4},
      {id=thing['chest'],x=1,y=7,z=4},
      {id=thing['chest'],x=2,y=8,z=4},
      {id=thing['chest'],x=8,y=8,z=4},
      {id=thing['fountain'],x=7,y=5,z=3}
    },
    c={
      {id=thing['dragon'],x=3,y=5,z=4},
      {id=thing['mimic'],x=1,y=5,z=4},
      {id=thing['mimic'],x=7,y=5,z=4},
      {id=thing['reaper'],x=5,y=3,z=4},
      {id=thing['reaper'],x=5,y=7,z=4}
    }
  },{
    n="sheol",
    ex=33,
    ey=58,
    attr='dex',
    l={
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
    i={
      {id=thing['ladder up'],x=1,y=1,z=1},
      {id=thing['ladder up'],x=5,y=2,z=2},
      {id=thing['ladder up'],x=8,y=4,z=3},
      {id=thing['ladder up'],x=4,y=8,z=4},
      {id=thing['chest'],x=5,y=5,z=4},
      {id=thing['chest'],x=3,y=6,z=4},
      {id=thing['chest'],x=4,y=6,z=4},
      {id=thing['chest'],x=5,y=6,z=4},
      {id=thing['chest'],x=6,y=6,z=4},
      {id=thing['fountain'],x=6,y=6,z=3}
    },
    c={
      {id=thing['dragon'],x=3,y=1,z=4},
      {id=thing['mimic'],x=4,y=5,z=4},
      {id=thing['mimic'],x=5,y=2,z=4},
      {id=thing['reaper'],x=3,y=4,z=4},
      {id=thing['reaper'],x=6,y=4,z=4}
    }
  },{
    n="the upper levels",
    ex=124,
    ey=26,
    sx=8,
    sz=3,
    mn=8,
    l={
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
    i={
      {id=thing['ladder down'],x=8,y=1,z=3},
      {id=thing['ladder down'],x=3,y=8,z=3,tm=8,tx=117,ty=41,tz=0},
      {id=thing['ladder up'],x=8,y=7,z=3},
      {id=thing['ladder up'],x=3,y=4,z=3},
      {id=thing['ladder up'],x=1,y=2,z=2},
      {id=thing['ladder up'],x=8,y=2,z=2}
    },
    c={
      {id=thing['daemon'],x=4,y=6,z=1},
      {id=thing['daemon'],x=4,y=7,z=2},
      {id=thing['daemon'],x=1,y=7,z=3},
      {id=thing['reaper'],x=6,y=8,z=3},
      {id=thing['reaper'],x=8,y=4,z=3},
      {id=thing['reaper'],x=3,y=1,z=3},
      {id=thing['reaper'],x=6,y=6,z=2},
      {id=thing['reaper'],x=6,y=8,z=1}
    }
  }
}
-- Map by map...
for mapIdx, map in pairs(maps) do
  -- Only for dungeons...
  if map.l then
    -- Level by level...
    for levelIdx, level in pairs(map.l) do
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
