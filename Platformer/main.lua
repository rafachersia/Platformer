love.graphics.setDefaultFilter("nearest", "nearest")
local map = require("map")
local player = require("player")
local enemy = require("enemy")
local coin = require("coin")
local gui = require("gui")
local spike = require("spike")
local stone = require("stone")
local camera = require("camera")
local sound = require("sound")

function love.load()
	enemy.loadAssets()
	map:load()
	background = love.graphics.newImage("assets/background.png")
	player:load()
	coin:load()
	gui:load()
end

function love.update(dt)
	world:update(dt)
	map:update(dt)
	gui:update(dt)
	coin:updateAll(dt)
	spike:updateAll(dt)
	stone:updateAll(dt)
	enemy:updateAll(dt)
	player:update(dt)
	camera:setPosition(player.x, 0)
end

function love.draw()
	love.graphics.draw(background)
	map.level:draw(-camera.x, -camera.y, camera.scale, camera.scale) -- Dibujar el mapa cargado. Los argumentos son los puntos de origen X y Y, y la escala en X y Y
	camera:apply()
	coin:drawAll()
	spike:drawAll()
	stone:drawAll()
	enemy:drawAll()
	player:draw()
	camera:clear()
	gui:draw()
	sound:update()
end

function love.keypressed(key)
	player:playerJump(key)
end

function beginContact(a, b, collision) -- Se activa cuando dos objetos hacen contacto
	if coin:beginContact(a, b, collision) then return end -- Return para que no entre en el beginContact del jugador
	if spike:beginContact(a, b, collision) then return end
	enemy:beginContact(a, b, collision)
	player:beginContact(a, b, collision)
end

function endContact(a, b, collision) -- Se activa cuando dos objetos dejan de hacer contacto
	player:endContact(a, b, collision)
end