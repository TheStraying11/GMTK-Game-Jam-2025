--[[
	Ui Elements
]]

local button = {}

button.__index = button

function button:new(text, textColor, buttonColor, x, y, width, height, callback, optional)
	--[[
		optional:
			mode = 'fill'
			rx = nil,
			ry = rx,
			segments = nil,
			textLimit = love.graphics.getWidth(),
			font = love.graphics.getFont(),
			textAlignment = 'center'
	]]
	
	local optional = optional or {}
	
	local o = {
		text = text,
		textColor = textColor,
		buttonColor = buttonColor,
		x = x,
		y = y,
		width = width,
		height = height,
		callback = callback,
		mode = optional["mode"] or 'fill',
		rx = optional["rx"],
		ry = optional["ry"] or optional["rx"],
		segments = optional["segments"],
		textLimit = optional["textLimit"] or width,
		font = optional["font"] or love.graphics.getFont(),
		textAlignment = optional["alignment"] or 'center'
	}
	
	setmetatable(o, button)
	
	return o
end

function button:draw()
	local oldColor = {love.graphics.getColor()}
	
	love.graphics.setColor(self.buttonColor)
	love.graphics.rectangle(
		self.mode, 
		self.x, 
		self.y, 
		self.width, 
		self.height, 
		self.rx, 
		self.ry, 
		self.segments
	)
	
	local fontHeight = self.font:getHeight()

	love.graphics.setColor(self.textColor)
	love.graphics.printf(
		self.text, 
		self.x, 
		self.y + (self.height/2 - fontHeight/2), 
		self.textLimit, 
		self.textAlignment
	)

	love.graphics.setColor(oldColor)
end

function button:setText(s)
	self.text = s
end

function button:handleTouch(x, y, button, istouch, presses)
	if y >= self.y and y <= self.y+self.height and
	   x >= self.x and x <= self.x+self.width then
		self:callback(
			x, 
			y, 
			button, 
			istouch, 
			presses
		)
	end
end

--[[
	End of Ui Elements
]]

local prototypes = {
	ui = {
		button = setmetatable(button, {
				__call = button.new
			}
		)
	}
}

return prototypes