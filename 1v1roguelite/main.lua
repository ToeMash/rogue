arena = love.graphics.newImage("assets/arena.png")
player = love.graphics.newImage("assets/player.png")
opponent = love.graphics.newImage("assets/opponent.png")
dash_icon = love.graphics.newImage("assets/dash_icon.png")
ready_icon = love.graphics.newImage("assets/ready_icon.png")
stick_icon = love.graphics.newImage("assets/stick_icon.png")
stick = love.graphics.newImage("assets/stick.png")
stick_attack = love.graphics.newImage("assets/stick_attack.png")
stick_attack2 = love.graphics.newImage("assets/stick_attack2.png")
stick_attack2_icon = love.graphics.newImage("assets/stick_attack2_icon.png")
player_hp_icon = love.graphics.newImage("assets/player_hp_icon.png")
opponent_hp_icon = love.graphics.newImage("assets/opponent_hp_icon.png")

icons = {
    ['dash'] = dash_icon,
    ['ready'] = ready_icon,
    ['stick'] = stick_icon,
    ['stick_attack2']  = stick_attack2_icon
}

images = {}

icon_space_width = 150
width = 1000
height = 1000
wall_width = 20
stick_width = 10

speed = 1000
dash_len = 10
player_weapon = 'stick'

entities = {}

function setSpeed(entity, speed)
    entities[entity]['speed'] = speed
end

function createEntity(name, x, y, radius, speed, image, type, vector, hp, dmg, spin, parent, duration)
    entities[name] = {  ['pos'] = {['x'] = x or 500, ['y'] = y or 500},
                        ['radius'] = radius or 15,
                        ['speed'] = speed or 0,
                        ['image'] = image,
                        ['type'] = type or 'player',
                        ['vector'] = vector or newVector(0, 0),
                        ['hp'] = hp or 10,
                        ['dmg'] = dmg or 1,
                        ['rotation'] = 0,
                        ['spin'] = spin or false,
                        ['parent'] = parent or nil,
                        ['duration'] = duration or 1000
    }
end

function normalize(x, y)
    local len = math.sqrt(x^2 + y^2)
    if len == 0 then
        return {['x'] = 0, ['y'] = 0}
    end
    return {['x'] = x / len, ['y'] = y / len}
end

function newVector(x, y)
    return normalize(x, y)
end

function addVector(vector1, vector2)
    return newVector(vector1['x'] + vector2['x'], vector1['y'] + vector2['y'])
end

function multVector(vector, scalar)
    return {['x'] = vector['x'] * scalar, ['y'] = vector['y'] * scalar}
end 

keybinds = {
    ['up'] = 'w',
    ['down'] = 's',
    ['left'] = 'a',
    ['right'] = 'd',
    ['dash'] = 'space'
}

m_pos = {
    ['x'] = nil,
    ['y'] = nil
}

cooldowns = {
    ['dash'] = 2,
    ['basicattack'] = 1,
    ['secondaryattack'] = 2,
}

timers = {
    ['dash'] = 0,
    ['basicattack'] = 0,
    ['secondaryattack'] = 0,
}

weapons = {
    --['stick'] = stickAttack()
}

attack = nil

player_action_icons = {
    ['dash'] = icons['dash'],
    ['basicattack'] = icons[player_weapon],
    ['secondaryattack'] = icons['stick_attack2'],
}

function love.load()
    success = love.window.setMode( width + icon_space_width, height )
    font = love.graphics.newFont(45)
    createEntity('player', 500, 800, 15, speed, player)
    createEntity('opponent', 500, 200, 15, 0, opponent)
end

function drawHP()
    x = 1000
    y = 0
    love.graphics.draw(player_hp_icon, x, y)
    love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(font)
    love.graphics.print(entities['player']['hp'], x + 51, y)
    y = y + 50
    love.graphics.draw(opponent_hp_icon, x, y)
    love.graphics.print(entities['opponent']['hp'], x + 51, y)
end

function drawIcons()
    x = 1000
    y = 100
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

function drawEntities()
    for name, vals in pairs(entities) do
        love.graphics.draw(entities[name]['image'], entities[name]['pos']['x'], entities[name]['pos']['y'], entities[name]['rotation'], 1, 1, entities[name]['radius'], entities[name]['radius'], 0, 0)
    end
end

function love.draw()
    love.graphics.draw(arena, 0, 0)
    drawIcons()
    drawHP()
    drawEntities()
    

    if attack ~= nil then
        --love.graphics.draw(attack, entities['player']['pos']['x'], entities['player']['pos']['y'], 0, 1, 1, entities['player']['radius'], entities['player']['radius'], 0, 0)
    else
        love.graphics.draw(stick, entities['player']['pos']['x'], entities['player']['pos']['y'], 0, 1, 1, -entities['player']['radius'], entities['player']['radius'], 0, 0)
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

    local vector_out = newVector(0, 0)
    for _, key in ipairs(actions) do
        if key == 'up' then
            vector_out = addVector(vector_out, newVector(0, -1))
        elseif key == 'down' then
            vector_out = addVector(vector_out, newVector(0, 1))
        elseif key == 'left' then
            vector_out = addVector(vector_out, newVector(-1, 0))
        elseif key == 'right' then
            vector_out = addVector(vector_out, newVector(1, 0))
        end
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
    createEntity('stick_attack',
        entities['player']['pos']['x'], 
        entities['player']['pos']['y'],
        50,
        0,
        stick_attack,
        'melee',
        newVector(0,0),
        1,
        1,
        true,
        'player',
        1)
