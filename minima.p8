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
anyobj={f=1,mva=0,nm=0,mvp=0,hd=0,ch=0,z=0}

function makemetaobj(base,basetype)
  return setmetatable(base,{__index=base.ot or basetype})
end

-- the types of terrain that exist in the game. each is
-- given a name and a list of allowed monster types.
terrains={"plains","bare ground","tundra","scrub","swamp","forest","foothills","mountains","tall mountain","volcano","volcano","water","water","deep water","deep water","brick","brick road","brick","mismatched brick","stone","stone","road","barred window","window","bridge","ladder down","ladder up","door","locked door","open door","sign","shrine","dungeon","castle","tower","town","village","ankh"}
--terrains=json_parse('["plains","bare ground","tundra","scrub","swamp","forest","foothills","mountains","tall mountain","volcano","volcano","water","water","deep water","deep water","brick","brick road","brick","mismatched brick","stone","stone","road","barred window","window","bridge","ladder down","ladder up","door","locked door","open door","sign","shrine","dungeon","castle","tower","town","village","ankh"]')
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
basetypes=json_parse('[{"t":[1,2,3,4,5,6,7,8,17,18,22,25,26,27,30,31,33,35],"gp":10,"hp":10,"ch":1,"mva":1,"hos":1,"ar":1,"exp":2,"dex":8,"dmg":13},{"mxx":128,"mn":0,"fri":1,"mxy":64,"mnx":80,"mxm":0,"newm":0,"mny":0},{"sz":1,"sy":1,"sx":1,"mnx":1,"sf":1,"dg":1,"c":{},"mxm":27,"mn":0,"ss":17,"mxy":9,"fri":false,"newm":25,"mxx":9,"mny":1},{"i":38,"ia":38,"n":"ankh","d":["yes, ankhs can talk.","shrines make good landmarks."]},{"ia":70,"p":1,"i":70,"f":2,"n":"ship","fm":1},{"ia":92,"shm":-2,"i":92,"szm":11,"n":"chest","p":1},{"iseq":12,"n":"fountain","fi":1,"i":39,"szm":14,"shm":-2,"p":1},{"ia":27,"shm":12,"i":27,"szm":20,"n":"ladder up","p":1},{"ia":26,"shm":-3,"i":26,"szm":20,"n":"ladder down","p":1},{"hos":false,"i":80,"exp":1,"gp":5,"ar":0},{"n":"orc","ch":8,"d":["urg!","grar!"]},{"dmg":14,"gp":5,"ch":5,"dex":6},{"dex":10,"gp":0,"ch":3,"ar":0},{"dex":9,"n":"fighter","cs":[{},[[1,12],[14,2],[15,4]]],"d":["check out these pecs!","i\'m jacked!"],"i":82,"hp":12,"dmg":20,"ar":3},{"ar":12,"n":"guard","cs":[{},[[15,4]]],"d":["behave yourself.","i protect good citizens."],"i":90,"hp":85,"dmg":60,"mva":0},{"n":"merchant","fi":1,"d":["consume!","stuff makes you happy!"],"i":75,"cs":[{},[[1,4],[4,15],[6,1],[14,13]],[[1,4],[6,5],[14,10]],[[1,4],[4,15],[6,1],[14,3]]]},{"n":"lady","fi":1,"d":["pardon me.","well i never."],"i":81,"cs":[{},[[2,9],[4,15],[13,14]],[[2,10],[4,15],[13,9]],[[2,11],[13,3]]]},{"i":76,"n":"shepherd","cs":[{},[[6,5],[15,4]],[[6,5]],[[15,4]]],"d":["i like sheep.","the open air is nice."]},{"i":78,"n":"jester","dex":12,"d":["ho ho ho!","ha ha ha!"]},{"i":84,"n":"mage","ac":[[9,6],[8,13],[10,12]],"d":["a mage is always on time.","brain over brawn."]},{"cs":[{},[[9,11],[1,3],[15,4]],[[9,11],[1,3]],[[15,4]]],"n":"ranger","fi":1,"d":["i travel the land.","my home is the range."]},{"hos":1,"n":"villain","d":["stand and deliver!","you shall die!"],"ar":1,"exp":5,"gp":15},{"mch":"food","n":"grocer"},{"mch":"armor","n":"armorer"},{"mch":"weapons","n":"smith"},{"mch":"hospital","n":"medic"},{"mch":"guild","n":"guildkeeper"},{"mch":"bar","n":"barkeep"},{"i":96},{"n":"troll","exp":4,"i":102,"hp":15,"gp":10,"dmg":16},{"exp":3,"gp":8,"i":104,"hp":15,"dmg":14,"ns":["hobgoblin","bugbear"]},{"exp":1,"gp":5,"i":114,"hp":8,"dmg":10,"ns":["goblin","kobold"]},{"n":"ettin","fi":1,"exp":6,"i":118,"hp":20,"ch":1,"dmg":18},{"i":98,"n":"skeleton","gp":12},{"i":100,"hp":10,"ns":["zombie","wight","ghoul"]},{"d":["boooo!","feeear me!"],"fi":1,"t":[1,2,3,4,5,6,7,8,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,33,35],"i":123,"hp":15,"exp":7,"ns":["phantom","ghost","wraith"]},{"exp":10,"cs":[{},[[2,8],[15,4]]],"d":["i hex you!","a curse on you!"],"i":84,"dmg":18,"ac":[[9,6],[8,13],[10,12]],"ns":["warlock","necromancer","sorcerer"]},{"cs":[{},[[1,5],[8,2],[4,1],[2,12],[15,4]]],"dex":10,"i":88,"th":1,"ch":2,"ns":["rogue","bandit","cutpurse"]},{"exp":8,"cs":[{},[[1,5],[15,4]]],"d":["you shall die at my hands.","you are no match for me."],"i":86,"gp":10,"po":1,"ns":["ninja","assassin"]},{"n":"giant spider","exp":5,"i":106,"hp":18,"gp":8,"po":1},{"n":"giant rat","exp":2,"eat":1,"i":108,"hp":5,"po":1,"dmg":10},{"po":1,"exp":6,"t":[4,5,6,7],"i":112,"hp":20,"ch":1,"ns":["giant snake","serpent"]},{"n":"sea serpent","t":[5,12,13,14,15,25],"i":116,"hp":45,"exp":10},{"n":"megascorpion","fi":1,"exp":5,"i":125,"hp":12,"ch":1,"po":1},{"exp":2,"eat":1,"cs":[{},[[3,9],[11,10]],[[3,14],[11,15]]],"t":[17,22,23],"i":122,"gp":5,"fi":1,"ns":["slime","jelly","blob"]},{"exp":8,"t":[12,13,14,15],"i":94,"hp":50,"ch":2,"ns":["kraken","giant squid"]},{"n":"wisp","fi":1,"t":[4,5,6],"i":120,"exp":3},{"exp":8,"n":"pirate","cs":[[[6,5],[7,6]]],"t":[12,13,14,15],"i":70,"f":1,"fi":false,"fm":1},{"cs":[{},[[2,14],[1,4]]],"t":[17,22],"i":119,"exp":4,"fi":1,"ns":["gazer","beholder"]},{"fi":1,"ac":[[9,6],[8,13],[10,12]],"hp":50,"ns":["dragon","drake","wyvern"],"exp":17,"i":121,"gp":20,"dmg":28,"ar":7},{"t":[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,22,25,26,27,30,31,33,35],"ac":[[9,10],[8,9],[10,7]],"hp":50,"ch":0.25,"ns":["daemon","devil"],"exp":15,"i":110,"gp":25,"dmg":23,"ar":3},{"th":1,"n":"mimic","exp":4,"t":[17,22],"i":92,"gp":12,"ch":0,"mva":0},{"fi":1,"t":[17,22],"gp":8,"hp":30,"ch":0,"mva":0,"n":"reaper","i":124,"exp":5,"ar":5}]')
-- give our base objects ns for convenience & efficiency.
shiptype=basetypes[5]

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
    basetype=basetypes[1]
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
    basetype=basetypes[1]
  end
  objecttype.id=basetypenum
  makemetaobj(objecttype,basetype)
  if basetypenum>28 then
    for terrain in all(objecttype.t) do
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
  return desireditem and purchasefunc(desireditem) or desireditem==false and "you cannot afford that." or "no sale."
