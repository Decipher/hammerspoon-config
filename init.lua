local alert = require "hs.alert"
local fnutils = require "hs.fnutils"
local grid = require "hs.grid"
local hotkey = require "hs.hotkey"
local window = require "hs.window"

grid.MARGINX = 5
grid.MARGINY = 5
grid.GRIDHEIGHT = 13
grid.GRIDWIDTH = 13

local mash = { "⌘", "⌥", "⌃" }
local mashshift = { "⌘", "⌥", "⌃", "⇧" }
hs.window.animationDuration = 0


local function adjust(x, y, w, h)
  return function()
    local win = hs.window.focusedWindow()
    if not win then return end

    local f = win:frame()
    local max = win:screen():frame()

    f.w = math.floor(max.w * w)
    f.h = math.floor(max.h * h)
    f.x = math.floor((max.w * x) + max.x)
    f.y = math.floor((max.h * y) + max.y)

    win:setFrame(f)
  end
end
hotkey.bind(mash, "left", adjust(0, 0, 0.5, 1))
hotkey.bind(mash, "right", adjust(0.5, 0, 0.5, 1))
hotkey.bind(mash, "space", adjust(0, 0, 1, 1))
hotkey.bind(mashshift, "space", adjust(0.25, 0.25, 0.5, 0.5))

--
-- Screen resolution management
--
local function setres(direction)
    local screen = hs.screen.mainScreen()
    local modes = screen:availableModes()
    local currentMode = screen:currentMode()
    local currentKey = tonumber(currentMode.w .. '.' .. currentMode.h)

    alert.closeAll()

    local modes_rekeyed = {}
    for key, values in pairs(modes) do
        new_key = tonumber(values.w .. '.' .. values.h)
        modes_rekeyed[new_key] = values
    end

    local ordered_keys = {}
    for k in pairs(modes_rekeyed) do
        table.insert(ordered_keys, k)
    end
    table.sort(ordered_keys);
    local last = nil
    for i = 1, #ordered_keys do
        local k, v = ordered_keys[i], modes_rekeyed[ordered_keys[i]]
        if direction == 'up' and currentKey == last then
            screen:setMode(v.w, v.h, v.scale)
            alert.show(v.w .. ' x ' .. v.h)
            break
        elseif direction == 'down' and currentKey == k then
            v = modes_rekeyed[last]
            screen:setMode(v.w, v.h, v.scale)
            alert.show(v.w .. ' x ' .. v.h)
            break
        end
        last = k
    end
end

hotkey.bind(mash, "=", function() setres('up') end)
hotkey.bind(mash, "-", function() setres('down') end)



--
-- Monitor and reload config when required
--
function reload_config(files)
    hs.reload()
end

hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reload_config):start()
alert.show("Config loaded")
