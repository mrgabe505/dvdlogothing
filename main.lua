local shader

function love.load()
    -- window control
    shader = love.graphics.newShader("confetti.glsl")
    shader:send("iResolution", {love.graphics.getWidth(), love.graphics.getHeight()})
    love.window.setMode(800, 600, {resizable=true, vsync=0, minwidth=400, minheight=300})
    love.window.setTitle("DVD Logo")
    

    boopsfx = love.audio.newSource("boop.mp3", "static")
    

    x, y = 0,0 
    w, h = 180, 82 -- represnts the dvdlogo png
    
    dvd_logo = love.graphics.newImage("dvdlogosmall.png")


    -- rectangle/dvd logo stuff
    x_direction = 0
    y_direction = 0
    window_width, window_height = love.window.getMode()

    x_logosize = window_width - w
    y_logosize = window_height - h

    r_color = love.math.random(0,100) / 100
    g_color = love.math.random(0,100) / 100
    b_color = love.math.random(0,100) / 100

    cooldown = 0

end

function logo_move()
    window_width, window_height = love.window.getMode()
    x_logosize = window_width - w
    y_logosize = window_height - h

    if x_direction == 0 then
        x = x + 0.25
    elseif x_direction == 1 then
        x = x - 0.25
    end
    if x == x_logosize or x > x_logosize then
        x_direction = 1
    elseif x == 0 or x < 0 then
        x_direction = 0
    end

    if y_direction == 0 then
        y = y + 0.25
    elseif y_direction == 1 then
        y = y - 0.25
    end
    if y == y_logosize or y > y_logosize then
        y_direction = 1
    elseif y == 0 or y < 0 then
        y_direction = 0
    end
end

function new_dvd_color()
    r_color = love.math.random(0,100) / 100
    g_color = love.math.random(0,100) / 100
    b_color = love.math.random(0,100) / 100
end


-- checks for collision with window borders and changes direction if so.
function love.update(dt)
    cooldown = math.max(cooldown - dt, 0)
    shader:send("iTime", love.timer.getTime())
    if x == x_logosize or x == 0 then
        new_dvd_color()
        boopsfx:play()
        if y == y_logosize or y == 0 then
            cooldown = 2
        end
    elseif y == y_logosize or y == 0 then
        new_dvd_color()
        boopsfx:play()
    end
    logo_move()
end

-- Draw a coloured rectangle.
function love.draw()
    love.graphics.setColor(r_color, g_color, b_color)
    --love.graphics.rectangle("fill", x, y, w, h)
    
    love.graphics.draw(dvd_logo, x, y)

    if cooldown > 0 then
        love.graphics.setShader(shader)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setShader()
    end
    

end