end

function purchasedetail(desireditem)
  if desireditem and desireditem.p then
    return hero.gp>=desireditem.p and desireditem
  else
    return nil
  end
end

-- makes a purchase if all is in order.
function purchase(prompt,itemtype,attribute)
  return checkpurchase(prompt,
    function(cmd)
      return purchasedetail(itemtype[cmd])
    end,
    function(desireditem)
      if hero[attribute]>=desireditem.a then
        return "that is not an upgrade."
      else
        hero.gp-=desireditem.p
        hero[attribute]=desireditem.a
        return "the "..desireditem.n.." is yours."
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
        hero.fd=not_over_32767(hero.fd+25)
        return "you got more food."
      end
    )
  end,
  armor=function()
    return purchase({"buy \131cloth $12, \139leather $99,","\145chain $300, or \148plate $950: "},armors,'ar')
  end,
  weapons=function()
    return purchase({"buy d\65\71\71\69\82 $8, c\76\85\66 $40,","a\88\69 $75, or s\87\79\82\68 $150: "},weapons,'dmg')
  end,
  hospital=function()
    return checkpurchase({"choose m\69\68\73\67 ($8), c\85\82\69 ($10),","or s\65\86\73\79\82 ($25): "},
      function(cmd)
        desiredspell=spells[cmd]
        return purchasedetail(desiredspell)
      end,
      function(desiredspell)
        sfx(3)
        hero.gp-=desiredspell.p
        if desiredspell.n=='cure' then
          -- perform cure
          hero.st=band(hero.st,14)
        else
          -- perform healing
          increasehp(desiredspell.a)
        end
        return desiredspell.n.." is cast!"
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
        rumors=json_parse('["faxon has many guards.","faxon is very powerful.","fountains respect injury.","dungeon fountains rule.","faxon fears a magic sword.","watch for secret doors.","fighters can bust doors.","good mages can zap doors."]')
        update_lines{"while socializing, you hear:"}
        return '"'..rumors[flr(rnd(8)+1)]..'"'
      end
    )
  end,
  guild=function()
    return checkpurchase({"5 \139torches $12 or a \145key $23: "},
      function(cmd)
        local desiredtool=tools[cmd]
        return purchasedetail(desiredtool)
      end,
      function(desireditem)
        hero.gp-=desireditem.p
        hero[desireditem.attr]+=desireditem.q
        return "you purchase "..desireditem.n
      end
    )
  end
}

-- add numerical references to names by amounts
function makenameforamount(itemtype)
  nameforamount={}
  for itemcmd,item in pairs(itemtype) do
    nameforamount[item.a]=item.n
  end
  nameforamount[0]='none'
  return nameforamount
end

-- armor definitions
armors=json_parse('{"south":{"n":"cloth","a":8,"p":12},"west":{"n":"leather","a":23,"p":99},"east":{"n":"chain","a":40,"p":300},"north":{"n":"plate","a":70,"p":950}}')
armornames=makenameforamount(armors)

-- weapon definitions
weapons=json_parse('{"d":{"n":"dagger","a":8,"p":8},"c":{"n":"club","a":12,"p":40},"a":{"n":"axe","a":18,"p":75},"s":{"n":"sword","a":30,"p":150},"t":{"n":"magic swd","a":40}}')
weaponnames=makenameforamount(weapons)

-- spell definitions
spells=json_parse('{"a":{"n":"attack","c":3,"a":1},"x":{"n":"medic","c":5,"a":1,"p":8},"c":{"n":"cure","c":7,"p":10},"w":{"n":"wound","c":11,"a":5},"e":{"n":"exit","c":13},"s":{"n":"savior","c":17,"a":6,"p":25}}')

-- tool definitions
tools=json_parse('{"west":{"n":"5 torches","attr":"ts","p":12,"q":5},"east":{"n":"a key","attr":"keys","p":23,"q":1}}')

function setmap()
  local songstrt=curmap.ss
  curmap=maps[mapnum]
  contents=curmap.con
  if(songstrt and curmap.ss)music(curmap.ss)
  hero.hd=0
end

