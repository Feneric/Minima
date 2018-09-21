pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- minima
-- by feneric

-- a function for logging to an output log file.
-- function logit(entry)
--   printh(entry,'minima.out')
-- end

-- register json context here
_tok={
 ['true']=true,
 ['false']=false}
_g={}

-- json parser
-- from: https://gist.github.com/tylerneylon/59f4bcf316be525b30ab
table_delims={['{']="}",['[']="]"}

function match(s,tokens)
  for i=1,#tokens do
    if(s==sub(tokens,i,i)) return true
  end
  return false
end

function skip_delim(wrkstr, pos, delim, err_if_missing)
 if sub(wrkstr,pos,pos)!=delim then
  -- if(err_if_missing) assert'delimiter missing'
  return pos,false
 end
 return pos+1,true
end

function parse_str_val(wrkstr, pos, val)
  val=val or ''
  -- if pos>#wrkstr then
  --   assert'end of input found while parsing string.'
  -- end
  local c=sub(wrkstr,pos,pos)
  if(c=='"') return _g[val] or val,pos+1
  return parse_str_val(wrkstr,pos+1,val..c)
end

function parse_num_val(wrkstr,pos,val)
  val=val or ''
  -- if pos>#wrkstr then
  --   assert'end of input found while parsing string.'
  -- end
  local c=sub(wrkstr,pos,pos)
  -- support base 10, 16 and 2 numbers
  if(not match(c,"-xb0123456789abcdef.")) return tonum(val),pos
  return parse_num_val(wrkstr,pos+1,val..c)
end
-- public values and functions.

function json_parse(wrkstr, pos, end_delim)
  pos=pos or 1
  -- if(pos>#wrkstr) assert'reached unexpected end of input.'
  local first=sub(wrkstr,pos,pos)
  if match(first,"{[") then
    local obj,key,delim_found={},true,true
    pos+=1
    while true do
      key,pos=json_parse(wrkstr, pos, table_delims[first])
      if(key==nil) return obj,pos
      -- if not delim_found then assert'comma missing between table items.' end
      if first=="{" then
        pos=skip_delim(wrkstr,pos,':',true)  -- true -> error if missing.
        obj[key],pos=json_parse(wrkstr,pos)
      else
        add(obj,key)
      end
      pos,delim_found=skip_delim(wrkstr, pos, ',')
  end
  elseif first=='"' then
    -- parse a string (or a reference to a global object)
    return parse_str_val(wrkstr,pos+1)
  elseif match(first,"-0123456789") then
    -- parse a number.
    return parse_num_val(wrkstr, pos)
  elseif first==end_delim then  -- end of an object or array.
    return nil,pos+1
  else  -- parse true, false
    for lit_str,lit_val in pairs(_tok) do
      local lit_end=pos+#lit_str-1
      if sub(wrkstr,pos,lit_end)==lit_str then return lit_val,lit_end+1 end
    end
    -- assert'invalid json token'
  end
end

-- initialization data
fullheight,fullwidth,halfheight,halfwidth=11,13,5,6

-- set up the various messages
winmsg="\n\n\n\n\n\n  congratulations, you've won!\n\n\n\n\n\n\n\n\n\n    press p to get game menu,\n anything else to continue and\n      explore a bit more."
losemsg="\n\n\n\n\n\n      you've been killed!\n          you lose!\n\n\n\n\n\n\n\n\n\n\n\n    press p to get game menu"
helpmsg="minima commands:\n\na: attack\nc: cast spell\nd: dialog, talk, buy\ne: enter, board, mount, climb,\n   descend\np: pause, save, load, help\nf: fountain drink; force chest;\n   flame torch\ns: sit & wait\nw: wearing & wielding\nx: examine, look (repeat to\n   search)\n\nfor commands with options (like\ncasting or buying) use the first\ncharacter from the list, or\nanything else to cancel."
msg=helpmsg

-- anyobj is our root object. all others inherit from it to
-- save space and reduce redundancy.
anyobj=json_parse('{"facing":1,"moveallowance":0,"nummoves":0,"movepayment":0,"hd":0,"chance":0,"zabo":0}')

function makemetaobj(base,basetype)
  return setmetatable(base,{__index=base.objtype or basetype})
end

-- the types of terrain that exist in the game. each is
-- given a name and a list of allowed monster types.
terrains=json_parse('["plains","bare ground","tundra","scrub","swamp","forest","foothills","mountains","tall mountain","volcano","volcano","water","water","deep water","deep water","brick","brick road","brick","mismatched brick","stone","stone","road","barred window","window","bridge","ladder down","ladder up","door","locked door","open door","sign","shrine","dungeon","castle","tower","town","village","ankh"]')
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

-- basetypes are the objects we mean to use to make objects.
-- they inherit (often indirectly) from our root object.
basetypes=json_parse('[{"dmg":13,"hp":10,"hostile":true,"dex":8,"terrain":[1,2,3,4,5,6,7,8,17,18,22,25,26,27,30,31,33,35],"chance":1,"armor":1,"gp":10,"moveallowance":1,"exp":2},{"maxx":128,"friendly":true,"maxmonsters":0,"mn":0,"newmonsters":0,"miny":0,"minx":80,"maxy":64},{"friendly":false,"maxmonsters":27,"maxx":9,"songstart":17,"starty":1,"dungeon":true,"maxy":9,"startx":1,"creatures":{},"startz":1,"mn":0,"miny":1,"startfacing":1,"minx":1,"newmonsters":25},{"talk":["yes, ankhs can talk.","shrines make good landmarks."],"imgalt":38,"name":"ankh","img":38},{"passable":true,"facingmatters":true,"facing":2,"imgalt":70,"name":"ship","img":70},{"sizemod":12,"passable":true,"imgalt":92,"name":"chest","img":92},{"sizemod":15,"imgseq":12,"flipimg":true,"passable":true,"name":"fountain","img":39},{"sizemod":20,"shiftmod":12,"passable":true,"imgalt":27,"name":"ladder up","img":27},{"sizemod":20,"shiftmod":-3,"passable":true,"imgalt":26,"name":"ladder down","img":26},{"exp":1,"gp":5,"armor":0,"hostile":false,"img":80,"name":"human"},{"talk":["urg!","grar!"],"chance":8,"name":"orc"},{"dmg":14,"chance":5,"gp":5,"dex":6,"name":"undead"},{"chance":3,"armor":0,"gp":0,"dex":10,"name":"animal"},{"dmg":20,"talk":["check out these pecs!","i\'m jacked!"],"hp":12,"colorsubs":[{},[[1,12],[14,2],[15,4]]],"armor":3,"name":"fighter","dex":9,"img":82},{"dmg":60,"talk":["behave yourself.","i protect good citizens."],"hp":85,"colorsubs":[{},[[15,4]]],"armor":12,"name":"guard","moveallowance":0,"img":90},{"flipimg":true,"talk":["buy my wares!","consume!","stuff makes you happy!"],"name":"merchant","colorsubs":[{},[[1,4],[4,15],[6,1],[14,13]],[[1,4],[6,5],[14,10]],[[1,4],[4,15],[6,1],[14,3]]],"img":75},{"flipimg":true,"talk":["pardon me.","well i never."],"name":"lady","colorsubs":[{},[[2,9],[4,15],[13,14]],[[2,10],[4,15],[13,9]],[[2,11],[13,3]]],"img":81},{"talk":["i like sheep.","the open air is nice."],"colorsubs":[{},[[6,5],[15,4]],[[6,5]],[[15,4]]],"name":"shepherd","img":76},{"talk":["ho ho ho!","ha ha ha!"],"name":"jester","dex":12,"img":78},{"attackcolors":[[9,6],[8,13],[10,12]],"talk":["a mage is always on time.","brain over brawn."],"name":"mage","img":84},{"talk":["i travel the land.","my home is the range."],"colorsubs":[{},[[9,11],[1,3],[15,4]],[[9,11],[1,3]],[[15,4]]],"flipimg":true,"name":"ranger"},{"exp":5,"talk":["stand and deliver!","you shall die!"],"armor":1,"hostile":true,"gp":15,"name":"villain"},{"merch":"food","name":"grocer"},{"merch":"armor","name":"armorer"},{"merch":"weapons","name":"smith"},{"merch":"hospital","name":"medic"},{"merch":"guild","name":"guildkeeper"},{"merch":"bar","name":"barkeep"},{"img":96},{"dmg":16,"hp":15,"exp":4,"gp":10,"name":"troll","img":102},{"names":["hobgoblin","bugbear"],"hp":15,"exp":3,"gp":8,"dmg":14,"img":104},{"names":["goblin","kobold"],"hp":8,"exp":1,"gp":5,"dmg":10,"img":114},{"dmg":18,"chance":1,"hp":20,"flipimg":true,"exp":6,"name":"ettin","img":118},{"gp":12,"name":"skeleton","img":98},{"names":["zombie","wight","ghoul"],"hp":10,"img":100},{"names":["phantom","ghost","wraith"],"hp":15,"flipimg":true,"talk":["boooo!","feeear me!"],"exp":7,"terrain":[1,2,3,4,5,6,7,8,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,33,35],"img":123},{"names":["warlock","necromancer","sorcerer"],"talk":["i hex you!","a curse on you!"],"exp":10,"attackcolors":[[9,6],[8,13],[10,12]],"dmg":18,"colorsubs":[{},[[2,8],[15,4]]],"img":84},{"names":["rogue","bandit","cutpurse"],"chance":2,"thief":true,"colorsubs":[{},[[1,5],[8,2],[4,1],[2,12],[15,4]]],"dex":10,"img":88},{"names":["ninja","assassin"],"poison":true,"exp":8,"talk":["you shall die at my hands.","you are no match for me."],"gp":10,"colorsubs":[{},[[1,5],[15,4]]],"img":86},{"exp":5,"hp":18,"poison":true,"gp":8,"name":"giant spider","img":106},{"dmg":10,"hp":5,"exp":2,"name":"giant rat","poison":true,"eat":true,"img":108},{"names":["giant snake","serpent"],"chance":1,"hp":20,"exp":6,"terrain":[4,5,6,7],"poison":true,"img":112},{"terrain":[5,12,13,14,15,25],"hp":45,"exp":10,"name":"sea serpent","img":116},{"exp":5,"chance":1,"hp":12,"flipimg":true,"poison":true,"name":"megascorpion","img":125},{"names":["slime","jelly","blob"],"exp":2,"colorsubs":[{},[[3,9],[11,10]],[[3,14],[11,15]]],"flipimg":true,"terrain":[17,22,23],"gp":5,"eat":true,"img":122},{"names":["kraken","giant squid"],"chance":2,"hp":50,"exp":8,"terrain":[12,13,14,15],"img":94},{"terrain":[4,5,6],"flipimg":true,"exp":3,"name":"wisp","img":120},{"flipimg":false,"colorsubs":[[[6,5],[7,6]]],"terrain":[12,13,14,15],"exp":8,"facingmatters":true,"attackcolors":[[9,8],[8,9],[10,1]],"facing":1,"name":"pirate","img":70},{"names":["gazer","beholder"],"flipimg":true,"exp":4,"terrain":[17,22],"colorsubs":[{},[[2,14],[1,4]]],"img":119},{"dmg":28,"hp":50,"flipimg":true,"names":["dragon","drake","wyvern"],"exp":17,"attackcolors":[[9,6],[8,13],[10,12]],"gp":20,"armor":7,"img":121},{"dmg":23,"hp":50,"names":["daemon","devil"],"chance":0.25,"exp":15,"terrain":[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,22,25,26,27,30,31,33,35],"attackcolors":[[9,10],[8,9],[10,7]],"gp":25,"armor":3,"img":110},{"terrain":[17,22],"chance":0,"exp":4,"name":"mimic","thief":true,"gp":12,"moveallowance":0,"img":92},{"hp":30,"flipimg":true,"terrain":[17,22],"chance":0,"exp":5,"name":"reaper","armor":5,"gp":8,"moveallowance":0,"img":124}]')
-- give our base objects names for convenience & efficiency.
creature,shiptype=basetypes[1],basetypes[5]

-- set our base objects base values. the latter portion is
-- our bestiary. it holds all the different monster types that can
-- be encountered in the game. it builds off of the basic types
-- already defined so most do not need many changes. actual
-- monsters in the game are instances of creatures found in the
-- bestiary.
for basetypenum=1,#basetypes do
  local basetype
  local objecttype=basetypes[basetypenum]
  if basetypenum<10 then
    basetype=anyobj
  elseif basetypenum<14 then
    basetype=creature
  elseif basetypenum<23 then
    basetype=basetypes[10]
  elseif basetypenum<28 then
    basetype=basetypes[16]
  elseif basetypenum<29 then
    basetype=basetypes[17]
  elseif basetypenum<35 then
    basetype=basetypes[11]
  elseif basetypenum<38 then
    basetype=basetypes[12]
  elseif basetypenum<41 then
    basetype=basetypes[22]
  elseif basetypenum<48 then
    basetype=basetypes[13]
  else
    basetype=creature
  end
  objecttype.idtype=basetypenum
  makemetaobj(objecttype,basetype)
  if basetypenum>28 then
    for terrain in all(objecttype.terrain) do
      add(terrainmonsters[terrain],objecttype)
    end
  end
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
        return hero.gp>=desireditem.price and desireditem
      else
        return nil
      end
    end,
    function(desireditem)
      if hero[attribute]>=desireditem.amount then
        return "that is not an upgrade."
      else
        hero.gp-=desireditem.price
        hero[attribute]=desireditem.amount
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
          return hero.gp>=15
        else
          return nil
        end
      end,
      function()
        hero.gp-=15
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
          return hero.gp>=desiredspell.price and desiredspell
        else
          return nil
        end
      end,
      function(desiredspell)
        sfx(3)
        hero.gp-=desiredspell.price
        if desiredspell.name=='cure' then
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
          return hero.gp>=5
        else
          return nil
        end
      end,
      function()
        hero.gp-=5
        rumors=json_parse('["faxon has many guards.","faxon is scary powerful.","fountains respect injury.","dungeon fountains rule.","faxon fears a magic sword.","watch for secret doors.","fighters can bust doors.","good mages can zap doors."]')
        update_lines{"while socializing, you hear:"}
        return '"'..rumors[flr(rnd(8)+1)]..'"'
      end
    )
  end,
  guild=function()
    return checkpurchase({"buy \139torches (5) for $12 or","\145skeleton key (1) for $23: "},
      function(cmd)
        if cmd=='west' then
          return hero.gp>=12 and 'torches'
        elseif cmd=='east' then
          return hero.gp>=23 and 'key'
        else
          return nil
        end
      end,
      function(desireditem)
        if desireditem=='torches' then
          hero.gp-=12
          hero.torches+=5
          return "you purchase 5 torches."
        elseif desireditem=='key' then
          hero.gp-=23
          hero.keys+=1
          return "you purchase a skeleton key."
        end
      end
    )
  end
}

