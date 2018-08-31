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

function makemetaobj(base,basetype)
  return setmetatable(base,{__index=base.objtype or basetype})
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
    img=70,
    imgalt=70,
    name="ship",
    facingmatters=true,
    facing=2
  },{
    img=92,
    imgalt=92,
    name="chest"
  },{
    img=74,
    flipimg=true,
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
    name="human",
    img=75,
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
  makemetaobj(basetypes[basetypenum],basetype)
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
  bestiary[beastnum].idtype=beastnum
  makemetaobj(bestiary[beastnum],beasttype)
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
  friendly=false,
  creatures={},
  songstart=17
}
maps={
  {
    name="saugus",
    enterx=13,
    entery=4,
    startx=92,
    starty=23,
    minx=80,
    miny=0,
    maxx=105,
    maxy=24,
    signs={
      {
        x=92,
        y=19,
        msg="welcome to saugus!"
      }
    },
    items={
      {x=84,y=4,objtype=ankhtype}
    },
    creatures={
      {objtype=guard,x=89,y=21},
      {objtype=medic,x=84,y=9},
      {objtype=armorer,x=95,y=3},
      {objtype=grocer,x=97,y=13},
      {objtype=shepherd,x=82,y=21},
      {objtype=guard,x=95,y=21}
    }
  },{
    name="lynn",
    enterx=17,
    entery=4,
    startx=116,
    starty=23,
    minx=104,
    miny=0,
    maxx=128,
    maxy=24,
    signs={
      {
        x=125,
        y=9,
        msg="marina for members only."
      }
    },
    items={
      {x=125,y=5,objtype=shiptype}
    },
    creatures={
      {objtype=guard,x=118,y=22},
      {objtype=smith,x=106,y=1},
      {objtype=barkeep,x=118,y=2},
      {objtype=grocer,x=107,y=9},
      {objtype=jester,x=106,y=16},
      {objtype=medic,x=122,y=12},
      {objtype=guard,x=114,y=22}
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
      {x=1,y=8,z=1,objtype=ladderuptype}
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

-- map 0 is special; it's the world map, the overview map.
maps[0]={
  name="world",
  minx=0,
  miny=0,
  maxx=80,
  maxy=64,
  wrap=true,
  newmonsters=10,
  maxmonsters=10,
  friendly=false,
  songstart=0
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

function setmap()
  local songstart=curmap.songstart
  curmap=maps[mapnum]
  contents=curmap.contents
  if(songstart and curmap.songstart)music(curmap.songstart)
  hero.hitdisplay=0
end

function initobjs()
  -- the creatures structure holds the live copy saying which
  -- creatures (both human and monster) are where in the world.
  -- individually they are instances of bestiary objects or
  -- occupation type objects.
  creatures={}

  -- perform the per-map data structure initializations.
  for mapnum=0,#maps do
    local maptype
    curmap=maps[mapnum]
    if mapnum>0 then
      if mapnum<3 then
        maptype=towntype
      else
        maptype=dungeontype
      end
      makemetaobj(curmap,maptype)
    end
    curmap.width=curmap.maxx-curmap.minx
    curmap.height=curmap.maxy-curmap.miny
    creatures[mapnum]={}
    curmap.contents={}
    for num=0,127 do
      curmap.contents[num]={}
    end
    for item in all(curmap.items) do
      curmap.contents[item.x][item.y]=makemetaobj(item)
    end
    for creature in all(curmap.creatures) do
      creature.mapnum=mapnum
      definemonster(creature)
    end
  end

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
    ship=false
  }
  hero.mp=hero.int
  hero.hp=hero.str*3

  -- make the map info global for efficiency
  mapnum=0
  setmap()

  -- creature 0 is the maelstrom and not really a creature at all,
  -- although it shares most creature behaviors.
  creatures[0]={}
  creatures[0][0]={
    img=69,
    imgseq=23,
    name="maelstrom",
    terrain={12,13,14,15},
    moveallowance=1,
    x=13,
    y=61,
    z=0,
    facing=1,
  }
  makemetaobj(creatures[0][0],anyobj)
  contents[13][61]=creatures[0][0]

  turn=0
  turnmade=false
  cycle=0
  _update=world_update
  _draw=world_draw
  draw_state=world_draw
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

attrlist={'armor','dmg','x','y','exp','lvl','str','int','dex','status','gold','food','mp','hp','ship','facing'}

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
      definemonster{mapnum=0,objtype=bestiary[creaturenum],x=dget(storagenum+1),y=dget(storagenum+2)}
      storagenum+=3
    else
      break
    end
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
  setmap()
  hero.facing=0
  _draw=world_draw
end

function inputprocessor(cmd)
  while true do
    local spots=calculatemoves(hero)
    local curobj=contents[hero.x][hero.y]
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
      if curmap.dungeon then
        if curobj and curobj.name=='ladder up' then
          if curmap.dungeon and hero.z==curmap.startz and hero.x==curmap.startx and hero.y==curmap.starty then
            msg="exiting "..curmap.name.."."
            exitdungeon()
          else
            msg="ascending."
            hero.z-=1
          end
        elseif curobj and curobj.name=='ladder down' then
          msg="descending."
          hero.z+=1
        end
      elseif hero.ship then
        msg="exiting ship."
        contents[hero.x][hero.y]=makemetaobj{facing=hero.facing,objtype=shiptype}
        hero.ship=false
        hero.img=0
        hero.facing=0
      elseif curobj and curobj.name=='ship' then
        msg="boarding ship."
        hero.img=curobj.img
        hero.facing=curobj.facing
        hero.ship=true
        contents[hero.x][hero.y]=nil
      else
        for loopmapnum=1,#maps do
          local loopmap=maps[loopmapnum]
          if mapnum==loopmap.mapnum and hero.x==loopmap.enterx and hero.y==loopmap.entery then
            -- enter the new location
            hero.x,hero.y=loopmap.startx,loopmap.starty
            mapnum=loopmapnum
            setmap()
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
      if hero.ship then
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

function definemonster(monster)
  local objtype=monster.objtype
  makemetaobj(monster)
  if(objtype.names)monster.name=objtype.names[flr(rnd(#objtype.names)+1)]
  --if(objtype.imgs)monster.img=objtype.imgs[flr(rnd(#objtype.imgs)+1)]
  if(objtype.colorsubs)monster.colorsub=objtype.colorsubs[flr(rnd(#objtype.colorsubs)+1)]
  monster.imgseq=flr(rnd(30))
  monster.imgalt=false
  add(creatures[monster.mapnum],monster)
  maps[monster.mapnum].contents[monster.x][monster.y]=monster
  logit("made "..monster.name.." at ("..monster.x..","..monster.y..","..(monster.z or 'nil')..")")
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
    for objtype in all(terrainmonsters[monsterspot]) do
      if rnd(200)<objtype.chance then
        definemonster{mapnum=mapnum,objtype=objtype,x=monsterx,y=monstery,z=monsterz}
        break
      end
    end
  end
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
    sfx(1,3,8)
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
  local content=contents[xeno][yako]
  --update_lines(""..xeno..","..yako.." "..newloc.." "..movecost.." "..fget(newloc))
  if hero.ship then
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
      setmap()
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
      setmap()
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
    if not hero.ship then
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
  elseif hero.ship then
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
        if creature.name=='pirate' then
          contents[x][y]=makemetaobj{
            facing=creature.facing,
            objtype=shiptype
          }
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
      sfx(1,3,8)
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
    dungeondrawobject(row[2].x,row[2].y,hero.z,3-depthindex)
  end
  rectfill(82,0,112,82,0)
  draw_stats()
end

function dungeondrawobject(xeno,yako,zabo,distance)
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
      sspr(item.img%16*8,flr(item.img/16)*8,8,8,xoffset,yoffset,imgsize,imgsize,flipped)
      pal()
      if item.hitdisplay>0 then
        palt(0,true)
        sspr(120,56,8,8,xoffset,yoffset,imgsize,imgsize)
        item.hitdisplay-=1
        palt(0,false)
      end
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
0060060000050500080000800051150000000000000040000077750000c01c005555555555555555555555555555555555555555555555555555555555555555
006006000050505086000068000550005505505500044400075007500c17c7100006600006666600006666000666660006666660066666600066660006000060
05600650550000500677776000055000666666660004250007500750010c70c00060060006000060060000600600006006000000060000000600006006000060
655005560004400506666660005555006566665600052400007575000c07c0100600006006666600060000000600006006666000066660000600000006666660
65666656004004000677776000555500656556560400444000075000010c70c00666666006000060060000000600006006000000060000000606666006000060
656556560540045066744766005445006664466644404240077777506c07c0160600006006000060060000600600006006000000060000000600006006000060
6060060650400400667447660154451066644666424042400007500066cccc660600006006666600006666000666660006666660060000000066660006000060
00600600004004006774477601544510000000004240000000075000566666655555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
06666600066666000600060006000000066006600600006000666600066666000066660006666600006666000666660006000060060006000600006006000060
00060000000060000600600006000000060660600660006006000060060000600600006006000060060000000006000006000060060006000600006000600600
00060000000060000666000006000000060000600606006006000060060000600600006006000060006666000006000006000060006060000600006000066000
00060000000060000600600006000000060000600600606006000060066666000606006006666600000000600006000006000060006060000060060000600600
00060000060060000600060006000000060000600600066006000060060000000600606006000060060000600006000006000060000600000066660006000060
06666600006600000600006006666600060000600600006000666600060000000066660006000060006666000006000000666600000600000060060006000060
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555550011110000111000007270000002067000666000076020000004400000ff004000ff04000088aa000088aa00
06000600066666600000000000000000006600000100001001000100667276600067767077777770076776000004400400ff0404f0ff4040000770277e077000
060006000000060000000000000000000600600010000001100101006662666006770020777777700200776000eeeeee066660046666604000e772200ee77200
00606000000060000666666000000000006600001001100110100101677277600677067777777770776077604eeeee006666666f666666f00eee220000ee2220
00060000000600000000000000000000060060601010010110011001677277600067767077747770076776000e666600f0660664006666407e0b9000000b9027
000600000060000000000000000000000600060000101001100000010772770040020677066466007760200400600600006600040066004000bb99900bbb9900
000600000666666000000000000000000066606000100010010000100444440004444444044444004444444000600600006660040666604000b000ccdd000900
55555555555555555555555555555555555555550001110000111100004440000044444000444000044444000110011006666604066660400dd0000000000cc0
000ff00000044000600ff000000ff000402222004022220000011006000110000002200500022000000ff000000ff00000000000044444400d000dd00000dd00
600ff00000044004600ff550000ff000400ff200402ff00f600ff00f000ff000000ff00f000ff000000ff000f00ff00f0444444044a44a44d000dd00d00dd00d
5999990600d22d4460ee555500eee550402222204022222260111110f111110600111110f111110500cccc00ffccccff44444444444664440d0ddd0dd0ddd0d0
5099999504dddd006eee5555feee5555f222222240222222f11110006011111ff11110000011111f0fccacf000ccac0044466444455555540d0dd00dd0dd00d0
00099005044dd000fe1115506e1155554222220ff2222200010110006001100001011000000110000ffccff0000cc00055555555511111150d7d7dd00d7d7d00
00111000000dd0000010155060101550402222004222220000111100001111000088880000888800000cc000000cc000444444444444444400ddd00000ddd00d
0010110000dddd000040040060400550402222004022220000100100001001000040040000400400005005000050050044444444444444440d00d000dd00d0d0
044004400dddddd0044004400440044040222200402222000110011001100110044004400440044005500550055005500000000000000000d0000dd00dd00d00
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
c0c0c0c040404040101010604040c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c0c0c0c0c040406060604040404040c0c0c0e0e0e0e0e0e0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e0c0c0c0c0404040606060104040c0c0e0e0e0e0e0e0e0e0c07070c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e0e0c0c0c01040104040404040c0c0e0e0e0e0e0e0e0e0e0c0101070c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e0e0e0c0c0c0104010404040c0c0e0e0e0e0e0e0e0e0e0e0c01010c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e0e0e0c0c0c0104010106010c0c0e0e0e0e0e0e0e0e0e0e0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e0e0e00000000000000000000000e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000
0000000000000000000000e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c0c0c0c0c0c0c0c0c0c0c0c03080807080303030c0c0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000
0000000000000000000000e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c0c0808070707070c0c0c0c080803090808030903030c0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000
0000000000000000000000e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c0807070908090807070c0c070808080709080803030c0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000
0000000000000000000000e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c0803090809080308070c0c0c07080809070803030c0c0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000
0000000000000000000000e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c0c03030707030307070c0c0c0c0c0c080808030c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000
0000000000000000000000e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e0e0c0c0c0c0c0c0c0c0c0c0e0c0c0c0c0c0c03080307070c0c080808070c0c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0703090308070c0c0c0c0c0c0c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e091000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000033000000000000000000000000050000055000000550000005500000055000000005000000000000000000000550055055005500000066
00030000000300000333300001001000010010000050505000500500005005000050050000500500005050500100010101000101005000505050505050000600
00333000003330000333333000330000003300000505000500500050005000500050005000500050050500051010101010101010005000505050505050000600
00030030000300300033033300000000000000005000500005000005050000050500000505000005500050000001000000010000005000505050505050000606
00000333000003330300333300001001000010010005050050005500500055005000550050005500000505000000000000000000000550550050505550000666
00300030003000303333033000000330000003300050050050050050500500505005005050050050005005000100010101000101000000000000000000000000
03330000033300003333000010010000100100000500005000500005005000050050000500500005050000501010101010101010000000000000000000000000
00300000003000000330000003300000033000000000000000000000000000000000000000000000000000000001000000010000000000000000000000000000
00000300000000000000000000330000000005000005500000055000000550000000600000055000000005000000000000000000005000505050000000000666
03000000000300000003000003333000005050500050050000500500005005000006660000500500005050500100010100030000005000505050000000000606
000000000033300000333000033333300505000500500050005000500050005000d0060000500050050500051010101000333000005000505050000000000606
000300000003003000030030003303335000500005000005050000050500000505000d0005000005500050000001000000030030005000555050000000000606
00000003000003330000033303003333000505005000550050005500500055000505005050005500000505000000000000000333005550050055500000000666
00000000003000300030003033330330005005005005005050050050500500505000505050050050005005000100010100300030000000000000000000000000
00003000033300000333000033330000050000500050000500500005005000050000500500500005050000501010101003330000000000000000000000000000
30000000003000000030000003300000000000000000000000000000000000000000000000000000000000000001000000300000000000000000000000000000
00000300000003000000000000000000000000000000050000000500000005000005500000055000000003000000000000000000005050555066606060000000
03000000030000000003000000030000000300000050505000505050005050500050050000500500030000000100010155055055005050505000606060000000
00000000000000000033300000333000003330000505000505050005050500050050005000500050000000001010101066666666005550555066606660000000
00030000000300000003003000030030000300305000500050005000500050000500000505000005000300000001000065666656005050500060000060000000
00000003000000030000033300000333000003330005050000050500000505005000550050005500000000030000000065655656005050500066600060000000
00000000000000000030003000300030003000300050050000500500005005005005005050050050000000000100010166644666000000000000000000000000
00003000000030000333000003330000033300000500005005000050050000500050000500500005000030001010101066644666000000000000000000000000
30000000300000000030000000300000003000000000000000000000000000000000000000000000300000000001000000000000000000000000000000000000
00000300000003000000030000000000000000000000000000000000000005000005500000000300000003000000030000000300005550555066600000000000
03000000030000000300000000030000000300000003000000030000005050500050050003000000030000000300000003000000005550505060600000000000
00000000000000000000000000333000003330000033300000333000050500050050005000000000000000000000000000000000005050555066600000000000
00030000000300000003000000030030000300300003003000030030500050000500000500030000000300000003000000030000005050500060600000000000
00000003000000030000000300000333000003330000033300000333000505005000550000000003000000030000000300000003005050500066600000000000
00000000000000000000000000300030003000300030003000300030005005005005005000000000000000000000000000000000000000000000000000000000
00003000000030000000300003330000033300000333000003330000050000500050000500003000000030000000300000003000000000000000000000000000
30000000300000003000000000300000003000000030000000300000000000000000000030000000300000003000000030000000000000000000000000000000
00000000000003000000030000000300000003000000030000000000000005000000030000000300000003000000030000000300005550666066600000000000
01000101030000000300000003000000030000000300000000030000005050500300000003000000030000000300000003000000005500006060600000000000
10101010000000000000000000000000000000000000000000333000050500050000000000000000000000000000000000000000000550666060600000000000
00010000000300000003000000030000000300000003000000030030500050000003000000030000000300000003000000030000005550600060600000000000
00000000000000030000000300000003000000030000000300000333000505000000000300000003000000030000000300000003000500666066600000000000
01000101000000000000000000000000000000000000000000300030005005000000000000000000000000000000000000000000000000000000000000000000
10101010000030000000300000003000000030000000300003330000050000500000300000003000000030000000300000003000000000000000000000000000
00010000300000003000000030000000300000003000000000300000000000003000000030000000300000003000000030000000000000000000000000000000
000000000000000000000000000003000000030000000300600ff000000003000000030000000300000003000000030000000300005550666066600000000000
010001010100010101000101030000000300000003000000600ff550030000000300000003000000030000000300000003000000005000006060000000000000
10101010101010101010101000000000000000000000000060985555000000000000000000000000000000000000000000000000005500666066600000000000
00010000000100000001000000030000000300000003000068895555000300000003000000030000000300000003000000030000005000600000600000000000
000000000000000000000000000000030000000300000003f8999550000000030000000300000003000000030000000300000003005000666066600000000000
01000101010001010100010100000000000000000000000000909550000000000000000000000000000000000000000000000000000000000000000000000000
10101010101010101010101000003000000030000000300000400400000030000000300000003000000030000000300000003000000000000000000000000000
00010000000100000001000030000000300000003000000004400440300000003000000030000000300000003000000030000000000000000000000000000000
00000300000003000000030000000500000003000033000000000000000000000000000000000300000003000000000000000000005550505055500000000000
03000000030000000300000000505050030000000333300000030000000300000003000003000000030000000100010101000101005000505050500000000000
00000000000000000000000005050005000000000333333000333000003330000033300000000000000000001010101010101010005500050055500000000000
00030000000300000003000050005000000300000033033300030030000300300003003000030000000300000001000000010000005000505050000000000000
00000003000000030000000300050500000000030300333300000333000003330000033300000003000000030000000000000000005550505050000000000000
00000000000000000000000000500500000000003333033000300030003000300030003000000000000000000100010101000101000000000000000000000000
00003000000030000000300005000050000030003333000003330000033300000333000000003000000030001010101010101010000000000000000000000000
30000000300000003000000000000000300000000330000000300000003000000030000030000000300000000001000000010000006660000000000000000000
00000300000003000000050000000500000005000000000000000000003300000033000000000000000000000033000000000000006060000000000000000000
03000000030000000050505000505050005050500003000000030000033330000333300000030000010001010333300000030000006060000000000000000000
00000000000000000505000505050005050500050033300000333000033333300333333000333000101010100333333000333000006060000000000000000000
00030000000300005000500050005000500050000003003000030030003303330033033300030030000100000033033300030030006660000000000000000000
00000003000000030005050000050500000505000000033300000333030033330300333300000333000000000300333300000333000000000000000000000000
00000000000000000050050000500500005005000030003000300030333303303333033000300030010001013333033000300030000000000000000000000000
00003000000030000500005005000050050000500333000003330000333300003333000003330000101010103333000003330000000000000000000000000000
30000000300000000000000000000000000000000030000000300000033000000330000000300000000100000330000000300000005500555050500666000000
00000300000005000005500000055000000005000000030000330000003300000033000000000000000000000033000000000000005050500050500606000000
03000000005050500050050000500500005050500300000003333000033330000333300000030000010001010333300000030000005050550005000666000000
00000000050500050050005000500050050500050000000003333330033333300333333000333000101010100333333000333000005050500050500606000000
00030000500050000500000505000005500050000003000000330333003303330033033300030030000100000033033300030030005550555050500666000000
00000003000505005000550050005500000505000000000303003333030033330300333300000333000000000300333300000333000000000000000000000000
00000000005005005005005050050050005005000000000033330330333303303333033000300030010001013333033000300030000000000000000000000000
00003000050000500050000500500005050000500000300033330000333300003333000003330000101010103333000003330000000000000000000000000000
30000000000000000000000000000000000000003000000003300000033000000330000000300000000100000330000000300000005550550055500666000000
00000000000003000005500000050500000550000000050000000300000000000033000000330000003300000000000000000000000500505005000606000000
01000101030000000050050000505050005005000050505003000000000300000333300003333000033330000003000001000101000500505005000666000000
10101010000000000050005055000050005000500505000500000000003330000333333003333330033333300033300010101010000500505005000606000000
00010000000300000500000500044005050000055000500000030000000300300033033300330333003303330003003000010000005550505005000666000000
00000000000000035000550000400400500055000005050000000003000003330300333303003333030033330000033300000000000000000000000000000000
01000101000000005005005005400450500500500050050000000000003000303333033033330330333303300030003001000101000000000000000000000000
10101010000030000050000550400400005000050500005000003000033300003333000033330000333300000333000010101010000000000000000000000000
00010000300000000000000000400400000000000000000030000000003000000330000003300000033000000030000000010000000550555055500666000000
00000000000000000000000000000500000005000000000000000000000003000000000000000000000003000000030000000000005000050050500606000000
01000101010001010100010100505050005050500100010101000101030000000003000000030000030000000300000001000101005550050055000666000000
10101010101010101010101005050005050500051010101010101010000000000033300000333000000000000000000010101010000050050050500606000000
00010000000100000001000050005000500050000001000000010000000300000003003000030030000300000003000000010000005500050050500666000000
00000000000000000000000000050500000505000000000000000000000000030000033300000333000000030000000300000000000000000000000000000000
01000101010001010100010100500500005005000100010101000101000000000030003000300030000000000000000001000101000000000000000000000000
10101010101010101010101005000050050000501010101010101010000030000333000003330000000030000000300010101010000000000000000000000000
00010000000100000001000000000000000000000001000000010000300000000030000000300000300000003000000000010000000000000000000000000000
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
0000000001010201020303830484048408000800080000080800000008080000000000000000080008080808080808080808080808080808080808080808080808080808080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0e0c0c0c0c0c0c0c0c0c0c060c0e0e0e0e0c0c0c0c0e0e0c0c0c0803030303080e0e0e0e0e0c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e2610101010101010101010101010101010101010101010131010101010101010101010101010101010100c0c0c10101010
0c0606060506060707070606040c0e0e0e0c06060c0c0c0708080809030809080c0e0e0e0e0c0707070c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e100101010101010101010101010101010101010101010404101111111110040101010401103a2c28100c0c0101013410
0c04040605050708080808070c0c0c0e0c0c0606040104080809090303090908070c0e0e0e070303030707040c0c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c100110101810100101011010101010101010101010101004102839343a1001040104040410111111100c0c0c01012810
0c01040406070808080908070c04040c0c0c040101010107080909030309030308070c0c0c0407030303030704050c0c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c1001100c0c0c10010101101111111111111111111111100110111111111004040101040410373c2910020c0c0c013910
0c01010404040707070808010c24010c0124010104040707070807090903080807070c0404040407040407040505050c0c06040c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c041001180c260c18010101102e36362b433235302e2f3b100110111111111c111111111104101111111d02020c0c0c3010
0101010104040404070801010101010c010101010101040707070807080807072107070401040406040404040605050c0606060c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c041001100c160c1001010110111111111111111111111110011010101010100101010111041011111110020202020c3510
0c0c010101010104070101010101010c010101010101010404070704060707070607060401010606060606040606050c0606060c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c100110101610100101011011111111111111111111111001100101010101010101011101101111111002020202022810
0c0c0c0c010101010101010101010c0e040401010101010404010404040606060606060601010504060606060605050c060606040c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c10010101010101010101101111111111111111111111100110010101010101010101110110101c10101810181d181010
0c01010107010604040401010c0c040c0404060406040101040401010404060606060606040505050404060605050c0c040606040c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c100110101010100101011011111010101010101010101001101010101010101001011111111111111111111111040410
0c010107070704040606040c0604040c0c0406060601010101010401010104040606040401050c0c050505050c0c0c04040406040c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c1001101111111001010101111101010101010101010101011011111111111110010111040101010101010101011f0410
0c010708080701060606040c06040c0c010c0606010101010101010101040404040606010405050c0c0c050c0c050c04040406040c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c100110434343100101011111110101010101010101010101102e39362a2c391001041104010101010101010101010110
0c0c01082108070104060606040c0c0c01010c010101010101010101010c04040404040401050505050c0c0c05050c0c0406040c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c100110111111100101111111010101010101010101010101101111111111111c11111111010110101010101010101010
0e0c0c0c07070c0c01040401010c0e0c010101010101010101010c0c0c0c0c0c0c05040404050505050505050505050c0404040c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c100118111111180101111101011010101010101010101001101111111111111001010411010110111111111111111110
0e0e0e0c0c0c0c0c0c01010c0c0c0c0c0c01010101010104040c0c0c0e0e0c0c0c050505040505050505050505050c0c04040c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c0c1001101111111001111111010110111111111111111110011011111111111110010101110104102f363a37303b283310
0e0e0e0c0c0c0c05050101010c0505050c0c01010104010404040c0c0c0e0e0c0c0c050505050505050505050c0c0c0404070c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c0c10011011111110011111010101102d36362b3428393b1001101010101010101001010111040410111111111111111110
0e0e0c0c07070505040101050504040405050c05050101010404040c0c0c0c0c0c0c0505050505050505050c0c01010407070c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c0c10011011111111111111010101101111111111111111100110010101010101010101011111111c111111111111111110
0e0c0c070707070404010505040404040101050101010101010101010c0c0c0505050505010101010505050c0c010407070c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c0c100110111111111111110101011011111111111111111001100101010101040601010111040410111111111111111110
0c010707080804040101010101010101010101010101010101010601010101010505050101010c0c0c0c050c0c010407070c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c1001101111111001111101010110101010101111101010011001010106040104010101110401101c10101c10101c1010
0c0707080804010101070707070101010101010101010106040401040401060406010101010c0c01010c0c0c010107070c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c100110342c2b100111110101010101010101111101010101100101010401010106010111010110111110111110111110
0c0c08060401010107070202020707070707070101040606060604060606060404010101010c01010101010101070c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c1001101010101001111111111f1111111111111101010101100101060401040401010111110110111110111110111110
0c0c060806010407020202020202020202020707070404060606060606060406060101010119010101060404070c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c100101010101010101111111111111111111111101010101100101010404060101010404110410101010101010101010
0c0c0c060401080702020202020202020202020207040404060606060404040404010101010c010106060404070c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c100401010101010101010411111104010101010101010104100101010101010101040404110404010101010101040110
0c0c0c040101010702020202020202020202020208040404060604040406060c0c04040c0c0c0404060404070c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c100404010101010101040411111104040101010101010404100101010101010101040411111104040101040401010110
0c0c0c01010104040702020202020202020202020704060606040406040606060c0c0c0c040606060404070c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c101010101010101010100411111104101010101010101010101010101010101010101011111110101010101010101010
0c0c010101040408040702020202020202020707040404060c01060606040604040404040606060c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c000000000000000000000000000000000000000000000000000000000000000014020202020202020202020202020214
0c01010101010404040407070707080807070704040404060c01010606010106060101010c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c000000000000000000000000000000000000000000000000000000000000000014020202020202020202020202020214
0c0c0c0c06040601010406060404070707040505050404040c0c010101010101010c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c000000000000000000000000000000000000000000000000000000000000000014020202020202020202020202020214
0707010c0404010101040406060404040404050505050c04040c0c0c0c0c0c0c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c000000000000000000000000000000000000000000000000000000000000000014020202020202020202020202020214
080101190101010101060401010c0c0c050505050c0c0c0c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c000000000000000000000000000000000000000000000000000000000000000014020202020202020202020202020214
0701010c0c0c0c0101040401010c0c0c0c0c0c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c000000000000000000000000000000000000000000000000000000000000000014020202020202020202020202020214
0704010c0101010c0104060101040c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c000000000000000000000000000000000000000000000000000000000000000014141414141414141414141414141414
0c040c0c040101010101010101040c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100002365024650206501e64000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000245202a6403075034660367703667034770326602f6602d75029650297502a640296402b7402c6502e6502f7502f6502d640296302563022720000000000000000000000000000000000000000000000
0001000017070160601505016050170501a06021060290702f0700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000276432f4732f4732f4732f4732f4732f4733b1733b2733b2733b2733b2733b2733b2733b2733b2733b2733b2333851500000000000000000000000000000000000000000000000000000000000000000
0002000002643024730347305473074730a4730d47311173162731b2731f27324273292732d27331273362733b2733e2333f51500000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01200000134201342013420134200e4200e4200e4200e420134201342013420134200e4200e4200e4200e420134201342013420134200e4200e4200e4200e420134201342013420134200e4200e4200e4200e420
01200000134201342013420134200e4200e4200e4200e420134201342013420134200e4200e4200e4200e42013420134201a4201a4200e4200e4201a4201a42013420134201a4201a4200e4200e4201a4201a420
0120000013420134201a4201a4200e4200e4201a4201a42013420134201a4201a4200e4200e4200e4200e42013420134201a4201a4200e4200e4201a4201a42013420134201a4201a4200e4200e4201a4201a420
0120000013420134201a4201a4200e4200e4201a4201a42013420134201a4201a4200e4200e4200e4200e420134201342013420134200e4200e4200e4200e420134201342013420134200e4200e4200e4200e420
01200000134201342013420134200e4200e4200e4200e420134201342013420134200e4200e4200e4200e420134201342013420134200e4200e4200e4200e420134201542016420184201a4201a4201a4201a420
01200000184201842018420184201142011420114201142016420184201a4201b4201d4201d4201e4201e4201f4201f4201f4201f420184201842018420184201a42016420154201342015420134201542013420
0120000013420134201a4201a4200e4200e4201a4201a42013420134201a4201a4200e4200e4201a4201a42013420134201a4201a4200e4200e4201a4201a42013420134201a4201a4200e4200e4200e4200e420
012000000c4200c420114201142016420164201742017420184201a4201c4201e4201f4201f4201d4201d4202042020420204202042021420204201e4201c4201e4201e4201e4201e42020420204202642026420
0120000025420214201c420214201942019420194201942024420214201c4202142018420184201842018420234201f4201a4201f42017420174201742017420224201f4201a4201f42016420164201842018420
012000000c4200c420114201142016420164201742017420184201a4201c4201e4201f4201f4201e4201e4202042020420204202042021420204201e4201c4201e4201e4201e4201e42020420204202642026420
012000001f4201f42013420134201a4201a4200e4200e420134201342013420004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
01200000004000040000400004000040000400004000040000400004000040000400004000040000400264202b4202d4202e4202b4202d4202e420304202d4202e4202e4203242032420304202e4202d42030420
012000002e4202d4202b4202e4202d4202d4202a4202a4202b4202b4202642026420244002440026420264202b4202d4202e4202b4202d4202e420304202d4202e4202e4203242032420304202e4202d42030420
012000002e4202d4202b4202e4202d4202d4202a4202a4202b4202b4202642026420244002440026420264202b4202d4202e4202e4202d4202e42030420304202e420304203242032420304202e4202d4202d420
012000002e4202d4202b4202b4202d4202b4202a4202a4202b4202d4202b4202b420264202642026420264202b4202d4202e4202b4202d4202e420304202d4202e4202e4203242032420304202e4202d42030420
012000002e4202d4202b4202e4202d4202d4202a4202a4202b4202b4202642026420244002440026420264202d4202b4202d4202b4202a4202a420334203342032420324202e4202e4202e4202a4002e4202e420
01200000304202e420304202e4202d4202d420334203342032420324202e4202e4202e4202e4202d4202d4202e4202e4202b4202b420294202942027420274202642026420264202642029420294202942029420
012000002b4202d4202e4202b4202d4202e420304202d4202e4202e4203242032420304202e4202d420304202e4202d4202b4202e4202d4202d4202a4202a4202b4202b420264202642000000000002642026420
012000002b4202d4202e4202e4202d4202e42030420304202e420304203242032420304202e4202d4202d4202e4202d4202b4202b4202d4202b4202a4202a4202b4202d4202b4202b42026420264202642026420
012000002742026420244202442026420264202642026420284202642024420244202642026420274202742028420284202f4202f420314202f4202d4202c4202d4202d4202d4202d4202f4202f4202c4202c420
012000002d420284202542028420214202142021420214202d420284202442028420214202142021420214202b4202642023420264201f4201f4201f4201f4202b4202642022420264201f4201f4201e4201e420
012000002742026420244202442026420264202642026420284202642024420244202642026420274202742028420284202f4202f420314202f4202d4202c4202d4202d4202d4202d4202f4202f4202c4202c420
012000002b4202d4202e4203042032420334203642032420374203742037420320001800022000210002100022000210001f0001f000210001f0001e0001e0000000000000000000000000000000000000000000
01200000220051a0051f005220051a0051f005210051e005000000000000000000000000000000000000000022420264202b42022420264202b4202d4202a4202b4202b4202e4202e4202d4202b4202a4202d420
012000002b4202b42026420264202a4202a42024420244202242026420214201f4201a4201b4201e420244202a420284202a42028420264202642030420304202e4202e4202b4202b4202b4202b4002b4202b420
012000002d4202b4202d4202b420294202942030420304202e4202e4202942029420294202942026420264202b4202b4202742027420214202142024420244202242022420224202242021420214202142021420
0120000022420264202b4202e420264202b4202d4202a4202b4202b4202e4202e4202d4202b4202a4202d4202b4202b42026420264202a4202a4202442024420224201a420224201f4201a4201b4201e42024420
012000002442022420214202142022420224201f4201f420244202342021420214202342023425234202342523420234202342023420284202842028420284002842028420274202742028420284202842028420
01200000284202542021420254201c4201c4201c4201c420284202442021420244201c4201c4201c4201c42026420234201f420234201a4201a4201a4201a42026420224201f420224201a4201a4251a4201a420
0120000022420214201f42022420214201f4201e420214201f4201f4201f420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011800000942009420104201042015420154201042010420114201142011420114200000000000000000000009420094201042010420154201542018420184201c4201c4201c4201c42000000000000000000000
011800000942009420104201042015420154201042010420114201142011420114200000000000000000000010420104201142011420104200e4200c4200b4200942009420094200942000000000000000000000
01180000000001a4201a42021420214202642026420214202142022420224202242000000000000000000000000001a4201a420214202142026420264201d420294202d4202d4202d42000000000000000000000
01180000000001a4201a420214202142026420264202142021420224202242022420000000000000000000000000021420214202242022420214201f4201d4201c4201a4201a4201a42000000000000000000000
01180000000000942009420104201042015420154201042010420114201142011420000000000000000000000000009420094201042010420154201542018420184201c4201c4201c42000000000000000000000
01180000000000942009420104201042015420154201042010420114201142011420000000000000000000000000010420104201142011420104200e4200c4200b42009420094200942000000000000000000000
011800002442024420244202442024420244202442024420214202142021420214200040000400004000040024420244202442024420244202442024420244201f4201f4201f4201f4201c000000000000000000
011800002442024420244202442024420244202442024420214202142021420214200000000000000000000020420204202042020420234202342023420234202442024420244202442000000000000000000000
01180000244202442028420284202d4202d420284202842027420274202742027420000000000000000000002142024420284202c4202d4202b42028420284202b4202b4202b4202b42000000000000000000000
011800002442024420284202842024420244202842028420294202942029420294200000000000000000000028420264202842024420264202442026420234202142021420214202142000000000000000000000
0118000015420154201c4201c42021420214201c4201c4201d4201d4201d4201d4200000000000000000000021420214201c4201c420214202142024420244202842028420284202842000000000000000000000
0118000015420154201c4201c42021420214201c4201c4201d4201d4201d4201d420000000000000000000001c4201c4201d4201d4201c4201a42018420174201542015420154201542000000000000000000000
011800000000015420154201c4201c42021420214201c4201c4201d4201d4201d4201d4200000000000000000000015420154201c4201c4202142021420244202442028420284202842028420000000000000000
011800000000015420154201c4201c42021420214201c4201c4201d4201d4201d4201d420000000000000000000001c4201c4201d4201d4201c4201a420184201742015420154201542015420000000000000000
01180000000003542035420394203942032420324203942039420364203642036420364000000000000000000000032420354203b4203142032420314203b4203b42030420304203042030400000000000000000
011800000000035420354203942039420324203242039420394203642036420364203640000000000000000000000394203742039420354203742035420374203442032420324203242032400000000000000000
011800000000024420244202442024420244202442024420000002142021420214200000000000000000000000000244202442024420244202442024420244200000020420204202042000000000000000000000
011800000000024420244202442024420244202442024420000002142021420214200000000000000000000000000204202042020420234202342023420244202442024420244202442000000000000000000000
011800003441034410344103441034410344103441034415334103341033410334100000000000000000000034410344103441034410344103441034410344153441034410344103441000000000000000000000
011800003441034410344103441034410344103441034415354103541035410354100000000000000000000034410344103441034410384103841038410384103941039410394103941000000000000000000000
01180000344103441039410394103c4103b410394103941539410394103941039410000000000000000000003041034410394103b4103c4103b41039410394103b4103b4103b4103b41000000000000000000000
01180000344103441039410394103c4103b410394103941539410394103941039410000000000000000000003c4103b4103c410394103b410394103b410384103941039410394103941000000000000000000000
011800001c4101c41023410234102841028410234102341024410244102441024410000000000000000000001d4101d410234102341028410284102b4102b4102f4102f4102f4102f41000000000000000000000
011800001c4101c41023410234102841028410234102341024410244102441024410000000000000000000002341023410244102441023410214101f4101e4101c4101c4101c4101c41000000000000000000000
01180000000002d4102d41034410344103941039410344103441035410354103541035410000000000000000000002d4102d410344103441039410394103c4103c41034410344103441034410000000000000000
01180000000002d4102d4103441034410394103941034410344103541035410354103541000000000000000000000344103441035410354103441032410304102f4102d4102d4102d4102d410000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 06114344
00 07124344
00 08134344
00 09141d44
00 0a151e44
00 0b161f44
00 0c172044
00 0c182044
00 0d192144
00 0e1a2244
00 06174344
00 0c172044
00 0d1b2144
00 0e1a2244
00 06182044
00 0c182044
02 101c2344
01 246a4344
00 25424344
00 242a3644
00 252b3744
00 242c3844
00 252d3944
00 242e3a44
00 252f3b44
00 24303c44
00 25313d44
00 26324344
00 27334344
00 28344344
02 29354344

