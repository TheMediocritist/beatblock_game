ResultsScene = {}

class("ResultsScene").extends(NobleScene)

function ResultsScene:init()
  ResultsScene.super.init(self)
end

function ResultsScene:enter(prev)
  cs.gm.currst.source.source:stop()
  ResultsScene.super.enter(self)
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


function ResultsScene:exit()
  ResultsScene.super.exit(self)

end


function ResultsScene:resume()

end

function ResultsScene:mousepressed(x,y,b,t,p)

end

function ResultsScene:mousepressed(x,y,b,t,p)
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

function ResultsScene:update()
  updateDt()
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

    --flux.update(1)
    em.update(dt)
  end
end

function ResultsScene:draw()

  gfx.setFont(DigitalDisco16)

  -- clear the screen
  gfx.setColor(playdate.graphics.kColorWhite)
  gfx.fillRect(0, 0, gameWidth, gameHeight)
  gfx.setColor(playdate.graphics.kColorBlack)
  
  --metadata bar
  local meta_text = (cs.level.metadata.artist .. " - " .. cs.level.metadata.songname)
  --print(meta_text)
  gfx.drawTextAligned(meta_text, 200, 10, kTextAlignment.center) -- TEMP no idea why drawTextAligned is throwing error. Font issue?
  gfx.fillRect(0, 33, 400, 2)

  --results circle
  gfx.setLineWidth(2)
  gfx.drawCircleAtPoint(200, 139, 100)
  --gfx.font:drawTextAligned(gfx.getLocalizedText("grade"), 200, 45, kTextAlignment.center)
  sprites.results.grades[self.lgrade]:draw (175+self.goffset,62)
  if self.lgradepm ~= "none" then
    sprites.results.grades[self.lgradepm]:draw(202,61)
  end
  gfx.drawTextAligned(gfx.getLocalizedText("hits: ") .. cs.gm.currst.misses, 200, 135, kTextAlignment.center)
  gfx.drawTextAligned(gfx.getLocalizedText("misses: ") .. cs.gm.currst.hits, 200, 158, kTextAlignment.center)
  
  gfx.setFont(DigitalDisco12)
  gfx.drawTextAligned(gfx.getLocalizedText("continue"), 200, 201, kTextAlignment.center)
  gfx.drawTextAligned(gfx.getLocalizedText("retry"), 200, 218, kTextAlignment.center)
  gfx.setLineWidth(1)
  gfx.drawRect(self.cselectionbounds.x,self.cselectionbounds.y,self.cselectionbounds.w,self.cselectionbounds.h)
  
  em.draw()

end


return ResultsScene