function initobjs()
  -- the maps structure holds information about all of the regular
  -- places in the game, dungeons as well as towns.
  maps=json_parse('[{"sy":23,"mxx":105,"ex":13,"sx":92,"n":"saugus","signs":[{"x":92,"msg":"welcome to saugus!","y":19}],"mxy":24,"c":[{"x":89,"id":15,"y":21},{"x":84,"id":26,"y":9},{"x":95,"id":24,"y":3},{"x":97,"id":23,"y":13},{"x":82,"id":14,"y":21},{"x":101,"id":21,"y":5},{"x":84,"d":["the secret room is key.","the way must be clear."],"id":20,"y":5},{"x":103,"d":["faxon is in a tower.","volcanoes mark it."],"id":21,"y":18},{"x":85,"d":["poynter has a ship.","poynter is in lynn."],"id":17,"y":16},{"x":95,"id":15,"y":21}],"i":[{"x":84,"id":4,"y":4}],"ey":4},{"sy":23,"ex":17,"sx":116,"n":"lynn","signs":[{"x":125,"msg":"marina for members only.","y":9}],"mxy":24,"c":[{"x":118,"id":15,"y":22},{"x":106,"id":25,"y":1},{"x":118,"id":28,"y":2},{"x":107,"id":23,"y":9},{"x":106,"id":19,"y":16},{"x":122,"id":26,"y":12},{"x":105,"d":["i\'ve seen faxon\'s tower.","south of the eastern shrine."],"id":14,"y":4},{"x":106,"d":["griswold knows dungeons.","griswold is in salem."],"id":17,"y":7},{"x":119,"d":["i\'m rich! i have a yacht!","ho ho! i\'m the best!"],"id":16,"y":6},{"x":114,"id":15,"y":22}],"i":[{"x":125,"id":5,"y":5}],"mnx":104,"ey":4},{"sy":54,"mxx":112,"ex":45,"sx":96,"n":"boston","mxy":56,"c":[{"x":94,"id":15,"y":49},{"x":103,"id":25,"y":39},{"x":92,"id":24,"y":30},{"x":88,"id":23,"y":38},{"x":100,"id":26,"y":30},{"x":96,"id":19,"y":44},{"x":83,"d":["zanders has good tools.","be prepared!"],"id":14,"y":27},{"x":81,"id":16,"y":44},{"x":104,"d":["each shrine has a caretaker.","seek their wisdom."],"id":20,"y":26},{"x":110,"d":["i\'ve seen the magic sword.","search south of the shrine."],"id":16,"y":40},{"x":105,"mva":1,"id":15,"y":35},{"x":98,"id":15,"y":49}],"i":[{"x":96,"id":7,"y":40}],"mny":24,"ey":19},{"sy":62,"ex":7,"sx":119,"n":"salem","i":[{"x":116,"id":4,"y":53}],"c":[{"x":118,"id":15,"y":63},{"x":125,"id":27,"y":44},{"x":114,"id":28,"y":44},{"x":122,"id":23,"y":51},{"x":118,"id":17,"y":58},{"x":113,"d":["faxon is a blight.","daemons serve faxon."],"id":21,"y":50},{"x":123,"d":["increase stats in dungeons!","only severe injuries work."],"id":14,"y":57},{"x":120,"id":15,"y":63}],"mny":43,"mnx":112,"ey":36},{"c":[{"x":93,"id":23,"y":57},{"x":100,"id":28,"y":57},{"x":91,"d":["even faxon has fears.","lalla knows who to see."],"id":14,"y":60},{"x":82,"id":18,"y":57},{"x":102,"d":["gilly is in boston.","gilly knows of the sword."],"id":18,"y":63}],"sy":59,"mxx":103,"ex":27,"mny":56,"sx":82,"n":"great misery","ey":35},{"sy":62,"mxx":112,"ex":1,"sx":107,"n":"western shrine","c":[{"x":107,"d":["magic serves good or evil.","swords cut both ways."],"id":20,"y":59}],"mny":56,"mnx":103,"ey":28},{"sy":62,"mxx":112,"ex":49,"sx":107,"n":"eastern shrine","c":[{"x":107,"d":["some fountains have secrets.","know when to be humble."],"id":18,"y":59}],"mny":56,"mnx":103,"ey":6},{"sy":41,"newm":35,"ex":56,"sx":120,"n":"the dark tower","c":[{"x":119,"id":53,"y":41},{"x":126,"id":53,"y":40},{"x":123,"id":53,"y":38},{"x":113,"id":53,"y":40},{"x":121,"id":52,"y":37},{"x":119,"id":52,"y":38},{"x":120,"id":45,"y":34},{"x":118,"id":45,"y":35},{"ar":25,"dmg":50,"hp":255,"y":30,"x":118,"i":126,"id":50,"pn":"faxon"}],"i":[{"tm":12,"ty":8,"y":41,"x":117,"tz":3,"id":8,"tx":3},{"x":119,"id":6,"y":37},{"x":119,"id":6,"y":39},{"x":120,"id":6,"y":37},{"x":120,"id":6,"y":38},{"x":120,"id":6,"y":39},{"x":121,"id":6,"y":38},{"x":121,"id":6,"y":39}],"ss":17,"mxm":23,"mxy":43,"fri":false,"mny":24,"mnx":112,"ey":44},{"l":[[0,16382,768,12336,16380,13056,13308,192],[0,-13107,816,12336,15612,768,16332,704],[-32768,-3316,1020,12300,13116,13056,-3076,448],[29488,13116,0,-3073,0,-3124,780,13116]],"sy":8,"c":[{"x":8,"z":4,"id":50,"y":5},{"x":3,"z":4,"id":52,"y":1},{"x":1,"z":4,"id":52,"y":5},{"x":5,"z":4,"id":52,"y":1},{"x":3,"z":4,"id":53,"y":3}],"ex":4,"attr":"int","i":[{"x":1,"z":1,"id":8,"y":8},{"x":8,"z":2,"id":8,"y":2},{"x":4,"z":3,"id":8,"y":8},{"x":1,"z":4,"id":8,"y":1},{"x":1,"z":4,"id":6,"y":8},{"x":7,"z":4,"id":6,"y":1},{"x":3,"z":4,"id":6,"y":8},{"x":5,"z":4,"id":6,"y":8},{"x":8,"z":4,"id":6,"y":8},{"x":6,"z":3,"id":7,"y":8}],"n":"nibiru","ey":11},{"l":[[824,16188,768,13296,-4036,13056,13308,768],[13060,13116,12,16332,12540,15360,15311,768],[768,13116,-20432,-196,48,16140,14140,816],[0,-13108,19468,-13108,192,-13108,3084,-13108]],"c":[{"x":3,"z":4,"id":50,"y":5},{"x":1,"z":4,"id":52,"y":5},{"x":7,"z":4,"id":52,"y":5},{"x":5,"z":4,"id":53,"y":3},{"x":5,"z":4,"id":53,"y":7}],"ex":32,"attr":"str","i":[{"x":1,"z":1,"id":8,"y":1},{"x":7,"z":2,"id":8,"y":1},{"x":3,"z":3,"id":8,"y":7},{"x":1,"z":4,"id":8,"y":3},{"x":1,"z":4,"id":6,"y":1},{"x":1,"z":4,"id":6,"y":8},{"x":1,"z":4,"id":6,"y":7},{"x":2,"z":4,"id":6,"y":8},{"x":8,"z":4,"id":6,"y":8},{"x":7,"z":3,"id":7,"y":5}],"n":"purgatory","ey":5},{"l":[[768,16304,1020,13056,13299,12288,-4,0],[768,13180,12303,16382,252,15360,13263,12288],[768,13116,12348,13105,13119,13068,13116,512],[0,16188,12300,13260,12300,12300,16380,256]],"c":[{"x":3,"z":4,"id":50,"y":1},{"x":4,"z":4,"id":52,"y":5},{"x":5,"z":4,"id":52,"y":2},{"x":3,"z":4,"id":53,"y":4},{"x":6,"z":4,"id":53,"y":4}],"ex":33,"attr":"dex","i":[{"x":1,"z":1,"id":8,"y":1},{"x":5,"z":2,"id":8,"y":2},{"x":8,"z":3,"id":8,"y":4},{"x":4,"z":4,"id":8,"y":8},{"x":5,"z":4,"id":6,"y":5},{"x":3,"z":4,"id":6,"y":6},{"x":4,"z":4,"id":6,"y":6},{"x":5,"z":4,"id":6,"y":6},{"x":6,"z":4,"id":6,"y":6},{"x":6,"z":3,"id":7,"y":6}],"n":"sheol","ey":58},{"sz":3,"c":[{"x":4,"z":1,"id":51,"y":6},{"x":4,"z":2,"id":51,"y":7},{"x":1,"z":3,"id":51,"y":7},{"x":6,"z":3,"id":53,"y":8},{"x":8,"z":3,"id":53,"y":4},{"x":3,"z":3,"id":53,"y":1},{"x":6,"z":2,"id":53,"y":6},{"x":6,"z":1,"id":53,"y":8}],"ex":124,"sx":8,"n":"the upper levels","l":[[192,-17202,-817,204,16332,3276,204,3072],[192,31949,16323,14576,15555,3276,15566,192],[192,-13105,3264,13564,16320,207,13261,15104]],"mn":8,"i":[{"x":8,"z":3,"id":9,"y":1},{"tz":0,"tm":8,"z":3,"y":8,"x":3,"ty":41,"id":9,"tx":117},{"x":8,"z":3,"id":8,"y":7},{"x":3,"z":3,"id":8,"y":4},{"x":1,"z":2,"id":8,"y":2},{"x":8,"z":2,"id":8,"y":2}],"ey":26}]')
  -- map 0 is special; it's the world map, the overview map.
  maps[0]=json_parse('{"n":"world","mnx":0,"mny":0,"mxx":80,"mxy":64,"wrap":1,"newm":10,"mxm":12,"fri":false,"ss":0}')

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
      if curmap.l then
        maptype=basetypes[3]
      else
        maptype=basetypes[2]
      end
      makemetaobj(curmap,maptype)
    end
    curmap.w,curmap.h=curmap.mxx-curmap.mnx,curmap.mxy-curmap.mny
    creatures[mapnum],curmap.con={},{}
    for num=curmap.mnx-1,curmap.mxx+1 do
      curmap.con[num]={}
      for inner=curmap.mny-1,curmap.mxy+1 do
        curmap.con[num][inner]={}
      end
    end
    for item in all(curmap.i) do
      item.ot,xcoord,ycoord,zcoord=basetypes[item.id],item.x,item.y,item.z or 0
      curmap.con[xcoord][ycoord][zcoord]=makemetaobj(item)
      -- automatically make a corresponding ladder down for every ladder up
      if item.ot.n=='ladder up' and curmap.dg then
        zcoord-=1
        curmap.con[xcoord][ycoord][zcoord]=makemetaobj{ot=basetypes[9]}
      end
    end
    for creature in all(curmap.c) do
      creature.mn=mapnum
      creature.ot=basetypes[creature.id]
      definemonster(creature)
    end
  end

  -- the hero is the player character. although human, it has
  -- enough differences that there is no advantage to inheriting
  -- the human type.
  hero=json_parse('{"i":0,"ar":0,"dmg":0,"x":7,"y":7,"z":0,"exp":0,"lvl":0,"str":8,"int":8,"dex":8,"st":0,"hd":0,"f":0,"gp":20,"fd":25,"mvp":0,"mp":8,"hp":24,"keys":0,"ts":5,"lit":0}')
  hero.color=rnd(10)>6 and 4 or 15
 
  -- make the map info global for efficiency
  mapnum=0
  setmap()

  -- creature 0 is the maelstrom and not really a creature at all,
  -- although it shares most creature behaviors.
  creatures[0]={}
  maelstrom=makemetaobj(json_parse('{"i":69,"iseq":23,"n":"maelstrom","t":[12,13,14,15],"mva":1,"x":13,"y":61}'),anyobj)
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

