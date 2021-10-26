local camera = {
	x = 0,
	y = 0,
	scale = 2
}

function camera:apply()
	love.graphics.push() -- Todo lo que se dibuje dentro del push y pop tendrá doble escala
	love.graphics.scale(self.scale, self.scale)
	love.graphics.translate(-self.x, -self.y)
end

function camera:clear()
	love.graphics.pop()
end

function camera:setPosition(x, y)
	self.x = x - love.graphics.getWidth() / 2 / self.scale -- Fija el centro de la ventana al valor de x que recibe la función
	self.y = y
	local rs = self.x + love.graphics.getWidth() / 2 -- Posicion del limite derecho del nivel para limitar la cámara

	if self.x < 0 then -- Limita la cámara por el lado izquierdo
		self.x = 0
	elseif rs > mapWidth then -- Lado derecho
		self.x = mapWidth - love.graphics.getWidth() / 2
	end
end

return camera