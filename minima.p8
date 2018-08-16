pico-8 cartridge // http://www.pico-8.com
version 10
__lua__
-- minima
-- by feneric

-- initialization data

fullheight,fullwidth=11,13
halfheight,halfwidth=5,6

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

-- creature is our most basic animate object. all living things
-- indirectly inherit from it to save space and reduce redundancy.
creature={
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
  z=0
}
setmetatable(creature,{__index=anyobj})

-- human isn't meant to be used directly; all occupation
-- types inherit from it. actual humans in the game are
-- instances of the occupation types.
human={
  img=74,
  name="person",
  armor=0,
  hostile=false,
  gold=5,
  exp=1
}
setmetatable(human,{__index=creature})

fighter={
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
}
setmetatable(fighter,{__index=human})

guard={
  img=90,
  colorsubs={{},{{15,4}}},
  name="guard",
  moveallowance=0,
  hp=18,
  armor=3,
  talk={"behave yourself.","i protect good citizens."}
}
setmetatable(guard,{__index=fighter})

merchant={
  img=75,
  flipimg=true,
  colorsubs={{},{{1,4},{4,15},{6,1},{14,13}},{{1,4},{6,5},{14,10}},{{1,4},{4,15},{6,1},{14,3}}},
  name="merchant",
  talk={"buy my wares!","consume!","stuff makes you happy!"}
}
setmetatable(merchant,{__index=human})

grocer={
  name="grocer",
  merch='food'
}
setmetatable(grocer,{__index=merchant})

armorer={
  name="armorer",
  merch='armor'
}
setmetatable(armorer,{__index=merchant})

smith={
  name="smith",
  merch='weapons'
}
setmetatable(smith,{__index=merchant})

medic={
  name="medic",
  merch='hospital'
}
setmetatable(medic,{__index=merchant})

lady={
  flipimg=true,
  colorsubs={{},{{2,9},{4,15},{13,14}},{{2,10},{4,15},{13,9}},{{2,11},{13,3}}},
  name="lady",
  talk={"pardon me.","well i never."}
}
setmetatable(lady,{__index=human})

barkeep={
  name="barkeep",
  merch='bar'
}
setmetatable(barkeep,{__index=lady})

shepherd={
  img=76,
  name="shepherd",
  colorsubs={{},{{6,5},{15,4}},{{6,5}},{{15,4}}},
  talk={"i like sheep.","the open air is nice."}
}
setmetatable(shepherd,{__index=human})

jester={
  img=78,
  name="jester",
  dex=12,
  talk={"ho ho ho!","ha ha ha!"}
}
setmetatable(jester,{__index=human})

villain={
  name="villain",
  armor=1,
  hostile=true,
  gold=15,
  exp=5,
  talk={"stand and deliver!","you shall die!"}
}
setmetatable(villain,{__index=human})

-- orc isn't meant to be used directly; other orclike
-- creatures inherit from it.
orc={
  int=6,
  talk={"urg!","grar!"}
}
setmetatable(orc,{__index=creature})

-- undead isn't meant to be used directly; all undead
-- creatures inherit from it.
undead={
  int=7,
  dmg=6,
  dex=6,
  gold=5
}
setmetatable(undead,{__index=creature})

-- animal isn't meant to be used directly; all non-sentient
-- animal types inherit from it.
animal={
  int=3,
  dex=10,
  armor=0,
  hostile=nil,
  gold=0
}
setmetatable(animal,{__index=creature})

-- the bestiary holds all the different monster types that can
-- be encountered in the game. it builds off of the basic types
-- already defined so most do not need many changes. actual
-- monsters in the game are instances of creatures found in the
-- bestiary.
bestiary={}

bestiary[1]={
  img=96,
  names={"orc","hobgoblin"},
  chance=5
}
setmetatable(bestiary[1],{__index=orc})

bestiary[2]={
  img=98,
  name="skeleton",
  gold=12,
  chance=5
}
setmetatable(bestiary[2],{__index=undead})

bestiary[3]={
  img=100,
  names={"zombie","wight","ghoul"},
  hp=10,
  dmg=4,
  chance=3
}
setmetatable(bestiary[3],{__index=undead})

bestiary[4]={
  img=102,
  name="troll",
  hp=15,
  gold=10,
  exp=4,
  chance=4
}
setmetatable(bestiary[4],{__index=orc})

bestiary[5]={
  img=104,
  names={"hobgoblin","bugbear"},
  hp=15,
  gold=8,
  exp=3,
  chance=4
}
setmetatable(bestiary[5],{__index=orc})

bestiary[6]={
  img=106,
  name="giant spider",
  hp=18,
  poison=true,
  hostile=true,
  gold=8,
  exp=5,
  chance=3
}
setmetatable(bestiary[6],{__index=animal})

bestiary[7]={
  img=108,
  name="giant rat",
  hp=5,
  dmg=4,
  poison=true,
  eat=true,
  exp=2,
  chance=3
}
setmetatable(bestiary[7],{__index=animal})