-- the maps structure holds information about all of the regular
-- places in the game, dungeons as well as towns.
maps=json_parse('[{"creatures":[{"idtype":15,"xeno":89,"yako":21},{"idtype":26,"xeno":84,"yako":9},{"idtype":24,"xeno":95,"yako":3},{"idtype":23,"xeno":97,"yako":13},{"idtype":14,"xeno":82,"yako":21},{"idtype":21,"xeno":101,"yako":5},{"idtype":20,"xeno":84,"talk":["the secret room is key.","the way must be clear."],"yako":5},{"idtype":21,"xeno":103,"talk":["faxon is in a tower.","volcanoes mark it."],"yako":18},{"idtype":17,"xeno":85,"talk":["poynter has a ship.","poynter is in lynn."],"yako":16},{"idtype":15,"xeno":95,"yako":21}],"enterx":13,"items":[{"idtype":4,"xeno":84,"yako":4}],"signs":[{"xeno":92,"msg":"welcome to saugus!","yako":19}],"entery":4,"name":"saugus","maxx":105,"starty":23,"startx":92,"maxy":24},{"creatures":[{"idtype":15,"xeno":118,"yako":22},{"idtype":25,"xeno":106,"yako":1},{"idtype":28,"xeno":118,"yako":2},{"idtype":23,"xeno":107,"yako":9},{"idtype":19,"xeno":106,"yako":16},{"idtype":26,"xeno":122,"yako":12},{"idtype":14,"xeno":105,"talk":["i\'ve seen faxon\'s tower.","south of the eastern shrine."],"yako":4},{"idtype":17,"xeno":106,"talk":["griswold knows dungeons.","griswold is in salem."],"yako":7},{"idtype":16,"xeno":119,"talk":["i\'m rich! i have a yacht!","ho ho! i\'m the best!"],"yako":6},{"idtype":15,"xeno":114,"yako":22}],"minx":104,"enterx":17,"items":[{"idtype":5,"xeno":125,"yako":5}],"entery":4,"name":"lynn","signs":[{"xeno":125,"msg":"marina for members only.","yako":9}],"starty":23,"startx":116,"maxy":24},{"creatures":[{"idtype":15,"xeno":94,"yako":49},{"idtype":25,"xeno":103,"yako":39},{"idtype":24,"xeno":92,"yako":30},{"idtype":23,"xeno":88,"yako":38},{"idtype":26,"xeno":100,"yako":30},{"idtype":19,"xeno":96,"yako":44},{"idtype":14,"xeno":83,"talk":["zanders has good tools.","be prepared!"],"yako":27},{"idtype":16,"xeno":81,"yako":44},{"idtype":20,"xeno":104,"talk":["each shrine has a caretaker.","seek their wisdom."],"yako":26},{"idtype":16,"xeno":110,"talk":["i\'ve seen the magic sword.","search south of the shrine."],"yako":40},{"idtype":15,"xeno":105,"moveallowance":1,"yako":35},{"idtype":15,"xeno":98,"yako":49}],"enterx":45,"miny":24,"items":[{"idtype":7,"xeno":96,"yako":40}],"entery":19,"name":"boston","maxx":112,"starty":54,"startx":96,"maxy":56},{"creatures":[{"idtype":15,"xeno":118,"yako":63},{"idtype":27,"xeno":125,"yako":44},{"idtype":28,"xeno":114,"yako":44},{"idtype":23,"xeno":122,"yako":51},{"idtype":17,"xeno":118,"yako":58},{"idtype":21,"xeno":113,"talk":["faxon is a blight.","daemons serve faxon."],"yako":50},{"idtype":14,"xeno":123,"talk":["increase stats in dungeons!","only severe injuries work."],"yako":57},{"idtype":15,"xeno":120,"yako":63}],"minx":112,"enterx":7,"miny":43,"name":"salem","items":[{"idtype":4,"xeno":116,"yako":53}],"starty":62,"startx":119,"entery":36},{"creatures":[{"idtype":23,"xeno":93,"yako":57},{"idtype":28,"xeno":100,"yako":57},{"idtype":14,"xeno":91,"talk":["i saw a dragon once.","it was deep in a dungeon."],"yako":60},{"idtype":18,"xeno":82,"yako":57},{"idtype":18,"xeno":102,"talk":["gilly is in boston.","gilly knows of the sword."],"yako":63}],"starty":59,"entery":35,"name":"great misery","maxx":103,"startx":82,"enterx":27,"miny":56},{"creatures":[{"idtype":20,"xeno":107,"talk":["magic serves good or evil.","swords cut both ways.","even faxon has fears."],"yako":59}],"minx":103,"enterx":1,"miny":56,"name":"western shrine","maxx":112,"starty":62,"startx":107,"entery":28},{"creatures":[{"idtype":18,"xeno":107,"talk":["some fountains have secrets.","learn of dungeon fountains.","know when to be humble."],"yako":59}],"minx":103,"enterx":49,"miny":56,"name":"eastern shrine","maxx":112,"starty":62,"startx":107,"entery":6},{"maxmonsters":23,"songstart":17,"minx":112,"creatures":[{"idtype":53,"xeno":119,"yako":41},{"idtype":53,"xeno":126,"yako":40},{"idtype":53,"xeno":123,"yako":38},{"idtype":53,"xeno":113,"yako":40},{"idtype":52,"xeno":121,"yako":37},{"idtype":52,"xeno":119,"yako":38},{"idtype":45,"xeno":120,"yako":34},{"idtype":45,"xeno":118,"yako":35},{"dmg":50,"hp":255,"img":126,"yako":30,"idtype":50,"xeno":118,"armor":25,"propername":"faxon"}],"enterx":56,"miny":24,"items":[{"targetx":3,"targety":8,"yako":41,"idtype":8,"xeno":117,"targetmap":12,"targetz":3},{"idtype":6,"xeno":119,"yako":37},{"idtype":6,"xeno":119,"yako":39},{"idtype":6,"xeno":120,"yako":37},{"idtype":6,"xeno":120,"yako":38},{"idtype":6,"xeno":120,"yako":39},{"idtype":6,"xeno":121,"yako":38},{"idtype":6,"xeno":121,"yako":39}],"friendly":false,"newmonsters":35,"name":"the dark tower","entery":44,"starty":41,"startx":120,"maxy":43},{"creatures":[{"idtype":50,"xeno":8,"zabo":4,"yako":5},{"idtype":52,"xeno":3,"zabo":4,"yako":1},{"idtype":52,"xeno":1,"zabo":4,"yako":5},{"idtype":52,"xeno":5,"zabo":4,"yako":1},{"idtype":53,"xeno":3,"zabo":4,"yako":3}],"items":[{"idtype":8,"xeno":1,"zabo":1,"yako":8},{"idtype":8,"xeno":8,"zabo":2,"yako":2},{"idtype":8,"xeno":4,"zabo":3,"yako":8},{"idtype":8,"xeno":1,"zabo":4,"yako":1},{"idtype":6,"xeno":1,"zabo":4,"yako":8},{"idtype":6,"xeno":7,"zabo":4,"yako":1},{"idtype":6,"xeno":3,"zabo":4,"yako":8},{"idtype":6,"xeno":5,"zabo":4,"yako":8},{"idtype":6,"xeno":8,"zabo":4,"yako":8},{"idtype":7,"xeno":6,"zabo":3,"yako":8}],"entery":11,"name":"nibiru","levels":[[0,16382,768,12336,16380,13056,13308,192],[0,-13107,816,12336,15612,768,16332,704],[-32768,-3316,1020,12300,13116,13056,-3076,448],[29488,13116,0,-3073,0,-3124,780,13116]],"starty":8,"enterx":4,"attr":"int"},{"creatures":[{"idtype":50,"xeno":3,"zabo":4,"yako":5},{"idtype":52,"xeno":1,"zabo":4,"yako":5},{"idtype":52,"xeno":7,"zabo":4,"yako":5},{"idtype":53,"xeno":5,"zabo":4,"yako":3},{"idtype":53,"xeno":5,"zabo":4,"yako":7}],"items":[{"idtype":8,"xeno":1,"zabo":1,"yako":1},{"idtype":8,"xeno":7,"zabo":2,"yako":1},{"idtype":8,"xeno":3,"zabo":3,"yako":7},{"idtype":8,"xeno":1,"zabo":4,"yako":3},{"idtype":6,"xeno":1,"zabo":4,"yako":1},{"idtype":6,"xeno":1,"zabo":4,"yako":8},{"idtype":6,"xeno":1,"zabo":4,"yako":7},{"idtype":6,"xeno":2,"zabo":4,"yako":8},{"idtype":6,"xeno":8,"zabo":4,"yako":8},{"idtype":7,"xeno":7,"zabo":3,"yako":5}],"name":"purgatory","levels":[[824,16188,768,13296,-4036,13056,13308,768],[13060,13116,12,16332,12540,15360,15311,768],[768,13116,-20432,-196,48,16140,14140,816],[0,-13108,19468,-13108,192,-13108,3084,-13108]],"entery":5,"enterx":32,"attr":"str"},{"creatures":[{"idtype":50,"xeno":3,"zabo":4,"yako":1},{"idtype":52,"xeno":4,"zabo":4,"yako":5},{"idtype":52,"xeno":5,"zabo":4,"yako":2},{"idtype":53,"xeno":3,"zabo":4,"yako":4},{"idtype":53,"xeno":6,"zabo":4,"yako":4}],"items":[{"idtype":8,"xeno":1,"zabo":1,"yako":1},{"idtype":8,"xeno":5,"zabo":2,"yako":2},{"idtype":8,"xeno":8,"zabo":3,"yako":4},{"idtype":8,"xeno":4,"zabo":4,"yako":8},{"idtype":6,"xeno":5,"zabo":4,"yako":5},{"idtype":6,"xeno":3,"zabo":4,"yako":6},{"idtype":6,"xeno":4,"zabo":4,"yako":6},{"idtype":6,"xeno":5,"zabo":4,"yako":6},{"idtype":6,"xeno":6,"zabo":4,"yako":6},{"idtype":7,"xeno":6,"zabo":3,"yako":6}],"name":"sheol","levels":[[768,16304,1020,13056,13299,12288,-4,0],[768,13180,12303,16382,252,15360,13263,12288],[768,13116,12348,13105,13119,13068,13116,512],[0,16188,12300,13260,12300,12300,16380,256]],"entery":58,"enterx":33,"attr":"dex"},{"creatures":[{"idtype":51,"xeno":4,"zabo":1,"yako":6},{"idtype":51,"xeno":4,"zabo":2,"yako":7},{"idtype":51,"xeno":1,"zabo":3,"yako":7},{"idtype":53,"xeno":6,"zabo":3,"yako":8},{"idtype":53,"xeno":8,"zabo":3,"yako":4},{"idtype":53,"xeno":3,"zabo":3,"yako":1},{"idtype":53,"xeno":6,"zabo":2,"yako":6},{"idtype":53,"xeno":6,"zabo":1,"yako":8}],"startz":3,"enterx":124,"items":[{"idtype":9,"xeno":8,"zabo":3,"yako":1},{"zabo":3,"targetx":117,"targety":41,"yako":8,"idtype":9,"xeno":3,"targetmap":8,"targetz":0},{"idtype":8,"xeno":8,"zabo":3,"yako":7},{"idtype":8,"xeno":3,"zabo":3,"yako":4},{"idtype":8,"xeno":1,"zabo":2,"yako":2},{"idtype":8,"xeno":8,"zabo":2,"yako":2}],"name":"the upper levels","levels":[[192,-17202,-817,204,16332,3276,204,3072],[192,31949,16323,14576,15555,3276,15566,192],[192,-13105,3264,13564,16320,207,13261,15104]],"mn":8,"startx":8,"entery":26}]')
-- map 0 is special; it's the world map, the overview map.
maps[0]=json_parse('{"name":"world","minx":0,"miny":0,"maxx":80,"maxy":64,"wrap":true,"newmonsters":10,"maxmonsters":12,"friendly":false,"songstart":0}')

