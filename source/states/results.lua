Results = {}

class("Results").extends(NobleScene)

function Results:init()
  Results.super.init(self)
end

function Results:enter(prev)
  Results.super.enter(self)
  entities = {}
  self.selection = 1
  self.selectionbounds = {
    {x=167,y=201,w=64,h=14},
    {x=179,y=218,w=40,h=17}
  }
  self.cselectionbounds = {x=167,y=201,w=64,h=14}
  self.goffset = 0
  self.pctgrade = ((cs.gm.currst.maxhits - cs.gm.currst.misses) / cs.gm.currst.maxhits)*100
  self.lgrade, self.lgradepm = helpers.gradecalc(self.pctgrade)
  -- self.pljson = json.decodeFile("savedata/playedlevels.json",{})
  self.timesplayed = 0
  self.storepctgrade = self.pctgrade
  self.storemisses = cs.misses
  -- print("results.lua [25] cs.level")
  -- printTable(cs.level)
  -- if self.pljson[cs.level.metadata.songname.."_"..cs.level.metadata.charter] then
  --   self.timesplayed = self.pljson[cs.level.metadata.songname.."_"..cs.level.metadata.charter].timesplayed
  --   self.timesplayed = self.timesplayed + 1
  --   if self.pljson[cs.level.metadata.songname.."_"..cs.level.metadata.charter].misses < self.storemisses then
  --     self.storemisses = self.pljson[cs.level.metadata.songname.."_"..cs.level.metadata.charter].misses
  --   end
  --   if self.pljson[cs.level.metadata.songname.."_"..cs.level.metadata.charter].pctgrade > self.storepctgrade then
  --     self.storepctgrade = self.pljson[cs.level.metadata.songname.."_"..cs.level.metadata.charter].pctgrade
  --   end
  -- else
  --   self.timesplayed = 1
  -- end
  -- self.pljson[cs.level.metadata.songname.."_"..cs.level.metadata.charter]={pctgrade=self.storepctgrade,misses=self.storemisses,timesplayed=self.timesplayed}
  -- json.encodeToFile("savedata/playedlevels.json", self.pljson)
end


function Results:exit()
  Results.super.exit(self)

end


function Results:resume()

end

function Results:mousepressed(x,y,b,t,p)

end

function Results:mousepressed(x,y,b,t,p)
  if ismobile then
    if (love.mouse.getY()/shuv.scale) < 240/3 then -- up
      self.selection = 1
      self.ease = flux.to(self.cselectionbounds,30,{
        x=self.selectionbounds[1].x,
        y=self.selectionbounds[1].y,
        w=self.selectionbounds[1].w,
        h=self.selectionbounds[1].h,

      }):ease("outExpo")
    elseif (love.mouse.getY()/shuv.scale) > 240/3*2 then -- down
      self.selection = 2
      self.ease = flux.to(self.cselectionbounds,30,{
        x=self.selectionbounds[2].x,
        y=self.selectionbounds[2].y,
        w=self.selectionbounds[2].w,
        h=self.selectionbounds[2].h,

      }):ease("outExpo")
    else -- center
      if self.selection == 1 then
        Noble.transition(SongSelectScene)
      else
        Noble.transition(GameScene)
      end

    end
  end
end

function Results:update()
  pq = ""
  if not paused then
    if maininput.pressed("up") then
      self.selection = 1
      self.ease = flux.to(self.cselectionbounds,30,{
        x=self.selectionbounds[1].x,
        y=self.selectionbounds[1].y,
        w=self.selectionbounds[1].w,
        h=self.selectionbounds[1].h,

      }):ease("outExpo")
    end
    if maininput.pressed("down") then
      self.selection = 2
      self.ease = flux.to(self.cselectionbounds,30,{
        x=self.selectionbounds[2].x,
        y=self.selectionbounds[2].y,
        w=self.selectionbounds[2].w,
        h=self.selectionbounds[2].h,

      }):ease("outExpo")
    end
    if maininput.pressed("accept") then
      if self.selection == 1 then
        Noble.transition(SongSelectScene)
      else
        Noble.transition(GameScene)
        end
    end

    flux.update(1)
    em.update(dt)
  end
end


function Results:draw()
  gfx.setFont(Axolotl12)
  --push:start()
  --shuv.start()
  gfx.setColor(1)

  gfx.fillRect(0, 0, gameWidth, gameHeight)
  gfx.setColor(0)
  
  --metadata bar
  local meta_text = (cs.level.metadata.artist .. " - " .. cs.level.metadata.songname)
  print(meta_text)
  --gfx.font:drawTextAligned(meta_text, 200, 10, kTextAlignment.center) -- TEMP no idea why drawTextAligned is throwing error. Font issue?
  gfx.fillRect(0, 33, 400, 2)

  --results circle
  gfx.setLineWidth(2)
  gfx.drawCircleAtPoint(200, 139, 100)
  --gfx.font:drawTextAligned(gfx.getLocalizedText("grade"), 200, 45, kTextAlignment.center)
  --love.graphics.setColor(1,1,1)
  sprites.results.grades[self.lgrade]:draw (175+self.goffset,62)
  if self.lgradepm ~= "none" then
    sprites.results.grades[self.lgradepm]:draw(202,61)
  end
  --love.graphics.setColor(0,0,0)
  --gfx.font:drawTextAligned(gfx.getLocalizedText("misses") .. cs.gm.currst.misses, 200, 135, kTextAlignment.center)
  --gfx.font:drawTextAligned(gfx.getLocalizedText("continue"), 200, 201, kTextAlignment.center)
  --gfx.font:drawTextAligned(gfx.getLocalizedText("retry"), 200, 218, kTextAlignment.center)
  gfx.setLineWidth(1)
  gfx.drawRect(self.cselectionbounds.x,self.cselectionbounds.y,self.cselectionbounds.w,self.cselectionbounds.h)
  --love.graphics.setColor(1,1,1)

  em.draw()

  --shuv.finish()
end


return Results