bestiary[8]={
  img=110,
  names={"daemon","devil"},
  hp=50,
  dmg=10,
  terrain={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,22,25,26,27,30,31,33,35},
  gold=25,
  exp=15,
  chance=1
}
setmetatable(bestiary[8],{__index=creature})

bestiary[9]={
  img=112,
  names={"giant snake","giant asp","serpent"},
  hp=20,
  poison=true,
  terrain={4,5,6,7},
  exp=6,
  chance=1
}
setmetatable(bestiary[9],{__index=animal})

bestiary[10]={
  img=114,
  names={"goblin","kobold"},
  hp=8,
  dmg=3,
  gold=5,
  exp=1,
  chance=5
}
setmetatable(bestiary[10],{__index=orc})

bestiary[11]={
  img=116,
  name="sea serpent",
  hp=45,
  hostile=true,
  terrain={5,12,13,14,15,25},
  exp=10,
  chance=5
}
setmetatable(bestiary[11],{__index=animal})

bestiary[12]={
  img=123,
  flipimg=true,
  names={"phantom","ghost","wraith"},
  hp=15,
  dmg=3,
  terrain={1,2,3,4,5,6,7,8,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,33,35},
  exp=7,
  chance=3,
  talk={'boooo!','feeear me!'}
}
setmetatable(bestiary[12],{__index=undead})

bestiary[13]={
  img=125,
  flipimg=true,
  name="megascorpion",
  hp=12,
  dmg=4,
  poison=true,
  hostile=true,
  exp=5,
  chance=1
}
setmetatable(bestiary[13],{__index=animal})

bestiary[14]={
  --imgs={76,78},
  img=84,
  colorsubs={{},{{2,8},{15,4}}},
  names={"warlock","necromancer","sorceror"},
  int=10,
  exp=10,
  chance=1,
  talk={"i hex you!","a curse on you!"}
}
setmetatable(bestiary[14],{__index=villain})

bestiary[15]={
  --imgs={84,86},
  img=88,
  colorsubs={{},{{1,5},{8,2},{4,1},{2,12},{15,4}}},
  names={"rogue","bandit","cutpurse"},
  dex=10,
  dmg=6,
  thief=true,
  chance=2
}
setmetatable(bestiary[15],{__index=villain})

bestiary[16]={
  --imgs={80,82},
  img=86,
  colorsubs={{},{{1,5},{15,4}}},
  names={"ninja","assassin"},
  poison=true,
  gold=10,
  exp=8,
  chance=1,
  talk={"you shall die at my hands.","you are no match for me."}
}
setmetatable(bestiary[16],{__index=villain})

bestiary[17]={
  img=120,
  flipimg=true,
  name="wisp",
  terrain={4,5,6},
  exp=3,
  chance=1
}
setmetatable(bestiary[17],{__index=creature})

bestiary[18]={
  img=121,
  flipimg=true,
  names={"dragon","drake","wyvern"},
  terrain={1,2,3,4,5,6,7,8,17,18,22,25,26,27,30,31,33,35},
  hp=50,
  dmg=10,
  gold=20,
  exp=17,
  chance=1
}
setmetatable(bestiary[18],{__index=creature})

bestiary[19]={
  img=122,
  colorsubs={{},{{3,9},{11,10}},{{3,14},{11,15}}},
  flipimg=true,
  names={"slime","jelly","blob"},
  gold=5,
  terrain={17,22,23},
  eat=true,
  exp=2,
  chance=3
}
setmetatable(bestiary[19],{__index=animal})

bestiary[20]={
  img=92,
  name="mimic",
  moveallowance=0,
  thief=true,
  gold=12,
  terrain={17,22},
  exp=4,
  chance=1
}
setmetatable(bestiary[20],{__index=creature})

bestiary[21]={
  img=124,
  flipimg=true,
  name="reaper",
  moveallowance=0,
  gold=8,
  terrain={17,22},
  exp=5,
  chance=2
}
setmetatable(bestiary[21],{__index=creature})

bestiary[22]={
  img=69,
  colorsubs={{{6,5},{7,6}}},
  flipimg=false,
  name="pirates",
  facingmatters=true,
  facing=1,
  terrain={12,13,14,15},
  exp=8,
  chance=1
}
setmetatable(bestiary[22],{__index=creature})

bestiary[23]={
  img=94,
  names={"kraken","giant squid"},
  hp=50,
  hostile=true,
  terrain={12,13,14,15},
  exp=8,
  chance=2
}
setmetatable(bestiary[23],{__index=animal})

bestiary[24]={
  img=118,
  flipimg=true,
  name="ettin",
  hp=20,
  dmg=8,
  exp=6,
  chance=1
}
setmetatable(bestiary[24],{__index=orc})

bestiary[25]={
  img=119,
  colorsubs={{},{{2,14},{1,4}}},
  flipimg=true,
  names={"gazer","beholder"},
  hp=12,
  terrain={17,22},
  exp=4,
  chance=1
}
setmetatable(bestiary[25],{__index=creature})

