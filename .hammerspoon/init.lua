-- 3-finger trackpad swipe → AeroSpace workspace prev/next
--
-- REQUIRED: System Settings → Trackpad → More Gestures
--   Set "Swipe between full-screen apps" to 4 fingers (or Off)
--   so macOS doesn't intercept 3-finger swipes before Hammerspoon sees them.

local AEROSPACE = "/opt/homebrew/bin/aerospace"
local FINGERS   = 3
local THRESHOLD = 40    -- horizontal pixels before firing
local DEBOUNCE  = 0.35  -- seconds between swipes

local startX   = nil
local lastSwipe = 0

local watcher = hs.eventtap.new({ hs.eventtap.event.types.gesture }, function(event)
    local touches = event:getTouches()
    if not touches then return false end

    local n, sumX = 0, 0
    for _, t in pairs(touches) do
        n    = n + 1
        sumX = sumX + t.absolutePosition.x
    end

    if n ~= FINGERS then
        startX = nil
        return false
    end

    local x   = sumX / n
    local now = hs.timer.secondsSinceEpoch()

    if startX == nil then
        startX = x
        return false
    end

    local dx = x - startX
    if math.abs(dx) >= THRESHOLD and (now - lastSwipe) > DEBOUNCE then
        lastSwipe = now
        startX    = nil
        -- swipe left → next workspace, swipe right → prev (matches Hyprland direction)
        if dx < 0 then
            hs.execute(AEROSPACE .. " workspace next", true)
        else
            hs.execute(AEROSPACE .. " workspace prev", true)
        end
    end

    return false
end)

watcher:start()