-- add numerical references to names by amounts
function makenameforamount(itemtype)
  nameforamount={}
  for itemcmd,item in pairs(itemtype) do
    nameforamount[item.amount]=item.name
  end
  nameforamount[0]='none'
  return nameforamount
end

-- armor definitions
armors=json_parse('{"south":{"name":"cloth","amount":8,"price":12},"west":{"name":"leather","amount":23,"price":99},"east":{"name":"chain","amount":40,"price":300},"north":{"name":"plate","amount":70,"price":950}}')
armornames=makenameforamount(armors)

-- weapon definitions
weapons=json_parse('{"d":{"name":"dagger","amount":8,"price":8},"c":{"name":"club","amount":12,"price":40},"a":{"name":"axe","amount":18,"price":75},"s":{"name":"sword","amount":30,"price":150},"t":{"name":"magic swd","amount":40}}')
weaponnames=makenameforamount(weapons)

-- spell definitions
spells=json_parse('{"a":{"name":"attack","cost":3,"amount":1},"x":{"name":"medic","cost":5,"amount":1,"price":8},"c":{"name":"cure","cost":7,"price":10},"w":{"name":"wound","cost":11,"amount":5},"e":{"name":"exit","cost":13},"s":{"name":"savior","cost":17,"amount":6,"price":25}}')

function setmap()
  local songstrt=curmap.songstart
  curmap=maps[mapnum]
  contents=curmap.contents
  if(songstrt and curmap.songstart)music(curmap.songstart)
  hero.hd=0
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
      if curmap.levels then
        maptype=basetypes[3]
      else
        maptype=basetypes[2]
      end
      makemetaobj(curmap,maptype)
    end
    curmap.width,curmap.height=curmap.maxx-curmap.minx,curmap.maxy-curmap.miny
    creatures[mapnum],curmap.contents={},{}
    for num=curmap.minx-1,curmap.maxx+1 do
      curmap.contents[num]={}
      for inner=curmap.miny-1,curmap.maxy+1 do
        curmap.contents[num][inner]={}
      end
    end
    for item in all(curmap.items) do
      item.objtype,xcoord,ycoord,zcoord=basetypes[item.idtype],item.xeno,item.yako,item.zabo or 0
      curmap.contents[xcoord][ycoord][zcoord]=makemetaobj(item)
      -- automatically make a corresponding ladder down for every ladder up
      if item.objtype.name=='ladder up' and maptype==dungeontype then
        zcoord-=1
        curmap.contents[xcoord][ycoord][zcoord]=makemetaobj{objtype=basetypes[9]}
      end
    end
    for creature in all(curmap.creatures) do
      creature.mn=mapnum
      creature.objtype=basetypes[creature.idtype]
      definemonster(creature)
    end
  end

  -- the hero is the player character. although human, it has
  -- enough differences that there is no advantage to inheriting
  -- the human type.
  hero=json_parse('{"img":0,"armor":0,"dmg":0,"xeno":7,"yako":7,"zabo":0,"exp":0,"lvl":0,"str":8,"int":8,"dex":8,"status":0,"hd":0,"facing":0,"gp":20,"food":25,"movepayment":0,"mp":8,"hp":24,"keys":0,"torches":5,"lit":0}')
  hero.color=rnd(10)>6 and 4 or 15
 
  -- make the map info global for efficiency
  mapnum=0
  setmap()

  -- creature 0 is the maelstrom and not really a creature at all,
  -- although it shares most creature behaviors.
  creatures[0]={}
  maelstrom=makemetaobj(json_parse('{"img":69,"imgseq":23,"name":"maelstrom","terrain":[12,13,14,15],"moveallowance":1,"xeno":13,"yako":61}'),anyobj)
  creatures[0][0]=maelstrom
  contents[13][61][0]=maelstrom

  turn=0
  turnmade=false
  cycle=0
  _update=world_update
  _draw=world_draw
  draw_state=world_draw
end

-- the lines list holds the text output displayed on the screen.
lines={"","","","",">"}
numoflines=5
curline=numoflines

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
  if _draw~=msg_draw then
    draw_state=_draw
    _draw=msg_draw
  end
end

attrlist={'armor','dmg','xeno','yako','str','int','dex','status','img','color','facing','keys','torches','exp','lvl','gp','food','mp','hp'}

function combinevalues(highval,lowval)
  return bor(shl(highval,8),lowval)
end

function savegame()
  if mapnum~=0 then
    update_lines{"sorry, only outside."}
  else
    local storagenum=0
    for heroattr in all(attrlist) do
      dset(storagenum,hero[heroattr])
      storagenum+=1
    end
    for creaturenum=1,12 do
      local creature=creatures[0][creaturenum]
      if creature then
        dset(storagenum,creature.idtype)
        dset(storagenum+1,combinevalues(creature.xeno,creature.yako))
      else
        dset(storagenum,0)
      end
      storagenum+=2
    end
    update_lines{"game saved."}
  end