end

function stickAttack2()
    attack = stick_attack2
    local vector = newVector(m_pos['x'] - entities['player']['pos']['x'], m_pos['y'] - entities['player']['pos']['y'])
    createEntity('stick_attack2',
        entities['player']['pos']['x'] + vector['x'] * (entities['player']['radius'] + 15), 
        entities['player']['pos']['y'] + vector['y'] * (entities['player']['radius'] + 15),
        15,
        200,
        stick_attack2,
        'projectile',
        vector,
        1,
        1,
        true)
end

function mouseCombat(button)
    if button == 1 then
        if timers['basicattack'] <= 0 then
            stickAttack()
            timers['basicattack'] = cooldowns['basicattack']
        end
    end
    if button == 2 then
        if timers['secondaryattack'] <= 0 then
            stickAttack2()
            timers['secondaryattack'] = cooldowns['secondaryattack']
        end
    end
    
end

function love.mousepressed(x, y, button)
    mouseCombat(button)
end

function updateVectorPosisitions(dt)
    local to_remove = {}
    for entity, value in pairs(entities) do
        --print("entity = ", entity, " pos=", value['pos']['x'],value['pos']['y'] )
        local new_pos = {
            ['x'] = value['pos']['x'] + value['vector']['x'] * entities[entity]['speed'] * dt,
            ['y'] = value['pos']['y'] + value['vector']['y'] * entities[entity]['speed'] * dt
        }
    
        for e, v in pairs(entities) do
            if e ~= entity and v ~= nil then
                if circleCollisionDetection(new_pos['x'], new_pos['y'], v['pos']['x'], v['pos']['y'], entities[entity]['radius'], entities[e]['radius']) then
                    if entities[entity]['type'] == 'player' and entities[e]['type'] == 'player' then
                        new_pos = fillGap(entity, e)
                    elseif entities[entity]['type'] == 'projectile' and entities[e]['type'] == 'player' then
                        entities[e]['hp'] = entities[e]['hp'] - entities[entity]['dmg']
                        table.insert(to_remove, entity)
                    elseif entities[entity]['type'] == 'projectile' and entities[e]['type'] == 'projectile' then
                        table.insert(to_remove, entity)
                        table.insert(to_remove, e)
                    elseif entities[entity]['type'] == 'melee' and entities[e]['type'] == 'projectile' then
                        table.insert(to_remove, e)
                    elseif entities[entity]['type'] == 'melee' and entities[e]['type'] == 'player' then
                        if entities[entity]['parent'] ~= e then
                            entities[e]['hp'] = entities[e]['hp'] - entities[entity]['dmg']
                            entities[entity]['dmg'] = 0
                        end
                    end
                end
            end
        end
        local temp_pos = wallCollisionCorrection(new_pos['x'], new_pos['y'], entities[entity]['radius'])
        if temp_pos['x'] ~= new_pos['x'] or temp_pos['y'] ~= new_pos['y'] then
            if entities[entity]['type'] == 'projectile' then
                table.insert(to_remove, entity)
            else
                new_pos = temp_pos
            end
        end
        if entities[entity]['spin'] == true then
            entities[entity]['rotation'] = entities[entity]['rotation'] + math.pi/4
        end

        entities[entity]['pos'] = new_pos
    end
    removeEntities(to_remove)
end

function removeEntities(to_remove)
    for _, e in ipairs(to_remove) do
        entities[e] = nil
        print(e)
    end
end

function fillGap(entity1, entity2)
    -- when two entities would otherwise collide, we need to find the amount to move entity1 along their vector without collision
    local dist_x = entities[entity1]['pos']['x'] - entities[entity2]['pos']['x']
    local dist_y = entities[entity1]['pos']['y'] - entities[entity2]['pos']['y']
    local dist = math.sqrt((dist_x^2) + (dist_y^2)) - entities[entity1]['radius'] - entities[entity2]['radius']
    local temp_vector = multVector(entities[entity1]['vector'], dist)
    local new_pos = {
        ['x'] = entities[entity1]['pos']['x'] + temp_vector['x'],
        ['y'] = entities[entity1]['pos']['y'] + temp_vector['y']
    }
    return new_pos
end

function wallCollisionCorrection(cx, cy, cr)
    -- detects wall collision returns corrected position

    local pos_out = {['x'] = cx, ['y'] = cy}
    if cx > width - wall_width - cr then
        pos_out['x'] = width - wall_width - cr
    elseif cx < wall_width + cr then
        pos_out['x'] = wall_width + cr
    end
    if cy > width - wall_width - cr then
        pos_out['y'] = width - wall_width - cr
    elseif cy < wall_width + cr then
        pos_out['y'] = wall_width + cr
    end

    return pos_out
end

function circleCollisionDetection(cx1, cy1, cx2, cy2, cr1, cr2)
    local dist_x = cx1 - cx2
    local dist_y = cy1 - cy2
    local dist = math.sqrt((dist_x^2) + (dist_y^2))

    if (dist <= cr1 + cr2) then
        return true
    end
    return false
end

function updateDurations(dt)
    for e, v in pairs(entities) do
        entities[e]['duration'] = entities[e]['duration'] - dt
        if entities[e]['duration'] <= 0 then
            print(entities[e]['duration'])
            entities[e] = nil
        end
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
    if timers['secondaryattack'] <= cooldowns['secondaryattack'] / 4 then
        attack = nil
    end

    checkInputs()
    updateDurations(dt)
    updateVectorPosisitions(dt)


end

