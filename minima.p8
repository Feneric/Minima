pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- minima
-- by feneric

-- initialization data
fullheight,fullwidth=11,13
halfheight,halfwidth=5,6

-- set up the various messages
winmsg="\n\n\n\n\n\n  congratulations, you've won!\n\n\n\n\n\n\n\n\n\n    press p to get game menu,\n anything else to continue and\n      explore a bit more."
losemsg="\n\n\n\n\n\n      you've been killed!\n          you lose!\n\n\n\n\n\n\n\n\n\n\n\n    press p to get game menu"
helpmsg="minima commands:\n\na: attack\nc: cast spell\nd: dialog, talk, buy\ne: enter, board, mount, climb,\n   descend\np: pause, save, load, help\ns: sit & wait\nw: wearing & wielding\nx: examine, look (repeat to\n   search)\n\nfor commands with options (like\ncasting or buying) use the first\ncharacter from the list, or\nanything else to cancel."
msg=helpmsg

-- anyobj is our root objects. all others inherit from it to
-- save space and reduce redundancy.
anyobj={
  facing=0,
  moveallowance=0,
  nummoves=0,
  movepayment=0,
  hitdisplay=0,
  chance=0 
}

function makemetaobj(objtype,base)
  return setmetatable(base or {},{__index=objtype})
end

-- basetypes are the objects we mean to use to make objects.
-- they inherit (often indirectly) from our root object.
basetypes={
  {
    hp=10,
    armor=1,
    dmg=5,
    int=8,
    str=8,
    dex=8,
    hostile=true,
    terrain={1,2,3,4,5,6,7,8,17,18,22,25,26,27,30,31,33,35},
    moveallowance=1,
    gold=10,
    exp=2,
    z=0,
    chance=1
  },{
    img=38,
    imgalt=38,
    name="ankh",
    talk={"yes, ankhs can talk.","shrines make good landmarks."}
  },{
    img=69,
    imgalt=69,
    name="ship",
    facingmatters=true,
    facing=2
  },{
    img=92,
    imgalt=92,
    name="chest"
  },{
    img=12,
    imgalt=13,
    name="fountain"
  },{
    img=27,
    imgalt=27,
    name="ladder up"
  },{
    img=26,
    imgalt=26,
    name="ladder down"
  },{
    img=74,
    armor=0,
    hostile=false,
    gold=5,
    exp=1
  },{
    name="orc",
    int=6,
    chance=5,
    talk={"urg!","grar!"}
  },{
    int=7,
    dmg=6,
    dex=6,
    gold=5,
    chance=3
  },{
    int=3,
    dex=10,
    armor=0,
    hostile=nil,
    gold=0,
    chance=3
  },{
    img=82,
    colorsubs={{},{{1,12},{14,2},{15,4}}},
    name="fighter",
    hp=12,
    armor=2,
    dmg=10,
    int=6,
    str=10,
    dex=9,
    talk={"check out these pecs!","i'm jacked!"}
  },{
    img=90,
    colorsubs={{},{{15,4}}},
    name="guard",
    moveallowance=0,
    hp=18,
    armor=3,
    talk={"behave yourself.","i protect good citizens."}
  },{
    img=75,
    flipimg=true,
    colorsubs={{},{{1,4},{4,15},{6,1},{14,13}},{{1,4},{6,5},{14,10}},{{1,4},{4,15},{6,1},{14,3}}},
    name="merchant",
    talk={"buy my wares!","consume!","stuff makes you happy!"}
  },{
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
  }
}

-- give our base objects names for convenience & efficiency.
creature=basetypes[1]
ankhtype=basetypes[2]
shiptype=basetypes[3]
chesttype=basetypes[4]
fountaintype=basetypes[5]
ladderuptype=basetypes[6]
ladderdowntype=basetypes[7]
human=basetypes[8]
orc=basetypes[9]
undead=basetypes[10]
animal=basetypes[11]
fighter=basetypes[12]
guard=basetypes[13]
merchant=basetypes[14]
lady=basetypes[15]
shepherd=basetypes[16]
jester=basetypes[17]
villain=basetypes[18]
grocer=basetypes[19]
armorer=basetypes[20]
smith=basetypes[21]
medic=basetypes[22]
barkeep=basetypes[23]

-- set our base objects base values.
for basetypenum=1,#basetypes do
  local basetype
  if basetypenum<8 then
    basetype=anyobj
  elseif basetypenum<12 then
    basetype=creature
  elseif basetypenum<19 then
    basetype=human
  elseif basetypenum<23 then
    basetype=merchant
  else
    basetype=lady
  end
  makemetaobj(basetype,basetypes[basetypenum])
end

-- the bestiary holds all the different monster types that can
-- be encountered in the game. it builds off of the basic types
-- already defined so most do not need many changes. actual
-- monsters in the game are instances of creatures found in the
-- bestiary.
bestiary={
  {
    img=96
  },{
    img=102,
    name="troll",
    hp=15,
    gold=10,
    exp=4,
    chance=4
  },{
    img=104,
    names={"hobgoblin","bugbear"},
    hp=15,
    gold=8,
    exp=3,
    chance=4
  },{
    img=114,
    names={"goblin","kobold"},
    hp=8,
    dmg=3,
    gold=5,
    exp=1
  },{
    img=118,
    flipimg=true,
    name="ettin",
    hp=20,
    dmg=8,
    exp=6,
    chance=1
  },{
    img=98,
    name="skeleton",
    gold=12,
    chance=5
  },{
    img=100,
    names={"zombie","wight","ghoul"},
    hp=10,
    dmg=4
  },{
    img=123,
    flipimg=true,
    names={"phantom","ghost","wraith"},
    hp=15,
    dmg=3,
    terrain={1,2,3,4,5,6,7,8,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,33,35},
    exp=7,
    talk={'boooo!','feeear me!'}
  },{
    img=84,
    colorsubs={{},{{2,8},{15,4}}},
    names={"warlock","necromancer","sorceror"},
    int=10,
    exp=10,
    talk={"i hex you!","a curse on you!"}
  },{
    img=88,
    colorsubs={{},{{1,5},{8,2},{4,1},{2,12},{15,4}}},
    names={"rogue","bandit","cutpurse"},
    dex=10,
    dmg=6,
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
    hostile=true,
    gold=8,
    exp=5
  },{
    img=108,
    name="giant rat",
    hp=5,
    dmg=4,
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
    hostile=true,
    terrain={5,12,13,14,15,25},
    exp=10,
    chance=5
  },{
    img=125,
    flipimg=true,
    name="megascorpion",
    hp=12,
    dmg=4,
    poison=true,
    hostile=true,
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
    hostile=true,
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
    img=69,
    colorsubs={{{6,5},{7,6}}},
    flipimg=false,
    name="pirates",
    facingmatters=true,
    facing=1,
    terrain={12,13,14,15},
    exp=8
  },{
    img=119,
    colorsubs={{},{{2,14},{1,4}}},
    flipimg=true,
    names={"gazer","beholder"},
    hp=12,
    terrain={17,22},
    exp=4
  },{
    img=121,
    flipimg=true,
    names={"dragon","drake","wyvern"},
    terrain={1,2,3,4,5,6,7,8,17,18,22,25,26,27,30,31,33,35},
    hp=50,
    dmg=10,
    gold=20,
    exp=17,
    chance=.5
  },{
    img=110,
    names={"daemon","devil"},
    hp=50,
    dmg=10,
    terrain={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,22,25,26,27,30,31,33,35},
    gold=25,
    exp=15,
    chance=.5
  },{
    img=92,
    name="mimic",
    moveallowance=0,
    thief=true,
    gold=12,
    terrain={17,22},
    exp=4
  },{
    img=124,
    flipimg=true,
    name="reaper",
    moveallowance=0,
    gold=8,
    terrain={17,22},
    exp=5
  }
}
-- set base values for monsters.
for beastnum=1,#bestiary do
  local beasttype
  if beastnum<6 then
    beasttype=orc
  elseif beastnum<9 then
    beasttype=undead
  elseif beastnum<12 then
    beasttype=villain
  elseif beastnum<19 then
    beasttype=animal
  else
    beasttype=creature
  end
  makemetaobj(beasttype,bestiary[beastnum])
  bestiary[beastnum].idtype=beastnum
end

-- check to see whether or not a desired purchase can
-- be made.
function checkpurchase(prompt,checkfunc,purchasefunc)
  update_lines(prompt)
  cmd=yield()
  desireditem=checkfunc(cmd)
  if desireditem then
    return purchasefunc(desireditem)
  elseif desireditem==false then
    return "you cannot afford that."
  else
    return "no sale."
  end
end

-- makes a purchase if all is in order.
function purchase(prompt,itemtype,attribute)
  return checkpurchase(prompt,
    function(cmd)
      desireditem=itemtype[cmd]
      if desireditem then
        logit("attr "..hero[attribute].." num "..desireditem.num)
        return hero.gold>=desireditem.price and desireditem
      else
        return nil
      end
    end,
    function(desireditem)
      if hero[attribute]>=desireditem.num then
        return "that is not an upgrade."
      else
        hero.gold-=desireditem.price
        hero[attribute]=desireditem.num
        return "the "..desireditem.name.." is yours."
      end
    end
  )
end