end

function separatevalues(comboval)
  return lshr(band(comboval,0xff00),8),band(comboval,0xff)
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
      creaturexeno,creatureyako=separatevalues(dget(storagenum+1))
      definemonster{objtype=basetypes[creaturenum],xeno=creaturexeno,yako=creatureyako,mn=0}
      storagenum+=2
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
  if hero.mp>=spell.cost then
    hero.mp-=spell.cost
    update_lines{spell.name.." is cast! "..(extra or '')}
    return true
  else
    update_lines{"not enough mp."}
    return false
  end
end

function exitdungeon(targx,targy,targmapnum)
  hero.xeno,hero.yako,hero.zabo,hero.facing,mapnum=targx or curmap.enterx,targy or curmap.entery,0,0,targmapnum or curmap.mn
  setmap()
  _draw=world_draw
end

function entermap(targmap,targmapnum,targx,targy,targz)
  hero.xeno,hero.yako=targx or targmap.startx,targy or targmap.starty
  mapnum=targmapnum
  setmap()
  if targmap.dungeon then
     _draw=dungeon_draw
     hero.facing,hero.zabo=targmap.startfacing,targmap.startz
  end
  return "entering "..targmap.name.."."
end

function inputprocessor(cmd)
  while true do
    local spots=calculatemoves(hero)
    local xcoord,ycoord,zcoord=hero.xeno,hero.yako,hero.zabo
    local curobj=contents[xcoord][ycoord][zcoord]
    local curobjname=curobj and curobj.name or nil
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
        hero.xeno,hero.yako=checkmove(spots[2],ycoord,"west")
      end
    elseif cmd=='east' then
      if curmap.dungeon then
        hero.facing+=1
        if hero.facing>4 then
          hero.facing=1
        end
        update_lines{"turn right."}
        turnmade=true
      else
        hero.xeno,hero.yako=checkmove(spots[4],ycoord,"east")
      end
    elseif cmd=='north' then
      if curmap.dungeon then
        hero.xeno,hero.yako,hero.zabo=checkdungeonmove(1)
      else
        hero.xeno,hero.yako=checkmove(xcoord,spots[1],"north")
        if hero.xeno==121 and hero.yako==36 then
          mset(116,41,22)
          update_lines{"something clicks."}
        end
      end
    elseif cmd=='south' then
      if curmap.dungeon then
        hero.xeno,hero.yako,hero.zabo=checkdungeonmove(-1)
      else
        hero.xeno,hero.yako=checkmove(xcoord,spots[3],"south")
      end
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
          increasehp(spells[cmd].amount*hero.int)
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
          local spelldamage=ceil(rnd(spells[cmd].amount*hero.int))
          if not getdirection(spots,attack_results,spelldamage) then
            update_lines{'nothing to target.'}
          end
        end
      else
        update_lines{"cast: huh?"}
      end
      turnmade=true
    elseif cmd=='x' then
      update_lines{"examine dir:"}
      if not getdirection(spots,look_results) then
        if cmd=='x' then
          local response={"search","you find nothing."}
          signcontents=check_sign(xcoord,ycoord)
          if signcontents then
            response={"read sign",signcontents}
          elseif xcoord==1 and ycoord==38 and hero.dmg<50 then
            -- search response
            response[2]="you find the magic sword!"
            hero.dmg=40
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
      if curobjname=='fountain' then
        sfx(3)
        msg="healed by the fountain!"
        if curmap.dungeon and hero.hp<23 and hero[curmap.attr]<16 then
          hero[curmap.attr]+=1
          msg="you feel more capable!"
        end
        increasehp(100)
        update_lines{msg}
      elseif curobjname=='chest' then
        local chestgold=ceil(rnd(100))
        hero.gp+=chestgold
        update_lines{"you find "..chestgold.." gp."}
        contents[xcoord][ycoord][zcoord]=nil
      elseif curmap.dungeon and hero.lit<1 then
        if hero.torches>1 then
          hero.lit=50
          hero.torches-=1
          update_lines{"the torch is now aflame."}
        else
          update_lines{"you have no torches."}
        end
      else
        update_lines{"nothing here."}
      end
    elseif cmd=='e' then
      turnmade=true
      local msg="nothing to enter."
      if curobjname=='ladder up' or curobjname=='ladder down' then
        if curmap.dungeon then
          if zcoord==curmap.startz and xcoord==curmap.startx and ycoord==curmap.starty then
            msg="exiting "..curmap.name.."."
            exitdungeon()
          elseif curobjname=='ladder up' then
            msg="ascending."
            hero.zabo-=1
          else
            msg="descending."
            hero.zabo+=1
          end
        end
        if curobj.targetmap then
          if curmap.dungeon and not maps[curobj.targetmap].dungeon then
            exitdungeon(curobj.targetx,curobj.targety,curobj.targetmap)
          else
            msg=entermap(maps[curobj.targetmap],curobj.targetmap,curobj.targetx,curobj.targety,curobj.targetz)
          end
        end
      elseif hero.img>0 then
        msg="exiting ship."
        contents[xcoord][ycoord][zcoord]=makemetaobj{facing=hero.facing,objtype=shiptype}
        hero.img,hero.facing=0,0
      elseif curobjname=='ship' then
        msg="boarding ship."
        hero.img,hero.facing=70,curobj.facing
        contents[xcoord][ycoord][zcoord]=nil
      end
      for loopmapnum=1,#maps do
        local loopmap=maps[loopmapnum]
        if mapnum==loopmap.mn and xcoord==loopmap.enterx and ycoord==loopmap.entery then
          msg=entermap(loopmap,loopmapnum)
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
        "worn: "..armornames[hero.armor].."; wield: "..weaponnames[hero.dmg],
        hero.torches..' torches & '..hero.keys..' skeleton keys.'
      }
    elseif cmd=='a' then
      if hero.img>0 then
        update_lines{"fire dir:"}
      else
        update_lines{"attack dir:"}
      end
      if not getdirection(spots,attack_results) then
        update_lines{"attack: huh?"}
      end
      turnmade=true
    end
    if hero.lit>1 then
      hero.lit-=1
      if hero.lit<1 then
        update_lines{"the torch burnt out."}
      end
    end
    if _draw==dungeon_draw and hero.lit<1 then
      update_lines{"it's dark!"}
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
    resultfunc(adir,spots[4],hero.yako,magic)
  elseif adir=='west' or hero.facing==4 then
    resultfunc(adir,spots[2],hero.yako,magic)
  elseif adir=='north' or hero.facing==1 then
    resultfunc(adir,hero.xeno,spots[1],magic)
  elseif adir=='south' or hero.facing==3 then
    resultfunc(adir,hero.xeno,spots[3],magic)
  else
    return false
  end
  return true
end

function update_lines(msg)
  local prompt="> "
  for curmsg in all(msg) do
    lines[curline]=prompt..curmsg
    curline+=1
    if(curline>numoflines)curline=1
    prompt=""
  end
  lines[curline]=">"
end

