arena = love.graphics.newImage("assets/arena.png")
player = love.graphics.newImage("assets/player.png")
opponent = love.graphics.newImage("assets/opponent.png")
dash_icon = love.graphics.newImage("assets/dash_icon.png")
ready_icon = love.graphics.newImage("assets/ready_icon.png")
stick_icon = love.graphics.newImage("assets/stick_icon.png")
stick = love.graphics.newImage("assets/stick.png")
stick_attack = love.graphics.newImage("assets/stick_attack.png")

icons = {
    ['dash'] = dash_icon,
    ['ready'] = ready_icon,
    ['stick'] = stick_icon
}

player_size = 30
opponent_size = 30

icon_space_width = 150
width = 1000
height = 1000
wall_width = 20
stick_width = 10

speed = 10
dash_len = 100
player_weapon = 'stick'

keybinds = {
    ['up'] = 'w',
    ['down'] = 's',
    ['left'] = 'a',
    ['right'] = 'd',
    ['dash'] = 'space'
}

p_pos = {
    ['x'] = 500,
    ['y'] = 800
}

o_pos = {
    ['x'] = 500,
    ['y'] = 200
}

m_pos = {
    ['x'] = nil,
    ['y'] = nil
}

cooldowns = {
    ['dash'] = 2,
    ['basicattack'] = 1
}

timers = {
    ['dash'] = 0,
    ['basicattack'] = 0
}

weapons = {
    --['stick'] = stickAttack()
}

attack = nil

player_action_icons = {
    ['basicattack'] = icons[player_weapon],
    ['dash'] = icons['dash']
}

function love.load()
    success = love.window.setMode( width + icon_space_width, height )
    font = love.graphics.newFont(45)
end

function drawIcons()
    x = 1000
    y = 0
    for k, icon in pairs(player_action_icons) do
        love.graphics.draw(icon, x, y)
        if timers[k] <= 0 then
            love.graphics.draw(ready_icon, x + 50, y)
        else
            love.graphics.setColor(255, 255, 255)
            love.graphics.setFont(font)
            love.graphics.print(timers[k], x + 51, y)
        end
        y = y + 50
    end
end

function love.draw()
    love.graphics.draw(arena, 0, 0)
    drawIcons()

    love.graphics.draw(opponent, o_pos['x'], o_pos['y'], 0, 1, 1, opponent_size/2, opponent_size/2, 0, 0)

    love.graphics.draw(player, p_pos['x'], p_pos['y'], 0, 1, 1, player_size/2, player_size/2, 0, 0)

    if attack ~= nil then
        love.graphics.draw(attack, p_pos['x'], p_pos['y'], calcRadians(), 1, 1, -stick_width/2, stick_width/2, 0, 0)
    else
        love.graphics.draw(stick, p_pos['x'], p_pos['y'], 0, 1, 1, -player_size/2, player_size/2, 0, 0)
    end
end

function hasVal(val, arr)
    -- Helper function to check if an array contains a value
    for _, item in ipairs(arr) do
        if item == val then
            return true
        end
    end

    return false
end

function doAction(actions)
    local dash = 0
    if hasVal('dash', actions) and timers['dash'] <= 0 then
        dash = dash_len / (#actions - 1)
        timers['dash'] = cooldowns['dash']
    end
    for _, key in ipairs(actions) do
        if key == 'up' then
            if p_pos['y'] - speed - dash - player_size/2 < 0 + wall_width then
                p_pos['y'] = 0 + wall_width + player_size/2
            else
                p_pos['y'] = p_pos['y'] - speed - dash
            end
        elseif key == 'down' then
            if p_pos['y'] + speed + dash + player_size/2 > width - wall_width then
                p_pos['y'] = width - wall_width - player_size/2
            else
                p_pos['y'] = p_pos['y'] + speed + dash
            end
        elseif key == 'left' then
            if p_pos['x'] - speed - dash - player_size/2 < 0 + wall_width then
                p_pos['x'] = 0 + wall_width + player_size/2
            else
                p_pos['x'] = p_pos['x'] - speed - dash
            end
        elseif key == 'right' then
            if p_pos['x'] + speed + dash + player_size/2 > width - wall_width then
                p_pos['x'] = width - wall_width - player_size/2
            else
                p_pos['x'] = p_pos['x'] + speed + dash
            end
        end
    end
end

function love.conf(t)
	t.console = true
end

function checkInputs()
    actions = {}
    for k, v in pairs(keybinds) do
        if love.keyboard.isDown(v) then
            table.insert(actions, k)
        end
    end
    if #actions > 0 then
        doAction(actions)
    end
end

function updateMouse()
    m_pos['x'], m_pos['y'] = love.mouse.getPosition()
end

function calcRadians()
    local theta = math.atan((m_pos['y'] - p_pos['y']) / (m_pos['x'] - p_pos['x']))
    if m_pos['x'] < p_pos['x'] then
        theta = theta + math.pi
    end
    return theta
end

function stickAttack()
    attack = stick_attack
    
end


function mouseCombat(button)
    if button == 1 then
        if timers['basicattack'] <= 0 then
            stickAttack()
            timers['basicattack'] = cooldowns['basicattack']
        end
    end
    
end

function love.mousepressed(x, y, button)
    mouseCombat(button)
end

function love.update(dt)
    updateMouse()
    for k, v in pairs(timers) do
        timers[k] = v - dt
    end
    if timers['basicattack'] <= cooldowns['basicattack'] / 4 then
        attack = nil
    end

    checkInputs()


end

