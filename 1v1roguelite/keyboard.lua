WINDOW_WIDTH = 600
WINDOW_HEIGHT = 200
FONT_SIZE = 30
TEXT_BOX_WIDTH = 400
TEXT_BOX_HEIGHT = 50
TEXT_BOX_X = (WINDOW_WIDTH - TEXT_BOX_WIDTH) / 2
TEXT_BOX_Y = (WINDOW_HEIGHT - TEXT_BOX_HEIGHT) / 2

host_button = love.graphics.newImage("assets/host_button.png")
join_button = love.graphics.newImage("assets/join_button.png")

buttons = {
    ['join'] = {['icon'] = join_button, ['x'] = 50, ['y'] = 300},
    ['host'] = {['icon'] = host_button, ['x'] = 600, ['y'] = 300},
}


KEY_IMAGE_ASSETS = {
    ["."] = "key_decimal",
    [" "] = "key_blank",
    ["0"] = "key_zero",
    ["1"] = "key_one",
    ["2"] = "key_two",
    ["3"] = "key_three",
    ["4"] = "key_four",
    ["5"] = "key_five",
    ["6"] = "key_six",
    ["7"] = "key_seven",
    ["8"] = "key_eight",
    ["9"] = "key_nine",
}

keys = {}

underscore_keys = {}

keyboard = {}
k_ind = 0
blink_duration = .6
k_blink = blink_duration
underscore = true


function loadKeyboard()
    love.graphics.setBackgroundColor(200, 200, 200)
    font = love.graphics.newFont(FONT_SIZE)

    for key, asset in pairs(KEY_IMAGE_ASSETS) do
        underscore_keys[key] = love.graphics.newImage("assets/keys/" .. asset .. ".png")
        keys[key] = love.graphics.newImage("assets/keys/" .. asset .. "_no_underscore.png")
    end


    inputFocus = true
    
    for i = 0, 14 do
        keyboard[i] = " "
    end

end

function drawKeyboard()

    -- Draw text box background
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(host_button, 50, 300)
    love.graphics.draw(join_button, 600, 300)
    for button, vals in pairs(buttons) do
        love.graphics.draw(buttons[button]['icon'], buttons[button]['x'], buttons[button]['y'])
    end

    local x = 50
    local y = 600

    for i, val in pairs(keyboard) do
        love.graphics.draw(keys[val], x, y)
        x = x + 100
    end
    
    local cursor = k_ind * 100 + 50
    if underscore then
        love.graphics.draw(underscore_keys[keyboard[k_ind]], cursor, y)
    end
end

function backspace()
    keyboard[k_ind] = ' '
    for i, v in pairs(keyboard) do
        if i > k_ind then
            keyboard[i - 1] = keyboard[i]
        end
    end
    keyboard[14] = ' '
    if k_ind > 0 then
        k_ind = k_ind - 1
    end
end

function checkKeyboardInput(key)

    if key ~= nil then
        if inputFocus then
            if key == "backspace" then
                backspace()
            elseif key == "left" then
                if k_ind > 0 then
                    k_ind = k_ind - 1
                end
            elseif key == "right" then
                if k_ind < 14 then
                    k_ind = k_ind + 1
                end
            elseif key == "escape" then
                inputFocus = false
            elseif keys[key] ~= nil then
                keyboard[k_ind] = key
                if k_ind < 14 then
                    k_ind = k_ind + 1
                end
            end
        end
    end
end

function updateKeyboard(dt)
    k_blink = k_blink - dt
    if k_blink <= 0 then
        k_blink = blink_duration
        if underscore then
            underscore = false
        else
            underscore = true
        end
    end

end