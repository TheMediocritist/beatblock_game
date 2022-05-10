GameScene = {}

class("GameScene").extends(NobleScene)
SongSelectScene.backgroundColor = Graphics.kColorWhite

local screenwidth, screenheight = playdate.display.getWidth(), playdate.display.getHeight()

function GameScene:init()
  GameScene.super.init(self)
  cs = Noble.currentScene()
end

function GameScene:enter(prev)
  GameScene.super.enter(self)
  cs = Noble.currentScene()
  self.p = em.init("player", screenwidth/2, screenheight/2)
  self.gm = em.init("gamemanager", screenwidth/2, screenheight/2)
  self.gm.init(self)

  self.canv = gfx.image.new(screenwidth, screenheight)

  self.level = json.decodeFile(clevel .. "level.json")
  self.gm.resetlevel()
  self.gm.on = true
end


function GameScene:leave()
  GameScene.super.exit(self)
  entities = {}
  if self.source ~= nil then
    self.source:stop()
    self.source = nil
  end
  self.sounddata = nil
end


function GameScene:resume()

end


function GameScene:update()
  updateDt()
  if not paused then
    if maininput.pressed("back") then
      -- helpers.swap(states.songselect)
      Noble.transition(SongSelectScene)
    end
    --if maininput.pressed("a") then
      --helpers.swap(states.rdconvert)
    --end

    flux.update(1)
    em.update(dt)
  end
end


function GameScene:draw()
  --shuv.start()
  
  --love.graphics.rectangle("fill",0,0,gameWidth,gameHeight)
  gfx.fillRect(0, 0, screenwidth, screenheight)
  --love.graphics.setCanvas(self.canv)
  gfx.lockFocus(self.canv)
  
  helpers.drawgame()
  -- love.graphics.setCanvas(shuv.canvas)
  -- love.graphics.setColor(1, 1, 1, 1)
  -- love.graphics.draw(self.canv)
  gfx.unlockFocus()
  self.canv:draw(0,0)
  if pq ~= "" then
    print(helpers.round(self.cbeat*8,true)/8 .. pq)
  end
  -- shuv.finish()

end


return Game