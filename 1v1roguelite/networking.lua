-- Requires the luasocket library
local socket = require("socket")

local entities = {} -- The table that will be transmitted
local isHost = false -- Flag to determine if the player is a host
local isClient = false -- Flag to determine if the player is a client

local server = nil
local client = nil
local connection = nil
local ip = "localhost" -- You can change this to the host's IP
local port = 12345

local inputMode = nil
local inputIP = true -- Start by asking for IP
local inputPort = false -- Then ask for port

local promptText = "Enter IP Address: "
local inputText = ""

-- Love2D callbacks
function loadNetwork()
    -- Decide if this player is the host or client
    local mode = love.window.showMessageBox("Choose Mode", "Host or Client?", {"Host", "Client"}, "info")
    
    if mode == 1 then
        isHost = true
        inputMode = "Host"
        promptText = "Enter Port to Host On: "
    elseif mode == 2 then
        isClient = true
        inputMode = "Client"
    end
end

function updateNetwork(dt)
    -- If host, accept clients and send data
    if isHost then
        acceptClient()
        if connection then
            sendEntities(connection)
            receiveEntities(connection)
        end
    end

    -- If client, send and receive data from the host
    if isClient and client then
        sendEntities(client)
        receiveEntities(client)
    end
end

-- Function to start the server (host)
function startServer()
    server = socket.bind(ip, port)
    server:settimeout(0) -- Make the server non-blocking
    print("Server started on " .. ip .. ":" .. port)
end

-- Function to accept clients (if any)
function acceptClient()
    if server then
        connection = server:accept() -- Accept a client connection
        if connection then
            connection:settimeout(0) -- Make the connection non-blocking
            print("Client connected")
        end
    end
end

-- Function to connect to the server (as a client)
function connectToServer()
    client = socket.tcp()
    client:settimeout(5) -- Set a timeout for connection attempts
    local success, err = client:connect(ip, port)
    
    if success then
        client:settimeout(0) -- Make the connection non-blocking
        print("Connected to server")
    else
        print("Failed to connect: " .. err)
    end
end

-- Function to send the entities table
function sendEntities(conn)
    local data = love.data.pack("string", "entities", entities)
    conn:send(data .. "\n") -- Send data followed by a newline for easy parsing
end

-- Function to receive the entities table
function receiveEntities(conn)
    local data, err = conn:receive()
    if data then
        entities = love.data.unpack("string", data)
    elseif err ~= "timeout" then
        print("Receive error: " .. err)
    end
end

function drawNetworking()
    love.graphics.print("Mode: " .. (inputMode or ""), 10, 10)
    love.graphics.print(promptText, 10, 40)
    love.graphics.print(inputText, 10, 70)

    if connection or client then
        love.graphics.print("Entities: " .. #entities, 10, 100)
    end
end

-- Capture keyboard input to get the IP and port
function love.textinput(t)
    inputText = inputText .. t
end

-- Handle backspace to remove characters
function love.keypressed(key)
    if key == "backspace" then
        inputText = inputText:sub(1, -2)
    elseif key == "return" then
        handleInput() -- Process the input once Enter is pressed
    end
end

function handleInput()
    if inputIP then
        ip = inputText
        inputText = ""
        inputIP = false
        inputPort = true
        promptText = "Enter Port: "
    elseif inputPort then
        port = inputText
        inputText = ""
        inputPort = false
        promptText = "Connecting..."

        if isHost then
            startServer()
        elseif isClient then
            connectToServer()
        end
    end
end