title = love.graphics.newImage("assets/title_card.png")
arena_button = love.graphics.newImage("assets/arena_button.png")
options_button = love.graphics.newImage("assets/options_button.png")
exit_button = love.graphics.newImage("assets/exit_button.png")


menu_buttons = {
    [1] = {name = "title", image = title, x = 0, y = 0, BUTTON_WIDTH = 1000, BUTTON_HEIGHT = 200},
    [2] = {name = "game", image = arena_button, x = 250, y = 210, BUTTON_WIDTH = 500, BUTTON_HEIGHT = 200},
    [3] = {name = "options", image = options_button, x = 250, y = 420, BUTTON_WIDTH = 500, BUTTON_HEIGHT = 200},
    [4] = {name = "exit", image = exit_button, x = 250, y = 630, BUTTON_WIDTH = 500, BUTTON_HEIGHT = 200},
}

function doMenu()
    for _, button in ipairs(menu_buttons) do
        love.graphics.draw(button['image'], button['x'], button['y'])
    end
end

function menuClick(m_pos)
    -- returns the correct window_state from a mouse position parameter
    local selection = nil
    if m_pos["x"] and m_pos["y"] then
        for _, button in ipairs(menu_buttons) do
            if button["x"] <= m_pos["x"] and button["x"] + button['BUTTON_WIDTH'] >= m_pos["x"] and button["y"] <= m_pos["y"] and button["y"] + button['BUTTON_HEIGHT'] >= m_pos["y"] then
                selection = button['name']
            end
        end
    end
    return selection
end