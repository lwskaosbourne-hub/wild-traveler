function love.conf(t)
    io.stdout:setvbuf("no")
    t.identity = "Wild Traveler"                    -- The name of the save directory (string)
    t.console = false                                           -- Attach a console (boolean, Windows only)
    t.window.width = 740                                        -- The window width (number)
    t.window.height = 460                                       -- The window height (number)
    t.window.fullscreen = false                                 -- Enable fullscreen (boolean)
    t.window.resizable = true
    t.window.vsync = 1
    t.window.msaa = 0                                           -- The number of samples to use with multi-sampled antialiasing (number)
    t.window.title = "Wild Traveler"
end