ankhtype={
  img=38,
  imgalt=38,
  name="ankh",
  talk={"yes, ankhs can talk.","shrines make good landmarks."}
}
setmetatable(ankhtype,{__index=anyobj})

shiptype={
  img=69,
  imgalt=69,
  name="ship",
  facingmatters=true,
  facing=2
}
setmetatable(shiptype,{__index=anyobj})

function purchase(itemtype,attribute)
  cmd,mapnum,curmap=yield()
  if itemtype[cmd] then
    desireditem=itemtype[cmd]
    logit("attr "..hero[attribute].." num "..desireditem.num)
    if hero[attribute]>=desireditem.num then
      return {"that is not an upgrade."}
    elseif hero.gold>=desireditem.price then
      hero.gold-=desireditem.price
      hero[attribute]=desireditem.num
      return {"the "..desireditem.name.." is yours."}
    else
      return {"you cannot afford that."}
    end
  else
    return {"no sale."}
  end
end

shop={
  food=function()
    update_lines{"$15 for 25 food; a\80\80\82\79\86\69? "}
    cmd,mapnum,curmap=yield()
    if cmd=='a' then
      if hero.gold>=15 then
        hero.gold-=15
        hero.food=min(hero.food+25,32767)
        return {"you got more food."}
      else
        return {"you cannot afford that."}
      end
    else
      return {"no sale."}
    end
  end,

  armor=function()
    update_lines{"buy \131cloth $12, \139leather $99,","\145chain $300, or \148plate $950: "}
    return purchase(armors,'armor')
  end,
  weapons=function()
    update_lines{"buy d\65\71\71\69\82 $8, c\76\85\66 $40,","a\88\69 $75, or s\87\79\82\68 $150: "}
    return purchase(weapons,'dmg')
  end,
  hospital=function()
    return {"choose m\69\68\73\67 ($8), c\85\82\69 ($10),","or s\65\86\73\79\82 ($15): "}
  end,
  bar=function()
    return {"$5 per drink; a\65\80\80\82\79\86\69? "}
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

contents={}
for num=0,127 do
  contents[num]={}
end

-- the maps structure holds information about all of the regular
-- places in the game, dungeons as well as towns.
maps={
  {
    name="saugus",
    mapnum=0,
    enterx=13,
    entery=4,
    startx=76,
    starty=23,
    minx=64,
    miny=0,
    maxx=89,
    maxy=24,
    newmonsters=0,
    maxmonsters=0,
    friendly=true
  },
  {
    name="lynn",
    mapnum=0,
    enterx=17,
    entery=4,
    startx=100,
    starty=23,
    minx=88,
    miny=0,
    maxx=112,
    maxy=24,
    newmonsters=0,
    maxmonsters=0,
    friendly=true
  },
  {
    name="nibiru",
    mapnum=0,
    enterx=4,
    entery=11,
    dungeon=true,
    startx=1,
    starty=8,
    startz=1,
    startfacing=1,
    minx=1,
    miny=1,
    maxx=9,
    maxy=9,
    newmonsters=25,
    maxmonsters=5,
    --maxmonsters=15,
    friendly=false,
    levels={
      {0x0000,0x3ffe,0x0300,0x3030,0x3ffc,0x3300,0x33fc,0x00c0},
      {0x0000,0xcccd,0x0330,0x3030,0x3cfc,0x0300,0x3fcc,0x00c0}
    }
  }
}
-- map 0 is special; it's the world map, the overview map.
maps[0]={
  name="world",
  minx=0,
  miny=0,
  maxx=64,
  maxy=64,
  wrap=true,
  newmonsters=10,
  maxmonsters=5,
  --maxmonsters=50,
  friendly=false
}

for mapnum=0,#maps do
   maps[mapnum].width=maps[mapnum].maxx-maps[mapnum].minx
   maps[mapnum].height=maps[mapnum].maxy-maps[mapnum].miny
end

-- all the signs found in all the maps are defined here with
-- their positions and text.
signs={
  {
    {
      x=76,
      y=19,
      msg="welcome to saugus!"
    },
  },
  {
    {
      x=109,
      y=9,
      msg="marina for members only."
    }
  }
}

-- armor definitions
armors={
  south={name='cloth',num=8,price=12},
  west={name='leather',num=23,price=99},
  east={name='chain',num=40,price=300},
  north={name='plate',num=90,price=950}
}

-- weapon definitions
weapons={
  d={name='dagger',num=8,price=8},
  c={name='club',num=12,price=40},
  a={name='axe',num=18,price=75},
  s={name='sword',num=30,price=150}
}

-- spell definitions
spells={
  a={name='attack',mp=3,amount=10},
  x={name='medic',mp=5,amount=12,price=20},
  c={name='cure',mp=7,price=30},
  tab={name='wound',mp=11,amount=50},
  s={name='savior',mp=13,amount=60,price=100}
}

-- the items structure holds the live copy saying which items are
-- where in the world.
items={
   {{}},
   {{}},
   {}
}
items[0]={}
setmetatable(items[1][1],{__index=ankhtype})
contents[67][3]=items[1][1]
setmetatable(items[2][1],{__index=shiptype})
contents[109][5]=items[2][1]

-- the creatures structure holds the live copy saying which
-- creatures (both human and monster) are where in the world.
-- individually they are instances of bestiary objects or
-- occupation type objects.
creatures={
 {},
 {},
 {}
}
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
  facing=1
}
setmetatable(creatures[0][0],{__index=anyobj})
contents[13][61]=creatures[0][0]

