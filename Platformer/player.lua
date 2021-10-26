local sound = require("sound")
local player = {}

function player:load()
	self.x = 100 -- Atritubos del jugador, posicion, dimensiones, velocidad X y Y
	self.y = 0
	self.startX = self.x
	self.startY = self.y
	self.width = 20
	self.height = 60
	self.velX = 0
	self.velY = 0
	
	self.maxSpeed = 200 -- Velocidad maxima, aceleracion, friccion, gravedad, altura de salto
	self.acceleration = 4000
	self.friction = 3500
	self.gravity = 1500
	self.jumpHeight = -500

	self.coins = 0
	self.health = {currentHealth = 3, maxHealth = 3}
	self.alive = true

	self.color = {red = 1, green = 1, blue = 1, speed = 3}

	self.state = "idle" -- Estado y dirección del jugador
	self.direction = "right"

	self.jumps = 0 -- Contador de saltos
	self.jumpLimit = 3 -- Limite de saltos

	self.graceTime = 0
	self.graceDuration = 0.1

	self.grounded = false -- Determina si esta o no pisando suelo

	self:loadAssets()

	self.physics = {} -- Nueva tabla para almacenar las fisicas del jugador
	self.physics.body = love.physics.newBody(world, self.x, self.y, "dynamic") -- Hay 3 tipos de cuerpos, static, dynamic y kinematic
	self.physics.body:setFixedRotation(true) -- Fija el cuerpo del jugador para que no tenga rotacion
	self.physics.shape = love.physics.newRectangleShape(self.width, self.height)
	self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape) -- Une el cuerpo con la forma creados
	self.physics.body:setGravityScale(0)

	sound:init("jump", "assets/sfx/player_jump.ogg", "static")
	sound:init("hit", "assets/sfx/player_hit.ogg", "static")
end

function player:update(dt)
	self:setState()
	self:syncPhysics()
	self:sideMovement(dt)
	self:applyGravity(dt)
	self:decreaseGraceTime(dt)
	self:animate(dt)
	self:setDirection()
	self:untintRed(dt)
	self:respawn()
end

function player:draw()
	local scaleX = 1
	if self.direction == "left" then
		scaleX = -1
	end
	-- Los argumentos que recibe esta funcion son:
	-- 1-Imagen, 2-Posicion en X, 3-Posicion en Y, 4-Rotacion
	-- 5-Escala en X, 6- Escala en Y, 7-Offset de origen X, 8-Offset de origen Y
	love.graphics.setColor(self.color.red, self.color.green, self.color.blue)
	love.graphics.draw(self.animation.draw, self.x, self.y, 0, scaleX, 1, self.animation.width / 2, self.animation.height / 2)
	love.graphics.setColor(1, 1, 1, 1)
end

function player:loadAssets() -- Carga las imagenes del jugador
	self.animation = {timer = 0, rate = 0.1} -- Reproduce las animaciones a 10 frames por segundo

	self.animation.run = {total = 6, current = 1, img= {}}
	for frame=1, self.animation.run.total do
		self.animation.run.img[frame] = love.graphics.newImage("assets/player/run/"..frame..".png")
	end

	self.animation.idle = {total = 4, current = 1, img= {}}
	for frame=1, self.animation.idle.total do
		self.animation.idle.img[frame] = love.graphics.newImage("assets/player/idle/"..frame..".png")
	end

	self.animation.air = {total = 4, current = 1, img= {}}
	for frame=1, self.animation.air.total do
		self.animation.air.img[frame] = love.graphics.newImage("assets/player/air/"..frame..".png")
	end

	self.animation.draw = self.animation.idle.img[1]
	self.animation.width = self.animation.draw:getWidth()
	self.animation.height = self.animation.draw:getHeight()
end

function player:animate(dt)
	self.animation.timer = self.animation.timer + dt
	if self.animation.timer > self.animation.rate then
		self.animation.timer = 0
		self:setNewFrame()
	end
end

function player:setNewFrame()
	local anim = self.animation[self.state]
	if anim.current < anim.total then
		anim.current = anim.current + 1
	else
		anim.current = 1
	end
	self.animation.draw = anim.img[anim.current]
end

function player:syncPhysics() -- Sincroniza el cuerpo creado, con el objeto player
	self.x, self.y = self.physics.body:getPosition()
	self.physics.body:setLinearVelocity(self.velX, self.velY)
end

function player:setState()
	if not self.grounded then
		self.state = "air"
	elseif self.velX == 0 then
		self.state = "idle"
	else
		self.state = "run"
	end
end

function player:setDirection()
	if self.velX < 0 then
		self.direction = "left"
	elseif self.velX > 0 then
		self.direction = "right"
	end
end