function definemonster(monster)
  local objtype,xcoord,ycoord,zcoord=monster.objtype,monster.xeno,monster.yako,monster.zabo or 0
  monster.objtype=objtype
  makemetaobj(monster)
  if objtype.propername then
    monster.name=objtype.propername
  elseif objtype.names then
    monster.name=objtype.names[flr(rnd(#objtype.names)+1)]
  end
  --if(objtype.imgs)monster.img=objtype.imgs[flr(rnd(#objtype.imgs)+1)]
  if(objtype.colorsubs)monster.colorsub=objtype.colorsubs[flr(rnd(#objtype.colorsubs)+1)]
  monster.imgseq=flr(rnd(30))
  monster.imgalt=false
  add(creatures[monster.mn],monster)
  maps[monster.mn].contents[xcoord][ycoord][zcoord]=monster
  return monster
end

function create_monster()
  local monsterx=flr(rnd(curmap.width))+curmap.minx
  local monstery=flr(rnd(curmap.height))+curmap.miny
  local monsterz=curmap.dungeon and flr(rnd(#curmap.levels)+1) or 0
  if contents[monsterx][monstery][monsterz] or monsterx==hero.xeno and monstery==hero.yako and monsterz==hero.zabo then
    -- don't create a monster where there already is one
    monsterx=nil
  end
  if monsterx then
    local monsterspot=mget(monsterx,monstery)
    if curmap.dungeon then
      monsterspot=getdungeonblockterrain(monsterx,monstery,monsterz)
    end
    for objtype in all(terrainmonsters[monsterspot]) do
      if rnd(200)<objtype.chance then
        definemonster{objtype=objtype,xeno=monsterx,yako=monstery,zabo=monsterz,mn=mapnum}
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
  hero.gp=not_over_32767(hero.gp+amount)
end

function increasemp(amount)
  hero.mp=not_over_32767(min(hero.mp+amount,hero.int*(hero.lvl+1)))
end

function increasehp(amount)
  hero.hp=not_over_32767(min(hero.hp+amount,hero.str*(hero.lvl+3)))
end

-- world updates

function checkdungeonmove(direction)
  local newx,newy=hero.xeno,hero.yako
  local xcoord,ycoord,zcoord=hero.xeno,hero.yako,hero.zabo
  local cmd=direction>0 and 'advance' or 'retreat'
  local item
  local iscreature=false
  if hero.facing==1 then
    newy-=direction
    result=getdungeonblock(xcoord,newy,zcoord)
    item=contents[xcoord][newy][zcoord]
  elseif hero.facing==2 then
    newx+=direction
    result=getdungeonblock(newx,ycoord,zcoord)
    item=contents[newx][ycoord][zcoord]
  elseif hero.facing==3 then
    newy+=direction
    result=getdungeonblock(xcoord,newy,zcoord)
    item=contents[xcoord][newy][zcoord]
  else
    newx-=direction
    result=getdungeonblock(newx,ycoord,zcoord)
    item=contents[newx][ycoord][zcoord]
  end
  if item and item.hp then
    iscreature=true
  end
  if result==3 or iscreature then
    sfx(5)
    update_lines{cmd,"blocked!"}
  else
    xcoord,ycoord=newx,newy
    sfx(0)
    update_lines{cmd}
  end
  turnmade=true
  return xcoord,ycoord,zcoord
end

function checkexit(xcoord,ycoord)
  if not curmap.wrap and(xcoord>=curmap.maxx or xcoord<curmap.minx or ycoord>=curmap.maxy or ycoord<curmap.miny) then
    update_lines{cmd,"exiting "..curmap.name.."."}
    mapnum=0
    return true
  else
    return false
  end
end

function checkmove(xcoord,ycoord,cmd)
  local movesuccess=true
  local newloc=mget(xcoord,ycoord)
  local movecost=band(fget(newloc),3)
  local water=fget(newloc,2)
  local impassable=fget(newloc,3)
  local content=contents[xcoord][ycoord][hero.zabo]
  --update_lines(""..xcoord..","..ycoord.." "..newloc.." "..movecost.." "..fget(newloc))
  if hero.img>0 then
    if cmd=='north' then
      hero.facing=1
    elseif cmd=='west' then
      hero.facing='2'
    elseif cmd=='south' then
      hero.facing='3'
    else
      hero.facing='4'
    end
    local terraintype=mget(xcoord,ycoord)
    if checkexit(xcoord,ycoord) then
      xcoord,ycoord=curmap.enterx,curmap.entery
      setmap()
    elseif content then
      if content.name=='maelstrom' then
        update_lines{cmd,"maelstrom! yikes!"}
        deducthp(ceil(rnd(25)))
      else
        sfx(5)
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
    if checkexit(xcoord,ycoord) then
      xcoord,ycoord=curmap.enterx,curmap.entery
      setmap()
    elseif content then
      if not content.passable then
        sfx(5)
        movesuccess=false
        update_lines{cmd,"blocked!"}
      end
    elseif newloc==28 then
      update_lines{cmd,"open door."}
      movesuccess=false
      mset(xcoord,ycoord,30)
    elseif newloc==29 then
      if hero.keys>0 then
        update_lines{cmd,"you jimmy the door."}
        hero.keys-=1
        mset(xcoord,ycoord,30)
      else
        update_lines{cmd,"the door is locked."}
      end
      movesuccess=false
    elseif impassable then
      sfx(5)
      movesuccess=false
      update_lines{cmd,"blocked!"}
    elseif water then
      movesuccess=false
      update_lines{cmd,"not without a boat."}
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
    if hero.img==0 then
      sfx(0)
    end
    if newloc==5 and rnd(10)>6 then
      update_lines{cmd,"poisoned!"}
      hero.status=bor(hero.status,1)
    end
  else
    xcoord,ycoord=hero.xeno,hero.yako
  end
  turnmade=true
  return xcoord,ycoord
end

function check_sign(xcoord,ycoord)
  local response=nil
  if mget(xcoord,ycoord)==31 then
    -- read the sign
    for sign in all(curmap.signs) do
      if xcoord==sign.xeno and ycoord==sign.yako then
        response=sign.msg
        break
      end
    end
  end
  return response
end

function look_results(ldir,xcoord,ycoord)
  local cmd,signcontents,content="examine: "..ldir,check_sign(xcoord,ycoord),contents[xcoord][ycoord][hero.zabo] or nil
  if signcontents then
    update_lines{cmd.." (read sign)",signcontents}
  elseif content then
    update_lines{cmd,content.name}
  elseif curmap.dungeon then
    update_lines{cmd,getdungeonblockterrain(xcoord,ycoord,hero.zabo)==20 and 'passage' or 'wall'}
  else
    update_lines{cmd,terrains[mget(xcoord,ycoord)]}
  end
end

function dialog_results(ddir,xcoord,ycoord)
  local cmd="dialog: "..ddir
  if terrains[mget(xcoord,ycoord)]=='counter' then
    return getdirection(calculatemoves({xeno=xcoord,yako=ycoord}),dialog_results,nil,ddir)
  end
  local dialog_target=contents[xcoord][ycoord][hero.zabo]
  if dialog_target then
    if dialog_target.merch then
      update_lines{shop[dialog_target.merch]()}
    elseif dialog_target.talk then
      update_lines{cmd,'"'..dialog_target.talk[flr(rnd(#dialog_target.talk)+1)]..'"'}
    else
      update_lines{cmd,'no response!'}
    end
  else
    update_lines{cmd,'no one to talk with.'}
  end
end

function attack_results(adir,xcoord,ycoord,magic)
  local cmd="attack: "..adir
  local zcoord,creature=hero.zabo,contents[xcoord][ycoord][hero.zabo]
  local damage=flr(rnd(hero.str+hero.lvl+hero.dmg))
  if magic then
    damage+=magic
  elseif hero.img>0 then
    cmd="fire: "..adir
    damage+=rnd(50)
  end
  if creature and creature.hp then
    if magic or rnd(hero.dex+hero.lvl*8)>rnd(creature.dex+creature.armor) then
      damage-=rnd(creature.armor)
      if magic then
        creature.hitcolors=json_parse('[[9,6],[8,13],[10,12]]')
      elseif hero.img>0 then
        creature.hitcolors=json_parse('[[9,8],[8,9],[10,1]]')
      else
        creature.hitcolors=nil
      end
      creature.hd=3
      sfx(1)
      creature.hp-=damage
      if creature.hp<=0 then
        increasegold(creature.gp)
        increasexp(creature.exp)
        if creature.name=='pirate' then
          contents[xcoord][ycoord][zcoord]=makemetaobj{
            facing=creature.facing,
            objtype=shiptype
          }
        else
          contents[xcoord][ycoord][zcoord]=nil
        end
        update_lines{cmd,creature.name..' killed; xp+'..creature.exp..' gp+'..creature.gp}
        if creature.name=='faxon' then
          msg=winmsg
          _draw=msg_draw
        end
        del(creatures[mapnum],creature)
      else
        update_lines{cmd,'you hit the '..creature.name..'!'}
      end
      if curmap.friendly then
        for townie in all(creatures[mapnum]) do
          townie.hostile=true
          townie.talk={"you're a lawbreaker!","criminal!"}
          if townie.name=='guard' then
            townie.moveallowance=1
          end
        end
      end
    else
      update_lines{cmd,'you miss the '..creature.name..'!'}
    end
  elseif mget(xcoord,ycoord)==29 then
    -- bash locked door
    sfx(1)
    if(not magic)deducthp(1)
    if rnd(damage)>9 then
      update_lines{cmd,'you break open the door!'}
      mset(xcoord,ycoord,30)
    else
      update_lines{cmd,'the door is still locked.'}
    end
  else
    update_lines{cmd,'nothing to attack.'}
  end
end

function squaredistance(x1,y1,x2,y2)
  local dx=abs(x1-x2)
  if curmap.wrap and dx>curmap.width/2 then
    dx=curmap.width-dx;
  end
  local dy=abs(y1-y2)
  if curmap.wrap and dy>curmap.height/2 then
    dy=curmap.height-dy;
  end
  return dx+dy
end

function calculatemoves(creature)
  local maxx,maxy=curmap.maxx,curmap.maxy
  local creaturex,creaturey=creature.xeno,creature.yako
  local eastspot,westspot=(creaturex+curmap.width-1)%maxx,(creaturex+1)%maxx
  local northspot,southspot=(creaturey+curmap.height-1)%maxy,(creaturey+1)%maxy
  if not curmap.wrap then
    northspot,southspot,eastspot,westspot=creaturey-1,creaturey+1,creaturex-1,creaturex+1
    if creature~=hero then
      northspot,southspot,eastspot,westspot=max(northspot,curmap.miny),min(southspot,maxy-1),max(eastspot,curmap.minx),min(westspot,maxx-1)
    end
  end
  return {northspot,eastspot,southspot,westspot}
end

function movecreatures(hero)
  local gothit=false
  local actualdistance=500
  local xcoord,ycoord,zcoord=hero.xeno,hero.yako,hero.zabo
  for creaturenum,creature in pairs(creatures[mapnum]) do
    local cfacing,desiredx,desiredy,desiredz=creature.facing,creature.xeno,creature.yako,creature.zabo
    if desiredz==zcoord then
      while creature.moveallowance>=creature.nummoves do
        local spots=calculatemoves(creature)
        --foreach(spots,logit)
        if creature.hostile then
          -- most creatures are hostile; move toward player
          local bestfacing=0
          actualdistance=squaredistance(creature.xeno,creature.yako,xcoord,ycoord)
          local currentdistance=actualdistance
          local bestdistance=currentdistance
          for facing=1,4 do
            if facing%2==1 then
              currentdistance=squaredistance(creature.xeno,spots[facing],xcoord,ycoord)
            else
              currentdistance=squaredistance(spots[facing],creature.yako,xcoord,ycoord)
            end
            if currentdistance<bestdistance or (currentdistance==bestdistance and rnd(10)<5) then
              bestdistance,bestfacing=currentdistance,facing
            end
          end
          if bestfacing%2==1 then
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
              creature.facing=facing
              if facing%2==1 then
                desiredy=spots[facing]
              else
                desiredx=spots[facing]
              end
            end
          end
        end
        local newloc=mget(desiredx,desiredy)
        if curmap.dungeon then
          newloc=getdungeonblockterrain(desiredx,desiredy,desiredz)
        end
        local canmove=false
        for terrain in all(creature.terrain) do
          if newloc==terrain and creature.moveallowance>creature.nummoves then
            canmove=true
            break
          end
        end
        creature.nummoves+=1
        if creature.hostile and actualdistance<=1 then
          local hero_dodge=hero.dex+2*hero.lvl
          local creature_msg="the "..creature.name
          if creature.eat and hero.food>0 and rnd(creature.dex*23)>rnd(hero_dodge) then
            sfx(2)
            update_lines{creature_msg.." eats!"}
            deductfood(flr(rnd(6)))
            gothit=true
            delay(9)
          elseif creature.thief and hero.gp>0 and rnd(creature.dex*20)>rnd(hero_dodge) then
            sfx(2)
            local amountstolen=min(ceil(rnd(5)),hero.gp)
            hero.gp-=amountstolen
            creature.gp+=amountstolen
            update_lines{creature_msg.." steals!"}
            gothit=true
            delay(9)
          elseif creature.poison and rnd(creature.dex*15)>rnd(hero_dodge) then
            sfx(1)
            hero.status=bor(hero.status,1)
            update_lines{"poisoned by the "..creature.name.."!"}
            gothit=true
            delay(3)
          elseif rnd(creature.dex*64)>rnd(hero_dodge+hero.armor) then
            hero.gothit=true
            sfx(1)
            local damage=max(ceil(rnd(creature.dmg)-rnd(hero.armor)),0)
            deducthp(damage)
            update_lines{creature_msg.." hits!"}
            gothit=true
            delay(3)
            hero.hd=3
            hero.hitcolors=creature.attackcolors
          else
            update_lines{creature_msg.." misses."}
          end
          break
        elseif canmove then
          local movecost=band(fget(newloc),3)
          creature.movepayment+=1
          if creature.movepayment>=movecost and not contents[desiredx][desiredy][zcoord] and not (desiredx==xcoord and desiredy==ycoord and desiredz==zcoord) then
            contents[creature.xeno][creature.yako][creature.zabo]=nil
            contents[desiredx][desiredy][desiredz]=creature
            creature.xeno,creature.yako=desiredx,desiredy
            creature.movepayment=0
            break
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
    gothit=movecreatures(hero)
    if #creatures[mapnum]<curmap.maxmonsters and rnd(10)<curmap.newmonsters then
      create_monster()
    end
  end
end

-- drawing routines

function delay(numofcycles)
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
  local linestart,midlinestart,longlinestart=106,110,119
  print("cond",linestart,0,5)
  print(band(hero.status,1)==1 and 'p' or 'g',125,0,6)
  print("lvl",linestart,8,5)
  print(hero.lvl,125,8,6)
  print("hp",linestart,16,5)
  print(hero.hp,linestart+8,16,6)
  print("mp",linestart,24,5)
  print(hero.mp,linestart+8,24,6)
  print("$",linestart,32,5)
  print(hero.gp,midlinestart,32,6)
  print("f",linestart,40,5)
  print(hero.food,midlinestart,40,6)
  print("exp",linestart,48,5)
  print(hero.exp,linestart,55,6)
  print("dex",linestart,63,5)
  print(hero.dex,longlinestart,63,6)
  print("int",linestart,71,5)
  print(hero.int,longlinestart,71,6)
  print("str",linestart,79,5)
  print(hero.str,longlinestart,79,6)
  for linenum=1,numoflines do
    print(lines[(curline-linenum)%numoflines+1],0,128-linenum*8)
  end
end

function substitutecolors(colorsubs)
  if colorsubs then
    for colorsub in all(colorsubs) do
      pal(colorsub[1],colorsub[2])
    end
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
  substitutecolors(item.colorsub)
  return flipped
end

function draw_map(x,y,scrtx,scrty,width,height)
  map(x,y,scrtx*8,scrty*8,width,height)
  for contentsx=x,x+width-1 do
    for contentsy=y,y+height-1 do
      local item=contents[contentsx][contentsy][0]
      if item then
        local flipped=itemdrawprep(item)
        local facing=item.facingmatters and item.facing or 0
        spr(item.img+facing,(contentsx-x+scrtx)*8,(contentsy-y+scrty)*8,1,1,flipped)
        pal()
        if item.hd>0 then
          substitutecolors(item.hitcolors)
          spr(127,(contentsx-x+scrtx)*8,(contentsy-y+scrty)*8)
          pal()
          item.hd-=1
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
        xeno=mapx,
        yako=viewy
      })
    end
    if facing==4 then
      triplereverse(blocks)
    end
  else
    -- we're looking for a row
    for viewx=mapx-1,mapx+1 do
      add(blocks,{
        block=getdungeonblock(viewx,mapy,mapz),
        xeno=viewx,
        yako=mapy
      })
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
  if hero.lit>0 then
    local view=getdungeonview(hero.xeno,hero.yako,hero.zabo,hero.facing)
    for depthindex,row in pairs(view) do
      local depthin,depthout=(depthindex-1)*10,depthindex*10
      local topouter,topinner,bottomouter,bottominner=30-depthout,30-depthin,52+depthout,52+depthin
      local lowextreme,highextreme,middle,lowerase,higherase=30-depthout*2,52+depthout*2,42,31-depthin,51+depthin
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
        local leftoneback,centeroneback,rightoneback=view[depthindex-1][1].block,view[depthindex-1][2].block,view[depthindex-1][3].block
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
      dungeondrawobject(row[2].xeno,row[2].yako,hero.zabo,3-depthindex)
    end
    rectfill(82,0,112,82,0)
  end
  draw_stats()
end

function dungeondrawobject(xcoord,ycoord,zcoord,distance)
  if xcoord>0 and ycoord>0 then
    local item=contents[xcoord][ycoord][zcoord]
    if item then
      local flipped,distancemod,shiftmod,sizemod=itemdrawprep(item),distance*3,item.shiftmod or 0,item.sizemod or 0
      local xoffset,yoffset=20+distancemod+(sizemod*(distance+1)/8),35-(3-distance)*shiftmod
      local imgsize=60-sizemod-distancemod*4
      sspr(item.img%16*8,flr(item.img/16)*8,8,8,xoffset,yoffset,imgsize,imgsize,flipped)
      pal()
      if item.hd>0 then
        palt(0,true)
        substitutecolors(item.hitcolors)
        sspr(120,56,8,8,xoffset,yoffset,imgsize,imgsize)
        pal()
        item.hd-=1
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
  local maxx,maxy,minx,miny=curmap.maxx,curmap.maxy,curmap.minx,curmap.miny
  local width,height,wrap=curmap.width,curmap.height,curmap.wrap
  local xtraleft,xtratop,xtrawidth,xtraheight,scrtx,scrty,left,right=0,0,0,0,0,0,hero.xeno-halfwidth,hero.xeno+halfwidth
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
      left,right=minx,right%width+minx
    else
      xtrawidth=right-maxx+1
      right=maxx
    end
  end
  local top,bottom=hero.yako-halfheight,hero.yako+halfheight
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
      scrty,xtratop=xtraheight,top
      top,bottom=miny,bottom%height+miny
    else
      xtraheight=bottom-maxy+1
      bottom=maxy
    end
  end
  local mainwidth,mainheight=min(fullwidth-xtrawidth,curmap.width),min(fullheight-xtraheight,curmap.height)
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
  palt(0,false)
  if hero.color==4 and hero.img==0 then
    substitutecolors{{4,1},{15,4}}
  end
  spr(hero.img+hero.facing,48,40)
  pal()
  palt()
  if hero.hd>0 then
    substitutecolors(hero.hitcolors)
    spr(127,48,40)
    pal()
    hero.hd-=1
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
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c010100111015050110111111111111101110111111111110111101001110110104161616161616161614141415141d141
c0c0c0c0c0c040406060604040404040c0c0c0e0e0e0e0e0e0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0101001110150501101111111111111011101111111111101111010011101101041616161616161616141616161616141
e0e0c0c0c0c0404040606060104040c0c0e0e0e0e0e0e0e0e0c07070c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0101001110150501101111111111111011101111111111101111010011101101041616161616161616141614141414141
e0e0e0c0c0c01040104040404040c0c0e0e0e0e0e0e0e0e0e0c0105270c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0101001110150501101010101110101011101010111010101111010011101101041616161616161616171616161616141
e0c0c0c0c0c0c0424010404040c0c0e0e0e0e0e0e0e0e0e0e0c01010c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0101001110111111111111111111111111111111111111111111111011101101041614141414141714151414141416141
c040c0c0c0c0c0104010106010c0c0e0e0e0e0e0e0e0e0e0e0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0101001110111010101010101111010101010101011010101010111011101101041616161616141616161416161616141
c06040c0c0c0c0c04040104010c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e010100111011101111111110111104010c01040101101b3c3d20111011101101041414141416141616161516141414141
c04040c0e0e0c0c040401010c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e01010011101110192c2825301111010c0c0c0101011011111110111011101101041616161616171616161416161616141
c0c0c0e0e0e0e0c0c01010c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e01010011101110111111111011110c0c061c0c01011018293430111011101101041614141414141414171414141416141
e0c0c0e0e0e0e0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c080c0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0101001110111011111111101111010c061c010101101111111011101110110104161616141b141616161616161616141
e0e0e0e0e0e0e0e0e0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0e0e0c080a080c0c0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e010100111011101111111110111104010611040101111111111011101110110104141414141414141d141414141414141
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c080c0e0c070807070c0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0101001110111011111111111111010106110101011011111110111011101101001010101010101010101010101010101
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c080a080c07070328070c0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0101001110111011111111101111111111111111111011111110111011101101001111111110111011111111111111101
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c080c0c070808070c0e0e0e0c0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e010100111011101a3b363730111111111111111111101111111011101110110100192c2c293011101148253b2c293a301
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0e0e0c07070c0e0e0e0c080c0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0101001110111010101010101110111111111110111010101c1011101110110100111111111c111011111111111111101
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c0e0e0e0c080a080
c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0101001110111111111111111110111111111110111111111111111011101101001111111110111011111111111111101
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c080c0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0100101110101010110101010100111111111110110101010100101011101010101f282c3a3011101010101c101010101
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0100111111111110110101010108111111111118110101010100111111111110101010101010111111111111111111101
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0100111111111110101010101010111111111110101010101010111111111110101111111111111110101010101011101
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e010811111111111111111111111d11111111111d111111111111111111111118101110101810101110111111111011101
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e01001111111111101010101010101111111111101010101010101111111111101011101c0c0c0011101e26363b2011101
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e01001111111111101101010101001111111111101101010101001111111111101011181c062c081110111111111c11101
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e01001010181010101101010101010111111111110101010101001010181010101011101c061c001110111111111011101
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0101010101010101010101010101011111111111010101010101010101010101001110101c10101110111111111011101
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e02020202020404060606001538253a204349293c2e3a30140401041104110404001111111111111110111111111011131
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c0c0c0c0c0c0c0c0c0c0c0c03080807080303030c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0202020202020404010600111111111111111111111110140104141104141104001111111601111110111111111011101
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c0c0808070707070c0c0c0c080803090128030903030c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e06161616161206110404001c282b3344434b2930353230110104141104141101001111160406011110111111111011101
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c0807070908090807070c0c070808080709080803030c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e061616161616161404040011111111111111111111111014110411010104110410111604010406011c111111111011101
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c0803090809080308070c0c0c07080809070803030c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e02020202020616120202001111111111111111111111101411010101010101041011111604060111101c282b3a3011101
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c0c03030707030307070c0c0c0c0c0c080808030c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e020202010202061612020010101010101c101010101010141104110101041104101111111601111110101010101011101
e0e0e0c0c0c0c0c0c0c0c0c0c0e0c0c0c0c0c0c03080307070c0c080808070c0c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0202010101020206161612020202040406140402020202040404110101041404001111111111111111111111111111101
e0e0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0703090308070c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0101010101010102020616161616161616120202020202010404110101041401001010101010111111101010101010101
__label__
01d10000000000000000000005d67d00016765000000000000000000000000000056765000000000000000000000000000000000000000000000000000000000
06777777777600000000167777777600577777d00000000000000000000000000d77777500000000000000000000000000000000000000000000000000000000
0d7777777777d0000000d77777777100777777700000000000000000000000001777777700000000000000000000000000000000000000000000000000000000
0057777777776000000067777777d005777777750000000000000000000000005777777710000000000000000000000000000000000000000000000000000000
000d7777777771000001777777775005777777710000000000000000000000005777777710000000000000000000000000000000000000000000000000000000
00057777777775000005777777775000777777700000000000000000000000000777777600000000000000000000000000000000000000000000000000000000
00017777777776000006777777775000177777500000000000000000000000000577777100000000000000000000000000000000000000000000000000000000
0000777777777700000677777777500000d667d00000000000000000000000000016667d00000000000000000000000000000000000000000000000000000000
00007777777777100017777777775000001d77700000000d6d01dd6dd50000000001d777000000056d015d66d5000005d6d51000000565111155d6d500000000
000077777777775000d7777777775000567777700055dd6777d77777776000001567777700000d67776777777761056777777600001777766777777760000000
000077777777776000677777777750d7777777700677777777777777777600067777777700d6777777777777777767777777776100d777777777777776000000
000077777777777001776777777750777777777006777777777777777777d0177777777706777777777777777777777777777776006777777777777777500000
00007777777777710d775777777750d7777777700067777777777777777771067777777706777777777777777777777777777777606777777777777777600000
000077677777777d067657777777500d77777770005777777777777777777600677777770577777777777777777777777777777771d777777616777777710000
0000776d77777776077d57777777500d7777777000577777777d567777777700d777777700677777777d567777777765677777777617777777d1777777750000
0000776577777776d77557777777500d77777770005777777760007777777750d777777700d77777775001777777770006777777760d777777d07777777d0000
0000776077777777777057777777500d777777700057777777d000d7777777d0d777777700d77777770000777777760001777777771056777610d77777760000
00007760677777777760577777775005777777700057777777d0001777777760d777777700d77777770000777777760000677777775005777777677777760000
00007760577777777750d77777775005777777700017777777d00006777777605777777700d77777770000777777760000677777775067777777777777771000
00007760177777777700d77777775005777777700017777777d00006777777605777777700d77777770000777777760000d77777775677777777777777775000
00017760067777777600d77777775005777777700017777777d00006777777605777777700577777770000777777770000d77777776777777777777777775000
00017760067777777500d77777775005777777700017777777d00006777777605777777700577777770000777777770000d7777777777777777777777777d000
00057760057777777100d77777775001777777700017777777d00006777777605777777700577777770000777777770000d777777777777776d7777777776000
00057770017777776000d7777777d005777777710017777777d00006777777d05777777700577777770000777777770000d77777777777777505d67777776000
000d777000677777d00067777777d005777777710017777777d00006777777505777777700577777770000777777770000d77777777777777500067777777100
0006777100577777500067777777d0057777777100177777776000067777771057777777005777777700007777777700006777777d7777777d00577777777100
00077775000777771000677777776005777777710057777777700007777776005777777700d777777700007777777700006777777167777777dd677777777d00
00577776000677760001777777777005777777750057777777700017777775005777777750d7777777100077777777100077777760d777777777777777777600
006777776005777d000d777777777d067777777710677777777500d777776001777777777567777777600577777777600d777777005777777777777777777750
067777777d0077710057777777777777777777777677777777775077777750167777777777777777777657777777777d0777777d000577777777777777777775
6777777777106760006777777777777777777777777777777777d677777d001777777777777777777777777777777776d777776000005677777777d777777776
1777777776005750005777777777776677777777d5677777777657777770000d7777777776667777776d16666666666567777700000000d7777761017777777d
0000000000000000000000000000000000000000000000000000d777760000000000000000000000000000000000000d77776000000000001110000000000110
00000000000000000000000000000000000000000000000000006777d000000000000000000000000000000000000006777d0000000000000000000000000000
0000000000000000000000000000000000000000000000000000d6d000000000000000000000000000000000000000016d100000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc00
0cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000101101010001011100000101110000110ccccc
cccc000000330000003300000033000000055000000550000005500000330000003300000033000000000000000000000000111000001110000011100000cccc
ccc01000033330000333300003333000005005000050050000500500033330000333300003333000000300000100010100110100001101000011010000110ccc
ccc30000033333300333333003333330005000500050005000500050033333300333333003333330003330001010101011000010110000101100001011000ccc
ccc00000003303330033033300330333050000050500000505000005003303330033033300330333000300300001000000000000000000000000000000000ccc
ccc01001030033330300333303003333500055005000550050005500030033330300333303003333000003330000000000011100000111000001110000011ccc
ccc00330333303303333033033330330500500505005005050050050333303303333033033330330003000300100010101101000011010000110100001101ccc
ccc10000333300003333000033330000005000050050000500500005333300003333000033330000033300001010101010000101100001011000010110000ccc
ccc00000033000000330000003300000000000000000000000000000033000000330000003300000003000000001000000000000000000000000000000000ccc
ccc00000000000000000050000000500000550000005500000055000000550000000050000000500000000000000000000000000000011100000111000001ccc
ccc01000010010000050505000505050005005000050050000500500005005000050505000505050010001010100010101000101001101000011010000110ccc
ccc30000003300000505000505050005005000500050005000500050005000500505000505050005101010101010101010101010110000101100001011000ccc
ccc00000000000005000500050005000050000050500000505000005050000055000500050005000000100000001000000010000000000000000000000000ccc
ccc01001000010010005050000050500500055005000550050005500500055000005050000050500000000000000000000000000000111000001110000011ccc
ccc00330000003300050050000500500500500505005005050050050500500500050050000500500010001010100010101000101011010000110100001101ccc
ccc10000100100000500005005000050005000050050000500500005005000050500005005000050101010101010101010101010100001011000010110000ccc
ccc00000033000000000000000000000000000000000000000000000000000000000000000000000000100000001000000010000000000000000000000000ccc
ccc30000000005000000050000055000000550000005500000006000000550000000050000000500000000000000000000000000000000000000000000001ccc
ccc33000005050500050505000500500005005000050050000066600005005000050505000505050010001010003000000030000010001010100010100110ccc
ccc33330050500050505000500500050005000500050005000d00600005000500505000505050005101010100033300000333000101010101010101011000ccc
ccc30333500050005000500005000005050000050500000505000d00050000055000500050005000000100000003003000030030000100000001000000000ccc
ccc03333000505000005050050005500500055005000550005050050500055000005050000050500000000000000033300000333000000000000000000011ccc
ccc30330005005000050050050050050500500505005005050005050500500500050050000500500010001010030003000300030010001010100010101101ccc
ccc30000050000500500005000500005005000050050000500005005005000050500005005000050101010100333000003330000101010101010101010000ccc
ccc00000000000000000000000000000000000000000000000000000000000000000000000000000000100000030000000300000000100000001000000000ccc
ccc00000000000000000050000000500000005000000050000000500000005000000030000000300000000000000000000000300000003000000000000000ccc
ccc30000000300000050505000505050005050500050505000505050005050500300000003000000010001015505505503000000030000000100010101000ccc
ccc33000003330000505000505050005050500050505000505050005050500050000000000000000101010106666666600000000000000001010101010101ccc
ccc30030000300305000500050005000500050005000500050005000500050000003000000030000000100006566665600030000000300000001000000010ccc
ccc00333000003330005050000050500000505000005050000050500000505000000000300000003000000006565565600000003000000030000000000000ccc
ccc00030003000300050050000500500005005000050050000500500005005000000000000000000010001016664466600000000000000000100010101000ccc
ccc30000033300000500005005000050050000500500005005000050050000500000300000003000101010106664466600003000000030001010101010101ccc
ccc00000003000000000000000000000000000000000000000000000000000003000000030000000000100000000000030000000300000000001000000010ccc
ccc00000000000000000000000000500000005000000050000000500600ff0000000030000000300000000000000030000000300000003000000000000000ccc
ccc30000000300000003000000505050005050500050505000505050600ff5500300000003000000010001010300000003000000030000000100010101000ccc
ccc33000003330000033300005050005050500050505000505050005609855550000000000000000101010100000000000000000000000001010101010101ccc
ccc30030000300300003003050005000500050005000500050005000688955550003000000030000000100000003000000030000000300000001000000010ccc
ccc00333000003330000033300050500000505000005050000050500f89995500000000300000003000000000000000300000003000000030000000000000ccc
ccc00030003000300030003000500500005005000050050000500500009095500000000000000000010001010000000000000000000000000100010101000ccc
ccc30000033300000333000005000050050000500500005005000050004004000000300000003000101010100000300000003000000030001010101010101ccc
ccc00000003000000030000000000000000000000000000000000000044004403000000030000000000100003000000030000000300000000001000000010ccc
ccc00000000000000000000000000000000000000000050000000500000003000000030000000300000003000000030000000300000003000000000000000ccc
ccc30000000300000003000000030000000300000050505000505050030000000300000003000000030000000300000003000000030000000100010101000ccc
ccc33000003330000033300000333000003330000505000505050005000000000000000000000000000000000000000000000000000000001010101010101ccc
ccc30030000300300003003000030030000300305000500050005000000300000003000000030000000300000003000000030000000300000001000000010ccc
ccc00333000003330000033300000333000003330005050000050500000000030000000300000003000000030000000300000003000000030000000000000ccc
ccc00030003000300030003000300030003000300050050000500500000000000000000000000000000000000000000000000000000000000100010101000ccc
ccc30000033300000333000003330000033300000500005005000050000030000000300000003000000030000000300000003000000030001010101010101ccc
ccc00000003000000030000000300000003000000000000000000000300000003000000030000000300000003000000030000000300000000001000000010ccc
ccc00300000003000000030000000300000000000000050000000300000003000000030000000300000003000000030000000300000003000000000000000ccc
ccc00000030000000300000003000000000300000050505003000000030000000300000003000000030000000300000003000000030000000100010101000ccc
ccc00000000000000000000000000000003330000505000500000000000000000000000000000000000000000000000000000000000000001010101010101ccc
ccc30000000300000003000000030000000300305000500000030000000300000003000000030000000300000003000000030000000300000001000000010ccc
ccc00003000000030000000300000003000003330005050000000003000000030000000300000003000000030000000300000003000000030000000000000ccc
ccc00000000000000000000000000000003000300050050000000000000000000000000000000000000000000000000000000000000000000100010101000ccc
ccc03000000030000000300000003000033300000500005000003000000030000000300000003000000030000000300000003000000030001010101010101ccc
ccc00000300000003000000030000000003000000000000030000000300000003000000030000000300000003000000030000000300000000001000000010ccc
ccc00300000003000000030000000300000003000000030000000300000003000000030000000300000003000000030000000000000000000000000000000ccc
ccc00000030000000300000003000000030000000300000003000000030000000300000003000000030000000300000001000101010001010100010100030ccc
ccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010101010101010101010101000333ccc
ccc30000000300000003000000030000000300000003000000030000000300000003000000030000000300000003000000010000000100000001000000030ccc
ccc00003000000030000000300000003000000030000000300000003000000030000000300000003000000030000000300000000000000000000000000000ccc
ccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000101010001010100010100300ccc
ccc03000000030000000300000003000000030000000300000003000000030000000300000003000000030000000300010101010101010101010101003330ccc
ccc00000300000003000000030000000300000003000000030000000300000003000000030000000300000003000000000010000000100000001000000300ccc
ccc00500000005000033000000330000000000000000000000000000000003000000030000000300000000000000000000000000000000000000000000000ccc
ccc05050005050500333300003333000000300000003000000030000030000000300000003000000010001010100010100030000010001010100010100030ccc
ccc50005050500050333333003333330003330000033300000333000000000000000000000000000101010101010101000333000101010101010101000333ccc
ccc05000500050000033033300330333000300300003003000030030000300000003000000030000000100000001000000030030000100000001000000030ccc
ccc50500000505000300333303003333000003330000033300000333000000030000000300000003000000000000000000000333000000000000000000000ccc
ccc00500005005003333033033330330003000300030003000300030000000000000000000000000010001010100010100300030010001010100010100300ccc
ccc00050050000503333000033330000033300000333000003330000000030000000300000003000101010101010101003330000101010101010101003330ccc
ccc00000000000000330000003300000003000000030000000300000300000003000000030000000000100000001000000300000000100000001000000300ccc
ccc00500000005000033000000000000000000000033000000330000000000000000030000000000003300000000000000000000000000000000000000000ccc
ccc05050005050500333300000030000000300000333300003333000000300000300000001000101033330000003000000030000010001010100010100030ccc
ccc50005050500050333333000333000003330000333333003333330003330000000000010101010033333300033300000333000101010101010101000333ccc
ccc05000500050000033033300030030000300300033033300330333000300300003000000010000003303330003003000030030000100000001000000030ccc
ccc50500000505000300333300000333000003330300333303003333000003330000000300000000030033330000033300000333000000000000000000000ccc
ccc00500005005003333033000300030003000303333033033330330003000300000000001000101333303300030003000300030010001010100010100300ccc
ccc00050050000503333000003330000033300003333000033330000033300000000300010101010333300000333000003330000101010101010101003330ccc
ccc00000000000000330000000300000003000000330000003300000003000003000000000010000033000000030000000300000000100000001000000300ccc
ccc00500000005000000000000000000000000000033000000330000003300000000000000000000003300000000000000000000000000000000000000000ccc
ccc05050005050500003000000030000000300000333300003333000033330000003000001000101033330000003000000030000010001010100010101000ccc
ccc50005050500050033300000333000003330000333333003333330033333300033300010101010033333300033300000333000101010101010101010100ccc
cccc500050005000000300300003003000030030003303330033033300330333000300300001000000330333000300300003003000010000000100000001cccc
ccccc5000005050000000333000003330000033303003333030033330300333300000333000000000300333300000333000003330000000000000000000ccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
0cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0
00cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc00

__gff__
0000000001010201020303830484048408000800080000080800000008080000000000000000080008080808080808080808080808080808080808080808080808080808080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0e0c0c0c0c0c0c0c0c0c0c060c0e0e0e0e0c0c0c0c0e0e0c0c0c0803030303080e0e0e0e0e0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e10101010101010101010101010101010101010101010131010101010101010101010101010101010100c101010101010
0c0606060506060707070606040c0e0e0e0c06060c0c0c0708080809030809080c0e0e0e0e0c0707070c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e100101010101010101010101010101010101010101010404101111111110040101010401103a2c28100c0c0101013410
0c04040605050708080808070c0c0c0e0c0c0606040104080809090303090908070c0e0e0e070303030707040c0c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c100110101810100101011010101010101010101010101004102839343a1001040104040410111111100c0c0c01012810
0c01040406070808080908070c04040c0c0c040101010107080909030309030308070c0c0c0407030303030704050c0c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c1001100c0c0c10010101101111111111111111111111100110111111111004040101040410373c2910020c0c0c013910
0c01010404040707070808010c24010c0124010104040707070807090903080807070c0404040407040407040505050c0c06040c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c041001180c260c18010101102e36362b433235302e2f3b100110111111111c111111111104101111111d02020c0c0c3010
0101010104040404070801010101010c010101010101040707070807080807072107070401040406040404040605050c0606060c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c041001100c160c1001010110111111111111111111111110011010101010100101010111041011111110020202020c3510
0c0c010101010104070101010101010c010101010101010404070704060707070607060401010606060606040606050c0620060c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c100110101610100101011011111111111111111111111001100101010101010101011101101111111002020202022810
0c0c0c0c010101010101010101010c0e040401010101010404010404040606060606060601010504060606060605050c060606040c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c10010101010101010101101111111111111111111111100110010101010101010101110110101c10101810181d181010
0c01010107010604040401010c0c040c0404060406040101040401010404060606060606040505050404060605050c0c040606040c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c100110101010100101011011111010101010101010101001101010101010101001011111111111111111111111040410
0c010107070704040606040c0604040c0c0406060601010101010401010104040606040401050c0c050505050c0c0c04040406040c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c1001101111111001010101111101010101010101010101011011111111111110010111040101010101010101011f0410
0c010708080701060606040c06040c0c010c0606010101010101010101040404040606010405050c0c0c050c0c050c04040406040c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c100110434343100101011111110101010101010101010101102e39362a2c391001041104010101010101010101010110
0c0c01082108070104060606040c0c0c01010c010101010101010101010c04040404040401050505050c0c0c05050c0c0406040c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e100110111111100101111111010101010101010101010101101111111111111c11111111010110101010101010101010
0e0c0c0c07070c0c01040401010c0e0c010101010101010101010c0c0c0c0c0c0c05040404050505050505050505050c0404040c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e100118111111180101111101011010101010101010101001101111111111111001010411010110111111111111111110
0e0e0e0c0c0c0c0c0c01010c0c0c0c0c0c01010101010104040c0c0c0e0e0c0c0c050505040505050505050505050c0c04040c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e1001101111111001111111010110111111111111111110011011111111111110010101110104102f363a37303b283310
0e0e0e0c0c0c0c05050101010c0505050c0c01010104010404040c0c0c0e0e0c0c0c050505050505050505050c0c0c0404070c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e10011011111110011111010101102d36362b3428393b1001101010101010101001010111040410111111111111111110
0e0e0c0c07070505040101050504040405050c05050101010404040c0c0c0c0c0c0c0505050505050505050c0c01010407070c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e10011011111111111111010101101111111111111111100110010101010101010101011111111c111111111111111110
0e0c0c070707070404010505040404040101050101010101010101010c0c0c0505050505010101010505050c0c010407070c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e100110111111111111110101011011111111111111111001100101010101040601010111040410111111111111111110
0c010707080804040101010101010101010101010101010101010601010101010505050101010c0c0c0c050c0c010407070c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e1001101111111001111101010110101010101111101010011001010106040104010101110401101c10101c10101c1010
0c0707080804010101070707070101010101010101010106040401040401060406010101010c0c01010c0c0c010107070c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c100110342c2b100111110101010101010101111101010101100101010401010106010111010110111110111110111110
0c0c08060401010107070202020707070707070101040606060604060606060404010101010c01010101010101220c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c1001101010101001111111111f1111111111111101010101100101060401040401010111110110111110111110111110
0c0c06080601040702020202020202020202070707040406060606060606040606010101011901010106040407070c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c100101010101010101111111111111111111111101010101100101010404060101010404110410101010101010101010
0c0c0c060401080702020202020202020202020207040404060606060404040404010101010c010106060404070c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c100401010101010101010411111104010101010101010104100101010101010101040404110404010101010101040110
0c0c0c040101010702020202020202020202020208040404060604040406060c0c04040c0c0c0404060404070c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c100404010101010101040411111104040101010101010404100101010101010101040411111104040101040401010110
0c0c0c01010104040702020202020202020202020704060606040406040606060c0c0c0c040606060404070c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c101010101010101010100411111104101010101010101010101010101010101010101011111110101010101010101010
0c0c010101040408040702020202020202020707040404060c01060606040604040404040606060c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c101010181010100101010101010101010101010101010101011010101810101014141414141414141414141414141414
0c01010101010404040407070707080807070704040404060c01010606010106060101010c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c101111111111101010101010101010101010101013101010101011111111111014161616161616161614161616161614
0c0c0c0c06040601010406060404070707040505050404040c0c010101010101010c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c10111111111111111111111111111111111111111111111111111111111111101416161616161616161416161b161614
0707010c0404010101040406060404040404050505050c04040c0c0c0c0c0c0c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c181111111111101010101010101010101010101010101010101011111111111814161616161616161614161616161614
082001190101010101060401010c0c0c050505050c0c0c0c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c101111111111101111111111111111111111111111111111111011111111111014161616161616161614161616161614
0701010c0c0c0c0101040401010c0c0c0c0c0c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c101111111111101110101010101010101110101010101010111011111111111014161616161616161614161616161614
0704010c0101010c0104060101040c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c101010111010101110111111111111101110111111111110111010101110131014161616161616161614161616161614
0c040c0c040101010101010101040c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0101101113050511102b2c2d2c353a101110342c2b302a10110101101110010114161616161616161617161616161614
__sfx__
000100002365024650206501e64000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000245202a6403075034660367703667034770326602f6602d75029650297502a640296402b7402c6502e6502f7502f6502d640296302563022720000000000000000000000000000000000000000000000
0001000017070160601505016050170501a06021060290702f0700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000276432f4732f4732f4732f4732f4732f4733b1733b2733b2733b2733b2733b2733b2733b2733b2733b2733b2333851500000000000000000000000000000000000000000000000000000000000000000
0002000002643024730347305473074730a4730d47311173162731b2731f27324273292732d27331273362733b2733e2333f51500000000000000000000000000000000000000000000000000000000000000000
000100001263113341164511335117451133511544111341144310e331114210b3210c411073110a41104611236011f6002f50029500235001e5001e500225002750029500255001f5001e500000000000000000
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
000100001050112501195012050124501000010e50111501165011b501235012a50100001000010c5010e501155011d50122501255010000100001095010c50111501175011d5012450129501000010000100001
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