-- the hero is the player character. although human, it has
-- enough differences that there is no advantage to inheriting
-- the human type.
hero={
  img=0,
  mapnum=0,
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
  health="g",
  hitdisplay=0,
  facing=0,
  gold=10,
  food=25,
  movepayment=0,
  items={}
}
hero.mp=hero.int
hero.hp=hero.str*2

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
  turn=0
  turnmade=false
  cycle=0
  menuitem(1,"save game",savegame)
  menuitem(2,"load game",loadgame)
  menuitem(3,"list commands",listcommands)
  processinput=cocreate(inputprocessor)
  _update=world_update
  _draw=world_draw
  definemonster(1,guard,73,21)
  definemonster(2,guard,102,22)
  definemonster(1,medic,68,8)
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

function listcommands()
  update_lines{"sorry, not implemented yet"}
end

function savegame()
  update_lines{"sorry, not implemented yet"}
end

function loadgame()
  update_lines{"sorry, not implemented yet"}
end

buttons={
  "west",
  "east",
  "north",
  "south",
  "c",
  "x",
  "p",
  "?",
  "s",
  "f",
  "e",
  "d",
  "tab",
  "a"
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
  if hero.mp>=spells[cmd].mp then
    hero.mp-=spells[cmd].mp
    update_lines{spells[cmd].name.." is cast! "..(extra or '')}
    return true
  else
    update_lines{"not enough mp."}
    return false
  end
end

function inputprocessor(cmd,mapnum,curmap)
  while true do
    local spots=calculatemoves(mapnum,curmap,hero)
    if cmd=='west' then
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
      update_lines{"choose a\84\84\65\67\75, m\69\68\73\67, c\85\82\69,","w\79\85\78\68, s\65\86\73\79\82: "}
      cmd,mapnum,curmap=yield()
      if cmd=='c' then
        -- cast cure
        if(checkspell(cmd))hero.health='g'
      elseif cmd=='x' or cmd=='s' then
        -- cast healing
        if(checkspell(cmd))increasehp(spells[cmd].amount)
      elseif cmd=='tab' or cmd=='a' then
        -- cast offensive spell
        if checkspell(cmd,'dir:') then
          local spelldamage=spells[cmd].amount
          if not getdirection(spots,mapnum,curmap,attack_results,spelldamage) then
            update_lines{'cast at what?'}
          end
        end
      else
        update_lines{"4 (cast "..cmd..")"}
      end
      turnmade=true
    elseif cmd=='x' then
      update_lines{"examine dir:"}
      if not getdirection(spots,mapnum,curmap,look_results) then
        if cmd=='x' then
          local response={"search","you find nothing."}
          signcontents=check_sign(hero.x,hero.y,mapnum)
          if signcontents then
            response={"read sign",signcontents}
          else
            local mapitems=items[mapnum]
            for objnum=1,#mapitems do
              if hero.x==mapitems[objnum].x and hero.y==mapitems[objnum].y then
                response[2]=mapitems[objnum].msg
                add(hero.items,mapitems[objnum])
                mapitems[objnum].x=nil
                mapitems[objnum].y=nil
              end
            end
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
        hero.x,hero.y,hero.z=curmap.enterx,curmap.entery,0
        hero.mapnum=curmap.mapnum
        hero.facing=0
        hero.hitdisplay=0
        _draw=world_draw
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
          if hero.mapnum==loopmap.mapnum and hero.x==loopmap.enterx and hero.y==loopmap.entery then
            -- enter the new location
            hero.x,hero.y=loopmap.startx,loopmap.starty
            hero.mapnum=loopmapnum
            msg="entering "..loopmap.name.."."
            logit("new hero mapnum: "..hero.mapnum)
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
      if not getdirection(spots,mapnum,curmap,dialog_results) then
        update_lines{"dialog: huh?"}
      end
      turnmade=true
    elseif cmd=='tab' then
      update_lines{
        "status: hp"..hero.hp.." mp"..hero.mp.." xp"..hero.exp.." $"..hero.gold,
        "l"..flr(hero.exp/100).." dex"..hero.dex.." int"..hero.int.." str"..hero.str.." "..hero.health
      }
    elseif cmd=='a' then
      if checkifinship() then
        update_lines{"fire dir:"}
      else
        update_lines{"attack dir:"}
      end
      if not getdirection(spots,mapnum,curmap,attack_results) then
        update_lines{"attack: huh?"}
      end
      turnmade=true
    end
    cmd,mapnum,curmap=yield()
  end
end

function getdirection(spots,mapnum,curmap,resultfunc,magic,adir)
  if curmap.dungeon then
    adir='ahead'
  elseif not adir then
    adir,mapnum,curmap=yield()
  end
  if adir=='east' or hero.facing==2 then
    resultfunc(adir,spots[4],hero.y,mapnum)
  elseif adir=='west' or hero.facing==4 then
    resultfunc(adir,spots[2],hero.y,mapnum)
  elseif adir=='north' or hero.facing==1 then
    resultfunc(adir,hero.x,spots[1],mapnum)
  elseif adir=='south' or hero.facing==3 then
    resultfunc(adir,hero.x,spots[3],mapnum)
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

function definemonster(mapnum,monstertype,monsterx,monstery,monsterz)
  local monster={x=monsterx,y=monstery,z=monsterz}
  setmetatable(monster,{__index=monstertype})
  if(monstertype.names)monster.name=monstertype.names[flr(rnd(#monstertype.names)+1)]
  --if(monstertype.imgs)monster.img=monstertype.imgs[flr(rnd(#monstertype.imgs)+1)]
  if(monstertype.colorsubs)monster.colorsub=monstertype.colorsubs[flr(rnd(#monstertype.colorsubs+1))]
  monster.imgseq=flr(rnd(30))
  monster.imgalt=false
  if monsterz then
    monster.z=monsterz
  end
  add(creatures[mapnum],monster)
  contents[monsterx][monstery]=monster
  logit("made "..(monster.name or monsternum).." at ("..monster.x..","..monster.y..","..(monster.z or 'nil')..")")
  return monster
end

function create_monster(mapnum,curmap)
  local monsterx=flr(rnd(curmap.width))+curmap.minx
  local monstery=flr(rnd(curmap.height))+curmap.miny
  local monsterz=curmap.dungeon and flr(rnd(#curmap.levels))+1 or 0
  if contents[monsterx][monstery] or monsterx==hero.x and monstery==hero.y and monsterz==hero.z then
    -- don't create a monster where there already is one
    monsterx=nil
  end
  if monsterx then
    local monsterspot=mget(monsterx,monstery)
    if curmap.dungeon then
      monsterspot=getdungeonblockterrain(curmap,monsterx,monstery,monsterz)
    end
    --logit('possible monster location: ('..monsterx..','..monstery..','..(monsterz or 'nil')..') terrain '..monsterspot)
    for monstertype in all(terrainmonsters[monsterspot]) do
      if rnd(100)<monstertype.chance then
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
    update_lines{"you've been killed!"}
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

function increasexp(amount)
  hero.exp=min(hero.exp+amount,32767)
  if hero.exp>=hero.lvl^2*10 then
    hero.lvl+=1
    increasehp(25)
    update_lines{"you went up a level!"}
  end
end

function increasegold(amount)
  hero.gold=min(hero.gold+amount,32767)
end

function increasemp(amount)
  hero.mp=min(hero.mp+amount,hero.int*(hero.lvl+1),32767)
end

function increasehp(amount)
  hero.hp=min(hero.hp+amount,hero.str*(hero.lvl+3),32767)
end

-- world updates

function checkdungeonmove(direction)
  local curmap=maps[hero.mapnum]
  local newx,newy=hero.x,hero.y
  local xeno,yako,zabo=hero.x,hero.y,hero.z
  local cmd=direction>0 and 'advance' or 'retreat'
  local item
  local iscreature=false
  if hero.facing==1 then
    newy-=direction
    result=getdungeonblock(curmap,xeno,newy,zabo)
    item=contents[xeno][newy]
  elseif hero.facing==2 then
    newx+=direction
    result=getdungeonblock(curmap,newx,yako,zabo)
    item=contents[newx][yako]
  elseif hero.facing==3 then
    newy+=direction
    result=getdungeonblock(curmap,xeno,newy,zabo)
    item=contents[xeno][newy]
  else
    newx-=direction
    result=getdungeonblock(curmap,newx,yako,zabo)
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

function checkmove(xeno,yako,cmd)
  local curmap=maps[hero.mapnum]
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
    if not curmap.wrap and((xeno>=curmap.maxx or xeno<curmap.minx)or(yako>=curmap.maxy or yako<curmap.miny)) then
      xeno,yako=curmap.enterx,curmap.entery
      update_lines{cmd,"exiting "..curmap.name.."."}
      hero.mapnum=0
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
    elseif not curmap.wrap and(xeno>=curmap.maxx or xeno<curmap.minx or yako>=curmap.maxy or yako<curmap.miny) then
      xeno,yako=curmap.enterx,curmap.entery
      update_lines{cmd,"exiting "..curmap.name.."."}
      hero.mapnum=0
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
      hero.health='p'
    end
  else
    xeno,yako=hero.x,hero.y
  end
  turnmade=true
  return xeno,yako
end

function check_sign(x,y,mapnum)
  local response=nil
  if mget(x,y)==31 then
    -- read the sign
    for objnum=1,#signs[mapnum] do
      local sign=signs[mapnum][objnum]
      if x==sign.x and y==sign.y then
        response=sign.msg
        break
      end
    end
  end
  return response
end

function look_results(ldir,x,y,mapnum)
  local cmd="examine: "..ldir
  local content=contents[x][y] or nil
  local signcontents=check_sign(x,y,mapnum)
  if signcontents then
    update_lines{cmd.." (read sign)",signcontents}
  elseif content and content.z==hero.z then
    update_lines{cmd,content.name}
  elseif maps[hero.mapnum].dungeon then
    update_lines{cmd,"dungeon"}
  else
    update_lines{cmd,terrains[mget(x,y)]}
  end
end

function dialog_results(ddir,x,y,mapnum)
  local cmd="dialog: "..ddir
  if terrains[mget(x,y)]=='counter' then
    return getdirection(calculatemoves(mapnum,maps[mapnum],{x=x,y=y}),mapnum,maps[mapnum],dialog_results,nil,ddir)
  end
  if contents[x][y] then
    local dialog_target=contents[x][y]
    if dialog_target.merch then
      update_lines(shop[dialog_target.merch]())
    elseif contents[x][y].talk then
      update_lines{cmd,'"'..dialog_target.talk[flr(rnd(#dialog_target.talk))+1]..'"'}
    else
      update_lines{cmd,'no response!'}
    end
  else
    update_lines{cmd,'no one to talk with.'}
  end
end

function attack_results(adir,x,y,mapnum,magic)
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
      logit(creature.name.." hp: "..creature.hp)
      if creature.hp<=0 then
        increasegold(creature.gold)
        increasexp(creature.exp)
        if creature.name=='pirates' then
          contents[x][y]={
            facing=creature.facing
          }
          setmetatable(contents[x][y],{__index=shiptype})
        else
          contents[x][y]=nil
        end
        update_lines{cmd,creature.name..' killed; xp+'..creature.exp..' gp+'..creature.gold}
        del(creatures[mapnum],creature)
      else
        update_lines{cmd,'you hit the '..creature.name..'!'}
        creature.hostile=true
        if maps[mapnum].friendly then
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
    if rnd(hero.str+hero.lvl)>8 then
      update_lines{cmd,'you break open the door!'}
      mset(x,y,30)
    else
      update_lines{cmd,'the door is still locked.'}
    end
  else
    update_lines{cmd,'nothing to attack.'}
  end
end

function squaredistance(x1,y1,x2,y2,curmap)
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

function calculatemoves(mapnum,curmap,creature)
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

function movecreatures(mapnum,curmap,hero)
  local gothit=false
  local actualdistance=500
  for creaturenum,creature in pairs(creatures[mapnum]) do
    if creature.z==hero.z then
      local desiredx,desiredy=creature.x,creature.y
      while creature.moveallowance>creature.nummoves do
        local spots=calculatemoves(mapnum,curmap,creature)
        --foreach(spots,logit)
        if creature.hostile then
          -- most creatures are hostile; move toward player
          bestfacing=0
          actualdistance=squaredistance(creature.x,creature.y,hero.x,hero.y,curmap)
          local currentdistance=actualdistance
          local bestdistance=currentdistance
          for facing=1,4 do
            if facing%2==1 then
              currentdistance=squaredistance(creature.x,spots[facing],hero.x,hero.y,curmap)
            else
              currentdistance=squaredistance(spots[facing],creature.y,hero.x,hero.y,curmap)
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
          if rnd(1)<.5 then
            if creature.facing and rnd(1)<.5 then
              if creature.facing%2==1 then
                desiredy=spots[creature.facing]
              else
                desiredx=spots[creature.facing]
              end
            else
              local facing=flr(rnd(4))+1
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
          newloc=getdungeonblockterrain(curmap,desiredx,desiredy,creature.z)
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
        --logit(creature.name..': actualdistance '..actualdistance..' x '..desiredx..' '..hero.x..' y '..desiredy..' '..hero.y)
        if creature.z==hero.z and (creature.hostile and actualdistance<=1 or (desiredx==hero.x and desiredy==hero.y and creature.hostile==nil and creaturenum~=0)) then
          local hero_dodge=hero.dex+2*hero.lvl
          if creature.eat and hero.food>0 and rnd(creature.dex*32)>rnd(hero_dodge) then
            sfx(2)
            update_lines{"the "..creature.name.." eats!"}
            deductfood(flr(rnd(6)))
            gothit=true
            delay(9)
          elseif creature.thief and hero.gold>0 and rnd(creature.dex*23)>rnd(hero_dodge) then
            sfx(2)
            local amountstolen=min(flr(rnd(5))+1,hero.gold)
            hero.gold-=amountstolen
            creature.gold+=amountstolen
            update_lines{"the "..creature.name.." steals!"}
            gothit=true
            delay(9)
          elseif creature.poison and rnd(creature.dex*25)>rnd(hero_dodge) then
            sfx(1)
            hero.health='p'
            update_lines{"poisoned by the "..creature.name.."!"}
            gothit=true
            delay(3)
          elseif rnd(creature.dex*64)>rnd(hero_dodge+hero.armor) then
            hero.gothit=true
            sfx(1)
            local damage=flr(rnd(creature.str+creature.dmg)-rnd(hero.armor))+1
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
          logit((creature.name or 'nil')..' desired '..(desiredx or 'nil')..','..(desiredy or 'nil')..' hero '..(hero.x or 'nil')..','..(hero.y or 'nil')..','..(hero.z or 'nil')..' movecost '..(movecost or 'nil'))
          if creature.movepayment>=movecost and not contents[desiredx][desiredy] and not (desiredx==hero.x and desiredy==hero.y and creature.z==hero.z) then
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
  local mapnum=hero.mapnum
  local curmap=maps[mapnum]
  local btnpress=btnp()
  if btnpress~=0 then
    coresume(processinput,getbutton(btnpress),mapnum,curmap)
  end
  if turnmade then
    mapnum=hero.mapnum
    curmap=maps[mapnum]
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
    if turn%5==0 and hero.health=='p' then
      deducthp(1)
      sfx(1,0,8)
      update_lines{"feeling sick!"}
    end
    if gothit then
      delay(3)
    end
    gothit=movecreatures(mapnum,curmap,hero)
    if #creatures[mapnum]<curmap.maxmonsters and rnd(10)<curmap.newmonsters then
      create_monster(mapnum,curmap)
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
  print(hero.health,125,0,6)
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

function getdungeonblock(curmap,mapx,mapy,mapz)
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

function getdungeonblockterrain(curmap,mapx,mapy,mapz)
  return getdungeonblock(curmap,mapx,mapy,mapz)>1 and 20 or 22
end

function triplereverse(triple)
  local tmp=triple[1]
  triple[1]=triple[3]
  triple[3]=tmp
end

function getdungeonblocks(curmap,mapx,mapy,mapz,facing)
  local blocks={}
  if facing%2==0 then
    -- we're looking for a column
    for viewy=mapy-1,mapy+1 do
      add(blocks,{
        block=getdungeonblock(curmap,mapx,viewy,mapz),
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
        block=getdungeonblock(curmap,viewx,mapy,mapz),
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

function getdungeonview(curmap,mapx,mapy,mapz,facing)
  local blocks={}
  local viewx,viewy=mapx,mapy
  if facing%2==0 then
    for viewx=mapx+4-facing,mapx+2-facing,-1 do
      add(blocks,getdungeonblocks(curmap,viewx,viewy,mapz,facing))
    end
    if facing==4 then
       triplereverse(blocks)
    end
  else
    for viewy=mapy-3+facing,mapy-1+facing do
      add(blocks,getdungeonblocks(curmap,viewx,viewy,mapz,facing))
    end
    if facing==3 then
      triplereverse(blocks)
    end
  end
  return blocks
end

function dungeon_draw()
  local curmap=maps[hero.mapnum]
  cls()
  local view=getdungeonview(curmap,hero.x,hero.y,hero.z,hero.facing)
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
    if hero.x==curmap.startx and hero.y==curmap.starty and hero.z==curmap.startz then
      -- we see the way out
      --line(middle,topouter,middle,middle,4)
      sspr(88,8,8,8,28,0,25,40)
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
      local distancemod=distance*4
      sspr(item.img%16*8,flr(item.img/16)*8,8,8,20+distancemod,35,60-distancemod*4,60-distancemod*4,flipped)
      pal()
      if item.hitdisplay>0 then
        sspr(127%16*8,flr(127/16)*8,8,8,20+distancemod,35,60-distancemod*4,60-distancemod*4)
        item.hitdisplay-=1
      end
    end
  end
end

function world_draw()
  local curmap=maps[hero.mapnum]
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
c0c0c0c0c0c040406060604040404040c0c0c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e0c0c0c0c040404060606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0000000001010201020303830484048408000800080000080800000008080000000000000000080808080808080808080808080808080808080808080808080808080808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0e0c0c0c0c0c0c0c0c0c0c060c0e0e0e0e0c0c0c0c0e0e0c0c0c0803030303080e0e0e0e0e0c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e2610101010101010101010101010101010101010101010131010101010101010101010101010101010100c0c0c1010101014141414141414141414141414141414
0c0606060506060707070606040c0e0e0e0c06060c0c0c0708080809030809080c0e0e0e0e0c0707070c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e10010101010101010101010101010101010101010101040410111111111004010101040110392b27100c0c010101331014020202020202020202020202020214
0c04040605050708080808070c0c0c0e0c0c0606040104080809090303090908070c0e0e0e070303030707040c0c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0c10010c0c0c0c01010101101010101010101010101010100410273833391001040104040410111111100c0c0c0101271014020202020202020202020202020214
0c01040406070808080908070c04040c0c0c040101010107080909030309030308070c0c0c0407030303030704050c0c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0c0c100119260c0c0c010101101111111111111111111111100110111111111004040101040410363b2810020c0c0c01381014020202020202020202020202020214
0c01010404040707070808010c22010c0122010104040707070807090903080807070c0404040407040407040505050c0c06040c0c0c0c0e0e0e0e0e0e0c0c0410010c0c0c0c0c010101102d35352a4231342f2d2e3a100110111111111c111111111104101111111d02020c0c0c2f1014020202020202020202020202020214
0101010104040404070801010101010c010101010101040707070807080807072107070401040406040404040605050c0606060c0c0c0c0c0e0e0e0e0e0c0c041001010c0c0c0101010110111111111111111111111110011010101010100101010111041011111110020202020c341014020202020202020202020202020214
0c0c010101010104070101010101010c010101010101010404070704060707070607060401010606060606040606050c0606060c0c0c0c0c0e0e0e0e0e0e0c0c10010101010101010101101111111111111111111111100110010101010101010101110110111111100202020202271014020202020202020202020202020214
0c0c0c0c010101010101010101010c0e040401010101010404010404040606060606060601010504060606060605050c060606040c0c0c0c0c0e0e0e0e0e0e0c10011010101010010101101111111111111111111111100110010101010101010101110110101c10101810181d18101014020202020202020202020202020214
0c01010107010604040401010c0c040c0404060406040101040401010404060606060606040505050404060605050c0c040606040c0c0c0c0c0e0e0e0e0e0e0c10011011111110010101101111101010101010101010100110101010101010100101111111111111111111111104041014020202020202020202020202020214
0c010107070704040606040c0604040c0c0406060601010101010401010104040606040401050c0c050505050c0c0c04040406040c0c0c0c0e0e0e0e0e0e0e0c1001104242421001010101111101010101010101010101011011111111111110010111040101010101010101011f041014020202020202020202020202020214
0c010708080701060606040c06040c0c010c0606010101010101010101040404040606010405050c0c0c050c0c050c04040406040c0c0c0c0e0e0e0e0e0e0c0c100110111111100101011111110101010101010101010101102d3835292b38100104110401010101010101010101011014020202020202020202020202020214
0c0c01082108070104060606040c0c0c01010c010101010101010101010c04040404040401050505050c0c0c05050c0c0406040c0c0c0c0c0c0c0e0e0e0e0c0c100118111111180101111111010101010101010101010101101111111111111c1111111101011010101010101010101014020202020202020202020202020214
0e0c0c0c07070c0c01040401010c0e0c010101010101010101010c0c0c0c0c0c0c05040404050505050505050505050c0404040c0c0c0c0e0e0e0e0e0e0e0c0c10011011111110010111110101101010101010101010100110111111111111100101041101011011111111111111111014020202020202020202020202020214
0e0e0e0c0c0c0c0c0c01010c0c0c0c0c0c01010101010104040c0c0c0e0e0c0c0c050505040505050505050505050c0c04040c0c0c0e0e0e0e0e0e0e0e0c0c0c1001101111111001111111010110111111111111111110011011111111111110010101110104102e3539362f3a27321014020202020202020202020202020214
0e0e0e0c0c0c0c05050101010c0505050c0c01010104010404040c0c0c0e0e0c0c0c050505050505050505050c0c0c0404070c0c0c0e0e0e0e0e0e0e0e0c0c0c10011011111110011111010101102c35352a3327383a100110101010101010100101011104041011111111111111111014020202020202020202020202020214
0e0e0c0c07070505040101050504040405050c05050101010404040c0c0c0c0c0c0c0505050505050505050c0c01010407070c0c0c0e0e0e0e0e0e0e0e0c0c0c10011011111111111111010101101111111111111111100110010101010101010101011111111c11111111111111111014141414141414141414141414141414
0e0c0c070707070404010505040404040101050101010101010101010c0c0c0505050505010101010505050c0c010407070c0c0c0e0e0e0e0e0e0e0e0e0c0c0c10011011111111111111010101101111111111111111100110010101010101010101011104041011111111111111111014020202020202020202020202020214
0c010707080804040101010101010101010101010101010101010601010101010505050101010c0c0c0c050c0c010407070c0c0c0e0e0e0e0e0e0e0e0e0e0c0c1001101111111001111101010110101010101111101010011001010101010101010101110401101c10101c10101c101014020202020202020202020202020214
0c0707080804010101070707070101010101010101010106040401040401060406010101010c0c01010c0c0c010107070c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0c100110332b2a10011111010101010101010111110101010110010101010101010101011101011011111011111011111014020202020202020202020202020214
0c0c08060401010107070202020707070707070101040606060604060606060404010101010c01010101010101070c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c1001101010101001111111111f111111111111110101010110010101010101010101011111011011111011111011111014020202020202020202020202020214
0c0c060806010407020202020202020202020707070404060606060606060406060101010119010101060404070c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c10010101010101010111111111111111111111110101010110010101010101010101040411041010101010101010101014020202020202020202020202020214
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
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344

