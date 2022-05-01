function player()
	local obj = {
		layer = 0,
		uplayer = 0,
		spr = {
			idle = sprites.player.idle,
			happy = sprites.player.happy,
			miss = sprites.player.miss
		},
		x = 0,
		y = 0,
		bobi = 0,
		angle = 0,
		angleprevframe = 0,
		extend = 0,
		paddle_size = 70,
		handle_size = 15,
		paddle_width = 10,
		paddle_distance = 25,
		--cmode = not love.joystick.getJoysticks()[1],
		cemotion = "idle",
		emotimer = 0,
		lookradius = 5,
		maxouchpulse = 0.2,
		ouchpulse = 0,
		ouchtime = 15
	}


	function obj.update(dt)
		obj.angle = obj.angle % 360
		obj.emotimer = obj.emotimer - 1
		if obj.emotimer <= 0 then
			obj.cemotion = "idle"
		end
		if maininput.pressed("a") then
			obj.cmode = not obj.cmode
		end
		if not cs.autoplay then

			if obj.cmode then
				obj.angleprevframe = obj.angle --this way obj.angleprevframe is always 1 frame behind obj.angle
				if is3ds then
					local touchx, touchy = 0, 0
					for i, v in ipairs(love.touch.getTouches()) do
						touchx, touchy = love.touch.getPosition(v)
					end
					obj.angle = 0 - math.deg(math.atan2(120 - touchy / shuv.scale, touchx / shuv.scale - 160))
				else

					obj.angle = 0 - math.deg(math.atan2(obj.y - love.mouse.getY() / shuv.scale, love.mouse.getX() / shuv.scale - obj.x)) + 90
				end
			else
				if maininput:down("left") and playdate.isCrankDocked() then
					obj.angle = obj.angle - 7
				elseif maininput:down("right") and playdate.isCrankDocked() then
					obj.angle = obj.angle + 7
				elseif not playdate.isCrankDocked() then
					obj.angleprevframe = obj.angle
					-- obj.angle = math.deg(math.atan2(love.joystick.getJoysticks()[1]:getAxis(2), love.joystick.getJoysticks()[1]:getAxis(1))) + 90
					obj.angle = playdate.getCrankPosition()
				end
			end
		end
		obj.bobi = obj.bobi + 0.03
	end

	function obj.draw()
		gfx.setLineWidth(2)
		gfx.setColor(0)

		-- draw the paddle
		gfx.pushContext()
		-- love.graphics.translate(obj.x, obj.y)
		-- love.graphics.rotate((obj.angle - 90) * math.pi / 180)

		-- draw the lines connecting the player to the paddle
		gfx.drawLine(
			0, 0,
			(obj.paddle_distance + cs.extend) * math.cos(obj.handle_size * math.pi / 180),
			(obj.paddle_distance + cs.extend) * math.sin(obj.handle_size * math.pi / 180)
		)
		gfx.drawLine(
			0, 0,
			(obj.paddle_distance + cs.extend) * math.cos(-obj.handle_size * math.pi / 180),
			(obj.paddle_distance + cs.extend) * math.sin(-obj.handle_size * math.pi / 180)
		)

		-- draw the paddle
		local paddle_angle = obj.paddle_size / 2 * math.pi / 180
		gfx.drawArc(0, 0, (obj.paddle_distance + cs.extend), paddle_angle, -paddle_angle)
		gfx.drawArc(0, 0, (obj.paddle_distance + cs.extend) + obj.paddle_width, paddle_angle, -paddle_angle)
		gfx.drawLine(
			(obj.paddle_distance + cs.extend) * math.cos(paddle_angle),
			(obj.paddle_distance + cs.extend) * math.sin(paddle_angle),
			((obj.paddle_distance + cs.extend) + obj.paddle_width) * math.cos(paddle_angle),
			((obj.paddle_distance + cs.extend) + obj.paddle_width) * math.sin(paddle_angle)
		)
		gfx.drawLine(
			(obj.paddle_distance + cs.extend) * math.cos(-paddle_angle),
			(obj.paddle_distance + cs.extend) * math.sin(-paddle_angle),
			((obj.paddle_distance + cs.extend) + obj.paddle_width) * math.cos(-paddle_angle),
			((obj.paddle_distance + cs.extend) + obj.paddle_width) * math.sin(-paddle_angle)
		)
		gfx.popContext()

		gfx.pushContext()
		-- scaling circle and face for hurt animation
		local ouchpulsescale = 1 + obj.ouchpulse
		-- love.graphics.scale(ouchpulsescale)

		-- adjusting x and y so they're unaffected by scaling
		local finalx = obj.x / ouchpulsescale
		local finaly = obj.y / ouchpulsescale

		-- draw the circle
		gfx.setColor(1)
		gfx.fillCircleAtPoint(finalx, finaly, 16 + cs.extend / 2 + (math.sin(obj.bobi)) / 2)
		gfx.setColor(0)
		gfx.drawCircleAtPoint(finalx, finaly, 16 + cs.extend / 2 + (math.sin(obj.bobi)) / 2)

		-- draw the eyes
		gfx.setColor(1)
		-- determine x and y offsets of the eyes
		local eyex = (obj.lookradius) * math.cos((obj.angle - 90) * math.pi / 180)
		local eyey = (obj.lookradius) * math.sin((obj.angle - 90) * math.pi / 180)
		-- love.graphics.draw(obj.spr[obj.cemotion], finalx + eyex, finaly + eyey, 0, 1, 1, 16, 16)
		gfx.popContext()
	end

	function obj.hurtpulse()
		obj.ouchpulse = obj.maxouchpulse
		flux.to(obj, obj.ouchtime, { ouchpulse = 0 }):ease("outSine")
	end

	return obj
end

return player