attrlist={'ar','dmg','x','y','str','int','dex','st','i','color','f','keys','ts','exp','lvl','gp','fd','mp','hp'}

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
        dset(storagenum,creature.id)
        dset(storagenum+1,combinevalues(creature.x,creature.y))
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
  for creaturenum=1,12 do
    creatureid=dget(storagenum)
    if creatureid~=0 then
      creaturex,creaturey=separatevalues(dget(storagenum+1))
      definemonster{ot=basetypes[creatureid],x=creaturex,y=creaturey,mn=0}
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
  if hero.mp>=spell.c then
    hero.mp-=spell.c
    update_lines{spell.n.." is cast! "..(extra or '')}
    return true
  else
    update_lines{"not enough mp."}
    return false
  end
end

function exitdungeon(targx,targy,targmapnum)
  hero.x,hero.y,hero.z,hero.f,hero.lit,mapnum=targx or curmap.ex,targy or curmap.ey,0,0,0,targmapnum or curmap.mn
  setmap()
  _draw=world_draw
end

function entermap(targmap,targmapnum,targx,targy,targz)
  hero.x,hero.y=targx or targmap.sx,targy or targmap.sy
  mapnum=targmapnum
  setmap()
  if targmap.dg then
     _draw=dungeon_draw
     hero.f,hero.z=targmap.sf,targmap.sz
  end
  return "entering "..targmap.n.."."
end