function player:sideMovement(dt)
	if love.keyboard.isDown("d", "right") then -- Suma la aceleracion * dt a la velocidad X hasta alcanzar velocidad maxima
		self.velX = math.min(self.velX + self.acceleration * dt, self.maxSpeed)
		--if self.velX < self.maxSpeed then
			--self.velX = self.velX + self.acceleration * dt
			--if self.velX > self.maxSpeed then -- Evitar que sobrepase la velocidad maxima
				--self.velX = self.maxSpeed
			--end
		--end
	elseif love.keyboard.isDown("a", "left") then -- Resta la aceleracion * dt a la velocidad X hasta alcanzar velocidad maxima negativa
		self.velX = math.max(self.velX - self.acceleration * dt, -self.maxSpeed)
		--if self.velX > -self.maxSpeed then
			--self.velX = self.velX - self.acceleration * dt
			--if self.velX < -self.maxSpeed then
				--self.velX = -self.maxSpeed
			--end
		--end
	else
		player:applyFriction(dt) -- Si no se está presionando ninguna dirección, llama applyFriction para detener al personaje
	end
end

function player:applyFriction(dt)
	if self.velX > 0 then -- Si el personaje está en movimiento, suma o resta la friccion * dt a la velocidad X
		self.velX = math.max(self.velX - self.friction * dt, 0)
		--self.velX = self.velX - self.friction * dt
		--if self.velX < 0 then -- Se detiene cuando la velocidad llega a 0
			--self.velX = 0
		--end
	elseif self.velX < 0 then
		self.velX = math.min(self.velX + self.friction * dt, 0)
		--self.velX = self.velX + self.friction * dt
		--if self.velX > 0 then
			--self.velX = 0
		--end
	end
end

function player:applyGravity(dt) -- Incrementa la velocidad vertical para simular gravedad
   if not self.grounded then -- Si jugador no está tocando el suelo
      self.velY = self.velY + self.gravity * dt
   end
end

function player:playerJump(key)
	if not self.grounded and self.jumps == 0 then
		self.jumps = self.jumps + 1
	end
	if (key == "w" or key == "up") then -- Si jugador está tocando el suelo, presionar la tecla lo hará saltar
		if self.grounded or self.graceTime > 0 then
			sound:play("jump", "sfx", 1, 1, false)
			self.velY = self.jumpHeight
			self.jumps = self.jumps + 1
			self.grounded = false
			self.graceTime = 0
		elseif self.jumps < self.jumpLimit then -- Para mas de un salto
			sound:play("jump", "sfx", 1, 1, false)
			self.jumps = self.jumps + 1
			self.velY = self.jumpHeight * 0.8
		end
	end
end

function player:decreaseGraceTime(dt)
	if not self.grounded then
		self.graceTime = self.graceTime - dt
	end
end

function player:playerLands(collision) -- Detiene la velocidad vertical cuando cae en un objeto solido
	self.currentGroundCollision = collision
	self.velY = 0
	self.grounded = true
	self.jumps = 0 -- Reinicia el contador de saltos
	self.graceTime = self.graceDuration
end

function player:incrementCoins()
	self.coins = self.coins + 1
end

function player:takeDamage(damage)
	sound:play("hit", "sfx", 1, 1, false)
	self:tintRed()
	if self.health.currentHealth - damage > 0 then
		self.health.currentHealth = self.health.currentHealth - damage
	else
		self.health.currentHealth = 0
		self:die()
	end
end

function player:tintRed()
	self.color.green = 0
	self.color.blue = 0
end

function player:untintRed(dt)
	self.color.red = math.min(self.color.red + self.color.speed * dt, 1)
	self.color.green = math.min(self.color.green + self.color.speed * dt, 1)
	self.color.blue = math.min(self.color.blue + self.color.speed * dt, 1)
end

function player:die()
	self.alive = false
end

function player:respawn()
	if not self.alive then
		self:resetPosition()
		self.health.currentHealth = self.health.maxHealth
		self.alive = true
	end
end

function player:resetPosition()
	self.physics.body:setPosition(self.startX, self.startY)
end

function player:beginContact(a, b, collision) -- Se activa cuando dos objetos hacen contacto
	if self.grounded == true then return end
	local nx, ny = collision:getNormal()
	if a == self.physics.fixture then
		if ny > 0 then
			self:playerLands(collision)
		elseif ny < 0 then
			self.velY = 0
		end
	elseif b == self.physics.fixture then
		if ny < 0 then
			self:playerLands(collision)
		elseif ny > 0 then
			self.velY = 0
		end
	end
end

function player:endContact(a, b, collision) -- Se activa cuando dos objetos dejan de hacer contacto
	if a == self.physics.fixture or b == self.physics.fixture then
		if self.currentGroundCollision == collision then
			self.grounded = false
		end
	end
end

return player
