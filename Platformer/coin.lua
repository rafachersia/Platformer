local coin = {img = love.graphics.newImage("assets/coin.png")}
coin.__index = coin -- Crea una metatabla cuyo indice apunta a si misma
coin.width = coin.img:getWidth()
coin.height = coin.img:getHeight()
local activeCoins = {}
local player = require("player")
local sound = require("sound")

function coin:load()
	sound:init("coin", "assets/sfx/player_get_coin.ogg", "static")
end

function coin:update(dt)
	self:spin(dt)
	self:checkRemove()
end

function coin:draw()
	love.graphics.draw(self.img, self.x, self.y, 0, self.scaleX, 1, self.width / 2, self.height / 2)
end

function coin:spin(dt)
	self.scaleX = math.sin(love.timer.getTime() * 2 + self.spinOffset)
end

function coin:updateAll(dt)
	for i, instance in ipairs(activeCoins) do
		instance:update(dt)
	end
end

function coin:drawAll()
	for i, instance in ipairs(activeCoins) do
		instance:draw()
	end
end

function coin:new(x, y)
	instance = setmetatable({}, coin)
	instance.x = x
	instance.y = y
	instance.img = love.graphics.newImage("assets/coin.png")
	instance.scaleX = 1
	instance.spinOffset = math.random(0, 100)
	instance.removeCoin = false

	instance.physics = {}
	instance.physics.body = love.physics.newBody(world, instance.x, instance.y, "static")
	instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
	instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
	instance.physics.fixture:setSensor(true)
	table.insert(activeCoins, instance)
end

function coin:beginContact(a, b, collision)
	for i, instance in ipairs(activeCoins) do
		if a == instance.physics.fixture or b == instance.physics.fixture then
			if a == player.physics.fixture or b == player.physics.fixture then
				instance.removeCoin = true
				return true
			end
		end
	end
end

function coin:checkRemove()
	if self.removeCoin then
		self:pickUpCoin()
		sound:play("coin", "sfx", 1, 1, false)
	end
end

function coin:pickUpCoin()
	for i, instance in ipairs(activeCoins) do
		if instance == self then
			self.physics.body:destroy()
			table.remove(activeCoins, i)
			player:incrementCoins()
		end
	end
end

function coin:deleteAll()
	for i, instance in ipairs(activeCoins) do
		instance.physics.body:destroy()
	end
	activeCoins = {}
end

return coin