function inputprocessor(cmd)
  while true do
    local spots=calculatemoves(hero)
    local xcoord,ycoord,zcoord=hero.x,hero.y,hero.z
    local curobj=contents[xcoord][ycoord][zcoord]
    local curobjname=curobj and curobj.n or nil
    if _draw==msg_draw then
      if cmd!='p' and hero.hp>0 then
        _draw=draw_state
      end
    elseif cmd=='west' then
      if curmap.dg then
        hero.f-=1
        if hero.f<1 then
          hero.f=4
        end
        update_lines{"turn left"}
        turnmade=true
      else
        hero.x,hero.y=checkmove(spots[2],ycoord,cmd)
      end
    elseif cmd=='east' then
      if curmap.dg then
        hero.f+=1
        if hero.f>4 then
          hero.f=1
        end
        update_lines{"turn right."}
        turnmade=true
      else
        hero.x,hero.y=checkmove(spots[4],ycoord,cmd)
      end
    elseif cmd=='north' then
      if curmap.dg then
        hero.x,hero.y,hero.z=checkdungeonmove(1)
      else
        hero.x,hero.y=checkmove(xcoord,spots[1],cmd)
        if hero.x==121 and hero.y==36 then
          mset(116,41,22)
          update_lines{"something clicks."}
        end
      end
    elseif cmd=='south' then
      if curmap.dg then
        hero.x,hero.y,hero.z=checkdungeonmove(-1)
      else
        hero.x,hero.y=checkmove(xcoord,spots[3],cmd)
      end
    elseif cmd=='c' then
      update_lines{"choose a\84\84\65\67\75, m\69\68\73\67, c\85\82\69,","w\79\85\78\68, e\88\73\84, s\65\86\73\79\82: "}
      cmd=yield()
      if cmd=='c' then
        -- cast cure
        if checkspell(cmd) then
          sfx(3)
          hero.st=band(hero.st,14)
        end
      elseif cmd=='x' or cmd=='s' then
        -- cast healing
        if checkspell(cmd) then
          sfx(3)
          increasehp(spells[cmd].a*hero.int)
        end
      elseif cmd=='e' then
        -- cast exit dungeon
        if not curmap.dg then
          update_lines{'not in a dungeon.'}
        elseif(checkspell(cmd)) then
          sfx(4)
          exitdungeon()
        end
      elseif cmd=='w' or cmd=='a' then
        -- cast offensive spell
        if checkspell(cmd,'dir:') then
          local spelldamage=rnd(spells[cmd].a*hero.int)
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
          elseif xcoord==1 and ycoord==38 and hero.dmg<40 then
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
        msg="healed!"
        if curmap.dg and hero.hp<23 and hero[curmap.attr]<16 then
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
      elseif curmap.dg and hero.lit<1 then
        if hero.ts>1 then
          hero.lit=50
          hero.ts-=1
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
        if curmap.dg then
          if zcoord==curmap.sz and xcoord==curmap.sx and ycoord==curmap.sy then
            msg="exiting "..curmap.n.."."
            exitdungeon()
          elseif curobjname=='ladder up' then
            msg="ascending."
            hero.z-=1
          else
            msg="descending."
            hero.z+=1
          end
        end
        if curobj.tm then
          if curmap.dg and not maps[curobj.tm].dg then
            exitdungeon(curobj.tx,curobj.ty,curobj.tm)
          else
            msg=entermap(maps[curobj.tm],curobj.tm,curobj.tx,curobj.ty,curobj.tz)
          end
        end
      elseif hero.i>0 then
        msg="exiting ship."
        contents[xcoord][ycoord][zcoord]=makemetaobj{f=hero.f,ot=shiptype}
        hero.i,hero.f=0,0
      elseif curobjname=='ship' then
        msg="boarding ship."
        hero.i,hero.f=70,curobj.f
        contents[xcoord][ycoord][zcoord]=nil
      end
      for loopmapnum=1,#maps do
        local loopmap=maps[loopmapnum]
        if mapnum==loopmap.mn and xcoord==loopmap.ex and ycoord==loopmap.ey then
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
        "worn: "..armornames[hero.ar].."; wield: "..weaponnames[hero.dmg],
        hero.ts..' torches & '..hero.keys..' skeleton keys.'
      }
    elseif cmd=='a' then
      if hero.i>0 then
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
  if curmap.dg then
    adir=dngdirections[hero.f]
  elseif not adir then
    adir=yield()
  end
  if adir=='east' then
    resultfunc(adir,spots[4],hero.y,magic)
  elseif adir=='west' then
    resultfunc(adir,spots[2],hero.y,magic)
  elseif adir=='north' then
    resultfunc(adir,hero.x,spots[1],magic)
  elseif adir=='south' then
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
    curline+=1
    if(curline>numoflines)curline=1
    prompt=""
  end
  lines[curline]=">"
end