-- a table of functions to perform the different merchant
-- operations. while there is a lot in common between them,
-- there are a lot of differences, too.
shop={
  food=function()
    return checkpurchase({"$15 for 25 food; a\80\80\82\79\86\69? "},
      function(cmd)
        if cmd=='a' then
          return hero.gold>=15
        else
          return nil
        end
      end,
      function()
        hero.gold-=15
        hero.food=not_over_32767(hero.food+25)
        return "you got more food."
      end
    )
  end,
  armor=function()
    return purchase({"buy \131cloth $12, \139leather $99,","\145chain $300, or \148plate $950: "},armors,'armor')
  end,
  weapons=function()
    return purchase({"buy d\65\71\71\69\82 $8, c\76\85\66 $40,","a\88\69 $75, or s\87\79\82\68 $150: "},weapons,'dmg')
  end,
  hospital=function()
    return checkpurchase({"choose m\69\68\73\67 ($8), c\85\82\69 ($10),","or s\65\86\73\79\82 ($25): "},
      function(cmd)
        desiredspell=spells[cmd]
        if desiredspell and desiredspell.price then
          return hero.gold>=desiredspell.price and desiredspell
        else
          return nil
        end
      end,
      function(desiredspell)
        sfx(3)
        hero.gold-=desiredspell.price
        if desiredspell.mp==7 then
          -- perform cure
          hero.status=band(hero.status,14)
        else
          -- perform healing
          increasehp(desiredspell.amount)
        end
        return desiredspell.name.." is cast!"
      end
    )
  end,
  bar=function()
    return checkpurchase({"$5 per drink; a\80\80\82\79\86\69? "},
      function(cmd)
        if cmd=='a' then
          return hero.gold>=5
        else
          return nil
        end
      end,
      function()
        rumors={
          "1",
          "2",
          "3",
          "4",
          "5",
          "6",
          "7",
          "8"
        }
        update_lines{"while socializing, you hear:"}
        return '"'..rumors[flr(rnd(#rumors)+1)]..'"'
      end
    )
  end
}

-- the types of terrain that exist in the game. each is
-- given a name and a list of allowed monster types.
terrains={
  "plains","bare ground",
  "tundra","scrub","swamp",
  "forest","foothills","mountains",
  "tall mountain","volcano",
  "volcano","water","water",
  "deep water","deep water",
  "brick","brick road","brick",
  "mismatched brick","stone",
  "stone","road","barred window",
  "window","bridge","ladder down",
  "ladder up","door","locked door",
  "open door","sign","shrine",
  "dungeon","castle","tower",
  "town","village","ankh"
}
-- counter terrain types are special as they can be talked
-- over (essential for purchasing). there are a lot of them
-- as all the letters are represented.
for num=1,29 do
  add(terrains,"counter")
end

terrainmonsters={}
for num=1,38 do
  add(terrainmonsters,{})
end
for beast in all(bestiary) do
  for terrain in all(beast.terrain) do
    add(terrainmonsters[terrain],beast)
  end
end

-- the maps structure holds information about all of the regular
-- places in the game, dungeons as well as towns.
towntype={
  mapnum=0,
  newmonsters=0,
  maxmonsters=0,
  friendly=true
}
dungeontype={
  mapnum=0,
  dungeon=true,
  startz=1,
  startfacing=1,
  minx=1,
  miny=1,
  maxx=9,
  maxy=9,
  newmonsters=25,
  maxmonsters=10,
  friendly=false
}
maps={
  {
    name="saugus",
    enterx=13,
    entery=4,
    startx=76,
    starty=23,
    minx=64,
    miny=0,
    maxx=89,
    maxy=24,
    signs={
      {
        x=76,
        y=19,
        msg="welcome to saugus!"
      }
    },
    items={
      {x=68,y=4,objtype=ankhtype}
    }
  },{
    name="lynn",
    enterx=17,
    entery=4,
    startx=100,
    starty=23,
    minx=88,
    miny=0,
    maxx=112,
    maxy=24,
    signs={
      {
        x=109,
        y=9,
        msg="marina for members only."
      }
    },
    items={
      {x=109,y=5,objtype=shiptype}
    }
  },{
    name="nibiru",
    enterx=4,
    entery=11,
    startx=1,
    starty=8,
    levels={
      {0x0000,0x3ffe,0x0300,0x3030,0x3ffc,0x3300,0x33fc,0x00c0},
      {0x0000,0xcccd,0x0330,0x3030,0x3cfc,0x0300,0x3fcc,0x00c0}
    },
    items={
      {x=1,y=8,z=1,items=ladderuptype}
    }
  },{
    name="purgatory",
    enterx=32,
    entery=5,
    startx=1,
    starty=1,
    levels={
      {0x0330,0x3f3c,0x0300,0x33f0,0xf03c,0x3f00,0x33fc,0x0300}
    },
    items={
      {x=1,y=1,z=1,objtype=ladderuptype}
    }
  }
}
-- set base values for places.
for mapsnum=1,#maps do
  local maptype
  if mapsnum<3 then
    maptype=towntype
  else
    maptype=dungeontype
  end
  makemetaobj(maptype,maps[mapsnum])
end

-- map 0 is special; it's the world map, the overview map.
maps[0]={
  name="world",
  minx=0,
  miny=0,
  maxx=64,
  maxy=64,
  wrap=true,
  newmonsters=10,
  maxmonsters=10,
  friendly=false
}

-- armor definitions
armors={
  south={name='cloth',num=8,price=12},
  west={name='leather',num=23,price=99},
  east={name='chain',num=40,price=300},
  north={name='plate',num=90,price=950},
  [0]='none',
  [8]='cloth',
  [23]='leather',
  [40]='chain',
  [90]='plate'
}

-- weapon definitions
weapons={
  d={name='dagger',num=8,price=8},
  c={name='club',num=12,price=40},
  a={name='axe',num=18,price=75},
  s={name='sword',num=30,price=150},
  [0]='none',
  [8]='dagger',
  [12]='club',
  [18]='axe',
  [30]='sword'
}

-- spell definitions
spells={
  a={name='attack',mp=3,amount=10},
  x={name='medic',mp=5,amount=12,price=8},
  c={name='cure',mp=7,price=10},
  w={name='wound',mp=11,amount=50},
  e={name='exit',mp=13},
  s={name='savior',mp=17,amount=60,price=25}
}

function initobjs()
  -- the creatures structure holds the live copy saying which
  -- creatures (both human and monster) are where in the world.
  -- individually they are instances of bestiary objects or
  -- occupation type objects.
  creatures={}

  -- perform the per-map data structure initializations.
  for mapnum=0,#maps do
    curmap=maps[mapnum]
    curmap.width=curmap.maxx-curmap.minx
    curmap.height=curmap.maxy-curmap.miny
    creatures[mapnum]={}
    curmap.contents={}
    for num=0,127 do
      curmap.contents[num]={}
    end
    for item in all(curmap.items) do
      curmap.contents[item.x][item.y]=makemetaobj(item.objtype,item)
    end
  end

  -- make the map info global for efficiency
  mapnum=0
  curmap=maps[mapnum]
  contents=curmap.contents

  -- creature 0 is the maelstrom and not really a creature at all,
  -- although it shares most creature behaviors.
  creatures[0]={}
  creatures[0][0]={
    img=68,
    imgseq=23,
    name="maelstrom",
    terrain={12,13,14,15},
    moveallowance=1,
    x=13,
    y=61,
    z=0,
    facing=1
  }
  makemetaobj(anyobj,creatures[0][0])
  contents[13][61]=creatures[0][0]

  -- the hero is the player character. although human, it has
  -- enough differences that there is no advantage to inheriting
  -- the human type.
  hero={
    img=0,
    armor=0,
    dmg=0,
    x=7,
    y=7,
    z=0,
    exp=0,
    lvl=0,
    str=8,
    int=8,
    dex=8,
    status=0,
    hitdisplay=0,
    facing=0,
    gold=20,
    food=25,
    movepayment=0,
    items={}
  }
  hero.mp=hero.int
  hero.hp=hero.str*3

  turn=0
  turnmade=false
  cycle=0
  _update=world_update
  _draw=world_draw
  draw_state=world_draw

  -- townies
  definemonster(1,guard,73,21)
  definemonster(2,guard,102,22)
  definemonster(1,medic,68,9)
  definemonster(2,smith,90,1)
  definemonster(1,armorer,79,3)
  definemonster(2,barkeep,102,2)
  definemonster(1,grocer,81,13)
  definemonster(2,grocer,91,9)
  definemonster(2,jester,90,16)
  definemonster(1,shepherd,66,21)
  definemonster(2,medic,106,12)
  definemonster(1,guard,79,21)
  definemonster(2,guard,98,22)
end

-- the lines list holds the text output displayed on the screen.
lines={"","","","",">"}
numoflines=#lines
curline=numoflines

-- a function for logging to an output log file.
function logit(entry)
  printh(entry,'minima.out')
end

-- initialization routines

function _init()
  initobjs()
  menuitem(1,"list commands",listcommands)
  menuitem(2,"save game",savegame)
  menuitem(3,"load game",loadgame)
  menuitem(4,"new game",run)
  processinput=cocreate(inputprocessor)
  cartdata("minima0")
end

function listcommands()
  msg=helpmsg
  draw_state=_draw
  _draw=msg_draw
end

attrlist={'armor','dmg','x','y','exp','lvl','str','int','dex','status','gold','food','mp','hp'}

function savegame()
  if mapnum~=0 then
    update_lines{"sorry, only outside."}
  else
    local storagenum=0
    for heroattr in all(attrlist) do
      dset(storagenum,hero[heroattr])
      storagenum+=1
    end
    for creaturenum=1,10 do
      local creature=creatures[0][creaturenum]
      if creature then
        dset(storagenum,creature.idtype)
        dset(storagenum+1,creature.x)
        dset(storagenum+2,creature.y)
      else
        dset(storagenum,0)
      end
      storagenum+=3
    end
    dset(storagenum,checkifinship() or 0)
    update_lines{"game saved."}
  end
end

function loadgame()
  initobjs()
  local storagenum=0
  for heroattr in all(attrlist) do
    hero[heroattr]=dget(storagenum)
    storagenum+=1
  end
  for creaturenum=1,10 do
    creaturenum=dget(storagenum)
    if creaturenum~=0 then
      definemonster(0,bestiary[creaturenum],dget(storagenum+1),dget(storagenum+2))
      storagenum+=3
    else
      break
    end
  end
  if dget(storagenum)>0 then
    add(hero.items,makemetaobj(shiptype))
    hero.img=69
    hero.facing=1
  end
  update_lines{"game loaded."}
end

buttons={
  "west", "east", "north", "south",
  "c", "x", "p", "?", "s", "f", "e", "d", "w", "a"
}

function getbutton(btnpress)
  local bitcount=1
  while btnpress>1 do
    btnpress=lshr(btnpress,1)
    bitcount+=1
  end
  return buttons[bitcount] or 'none'
end

function checkspell(cmd,extra)
  local spell=spells[cmd]
  if hero.mp>=spell.mp then
    hero.mp-=spell.mp
    update_lines{spell.name.." is cast! "..(extra or '')}
    return true
  else
    update_lines{"not enough mp."}
    return false
  end
end

function exitdungeon()
  hero.x,hero.y,hero.z=curmap.enterx,curmap.entery,0
  mapnum=curmap.mapnum
  curmap=maps[mapnum]
  contents=curmap.contents
  hero.facing=0
  hero.hitdisplay=0
  _draw=world_draw
end

function inputprocessor(cmd)
  while true do
    local spots=calculatemoves(hero)
    if _draw==msg_draw then
      if cmd!='p' and hero.hp>0 then
        _draw=draw_state
      end
    elseif cmd=='west' then
      if curmap.dungeon then
        hero.facing-=1
        if hero.facing<1 then
          hero.facing=4
        end
        update_lines{"turn left"}
        turnmade=true
      else
        hero.x,hero.y=checkmove(spots[2],hero.y,"west")
      end
      logit('hero '..hero.x..','..hero.y..','..hero.z)
    elseif cmd=='east' then
      if curmap.dungeon then
        hero.facing+=1
        if hero.facing>4 then
          hero.facing=1
        end
        update_lines{"turn right."}
        turnmade=true
      else
        hero.x,hero.y=checkmove(spots[4],hero.y,"east")
      end
      logit('hero '..hero.x..','..hero.y..','..hero.z)
    elseif cmd=='north' then
      if curmap.dungeon then
        hero.x,hero.y,hero.z=checkdungeonmove(1)
      else
        hero.x,hero.y=checkmove(hero.x,spots[1],"north")
      end
      logit('hero '..hero.x..','..hero.y..','..hero.z)
    elseif cmd=='south' then
      if curmap.dungeon then
        hero.x,hero.y,hero.z=checkdungeonmove(-1)
      else
        hero.x,hero.y=checkmove(hero.x,spots[3],"south")
      end
      logit('hero '..hero.x..','..hero.y..','..hero.z)
    elseif cmd=='c' then
      update_lines{"choose a\84\84\65\67\75, m\69\68\73\67, c\85\82\69,","w\79\85\78\68, e\88\73\84, s\65\86\73\79\82: "}
      cmd=yield()
      if cmd=='c' then
        -- cast cure
        if checkspell(cmd) then
          sfx(3)
          hero.status=band(hero.status,14)
        end
      elseif cmd=='x' or cmd=='s' then
        -- cast healing
        if checkspell(cmd) then
          sfx(3)
          increasehp(spells[cmd].amount)
        end
      elseif cmd=='e' then
        -- cast exit dungeon
        if not curmap.dungeon then
          update_lines{'not in a dungeon.'}
        elseif(checkspell(cmd)) then
          sfx(4)
          exitdungeon()
        end
      elseif cmd=='w' or cmd=='a' then
        -- cast offensive spell
        if checkspell(cmd,'dir:') then
          local spelldamage=spells[cmd].amount
          if not getdirection(spots,attack_results,spelldamage) then
            update_lines{'cast at what?'}
          end
        end
      else
        update_lines{"4 (cast "..cmd..")"}
      end
      turnmade=true
    elseif cmd=='x' then
      update_lines{"examine dir:"}
      if not getdirection(spots,look_results) then
        if cmd=='x' then
          local response={"search","you find nothing."}
          signcontents=check_sign(hero.x,hero.y)
          if signcontents then
            response={"read sign",signcontents}
          --else
          -- search response
          end
          update_lines(response)
        else
          update_lines{"examine: huh?"}
        end
      end
      turnmade=true
    elseif cmd=='p' then
      update_lines{"pause / game menu"}
    elseif cmd=='s' then
      turnmade=true
      update_lines{"sit and wait."}
    elseif cmd=='f' then
      turnmade=true
      update_lines{"1,1"}
    elseif cmd=='e' then
      turnmade=true
      local msg="nothing to enter."
      local shipindex=checkifinship()
      if curmap.dungeon and hero.z==curmap.startz and hero.x==curmap.startx and hero.y==curmap.starty then
        msg="exiting "..curmap.name.."."
        exitdungeon()
      elseif shipindex then
        msg="exiting ship."
        hero.items[shipindex].facing=hero.facing
        contents[hero.x][hero.y]=hero.items[shipindex]
        hero.items[shipindex]=nil
        hero.img=0
        hero.facing=0
      elseif contents[hero.x][hero.y] then
        if contents[hero.x][hero.y].name=='ship' then
          msg="boarding ship."
          hero.img=contents[hero.x][hero.y].img
          hero.facing=contents[hero.x][hero.y].facing
          add(hero.items,contents[hero.x][hero.y])
          contents[hero.x][hero.y]=nil
        end
      else
        for loopmapnum=1,#maps do
          local loopmap=maps[loopmapnum]
          if mapnum==loopmap.mapnum and hero.x==loopmap.enterx and hero.y==loopmap.entery then
            -- enter the new location
            hero.x,hero.y=loopmap.startx,loopmap.starty
            mapnum=loopmapnum
            curmap=maps[mapnum]
            contents=curmap.contents
            msg="entering "..loopmap.name.."."
            logit("new hero mapnum: "..mapnum)
            if loopmap.dungeon then
               _draw=dungeon_draw
               hero.facing=loopmap.startfacing
               hero.z=loopmap.startz
            end
            break
          end
        end
      end
      update_lines{msg}
    elseif cmd=='d' then
      update_lines{"dialog dir:"}
      if not getdirection(spots,dialog_results) then
        update_lines{"dialog: huh?"}
      end
      turnmade=true
    elseif cmd=='w' then
      update_lines{
        "worn: "..armors[hero.armor].."; wield: "..weapons[hero.dmg]
      }
    elseif cmd=='a' then
      if checkifinship() then
        update_lines{"fire dir:"}
      else
        update_lines{"attack dir:"}
      end
      if not getdirection(spots,attack_results) then
        update_lines{"attack: huh?"}
      end
      turnmade=true
    end
    cmd=yield()
  end
end

function getdirection(spots,resultfunc,magic,adir)
  if curmap.dungeon then
    adir='ahead'
  elseif not adir then
    adir=yield()
  end
  if adir=='east' or hero.facing==2 then
    resultfunc(adir,spots[4],hero.y,magic)
  elseif adir=='west' or hero.facing==4 then
    resultfunc(adir,spots[2],hero.y,magic)
  elseif adir=='north' or hero.facing==1 then
    resultfunc(adir,hero.x,spots[1],magic)
  elseif adir=='south' or hero.facing==3 then
    resultfunc(adir,hero.x,spots[3],magic)
  else
    return false
  end
  return true
end

function update_lines(msg)
  local prompt="> "
  for curmsg in all(msg) do
    lines[curline]=prompt..curmsg
    logit(curmsg)
    curline+=1
    if(curline>numoflines)curline=1
    prompt=""
  end
  lines[curline]=">"
end

function definemonster(targetmap,monstertype,monsterx,monstery,monsterz)
  local monster={x=monsterx,y=monstery,z=monsterz}
  makemetaobj(monstertype,monster)
  if(monstertype.names)monster.name=monstertype.names[flr(rnd(#monstertype.names)+1)]
  --if(monstertype.imgs)monster.img=monstertype.imgs[flr(rnd(#monstertype.imgs)+1)]
  if(monstertype.colorsubs)monster.colorsub=monstertype.colorsubs[flr(rnd(#monstertype.colorsubs)+1)]
  monster.imgseq=flr(rnd(30))
  monster.imgalt=false
  if monsterz then
    monster.z=monsterz
  end
  add(creatures[targetmap],monster)
  maps[targetmap].contents[monsterx][monstery]=monster
  logit("made "..(monster.name or monsternum).." at ("..monster.x..","..monster.y..","..(monster.z or 'nil')..")")
  return monster
end

function create_monster()
  local monsterx=flr(rnd(curmap.width))+curmap.minx
  local monstery=flr(rnd(curmap.height))+curmap.miny
  local monsterz=curmap.dungeon and flr(rnd(#curmap.levels)+1) or 0
  if contents[monsterx][monstery] or monsterx==hero.x and monstery==hero.y and monsterz==hero.z then
    -- don't create a monster where there already is one
    monsterx=nil
  end
  if monsterx then
    local monsterspot=mget(monsterx,monstery)
    if curmap.dungeon then
      monsterspot=getdungeonblockterrain(monsterx,monstery,monsterz)
    end
    --logit('possible monster location: ('..monsterx..','..monstery..','..(monsterz or 'nil')..') terrain '..monsterspot)
    for monstertype in all(terrainmonsters[monsterspot]) do
      if rnd(200)<monstertype.chance then
        definemonster(mapnum,monstertype,monsterx,monstery,monsterz)
        break
      end
    end
  end
end

function checkifinship()
  local shipindex=nil
  for itemindex,item in pairs(hero.items) do
    if item.name=='ship' then
      shipindex=itemindex
      break
    end
  end
  return shipindex
end

function deducthp(damage)
  hero.hp-=damage
  if hero.hp<=0 then
    msg=losemsg
    -- draw_state=_draw
    _draw=msg_draw
  end
end

function deductfood(amount)
  hero.food-=amount
  if hero.food<=0 then
    sfx(1,0,8)
    hero.food=0
    update_lines{"starving!"}
    deducthp(1)
  end
end

function not_over_32767(num)
  return min(num,32767)
end

function increasexp(amount)
  hero.exp=not_over_32767(hero.exp+amount)
  if hero.exp>=hero.lvl^2*10 then
    hero.lvl+=1
    increasehp(12)
    update_lines{"you went up a level!"}
  end
end

function increasegold(amount)
  hero.gold=not_over_32767(hero.gold+amount)
end

function increasemp(amount)
  hero.mp=not_over_32767(min(hero.mp+amount,hero.int*(hero.lvl+1)))
end

function increasehp(amount)
  hero.hp=not_over_32767(min(hero.hp+amount,hero.str*(hero.lvl+3)))
end

-- world updates

function checkdungeonmove(direction)
  local newx,newy=hero.x,hero.y
  local xeno,yako,zabo=hero.x,hero.y,hero.z
  local cmd=direction>0 and 'advance' or 'retreat'
  local item
  local iscreature=false
  if hero.facing==1 then
    newy-=direction
    result=getdungeonblock(xeno,newy,zabo)
    item=contents[xeno][newy]
  elseif hero.facing==2 then
    newx+=direction
    result=getdungeonblock(newx,yako,zabo)
    item=contents[newx][yako]
  elseif hero.facing==3 then
    newy+=direction
    result=getdungeonblock(xeno,newy,zabo)
    item=contents[xeno][newy]
  else
    newx-=direction
    result=getdungeonblock(newx,yako,zabo)
    item=contents[newx][yako]
  end
  if item and item.z==hero.z and item.hp then
    iscreature=true
  end
  if result==3 or iscreature then
    update_lines{cmd,"blocked!"}
  else
    xeno,yako=newx,newy
    if result==2 then
      zabo+=1
      sfx(1)
      update_lines{cmd,"fell in pit!"}
      deducthp(flr(rnd(10)))
    else
      sfx(0)
      update_lines{cmd}
    end
  end
  turnmade=true
  return xeno,yako,zabo
end

function checkexit(xeno,yako)
  if not curmap.wrap and(xeno>=curmap.maxx or xeno<curmap.minx or yako>=curmap.maxy or yako<curmap.miny) then
    update_lines{cmd,"exiting "..curmap.name.."."}
    mapnum=0
    return true
  else
    return false
  end
end

function checkmove(xeno,yako,cmd)
  local movesuccess=true
  local newloc=mget(xeno,yako)
  local movecost=band(fget(newloc),3)
  local water=fget(newloc,2)
  local impassable=fget(newloc,3)
  local inship=checkifinship()
  local content=contents[xeno][yako]
  --update_lines(""..xeno..","..yako.." "..newloc.." "..movecost.." "..fget(newloc))
  if inship then
    if cmd=='north' then
      hero.facing=1
    elseif cmd=='west' then
      hero.facing='2'
    elseif cmd=='south' then
      hero.facing='3'
    else
      hero.facing='4'
    end
    local terraintype=mget(xeno,yako)
    if checkexit(xeno,yako) then
      xeno,yako=curmap.enterx,curmap.entery
      curmap=maps[0]
      contents=curmap.contents
    elseif content then
      if content.name=='maelstrom' then
        update_lines{cmd,"maelstrom! yikes!"}
        deducthp(flr(rnd(25)))
      else
        movesuccess=false
        update_lines{cmd,"blocked!"}
      end
    elseif terraintype<12 or terraintype>15 then
      update_lines{cmd,"must exit ship first."}
      movesuccess=false
    else
      update_lines{cmd}
    end
  else
    if content and (content.z==0 or content.z==nil) then
      if content.name~='ship' then
        movesuccess=false
        update_lines{cmd,"blocked!"}
      end
    elseif newloc==28 then
      update_lines{cmd,"open door."}
      movesuccess=false
      mset(xeno,yako,30)
    elseif newloc==29 then
      update_lines{cmd,"the door is locked."}
      movesuccess=false
    elseif impassable then
      movesuccess=false
      update_lines{cmd,"blocked!"}
    elseif water then
      movesuccess=false
      update_lines{cmd,"not without a boat."}
    elseif checkexit(xeno,yako) then
      xeno,yako=curmap.enterx,curmap.entery
      curmap=maps[0]
      contents=curmap.contents
    elseif movecost>hero.movepayment then
      hero.movepayment+=1
      movesuccess=false
      update_lines{cmd,"slow progress."}
    else
      hero.movepayment=0
      update_lines{cmd}
    end
  end
  if movesuccess then
    if not inship then
      sfx(0)
    end
    if newloc==5 and rnd(10)>8 then
      update_lines{cmd,"poisoned!"}
      hero.status=bor(hero.status,1)
    end
  else
    xeno,yako=hero.x,hero.y
  end
  turnmade=true
  return xeno,yako
end

function check_sign(x,y)
  local response=nil
  if mget(x,y)==31 then
    -- read the sign
    for sign in all(curmap.signs) do
      if x==sign.x and y==sign.y then
        response=sign.msg
        break
      end
    end
  end
  return response
end

function look_results(ldir,x,y)
  local cmd="examine: "..ldir
  local content=contents[x][y] or nil
  local signcontents=check_sign(x,y)
  if signcontents then
    update_lines{cmd.." (read sign)",signcontents}
  elseif content and content.z==hero.z then
    update_lines{cmd,content.name}
  elseif curmap.dungeon then
    update_lines{cmd,"dungeon"}
  else
    update_lines{cmd,terrains[mget(x,y)]}
  end
end

function dialog_results(ddir,xeno,yako)
  local cmd="dialog: "..ddir
  if terrains[mget(xeno,yako)]=='counter' then
    return getdirection(calculatemoves({x=xeno,y=yako}),dialog_results,nil,ddir)
  end
  if contents[xeno][yako] then
    local dialog_target=contents[xeno][yako]
    if dialog_target.merch then
      update_lines{shop[dialog_target.merch]()}
    elseif contents[xeno][yako].talk then
      update_lines{cmd,'"'..dialog_target.talk[flr(rnd(#dialog_target.talk)+1)]..'"'}
    else
      update_lines{cmd,'no response!'}
    end
  else
    update_lines{cmd,'no one to talk with.'}
  end
end

function attack_results(adir,x,y,magic)
  local cmd="attack: "..adir
  local z,creature=hero.z,contents[x][y]
  local damage=flr(rnd(hero.str+hero.lvl+hero.dmg))
  if magic then
    damage+=magic
  elseif checkifinship() then
    cmd="fire: "..adir
    damage+=rnd(50)
  end
  if creature and creature.hp and creature.z==z then
    if magic or rnd(hero.dex+hero.lvl*8)>rnd(creature.dex+creature.armor) then
      damage-=rnd(creature.armor)
      creature.hitdisplay=3
      sfx(1)
      creature.hp-=damage
      if creature.hp<=0 then
        increasegold(creature.gold)
        increasexp(creature.exp)
        if creature.name=='pirates' then
          contents[x][y]={
            facing=creature.facing
          }
          makemetaobj(shiptype,contents[x][y])
        else
          contents[x][y]=nil
        end
        update_lines{cmd,creature.name..' killed; xp+'..creature.exp..' gp+'..creature.gold}
        del(creatures[mapnum],creature)
      else
        update_lines{cmd,'you hit the '..creature.name..'!'}
        creature.hostile=true
        if curmap.friendly then
          for townie in all(creatures[mapnum]) do
            logit(townie.name.." is turning hostile.")
            townie.hostile=true
            townie.talk={"you're a lawbreaker!","criminal!"}
            if townie.name=='guard' then
              townie.moveallowance=1
            end
          end
        end
      end
    else
      update_lines{cmd,'you miss the '..creature.name..'!'}
    end
  elseif mget(x,y)==29 then
    -- bash locked door
    sfx(1)
    if(not magic)deducthp(1)
    if rnd(damage)>8 then
      update_lines{cmd,'you break open the door!'}
      mset(x,y,30)
    else
      update_lines{cmd,'the door is still locked.'}
    end
  else
    update_lines{cmd,'nothing to attack.'}
  end
end

function squaredistance(x1,y1,x2,y2)
  local dx=abs(x1-x2)
  --logit('dx: '..dx..' '..x1..'-'..x2)
  if curmap.wrap and dx>curmap.width/2 then
    --logit('dx wrapper '..dx..' '..curmap.width-dx)
    dx=curmap.width-dx;
  end
  local dy=abs(y1-y2)
  --logit('dy: '..dy..' '..y1..'-'..y2)
  if curmap.wrap and dy>curmap.height/2 then
    --logit('dy wrapper '..dy..' '..curmap.height-dy)
    dy=curmap.height-dy;
  end
  return dx+dy
end

function calculatemoves(creature)
  local maxx,maxy=curmap.maxx,curmap.maxy
  local eastspot,westspot=(creature.x+curmap.width-1)%maxx,(creature.x+1)%maxx
  local northspot,southspot=(creature.y+curmap.height-1)%maxy,(creature.y+1)%maxy
  if not curmap.wrap then
    eastspot,westspot=creature.x-1,creature.x+1
    northspot,southspot=creature.y-1,creature.y+1
  end
  --logit('northspot '..northspot)
  --logit('eastspot '..eastspot)
  --logit('southspot '..southspot)
  --logit('westspot '..westspot)
  return {northspot,eastspot,southspot,westspot}
end

function movecreatures(hero)
  local gothit=false
  local actualdistance=500
  local xeno,yako,zabo=hero.x,hero.y,hero.z
  for creaturenum,creature in pairs(creatures[mapnum]) do
    local cfacing=creature.facing
    if creature.z==zabo then
      local desiredx,desiredy=creature.x,creature.y
      while creature.moveallowance>creature.nummoves do
        local spots=calculatemoves(creature)
        --foreach(spots,logit)
        if creature.hostile then
          -- most creatures are hostile; move toward player
          local bestfacing=0
          actualdistance=squaredistance(creature.x,creature.y,xeno,yako)
          local currentdistance=actualdistance
          local bestdistance=currentdistance
          for facing=1,4 do
            if facing%2==1 then
              currentdistance=squaredistance(creature.x,spots[facing],xeno,yako)
            else
              currentdistance=squaredistance(spots[facing],creature.y,xeno,yako)
            end
            if currentdistance<bestdistance then
              --logit(creature.name..' best distance (cur): '..currentdistance..' (old): '..bestdistance..' facing: '..facing)
              bestdistance,bestfacing=currentdistance,facing
            else
             --logit(creature.name..' worse distance (cur): '..currentdistance..' (old): '..bestdistance..' facing: '..facing)
            end
          end
          if bestfacing and bestfacing%2==1 then
            desiredy=spots[bestfacing]
          else
            desiredx=spots[bestfacing]
          end
          creature.facing=bestfacing
        else
          -- neutral & friendly creatures just do their own thing
          if rnd(10)<5 then
            if cfacing and rnd(10)<5 then
              if cfacing%2==1 then
                desiredy=spots[cfacing]
              else
                desiredx=spots[cfacing]
              end
            else
              local facing=flr(rnd(4)+1)
              if facing%2==1 then
                desiredy=spots[facing]
              else
                desiredx=spots[facing]
              end
            end
          end
        end
        --logit((creature.name or 'nil')..'desiredx '..(desiredx or 'nil')..' desiredy '..(desiredy or 'nil'))
        local newloc=mget(desiredx,desiredy)
        if curmap.dungeon then
          newloc=getdungeonblockterrain(desiredx,desiredy,creature.z)
        end
        local canmove=false
        for terrain in all(creature.terrain) do
          if newloc==terrain then
            canmove=true
            break
          end
        end
        --if curmap.dungeon then
        --  logit(creature.name..' newloc '..newloc..' '..desiredx..','..desiredy..' '..creature.x..','..creature.y..','..creature.z..' can move '..(canmove and 'true' or 'false'))
        --end
        --logit(creature.name..' bestfacing '..bestfacing..': '..spots[bestfacing]..' '..(canmove and 'true' or 'false')..' t '..mget(desiredx,desiredy)..' mp '..creature.movepayment)
        creature.nummoves+=1
        --logit(creature.name..': actualdistance '..actualdistance..' x '..desiredx..' '..xeno..' y '..desiredy..' '..yako)
        if creature.z==zabo and (creature.hostile and actualdistance<=1 or (desiredx==xeno and desiredy==yako and creature.hostile==nil and creaturenum~=0)) then
          local hero_dodge=hero.dex+2*hero.lvl
          if creature.eat and hero.food>0 and rnd(creature.dex*25)>rnd(hero_dodge) then
            sfx(2)
            update_lines{"the "..creature.name.." eats!"}
            deductfood(flr(rnd(6)))
            gothit=true
            delay(9)
          elseif creature.thief and hero.gold>0 and rnd(creature.dex*23)>rnd(hero_dodge) then
            sfx(2)
            local amountstolen=min(ceil(rnd(5)),hero.gold)
            hero.gold-=amountstolen
            creature.gold+=amountstolen
            update_lines{"the "..creature.name.." steals!"}
            gothit=true
            delay(9)
          elseif creature.poison and rnd(creature.dex*20)>rnd(hero_dodge) then
            sfx(1)
            hero.status=bor(hero.status,1)
            update_lines{"poisoned by the "..creature.name.."!"}
            gothit=true
            delay(3)
          elseif rnd(creature.dex*64)>rnd(hero_dodge+hero.armor) then
            hero.gothit=true
            sfx(1)
            local damage=max(ceil(rnd(creature.str+creature.dmg)-rnd(hero.armor)),0)
            deducthp(damage)
            update_lines{"the "..creature.name.." hits!"}
            gothit=true
            delay(3)
            hero.hitdisplay=3
          else
            update_lines{"the "..creature.name.." misses."}
          end
        elseif canmove then
          local movecost=band(fget(newloc),3)
          --logit(creature.name..' movepayment '..(creature.movepayment or 'nil')..' '..creature.x..','..creature.y)
          creature.movepayment+=1
          logit((creature.name or 'nil')..' desired '..(desiredx or 'nil')..','..(desiredy or 'nil')..' hero '..(xeno or 'nil')..','..(yako or 'nil')..','..(zabo or 'nil')..' movecost '..(movecost or 'nil'))
          if creature.movepayment>=movecost and not contents[desiredx][desiredy] and not (desiredx==xeno and desiredy==yako and creature.z==zabo) then
            contents[creature.x][creature.y]=nil
            contents[desiredx][desiredy]=creature
            creature.x,creature.y=desiredx,desiredy
            creature.movepayment=0
          end
        end
      end
      creature.nummoves=0
    end
  end
  return gothit
end

function world_update()
  local btnpress=btnp()
  if btnpress~=0 then
    coresume(processinput,getbutton(btnpress))
  end
  if turnmade then
    turnmade=false
    turn+=1
    if turn%500==0 then
      increasehp(1)
    end
    if turn%50==0 then
      deductfood(1)
    end
    if turn%10==0 then
      increasemp(1)
    end
    if turn%5==0 and band(hero.status,1)==1 then
      deducthp(1)
      sfx(1,0,8)
      update_lines{"feeling sick!"}
    end
    if gothit then
      delay(3)
    end
    gothit=movecreatures(hero)
    if #creatures[mapnum]<curmap.maxmonsters and rnd(10)<curmap.newmonsters then
      create_monster()
    end
  end
end

-- drawing routines

function delay(numofcycles)
  --logit('delay numofcycles='..numofcycles)
  for delaycount=0,numofcycles do
    flip()
  end
end

function animatespr(sprnum)
  local sprloc=flr(sprnum/16)*512+sprnum%16*4
  if(fget(sprnum,7))then
    for row=0,448,64 do
      reload(sprloc+row,sprloc+row,4)
      fset(sprnum,band(fget(sprnum),64))
    end
  else
    for row=0,448,64 do
      memcpy(sprloc+row,sprloc+row+4,4)
      fset(sprnum,7,true)
    end
  end
  fset(sprnum,2,true)
end

function draw_stats()
  local linestart=106
  print("cond",linestart,0,5)
  print(band(hero.status,1)==1 and 'p' or 'g',125,0,6)
  print("lvl",linestart,8,5)
  print(hero.lvl,125,8,6)
  print("hp",linestart,16,5)
  print(hero.hp,linestart+8,16,6)
  print("mp",linestart,24,5)
  print(hero.mp,linestart+8,24,6)
  print("$",linestart,32,5)
  print(hero.gold,linestart+4,32,6)
  print("f",linestart,40,5)
  print(hero.food,linestart+4,40,6)
  print("exp",linestart,48,5)
  print(hero.exp,linestart,55,6)
  print("dex",linestart,63,5)
  print(hero.dex,linestart+13,63,6)
  print("int",linestart,71,5)
  print(hero.int,linestart+13,71,6)
  print("str",linestart,79,5)
  print(hero.str,linestart+13,79,6)
  for linenum=1,numoflines do
    print(lines[(curline-linenum)%numoflines+1],0,128-linenum*8)
  end
end

function itemdrawprep(item)
  local flipped=false
  if item.imgseq then
    item.imgseq-=1
    if item.imgseq<0 then
      item.imgseq=23
      if item.imgalt then
        item.imgalt=false
        --if(item.img==nil)update_lines{"item.img nil"}
        if(item.flipimg==nil)item.img-=1
      else
        item.imgalt=true
        --if(item.img==nil)update_lines{"item.img nil"}
        if(item.flipimg==nil)item.img+=1
      end
    end
    if item.flipimg then
      flipped=item.imgalt
    end
  end
  palt(0,false)
  if item.colorsub then
    for colorsub in all(item.colorsub) do
      pal(colorsub[1],colorsub[2])
    end
  end
  return flipped
end

function draw_map(x,y,scrtx,scrty,width,height)
  map(x,y,scrtx*8,scrty*8,width,height)
  for contentsx=x,x+width-1 do
    for contentsy=y,y+height-1 do
      local item=contents[contentsx][contentsy]
      if item and (item.z==0 or item.z==nil) then
        local flipped=itemdrawprep(item)
        local facing=item.facingmatters and item.facing or 0
        spr(item.img+facing,(contentsx-x+scrtx)*8,(contentsy-y+scrty)*8,1,1,flipped)
        pal()
        if item.hitdisplay>0 then
          spr(127,(contentsx-x+scrtx)*8,(contentsy-y+scrty)*8)
          item.hitdisplay-=1
        end
      end
    end
  end
end

function getdungeonblock(mapx,mapy,mapz)
  local block=0
  if mapx>=curmap.maxx or mapx<curmap.minx or mapy>=curmap.maxy or mapy<curmap.miny then
    block=3
  else
    local row=curmap.levels[mapz][mapy]
    row=flr(shr(row,(curmap.width-mapx)*2))
    block=band(row,3)
  end
  return block
end

function getdungeonblockterrain(mapx,mapy,mapz)
  return getdungeonblock(mapx,mapy,mapz)>1 and 20 or 22
end

function triplereverse(triple)
  local tmp=triple[1]
  triple[1]=triple[3]
  triple[3]=tmp
end

function getdungeonblocks(mapx,mapy,mapz,facing)
  local blocks={}
  if facing%2==0 then
    -- we're looking for a column
    for viewy=mapy-1,mapy+1 do
      add(blocks,{
        block=getdungeonblock(mapx,viewy,mapz),
        x=mapx,
        y=viewy}
      )
    end
    if facing==4 then
      triplereverse(blocks)
    end
  else
    -- we're looking for a row
    for viewx=mapx-1,mapx+1 do
      add(blocks,{
        block=getdungeonblock(viewx,mapy,mapz),
        x=viewx,
        y=mapy
        }
      )
    end
    if facing==3 then
      triplereverse(blocks)
    end
  end
  return blocks
end

function getdungeonview(mapx,mapy,mapz,facing)
  local blocks={}
  local viewx,viewy=mapx,mapy
  if facing%2==0 then
    for viewx=mapx+4-facing,mapx+2-facing,-1 do
      add(blocks,getdungeonblocks(viewx,viewy,mapz,facing))
    end
    if facing==4 then
       triplereverse(blocks)
    end
  else
    for viewy=mapy-3+facing,mapy-1+facing do
      add(blocks,getdungeonblocks(viewx,viewy,mapz,facing))
    end
    if facing==3 then
      triplereverse(blocks)
    end
  end
  return blocks
end

function dungeon_draw()
  cls()
  local view=getdungeonview(hero.x,hero.y,hero.z,hero.facing)
  for depthindex,row in pairs(view) do
    local depthin=(depthindex-1)*10
    local depthout=depthindex*10
    local topouter=30-depthout
    local topinner=30-depthin
    local bottomouter=52+depthout
    local bottominner=52+depthin
    local lowextreme=30-depthout*2
    local highextreme=52+depthout*2
    local lowerase=31-depthin
    local higherase=51+depthin
    local middle=42
    if row[1].block==3 then
      rectfill(topouter,topouter,topinner,bottomouter,0)
      line(lowextreme,topouter,topouter,topouter,5)
      line(topouter,topouter,topinner,topinner)
      line(topouter,bottomouter,topinner,bottominner)
      line(lowextreme,bottomouter,topouter,bottomouter)
    end
    if row[3].block==3 then
      rectfill(bottominner,topinner,bottomouter,bottomouter,0)
      line(bottomouter,topouter,highextreme,topouter,5)
      line(bottominner,topinner,bottomouter,topouter)
      line(bottominner,bottominner,bottomouter,bottomouter)
      line(bottomouter,bottomouter,highextreme,bottomouter)
    end
    if depthindex>1 then
      local leftoneback=view[depthindex-1][1].block
      local centeroneback=view[depthindex-1][2].block
      local rightoneback=view[depthindex-1][3].block
      if (row[1].block==centeroneback and row[1].block==3) or
        (row[1].block~=leftoneback) then
        line(topinner,topinner,topinner,bottominner,5)
      end
      if (row[3].block==centeroneback and row[3].block==3) or
        (row[3].block~=rightoneback) then
        line(bottominner,topinner,bottominner,bottominner,5)
      end
      if centeroneback==3 and leftoneback==3 and row[1].block~=3 then
        line(topinner,lowerase,topinner,higherase,0)
      end
      if centeroneback==3 and rightoneback==3 and row[3].block~=3 then
        line(bottominner,lowerase,bottominner,higherase,0)
      end
    end
    if row[2].block==3 then
      rectfill(topouter,topouter,bottomouter,bottomouter,0)
      line(topouter,topouter,bottomouter,topouter,5)
      line(topouter,bottomouter,bottomouter,bottomouter)
      if row[1].block<3 then
        line(topouter,topouter,topouter,bottomouter)
      end
      if row[3].block<3 then
        line(bottomouter,topouter,bottomouter,bottomouter)
      end
    end
    if row[2].block==1 then
      -- we see the underside of a pit
      if row[1].block>2 then
        line(bottomouter,topouter,bottominner,topinner,0)
      end
      if row[3].block>2 then
        line(topouter,topouter,topinner,topinner)
      end
      line(topinner,topinner,bottominner,topinner,5)
      line(bottominner,topinner,bottominner,topouter)
      line(topinner,topouter,topinner,topinner)
      line(topouter,topouter,bottomouter,topouter)
    elseif row[2].block==2 then
      -- we see a pit
       if row[1].block>2 then
         line(bottomouter,bottomouter,bottominner,bottominner,0)
       end
       if row[3].block>2 then
         line(topouter,bottomouter,topinner,bottominner)
       end
       line(topinner,bottominner,bottominner,bottominner,5)
       line(topinner,bottomouter,topinner,bottominner)
       line(bottominner,bottominner,bottominner,bottomouter)
       line(topouter,bottomouter,bottomouter,bottomouter)
    end
    dungeondrawmonster(row[2].x,row[2].y,hero.z,3-depthindex)
    -- local distance=2
    -- if hero.facing%2==0 then
    --   for viewx=hero.x+4-hero.facing,hero.x+2-hero.facing,-1 do
    --     if viewx>curmap.minx and viewx<curmap.maxx and contents[viewx][hero.y] then
    --       --logit('got '..contents[viewx][hero.y].name..' at x '..hero.x..' ('..viewx..','..hero.y..','..hero.z..') hero at ('..hero.x..','..hero.y..','..hero.z..')')
    --       dungeondrawmonster(viewx,hero.y,contents[viewx][hero.y].z,distance)
    --     end
    --     distance-=1
    --   end
    -- else
    --   for viewy=hero.y-3+hero.facing,hero.y-1+hero.facing do
    --     if viewy>curmap.miny and viewy<curmap.maxy and contents[hero.x][viewy] then
    --       --logit('got '..(contents[hero.x][viewy].name or 'nil')..' at y '..(hero.y or 'nil')..' ('..(hero.x or 'nil')..','..(viewy or 'nil')..','..(contents[hero.x][viewy].z or 'nil')..') hero at ('..hero.x..','..hero.y..','..hero.z..')')
    --       dungeondrawmonster(hero.x,viewy,contents[hero.x][viewy].z,distance)
    --     end
    --     distance-=1
    --   end
    -- end
  end
  rectfill(82,0,112,82,0)
  draw_stats()
end

function dungeondrawmonster(xeno,yako,zabo,distance)
  --logit('drawmonster ('..(xeno or 'nil')..','..(yako or 'nil')..','..(zabo or 'nil')..') '..(distance or 'nil'))
  if xeno>0 and yako>0 then
    local item=contents[xeno][yako]
    if item and item.z==zabo then
      local flipped=itemdrawprep(item)
      local distancemod=distance*3
      local shiftmod,sizemod=0,0
      -- sspr(88,8,8,8,28,0,25,40)
      if item.img==27 then
        shiftmod,sizemod=12,20
      elseif item.img==26 then
        shiftmod,sizemod=-12,20
      end
      local xoffset,yoffset=20+distancemod+(sizemod*(distance+1)/8),35-(3-distance)*shiftmod
      local imgsize=60-sizemod-distancemod*4
      palt(0,true)
      sspr(item.img%16*8,flr(item.img/16)*8,8,8,xoffset,yoffset,imgsize,imgsize,flipped)
      pal()
      if item.hitdisplay>0 then
        sspr(120,56,8,8,xoffset,yoffset,imgsize,imgsize)
        item.hitdisplay-=1
      end
      palt(0,false)
    end
  end
end

function msg_draw()
  cls()
  print(msg)
end

function world_draw()
  local maxx,maxy=curmap.maxx,curmap.maxy
  local minx,miny=curmap.minx,curmap.miny
  local width,height,wrap=curmap.width,curmap.height,curmap.wrap
  local xtraleft,xtratop,xtrawidth,xtraheight=0,0,0,0
  local scrtx,scrty=0,0
  local left=hero.x-halfwidth
  local right=hero.x+halfwidth
  if left<minx then
    xtrawidth=minx-left
    scrtx=xtrawidth
    if wrap then
      xtraleft=left%width+minx
    end
    left=minx
  elseif right>=maxx then
    if wrap then
      xtrawidth=fullwidth-right+maxx-1
      scrtx=xtrawidth
      xtraleft=left
      left=minx
      right=right%width+minx
    else
      xtrawidth=right-maxx+1
      right=maxx
    end
  end
  local top=hero.y-halfheight
  local bottom=hero.y+halfheight
  if top<miny then
    xtraheight=miny-top
    scrty=xtraheight
    if wrap then
      xtratop=top%height+miny
    end
    top=miny
  elseif bottom>=maxy then
    if wrap then
      xtraheight=fullheight-bottom+maxy-1
      scrty=xtraheight
      xtratop=top
      top=miny
      bottom=bottom%height+miny
    else
      xtraheight=bottom-maxy+1
      bottom=maxy
    end
  end
  local mainwidth=fullwidth-xtrawidth
  local mainheight=fullheight-xtraheight
  if cycle%16==0 then
    for sprnum=10,14,2 do
      animatespr(sprnum)
    end
  end
  cycle+=1
  cls()
  if wrap then
    if xtrawidth then
      -- we have an edge
      draw_map(xtraleft,top,0,scrty,xtrawidth,mainheight)
    end
    if xtraheight then
      -- we have a top
      draw_map(left,xtratop,scrtx,0,mainwidth,xtraheight)
    end
    if xtrawidth and xtraheight then
      -- we have a corner
      draw_map(xtraleft,xtratop,0,0,xtrawidth,xtraheight)
    end
  end
  draw_map(left,top,scrtx,scrty,mainwidth,mainheight)
  --update_lines{"lt"..left..","..top.." h("..hero.x..","..hero.y..") x("..xtrawidth..","..xtraheight..") m("..fullwidth-xtrawidth..","..fullheight-xtraheight..")"}
  palt(0,false)
  spr(hero.img+hero.facing,48,40)
  palt()
  if hero.hitdisplay>0 then
    spr(127,48,40)
    hero.hitdisplay-=1
  end
  draw_stats()
end

__gfx__
600ff000000003000000040000000600000000000000000000330000000005000005500000006000000000000000000000000000000000000000111011100000
600ff550030000000400000006000000000300000100100003333000005050500050050000066600000898000008a90001000101101010000011010001000011
60985555000000000000000000000000003330000033000003333330050500050050005000d00600008089000080980010101010010101011100001000101100
68895555000300000004000000060000000300300000000000330333500050000500000505000d00050500800508008000010000000000100000000000000000
f8999550000000030000000400000006000003330000100103003333000505005000550005050050050000500500005000000000000000000001110011000001
00909550000000000000000000000000003000300000033033330330005005005005005050005050505000055050000501000101101010000110100010000110
00400400000030000000400000006000033300001001000033330000050000500050000500005005000000050000000510101010010101011000010101011000
04400440300000004000000060000000003000000330000003300000000000000000000000000000000000000000000000010000000000100000000000000000
6660666088808880555055506660666055005550550055500000050055555555cccccccc44000044000000005545545555555555555555555555555500000000
000000000000000000000000000000005550555055505550050000005d0d0d05c000000c44444444004004000044440054444405544444055400000500055000
606660668088808850555055606560665055505550555055000000005d0d0d05c000000c00000000004444000040040054444405544444055400000504444440
000000000000000000000000000000000055505500505055000500005d0d0d05c000000c00000000004004000044440054444405544444055400000507777770
666066608880888055505550666066605550555055555550000000055d0d0d05c000000c00000000004444000040040054449405544494059490000507777770
000000000000000000000000000000005550055555500555000000005d0d0d05c000000c00000000004004000044440054444405544aa4055400000507777770
606660668088808850555055606660665055505550555055000050005d0d0d05c000000c44444444004444000040040054444405544444055400000500055000
0000000000000000000000000000000000550000005500005000000055555555cccccccc44000044554554550000000054444405544444055400000500055000
00600600000505000800008000511500000000000000400000777500555555555555555555555555555555555555555555555555555555555555555555555555
00600600005050508600006800055000550550550004440007500750000660000666660000666600066666000666666006666660006666000600006006666600
05600650550000500677776000055000666666660004250007500750006006000600006006000060060000600600000006000000060000600600006000060000
65500556000440050666666000555500656666560005240000757500060000600666660006000000060000600666600006666000060000000666666000060000
65666656004004000677776000555500656556560400444000075000066666600600006006000000060000600600000006000000060666600600006000060000
65655656054004506674476600544500666446664440424007777750060000600600006006000060060000600600000006000000060000600600006000060000
60600606504004006674476601544510666446664240424000075000060000600666660000666600066666000666666006000000006666000600006006666600
00600600004004006774477601544510000000004240000000075000555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
06666600060006000600000006600660060000600066660006666600006666000666660000666600066666000600006006000600060000600600006006000600
00006000060060000600000006066060066000600600006006000060060000600600006006000000000600000600006006000600060000600060060006000600
00006000066600000600000006000060060600600600006006000060060000600600006000666600000600000600006000606000060000600006600000606000
00006000060060000600000006000060060060600600006006666600060600600666660000000060000600000600006000606000006006000060060000060000
06006000060006000600000006000060060006600600006006000000060060600600006006000060000600000600006000060000006666000600006000060000
00660000060000600666660006000060060000600066660006000000006666000600006000666600000600000066660000060000006006000600006000060000
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555001111000011100000727000000206700066600007602000000440000004400000ff004000ff04000088aa000088aa00
06666660000000000000000000660000010000100100010066727660006776707777777007677600000440040004400400ff0404f0ff4040000770277e077000
0000060000000000000000000600600010000001100101006662666006770020777777700200776000d22d4400eeeeee066660046666604000e772200ee77200
0000600006666660000000000066000010011001101001016772776006770677777777707760776004dddd004eeeee006666666f666666f00eee220000ee2220
00060000000000000000000006006060101001011001100167727760006776707774777007677600044dd0000e666600f0660664006666407e0b9000000b9027
00600000000000000000000006000600001010011000000107727700400206770664660077602004000dd00000600600006600040066004000bb99900bbb9900
0666666000000000000000000066606000100010010000100444440004444444044444004444444000dddd0000600600006660040666604000b000ccdd000900
555555555555555555555555555555550001110000111100004440000044444000444000044444000dddddd00110011006666604066660400dd0000000000cc0
0000000000000000600ff000000ff000402222004022220000011006000110000002200500022000000ff000000ff00000000000044444400d000dd00000dd00
0000000000000000600ff550000ff000400ff200402ff00f600ff00f000ff000000ff00f000ff000000ff000f00ff00f0444444044a44a44d000dd00d00dd00d
000000000000000060ee555500eee550402222204022222260111110f111110600111110f111110500cccc00ffccccff44444444444664440d0ddd0dd0ddd0d0
00000000000000006eee5555feee5555f222222240222222f11110006011111ff11110000011111f0fccacf000ccac0044466444455555540d0dd00dd0dd00d0
0000000000000000fe1115506e1155554222220ff2222200010110006001100001011000000110000ffccff0000cc00055555555511111150d7d7dd00d7d7d00
00000000000000000010155060101550402222004222220000111100001111000088880000888800000cc000000cc000444444444444444400ddd00000ddd00d
00000000000000000040040060400550402222004022220000100100001001000040040000400400005005000050050044444444444444440d00d000dd00d0d0
0000000000000000044004400440044040222200402222000110011001100110044004400440044005500550055005500000000000000000d0000dd00dd00d00
40033000000330000006600000066000000550000005500040033000000330004003300000033000000000000000000000000000000000000858858000588500
40033000000330034006600000066006400550000005500540133100001331064003300000033003000000000500005000004440044400008808808808088080
43455430034554334000000000000060400110000001105043155130331551334350053033500533050000500500005000004004400400008845548888455488
33544533335445304056650006566500405115000551150033511533435115303355553343555530056006505560065500444400004444008848848888488488
00044003400440000600006040000000050110504001100000011006400110000005500340055000566556655065560504555440044555408808808888088088
00344300403443000006600640066000000110054001100000411400404114000035530040355300565885655658856505858540045858508854458888544588
003003004030030000500500405005000010010040100100004004000040040000300300003003000605506006055060045e54400445e5408080080888400488
03300330033003300650056006500560055005500550055004400440044004400330033003300330000000000600006000400400004004000880088084400448
0000000000000000000000000000000000100390001000930dd0dd0012001200000000000b0bb0b00003300000055000b0033000000088800066650000000000
0000000000000000400330000003300010000333100003330dd0dd000120201200000060b3bb703b003333000050050030355300000550080086850000900900
00bb008b00b00b804003300000033003000100330001033000ddd5000022220000600676b38b033b033b33306050050005333350005225006055550609088090
0b00b0b00b0b00b0431111300311113301033033013303300d5dd5d002277220067600609aa33b3b03333b3355555555008338030058850055065055008aa800
0b00b0b00b00b0b033511533335115300033330303333030d00dd00d0278872000600600aa13bb3b33b33333555555560535530b0505508060065006008aa800
00b00bb0b000bb00000110034001100000333303033330300011100d02277220000067609313313b33333b3050555505b0355350080008880056550009088090
000b00000b00000000311300403113000333330333333030011011000022220000000600b013310b033b3300005555000035530b888008080050050000900900
00000000000000000330033003300330033333033333303044000440000000000000000003311330000330000555555000355300808000000550055000000000
c0c0c0c040404040101010604040c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c0c0c0c0c040406060604040404040c0c0c0e0e0e0e0e0e0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e0c0c0c0c0404040606060104040c0c0e0e0e0e0e0e0e0e0c07070c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e0e0c0c0c01040104040404040c0c0e0e0e0e0e0e0e0e0e0c0101070c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e0e0e0c0c0c0104010404040c0c0e0e0e0e0e0e0e0e0e0e0c01010c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e0e0e0c0c0c0104010106010c0c0e0e0e0e0e0e0e0e0e0e0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0e0e0e0e0e0e000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c0c0c0c0c0c0c0c0c0c0c0c03080807080303030c0c0e0e0e0e0e000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000e0e0e0e0e0e0e0e0e0e0e0e0e0c0c0c0808070707070c0c0c0c080803090808030903030c0e0e0e0e0e000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000e0e0e0e0e0e0e0e0e0e0e0e0e0c0c0807070908090807070c0c070808080709080803030c0e0e0e0e0e000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000e0e0e0e0e0e0e0e0e0e0e0e0e0c0c0803090809080308070c0c0c07080809070803030c0c0e0e0e0e0e000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000e0e0e0e0e0e0e0e0e0e0e0e0c0c0c03030707030307070c0c0c0c0c0c080808030c0c0c0e0e0e0e0e0e000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000c0c0c0c0c0c0c0c0c0c0e0c0c0c0c0c0c03080307070c0c080808070c0c0c0c0c0c0c0c0e0e0e0e0e0e000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
810000c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0703090308070c0c0c0c0c0c0c0c0c0c0c0c0c000000000000000000000000000000000000091
__label__
00000000000000000033000000000000000000000000050000055000000550000005500000055000000005000000000000000000000550055055005500000066
00030000000300000333300001001000010010000050505000500500005005000050050000500500005050501010100010101000005000505050505050000600
00333000003330000333333000330000003300000505000500500050005000500050005000500050050500050101010101010101005000505050505050000600
00030030000300300033033300000000000000005000500005000005050000050500000505000005500050000000001000000010005000505050505050000606
00000333000003330300333300001001000010010005050050005500500055005000550050005500000505000000000000000000000550550050505550000666
00300030003000303333033000000330000003300050050050050050500500505005005050050050005005001010100010101000000000000000000000000000
03330000033300003333000010010000100100000500005000500005005000050050000500500005050000500101010101010101000000000000000000000000
00300000003000000330000003300000033000000000000000000000000000000000000000000000000000000000001000000010000000000000000000000000
00000300000000000000000000330000000005000005500000055000000550000000600000055000000005000000000000000000005000505050000000000666
03000000000300000003000003333000005050500050050000500500005005000006660000500500005050501010100000030000005000505050000000000606
000000000033300000333000033333300505000500500050005000500050005000d0060000500050050500050101010100333000005000505050000000000606
000300000003003000030030003303335000500005000005050000050500000505000d0005000005500050000000001000030030005000555050000000000606
00000003000003330000033303003333000505005000550050005500500055000505005050005500000505000000000000000333005550050055500000000666
00000000003000300030003033330330005005005005005050050050500500505000505050050050005005001010100000300030000000000000000000000000
00003000033300000333000033330000050000500050000500500005005000050000500500500005050000500101010103330000000000000000000000000000
30000000003000000030000003300000000000000000000000000000000000000000000000000000000000000000001000300000000000000000000000000000
00000300000003000000000000000000000000000000050000000500000005000005500000055000000003000000000008000080005050555066606060000000
03000000030000000003000000030000000300000050505000505050005050500050050000500500030000001010100086000068005050505000606060000000
00000000000000000033300000333000003330000505000505050005050500050050005000500050000000000101010106777760005550555066606660000000
00030000000300000003003000030030000300305000500050005000500050000500000505000005000300000000001006666660005050500060000060000000
00000003000000030000033300000333000003330005050000050500000505005000550050005500000000030000000006777760005050500066600060000000
00000000000000000030003000300030003000300050050000500500005005005005005050050050000000001010100066744766000000000000000000000000
00003000000030000333000003330000033300000500005005000050050000500050000500500005000030000101010166744766000000000000000000000000
30000000300000000030000000300000003000000000000000000000000000000000000000000000300000000000001067744776000000000000000000000000
00000300000003000000030000000000000000000000000000000000000005000005500000000300000003000000030000000300005550555066600000000000
03000000030000000300000000030000000300000003000000030000005050500050050003000000030000000300000003000000005550505060600000000000
00000000000000000000000000333000003330000033300000333000050500050050005000000000000000000000000000000000005050555066600000000000
00030000000300000003000000030030000300300003003000030030500050000500000500030000000300000003000000030000005050500060600000000000
00000003000000030000000300000333000003330000033300000333000505005000550000000003000000030000000300000003005050500066600000000000
00000000000000000000000000300030003000300030003000300030005005005005005000000000000000000000000000000000000000000000000000000000
00003000000030000000300003330000033300000333000003330000050000500050000500003000000030000000300000003000000000000000000000000000
30000000300000003000000000300000003000000030000000300000000000000000000030000000300000003000000030000000000000000000000000000000
00000000000003000000030000000300000003000000030000000000000005000000030000000300000003000000030000000300005550666066600000000000
10101000030000000300000003000000030000000300000000030000005050500300000003000000030000000300000003000000005500006060600000000000
01010101000000000000000000000000000000000000000000333000050500050000000000000000000000000000000000000000000550666060600000000000
00000010000300000003000000030000000300000003000000030030500050000003000000030000000300000003000000030000005550600060600000000000
00000000000000030000000300000003000000030000000300000333000505000000000300000003000000030000000300000003000500666066600000000000
10101000000000000000000000000000000000000000000000300030005005000000000000000000000000000000000000000000000000000000000000000000
01010101000030000000300000003000000030000000300003330000050000500000300000003000000030000000300000003000000000000000000000000000
00000010300000003000000030000000300000003000000000300000000000003000000030000000300000003000000030000000000000000000000000000000
000000000000000000000000000003000000030000000300600ff000000003000000030000000300000003000000030000000300005550666066600000000000
101010001010100010101000030000000300000003000000600ff550030000000300000003000000030000000300000003000000005000006060000000000000
01010101010101010101010100000000000000000000000060985555000000000000000000000000000000000000000000000000005500666066600000000000
00000010000000100000001000030000000300000003000068895555000300000003000000030000000300000003000000030000005000600000600000000000
000000000000000000000000000000030000000300000003f8999550000000030000000300000003000000030000000300000003005000666066600000000000
10101000101010001010100000000000000000000000000000909550000000000000000000000000000000000000000000000000000000000000000000000000
01010101010101010101010100003000000030000000300000400400000030000000300000003000000030000000300000003000000000000000000000000000
00000010000000100000001030000000300000003000000004400440300000003000000030000000300000003000000030000000000000000000000000000000
00000300000003000000030000000500000003000033000000000000000000000000000000000300000003000000000000000000005550505055500000000000
03000000030000000300000000505050030000000333300000030000000300000003000003000000030000001010100010101000005000505050500000000000
00000000000000000000000005050005000000000333333000333000003330000033300000000000000000000101010101010101005500050055500000000000
00030000000300000003000050005000000300000033033300030030000300300003003000030000000300000000001000000010005000505050000000000000
00000003000000030000000300050500000000030300333300000333000003330000033300000003000000030000000000000000005550505050000000000000
00000000000000000000000000500500000000003333033000300030003000300030003000000000000000001010100010101000000000000000000000000000
00003000000030000000300005000050000030003333000003330000033300000333000000003000000030000101010101010101000000000000000000000000
30000000300000003000000000000000300000000330000000300000003000000030000030000000300000000000001000000010006660000000000000000000
00000300000003000000050000000500000005000000000000000000003300000033000000000000000000000033000000000000006060000000000000000000
03000000030000000050505000505050005050500003000000030000033330000333300000030000101010000333300000030000006060000000000000000000
00000000000000000505000505050005050500050033300000333000033333300333333000333000010101010333333000333000006060000000000000000000
00030000000300005000500050005000500050000003003000030030003303330033033300030030000000100033033300030030006660000000000000000000
00000003000000030005050000050500000505000000033300000333030033330300333300000333000000000300333300000333000000000000000000000000
00000000000000000050050000500500005005000030003000300030333303303333033000300030101010003333033000300030000000000000000000000000
00003000000030000500005005000050050000500333000003330000333300003333000003330000010101013333000003330000000000000000000000000000
30000000300000000000000000000000000000000030000000300000033000000330000000300000000000100330000000300000005500555050500666000000
00000300000005000005500000055000000005000000030000330000003300000033000000000000000000000033000000000000005050500050500606000000
03000000005050500050050000500500005050500300000003333000033330000333300000030000101010000333300000030000005050550005000666000000
00000000050500050050005000500050050500050000000003333330033333300333333000333000010101010333333000333000005050500050500606000000
00030000500050000500000505000005500050000003000000330333003303330033033300030030000000100033033300030030005550555050500666000000
00000003000505005000550050005500000505000000000303003333030033330300333300000333000000000300333300000333000000000000000000000000
00000000005005005005005050050050005005000000000033330330333303303333033000300030101010003333033000300030000000000000000000000000
00003000050000500050000500500005050000500000300033330000333300003333000003330000010101013333000003330000000000000000000000000000
30000000000000000000000000000000000000003000000003300000033000000330000000300000000000100330000000300000005550550055500666000000
00000000000003000005500000050500000550000000050000000300000000000033000000330000003300000000000000000000000500505005000606000000
10101000030000000050050000505050005005000050505003000000000300000333300003333000033330000003000010101000000500505005000666000000
01010101000000000050005055000050005000500505000500000000003330000333333003333330033333300033300001010101000500505005000606000000
00000010000300000500000500044005050000055000500000030000000300300033033300330333003303330003003000000010005550505005000666000000
00000000000000035000550000400400500055000005050000000003000003330300333303003333030033330000033300000000000000000000000000000000
10101000000000005005005005400450500500500050050000000000003000303333033033330330333303300030003010101000000000000000000000000000
01010101000030000050000550400400005000050500005000003000033300003333000033330000333300000333000001010101000000000000000000000000
00000010300000000000000000400400000000000000000030000000003000000330000003300000033000000030000000000010000550555055500666000000
00000000000000000000000000000500000005000000000000000000000003000000000000000000000003000000030000000000005000050050500606000000
10101000101010001010100000505050005050501010100010101000030000000003000000030000030000000300000010101000005550050055000666000000
01010101010101010101010105050005050500050101010101010101000000000033300000333000000000000000000001010101000050050050500606000000
00000010000000100000001050005000500050000000001000000010000300000003003000030030000300000003000000000010005500050050500666000000
00000000000000000000000000050500000505000000000000000000000000030000033300000333000000030000000300000000000000000000000000000000
10101000101010001010100000500500005005001010100010101000000000000030003000300030000000000000000010101000000000000000000000000000
01010101010101010101010105000050050000500101010101010101000030000333000003330000000030000000300001010101000000000000000000000000
00000010000000100000001000000000000000000000001000000010300000000030000000300000300000003000000000000010000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0000000001010201020303830484048408000800080000080800000008080000000000000000080808080808080808080808080808080808080808080808080808080808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0e0c0c0c0c0c0c0c0c0c0c060c0e0e0e0e0c0c0c0c0e0e0c0c0c0803030303080e0e0e0e0e0c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e2610101010101010101010101010101010101010101010131010101010101010101010101010101010100c0c0c1010101014141414141414141414141414141414
0c0606060506060707070606040c0e0e0e0c06060c0c0c0708080809030809080c0e0e0e0e0c0707070c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e10010101010101010101010101010101010101010101040410111111111004010101040110392b27100c0c010101331014020202020202020202020202020214
0c04040605050708080808070c0c0c0e0c0c0606040104080809090303090908070c0e0e0e070303030707040c0c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0c10011010181010010101101010101010101010101010100410273833391001040104040410111111100c0c0c0101271014020202020202020202020202020214
0c01040406070808080908070c04040c0c0c040101010107080909030309030308070c0c0c0407030303030704050c0c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0c0c1001100c0c0c10010101101111111111111111111111100110111111111004040101040410363b2810020c0c0c01381014020202020202020202020202020214
0c01010404040707070808010c22010c0122010104040707070807090903080807070c0404040407040407040505050c0c06040c0c0c0c0e0e0e0e0e0e0c0c041001180c260c18010101102d35352a4231342f2d2e3a100110111111111c111111111104101111111d02020c0c0c2f1014020202020202020202020202020214
0101010104040404070801010101010c010101010101040707070807080807072107070401040406040404040605050c0606060c0c0c0c0c0e0e0e0e0e0c0c041001100c160c1001010110111111111111111111111110011010101010100101010111041011111110020202020c341014020202020202020202020202020214
0c0c010101010104070101010101010c010101010101010404070704060707070607060401010606060606040606050c0606060c0c0c0c0c0e0e0e0e0e0e0c0c10011010161010010101101111111111111111111111100110010101010101010101110110111111100202020202271014020202020202020202020202020214
0c0c0c0c010101010101010101010c0e040401010101010404010404040606060606060601010504060606060605050c060606040c0c0c0c0c0e0e0e0e0e0e0c10010101010101010101101111111111111111111111100110010101010101010101110110101c10101810181d18101014020202020202020202020202020214
0c01010107010604040401010c0c040c0404060406040101040401010404060606060606040505050404060605050c0c040606040c0c0c0c0c0e0e0e0e0e0e0c10011010101010010101101111101010101010101010100110101010101010100101111111111111111111111104041014020202020202020202020202020214
0c010107070704040606040c0604040c0c0406060601010101010401010104040606040401050c0c050505050c0c0c04040406040c0c0c0c0e0e0e0e0e0e0e0c1001101111111001010101111101010101010101010101011011111111111110010111040101010101010101011f041014020202020202020202020202020214
0c010708080701060606040c06040c0c010c0606010101010101010101040404040606010405050c0c0c050c0c050c04040406040c0c0c0c0e0e0e0e0e0e0c0c100110424242100101011111110101010101010101010101102d3835292b38100104110401010101010101010101011014020202020202020202020202020214
0c0c01082108070104060606040c0c0c01010c010101010101010101010c04040404040401050505050c0c0c05050c0c0406040c0c0c0c0c0c0c0e0e0e0e0c0c100110111111100101111111010101010101010101010101101111111111111c1111111101011010101010101010101014020202020202020202020202020214
0e0c0c0c07070c0c01040401010c0e0c010101010101010101010c0c0c0c0c0c0c05040404050505050505050505050c0404040c0c0c0c0e0e0e0e0e0e0e0c0c10011811111118010111110101101010101010101010100110111111111111100101041101011011111111111111111014020202020202020202020202020214
0e0e0e0c0c0c0c0c0c01010c0c0c0c0c0c01010101010104040c0c0c0e0e0c0c0c050505040505050505050505050c0c04040c0c0c0e0e0e0e0e0e0e0e0c0c0c1001101111111001111111010110111111111111111110011011111111111110010101110104102e3539362f3a27321014020202020202020202020202020214
0e0e0e0c0c0c0c05050101010c0505050c0c01010104010404040c0c0c0e0e0c0c0c050505050505050505050c0c0c0404070c0c0c0e0e0e0e0e0e0e0e0c0c0c10011011111110011111010101102c35352a3327383a100110101010101010100101011104041011111111111111111014020202020202020202020202020214
0e0e0c0c07070505040101050504040405050c05050101010404040c0c0c0c0c0c0c0505050505050505050c0c01010407070c0c0c0e0e0e0e0e0e0e0e0c0c0c10011011111111111111010101101111111111111111100110010101010101010101011111111c11111111111111111014141414141414141414141414141414
0e0c0c070707070404010505040404040101050101010101010101010c0c0c0505050505010101010505050c0c010407070c0c0c0e0e0e0e0e0e0e0e0e0c0c0c10011011111111111111010101101111111111111111100110010101010104060101011104041011111111111111111014020202020202020202020202020214
0c010707080804040101010101010101010101010101010101010601010101010505050101010c0c0c0c050c0c010407070c0c0c0e0e0e0e0e0e0e0e0e0e0c0c1001101111111001111101010110101010101111101010011001010106040104010101110401101c10101c10101c101014020202020202020202020202020214
0c0707080804010101070707070101010101010101010106040401040401060406010101010c0c01010c0c0c010107070c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0c100110332b2a10011111010101010101010111110101010110010101040101010601011101011011111011111011111014020202020202020202020202020214
0c0c08060401010107070202020707070707070101040606060604060606060404010101010c01010101010101070c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c1001101010101001111111111f111111111111110101010110010106040104040101011111011011111011111011111014020202020202020202020202020214
0c0c060806010407020202020202020202020707070404060606060606060406060101010119010101060404070c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c10010101010101010111111111111111111111110101010110010101040406010101040411041010101010101010101014020202020202020202020202020214
0c0c0c060401080702020202020202020202020207040404060606060404040404010101010c010106060404070c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c10040101010101010101041111110401010101010101010410010101010101010104040411040401010101010104011014020202020202020202020202020214
0c0c0c040101010702020202020202020202020208040404060604040406060c0c04040c0c0c0404060404070c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c10040401010101010104041111110404010101010101040410010101010101010104041111110404010104040101011014020202020202020202020202020214
0c0c0c01010104040702020202020202020202020704060606040406040606060c0c0c0c040606060404070c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c10101010101010101010041111110410101010101010101010101010101010101010101111111010101010101010101014020202020202020202020202020214
0c0c010101040408040702020202020202020707040404060c01060606040604040404040606060c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000014020202020202020202020202020214
0c01010101010404040407070707080807070704040404060c01010606010106060101010c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000014020202020202020202020202020214
0c0c0c0c06040601010406060404070707040505050404040c0c010101010101010c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000014020202020202020202020202020214
0707010c0404010101040406060404040404050505050c04040c0c0c0c0c0c0c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000014020202020202020202020202020214
080101190101010101060401010c0c0c050505050c0c0c0c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000014020202020202020202020202020214
0701010c0c0c0c0101040401010c0c0c0c0c0c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000014020202020202020202020202020214
0704010c0101010c0104060101040c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000014141414141414141414141414141414
0c040c0c040101010101010101040c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100002365024650206501e64000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000245202a6403075034660367703667034770326602f6602d75029650297502a640296402b7402c6502e6502f7502f6502d640296302563022720000000000000000000000000000000000000000000000
0001000017070160601505016050170501a06021060290702f0700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01020000276432f4732f4732f4732f4732f4732f4733b1733b2733b2733b2733b2733b2733b2733b2733b2733b2733b2333851500000000000000000000000000000000000000000000000000000000000000000
0002000002643024730347305473074730a4730d47311173162731b2731f27324273292732d27331273362733b2733e2333f51500000000000000000000000000000000000000000000000000000000000000000
