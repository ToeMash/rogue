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

speed = 1000
dash_len = 10
player_weapon = 'stick'

entities = {}

function createEntity(name, x, y)
    entities[name] = {  ['pos'] = {['x'] = x or 500, ['y'] = y or 500},
                        ['vector'] = newVector(0, 0)
    }
end

function normalize(x, y)
    local len = math.sqrt(x^2 + y^2)
    return {['x'] = x / len, ['y'] = y / len}

function newVector(x, y, scalar)
    local normalized = normalize(x, y)
    return {['x'] = normalized['x'], ['y'] = normalized['y'], ['scalar'] = scalar}
end

function addVector(vector1, vector2)
    return newVector(vector1['x'] + vector2['x'], vector1['y'] + vector2['y'])
end

function multVector(vector, scalar)
    return newVector(vector['x'] * scalar, vector['y'] * scalar)
end 

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
    createEntity('player', 500, 800)
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

    love.graphics.draw(player, entities['player']['pos']['x'], entities['player']['pos']['y'], 0, 1, 1, player_size/2, player_size/2, 0, 0)

    if attack ~= nil then
        --love.graphics.draw(attack, entities['player']['pos']['x'], entities['player']['pos']['y'], calcRadians(), 1, 1, -stick_width/2, stick_width/2, 0, 0)
    else
        love.graphics.draw(stick, entities['player']['pos']['x'], entities['player']['pos']['y'], 0, 1, 1, -player_size/2, player_size/2, 0, 0)
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

function calcRadians(src_x, src_y, dst_x, dst_y)
    local theta = math.atan((dst_y - src_y) / (dst_x - src_x))
    if dst_x < src_x then
        theta = theta + math.pi
    end
    return theta
end

function doAction(entity, actions)

    local vectors_to_add = {}
    for _, key in ipairs(actions) do
        if key == 'up' then
            table.insert(vectors_to_add, newVector(0, -speed))
        elseif key == 'down' then
            table.insert(vectors_to_add, newVector(0, speed))
        elseif key == 'left' then
            table.insert(vectors_to_add, newVector(-speed, 0))
        elseif key == 'right' then
            table.insert(vectors_to_add, newVector(speed, 0))
        end
    end
    local vector_out = newVector(0, 0)
    for _, v in ipairs(vectors_to_add) do
        vector_out = addVector(vector_out, multVector(v, 1/#vectors_to_add))
    end

    if hasVal('dash', actions) and timers['dash'] <= 0 then
        vector_out = multVector(vector_out, dash_len)
        timers['dash'] = cooldowns['dash']
    end

    entities[entity]['vector'] = vector_out
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
        doAction('player', actions)
    else
        entities['player']['vector']['x'] = 0
        entities['player']['vector']['y'] = 0
    end
end

function updateMouse()
    m_pos['x'], m_pos['y'] = love.mouse.getPosition()
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

function updateVectorPosisitions(dt)
    for entity, value in pairs(entities) do
        entities[entity]['pos']['x'] = entities[entity]['pos']['x'] + entities[entity]['vector']['x'] * dt
        entities[entity]['pos']['y'] = entities[entity]['pos']['y'] + entities[entity]['vector']['y'] * dt
    end
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
    updateVectorPosisitions(dt)


end