function definemonster(monster)
  local objtype,xcoord,ycoord,zcoord=monster.ot,monster.x,monster.y,monster.z or 0
  monster.ot=objtype
  makemetaobj(monster)
  if monster.pn then
    monster.n=monster.pn
  elseif objtype.ns then
    monster.n=objtype.ns[flr(rnd(#objtype.ns)+1)]
  end
  --if(objtype.is)monster.i=objtype.is[flr(rnd(#objtype.is)+1)]
  if(objtype.cs)monster.co=objtype.cs[flr(rnd(#objtype.cs)+1)]
  monster.iseq=flr(rnd(30))
  monster.ia=false
  add(creatures[monster.mn],monster)
  maps[monster.mn].con[xcoord][ycoord][zcoord]=monster
  return monster
end

function create_monster()
  local monsterx=flr(rnd(curmap.w))+curmap.mnx
  local monstery=flr(rnd(curmap.h))+curmap.mny
  local monsterz=curmap.dg and flr(rnd(#curmap.l)+1) or 0
  if contents[monsterx][monstery][monsterz] or monsterx==hero.x and monstery==hero.y and monsterz==hero.z then
    -- don't create a monster where there already is one
    monsterx=nil
  end
  if monsterx then
    local monsterspot=mget(monsterx,monstery)
    if curmap.dg then
      monsterspot=getdungeonblk(monsterx,monstery,monsterz,1)
    end
    for objtype in all(terrainmonsters[monsterspot]) do
      if rnd(200)<objtype.ch then
        definemonster{ot=objtype,x=monsterx,y=monstery,z=monsterz,mn=mapnum}
        break
      end
    end
  end
end

function deducthp(damage)
  hero.hp-=ceil(damage)
  if hero.hp<=0 then
    msg=losemsg
    -- draw_state=_draw
    _draw=msg_draw
  end
end

function deductfood(amount)
  hero.fd-=amount
  if hero.fd<=0 then
    sfx(1,3,8)
    hero.fd=0
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

function increasehp(amount)
  hero.hp=not_over_32767(min(hero.hp+amount,hero.str*(hero.lvl+3)))
end

-- world updates

function checkdungeonmove(direction)
  local newx,newy=hero.x,hero.y
  local xcoord,ycoord,zcoord=hero.x,hero.y,hero.z
  local cmd=direction>0 and 'advance' or 'retreat'
  local item
  local iscreature=false
  if hero.f==1 then
    newy-=direction
    result=getdungeonblk(xcoord,newy,zcoord)
    item=contents[xcoord][newy][zcoord]
  elseif hero.f==2 then
    newx+=direction
    result=getdungeonblk(newx,ycoord,zcoord)
    item=contents[newx][ycoord][zcoord]
  elseif hero.f==3 then
    newy+=direction
    result=getdungeonblk(xcoord,newy,zcoord)
    item=contents[xcoord][newy][zcoord]
  else
    newx-=direction
    result=getdungeonblk(newx,ycoord,zcoord)
    item=contents[newx][ycoord][zcoord]
  end
  if item and item.hp then
    iscreature=true
  end
  if result==3 or iscreature then
    blocked(cmd)
  else
    xcoord,ycoord=newx,newy
    sfx(0)
    update_lines{cmd}
  end
  turnmade=true
  return xcoord,ycoord,zcoord
end

function checkexit(xcoord,ycoord)
  if not curmap.wrap and(xcoord>=curmap.mxx or xcoord<curmap.mnx or ycoord>=curmap.mxy or ycoord<curmap.mny) then
    update_lines{cmd,"exiting "..curmap.n.."."}
    mapnum=0
    return true
  else
    return false
  end
end

function blocked(cmd)
  sfx(5)
  update_lines{cmd,"blocked!"}
  return false
end

-- this is kind of weird; the ship icons ought to be rearranged
directions={north=1,west=2,south=3,east=4}
dngdirections={"north","east","south","west"}

function checkmove(xcoord,ycoord,cmd)
  local movesuccess=true
  local newloc=mget(xcoord,ycoord)
  local movecost=band(fget(newloc),3)
  local water=fget(newloc,2)
  local impassable=fget(newloc,3)
  local content=contents[xcoord][ycoord][hero.z]
  --update_lines(""..xcoord..","..ycoord.." "..newloc.." "..movecost.." "..fget(newloc))
  if hero.i>0 then
    hero.f=directions[cmd]
    local terraintype=mget(xcoord,ycoord)
    if checkexit(xcoord,ycoord) then
      xcoord,ycoord=curmap.ex,curmap.ey
      setmap()
    elseif content then
      if content.n=='maelstrom' then
        update_lines{cmd,"maelstrom! yikes!"}
        deducthp(rnd(25))
      else
        movesuccess=blocked(cmd)
      end
    elseif terraintype<12 or terraintype>15 then
      update_lines{cmd,"must exit ship first."}
      movesuccess=false
    else
      update_lines{cmd}
    end
  else
    if checkexit(xcoord,ycoord) then
      xcoord,ycoord=curmap.ex,curmap.ey
      setmap()
    elseif content then
      if not content.p then
      movesuccess=blocked(cmd)
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
      movesuccess=blocked(cmd)
    elseif water then
      movesuccess=false
      update_lines{cmd,"not without a boat."}
    elseif movecost>hero.mvp then
      hero.mvp+=1
      movesuccess=false
      update_lines{cmd,"slow progress."}
    else
      hero.mvp=0
      update_lines{cmd}
    end
  end
  if movesuccess then
    if hero.i==0 then
      sfx(0)
    end
    if newloc==5 and rnd(10)>6 then
      update_lines{cmd,"poisoned!"}
      hero.st=bor(hero.st,1)
    end
  else
    xcoord,ycoord=hero.x,hero.y
  end
  turnmade=true
  return xcoord,ycoord
end

function check_sign(xcoord,ycoord)
  local response=nil
  if mget(xcoord,ycoord)==31 then
    -- read the sign
    for sign in all(curmap.signs) do
      if xcoord==sign.x and ycoord==sign.y then
        response=sign.msg
        break
      end
    end
  end
  return response
end

function look_results(ldir,xcoord,ycoord)
  local cmd,signcontents,content="examine: "..ldir,check_sign(xcoord,ycoord),contents[xcoord][ycoord][hero.z] or nil
  if signcontents then
    update_lines{cmd.." (read sign)",signcontents}
  elseif content then
    update_lines{cmd,content.n}
  elseif curmap.dg then
    update_lines{cmd,getdungeonblk(xcoord,ycoord,hero.z)<1 and 'passage' or 'wall'}
  else
    update_lines{cmd,terrains[mget(xcoord,ycoord)]}
  end
end

function dialog_results(ddir,xcoord,ycoord)
  local cmd="dialog: "..ddir
  if terrains[mget(xcoord,ycoord)]=='counter' then
    return getdirection(calculatemoves({x=xcoord,y=ycoord}),dialog_results,nil,ddir)
  end
  local dialog_target=contents[xcoord][ycoord][hero.z]
  if dialog_target then
    if dialog_target.mch then
      update_lines{shop[dialog_target.mch]()}
    elseif dialog_target.d then
      update_lines{cmd,'"'..dialog_target.d[flr(rnd(#dialog_target.d)+1)]..'"'}
    else
      update_lines{cmd,'no response!'}
    end
  else
    update_lines{cmd,'no one to talk with.'}
  end
end

function attack_results(adir,xcoord,ycoord,magic)
  local cmd="attack: "..adir
  local zcoord,creature=hero.z,contents[xcoord][ycoord][hero.z]
  local damage=flr(rnd(hero.str+hero.lvl+hero.dmg))
  if magic then
    damage+=magic
  elseif hero.i>0 then
    cmd="fire: "..adir
    damage+=rnd(50)
  end
  --if creature then
    --logit('creature: '..(creature.name or 'nil')..' '..(creature.x or 'nil')..','..(creature.y or 'nil')..','..(creature.z or 'nil'))
  --else
    --logit('creature: nil '..xcoord..','..ycoord..' '..adir)
  --end
  if creature and creature.hp then
    if magic or rnd(hero.dex+hero.lvl*8)>rnd(creature.dex+creature.ar) then
      damage-=rnd(creature.ar)
      if magic then
        --creature.hc=json_parse('[[9,6],[8,13],[10,12]]')
        creature.hc={{9,6},{8,13},{10,12}}
      else
        creature.hc=nil
      end
      creature.hd=3
      sfx(1)
      creature.hp-=damage
      if creature.hp<=0 then
        hero.gp=not_over_32767(hero.gp+creature.gp)
        increasexp(creature.exp)
        if creature.n=='pirate' then
          contents[xcoord][ycoord][zcoord]=makemetaobj{
            f=creature.f,
            ot=shiptype
          }
        else
          contents[xcoord][ycoord][zcoord]=nil
        end
        update_lines{cmd,creature.n..' killed; xp+'..creature.exp..' gp+'..creature.gp}
        if creature.n=='faxon' then
          msg=winmsg
          _draw=msg_draw
        end
        del(creatures[mapnum],creature)
      else
        update_lines{cmd,'you hit the '..creature.n..'!'}
      end
      if curmap.fri then
        for townie in all(creatures[mapnum]) do
          townie.hos=1
          townie.d={"you're a lawbreaker!","criminal!"}
          if townie.n=='guard' then
            townie.mva=1
          end
        end
      end
    else
      update_lines{cmd,'you miss the '..creature.n..'!'}
    end
  elseif mget(xcoord,ycoord)==29 then
    -- bash locked door
    sfx(1)
    if(not magic)deducthp(1)
    if rnd(damage)>9 then
      update_lines{cmd,'you break open the door!'}
      mset(xcoord,ycoord,30)
    else
      update_lines{cmd,'the door holds.'}
    end
  else
    update_lines{cmd,'nothing to attack.'}
    --logit('hero: '..hero.x..','..hero.y..','..hero.z..' '..hero.f..' target: '..xcoord..','..ycoord..' '..cmd)
  end
end

function squaredistance(x1,y1,x2,y2)
  local dx=abs(x1-x2)
  if curmap.wrap and dx>curmap.w/2 then
    dx=curmap.w-dx;
  end
  local dy=abs(y1-y2)
  if curmap.wrap and dy>curmap.h/2 then
    dy=curmap.h-dy;
  end
  return dx+dy
end

function calculatemoves(creature)
  local maxx,maxy=curmap.mxx,curmap.mxy
  local creaturex,creaturey=creature.x,creature.y
  local eastspot,westspot=(creaturex+curmap.w-1)%maxx,(creaturex+1)%maxx
  local northspot,southspot=(creaturey+curmap.h-1)%maxy,(creaturey+1)%maxy
  if not curmap.wrap then
    northspot,southspot,eastspot,westspot=creaturey-1,creaturey+1,creaturex-1,creaturex+1
    if creature~=hero then
      northspot,southspot,eastspot,westspot=max(northspot,curmap.mny),min(southspot,maxy-1),max(eastspot,curmap.mnx),min(westspot,maxx-1)
    end
  end
  return {northspot,eastspot,southspot,westspot}
end

function movecreatures()
  local gothit=false
  local actualdistance=500
  local xcoord,ycoord,zcoord=hero.x,hero.y,hero.z
  for creaturenum,creature in pairs(creatures[mapnum]) do
    local cfacing,desiredx,desiredy,desiredz=creature.f,creature.x,creature.y,creature.z
    if desiredz==zcoord then
      while creature.mva>=creature.nm do
        local spots=calculatemoves(creature)
        --foreach(spots,logit)
        if creature.hos then
          -- most creatures are hostile; move toward player
          local bestfacing=0
          actualdistance=squaredistance(creature.x,creature.y,xcoord,ycoord)
          local currentdistance=actualdistance
          local bestdistance=currentdistance
          for facing=1,4 do
            if facing%2==1 then
              currentdistance=squaredistance(creature.x,spots[facing],xcoord,ycoord)
            else
              currentdistance=squaredistance(spots[facing],creature.y,xcoord,ycoord)
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
          creature.f=bestfacing
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
              creature.f=facing
              if facing%2==1 then
                desiredy=spots[facing]
              else
                desiredx=spots[facing]
              end
            end
          end
        end
        local newloc=mget(desiredx,desiredy)
        if curmap.dg then
          newloc=getdungeonblk(desiredx,desiredy,desiredz,1)
        end
        local canmove=false
        for terrain in all(creature.t) do
          if newloc==terrain and creature.mva>creature.nm then
            canmove=true
            break
          end
        end
        creature.nm+=1
        if creature.hos and actualdistance<=1 then
          local hero_dodge=hero.dex+2*hero.lvl
          local creature_msg="the "..creature.n
          if creature.eat and hero.fd>0 and rnd(creature.dex*23)>rnd(hero_dodge) then
            sfx(2)
            update_lines{creature_msg.." eats!"}
            deductfood(flr(rnd(6)))
            gothit=true
            delay(9)
          elseif creature.th and hero.gp>0 and rnd(creature.dex*20)>rnd(hero_dodge) then
            sfx(2)
            local amountstolen=min(ceil(rnd(5)),hero.gp)
            hero.gp-=amountstolen
            creature.gp+=amountstolen
            update_lines{creature_msg.." steals!"}
            gothit=true
            delay(9)
          elseif creature.po and rnd(creature.dex*15)>rnd(hero_dodge) then
            sfx(1)
            hero.st=bor(hero.st,1)
            update_lines{"poisoned by the "..creature.n.."!"}
            gothit=true
            delay(3)
          elseif rnd(creature.dex*64)>rnd(hero_dodge+hero.ar) then
            hero.gothit=true
            sfx(1)
            local damage=max(rnd(creature.dmg)-rnd(hero.ar),0)
            deducthp(damage)
            update_lines{creature_msg.." hits!"}
            --logit('hit by creature '..(creature.n or 'nil')..' '..creature.x..','..creature.y..','..creature.z)
            gothit=true
            delay(3)
            hero.hd=3
            hero.hc=creature.ac
          else
            update_lines{creature_msg.." misses."}
          end
          break
        elseif canmove then
          local movecost=band(fget(newloc),3)
          creature.mvp+=1
          if creature.mvp>=movecost and not contents[desiredx][desiredy][zcoord] and not (desiredx==xcoord and desiredy==ycoord and desiredz==zcoord) then
            contents[creature.x][creature.y][creature.z]=nil
            contents[desiredx][desiredy][desiredz]=creature
            creature.x,creature.y=desiredx,desiredy
            creature.mvp=0
            break
          end
        end
      end
      creature.nm=0
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
      hero.mp=not_over_32767(min(hero.mp+1,hero.int*(hero.lvl+1)))
    end
    if turn%5==0 and band(hero.st,1)==1 then
      deducthp(1)
      sfx(1,3,8)
      update_lines{"feeling sick!"}
    end
    gothit=movecreatures()
    if #creatures[mapnum]<curmap.mxm and rnd(10)<curmap.newm then
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
  print(band(hero.st,1)==1 and 'p' or 'g',125,0,6)
  print("lvl",linestart,8,5)
  print(hero.lvl,longlinestart,8,6)
  print("hp",linestart,16,5)
  print(hero.hp,linestart+8,16,6)
  print("mp",linestart,24,5)
  print(hero.mp,linestart+8,24,6)
  print("$",linestart,32,5)
  print(hero.gp,midlinestart,32,6)
  print("f",linestart,40,5)
  print(hero.fd,midlinestart,40,6)
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
  if item.iseq then
    item.iseq-=1
    if item.iseq<0 then
      item.iseq=23
      if item.ia then
        item.ia=false
        --if(item.i==nil)update_lines{"item.i nil"}
        if(item.fi==nil)item.i-=1
      else
        item.ia=true
        --if(item.i==nil)update_lines{"item.i nil"}
        if(item.fi==nil)item.i+=1
      end
    end
    if item.fi then
      flipped=item.ia
    end
  end
  palt(0,false)
  substitutecolors(item.co)
  return flipped
end

function draw_map(x,y,scrtx,scrty,width,height)
  map(x,y,scrtx*8,scrty*8,width,height)
  for contentsx=x,x+width-1 do
    for contentsy=y,y+height-1 do
      local item=contents[contentsx][contentsy][0]
      if item then
        local flipped=itemdrawprep(item)
        local f=item.fm and item.f or 0
        spr(item.i+f,(contentsx-x+scrtx)*8,(contentsy-y+scrty)*8,1,1,flipped)
        pal()
        if item.hd>0 then
          substitutecolors(item.hc)
          spr(127,(contentsx-x+scrtx)*8,(contentsy-y+scrty)*8)
          pal()
          item.hd-=1
        end
      end
    end
  end
end

function getdungeonblk(mapx,mapy,mapz,asterrain)
  local blk=0
  if mapx>=curmap.mxx or mapx<curmap.mnx or mapy>=curmap.mxy or mapy<curmap.mny then
    blk=3
  else
    local row=curmap.l[mapz][mapy]
    row=flr(shr(row,(curmap.w-mapx)*2))
    blk=band(row,3)
  end
  return asterrain and (blk>1 and 20 or 22) or blk
end

function triplereverse(triple)
  local tmp=triple[1]
  triple[1]=triple[3]
  triple[3]=tmp
end

function getdungeonblks(mapx,mapy,mapz,facing)
  local blks={}
  if facing%2==0 then
    -- we're looking for a column
    for viewy=mapy-1,mapy+1 do
      add(blks,{
        blk=getdungeonblk(mapx,viewy,mapz),
        x=mapx,
        y=viewy
      })
    end
    if facing==4 then
      triplereverse(blks)
    end
  else
    -- we're looking for a row
    for viewx=mapx-1,mapx+1 do
      add(blks,{
        blk=getdungeonblk(viewx,mapy,mapz),
        x=viewx,
        y=mapy
      })
    end
    if facing==3 then
      triplereverse(blks)
    end
  end
  return blks
end

function getdungeonview(mapx,mapy,mapz,facing)
  local blks={}
  local viewx,viewy=mapx,mapy
  if facing%2==0 then
    for viewx=mapx+4-facing,mapx+2-facing,-1 do
      add(blks,getdungeonblks(viewx,viewy,mapz,facing))
    end
    if facing==4 then
       triplereverse(blks)
    end
  else
    for viewy=mapy-3+facing,mapy-1+facing do
      add(blks,getdungeonblks(viewx,viewy,mapz,facing))
    end
    if facing==3 then
      triplereverse(blks)
    end
  end
  return blks
end

function dungeon_draw()
  cls()
  if hero.lit>0 then
    local view=getdungeonview(hero.x,hero.y,hero.z,hero.f)
    for depthindex,row in pairs(view) do
      local depthin,depthout=(depthindex-1)*10,depthindex*10
      local topouter,topinner,bottomouter,bottominner=30-depthout,30-depthin,52+depthout,52+depthin
      local lowextreme,highextreme,middle,lowerase,higherase=30-depthout*2,52+depthout*2,42,31-depthin,51+depthin
      if row[1].blk==3 then
        rectfill(topouter,topouter,topinner,bottomouter,0)
        line(lowextreme,topouter,topouter,topouter,5)
        line(topouter,topouter,topinner,topinner)
        line(topouter,bottomouter,topinner,bottominner)
        line(lowextreme,bottomouter,topouter,bottomouter)
      end
      if row[3].blk==3 then
        rectfill(bottominner,topinner,bottomouter,bottomouter,0)
        line(bottomouter,topouter,highextreme,topouter,5)
        line(bottominner,topinner,bottomouter,topouter)
        line(bottominner,bottominner,bottomouter,bottomouter)
        line(bottomouter,bottomouter,highextreme,bottomouter)
      end
      if depthindex>1 then
        local leftoneback,centeroneback,rightoneback=view[depthindex-1][1].blk,view[depthindex-1][2].blk,view[depthindex-1][3].blk
        if (row[1].blk==centeroneback and row[1].blk==3) or
          (row[1].blk~=leftoneback) then
          line(topinner,topinner,topinner,bottominner,5)
        end
        if (row[3].blk==centeroneback and row[3].blk==3) or
          (row[3].blk~=rightoneback) then
          line(bottominner,topinner,bottominner,bottominner,5)
        end
        if centeroneback==3 and leftoneback==3 and row[1].blk~=3 then
          line(topinner,lowerase,topinner,higherase,0)
        end
        if centeroneback==3 and rightoneback==3 and row[3].blk~=3 then
          line(bottominner,lowerase,bottominner,higherase,0)
        end
      end
      if row[2].blk==3 then
        rectfill(topouter,topouter,bottomouter,bottomouter,0)
        line(topouter,topouter,bottomouter,topouter,5)
        line(topouter,bottomouter,bottomouter,bottomouter)
        if row[1].blk<3 then
          line(topouter,topouter,topouter,bottomouter)
        end
        if row[3].blk<3 then
          line(bottomouter,topouter,bottomouter,bottomouter)
        end
      end
      dungeondrawobject(row[2].x,row[2].y,hero.z,3-depthindex)
    end
    rectfill(82,0,112,82,0)
  end
  draw_stats()
end

function dungeondrawobject(xcoord,ycoord,zcoord,distance)
  if xcoord>0 and ycoord>0 then
    local item=contents[xcoord][ycoord][zcoord]
    if item then
      local flipped,distancemod,shm,szm=itemdrawprep(item),distance*3,item.shm or 0,item.szm or 0
      local xoffset,yoffset=20+distancemod+(szm*(distance+1)/8),35-(3-distance)*shm
      local isize=60-szm-distancemod*4
      sspr(item.i%16*8,flr(item.i/16)*8,8,8,xoffset,yoffset,isize,isize,flipped)
      pal()
      if item.hd>0 then
        palt(0,true)
        substitutecolors(item.hc)
        sspr(120,56,8,8,xoffset,yoffset,isize,isize)
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
  local maxx,maxy,minx,miny=curmap.mxx,curmap.mxy,curmap.mnx,curmap.mny
  local width,height,wrap=curmap.w,curmap.h,curmap.wrap
  local xtraleft,xtratop,xtrawidth,xtraheight,scrtx,scrty,left,right=0,0,0,0,0,0,hero.x-halfwidth,hero.x+halfwidth
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
  local top,bottom=hero.y-halfheight,hero.y+halfheight
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
  local mainwidth,mainheight=min(fullwidth-xtrawidth,curmap.w),min(fullheight-xtraheight,curmap.h)
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
  if hero.color==4 and hero.i==0 then
    substitutecolors{{4,1},{15,4}}
  end
  spr(hero.i+hero.f,48,40)
  pal()
  palt()
  if hero.hd>0 then
    substitutecolors(hero.hc)
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

