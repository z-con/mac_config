-- 3-finger trackpad swipe → AeroSpace workspace prev/next

require("hs.ipc")

local AEROSPACE = "/opt/homebrew/bin/aerospace"
local FINGERS   = 3
local THRESHOLD = 0.02
local DEBOUNCE  = 0.35

local accumDx   = 0
local lastN     = 0
local lastSwipe = 0

local watcher = hs.eventtap.new({ hs.eventtap.event.types.gesture }, function(event)
    local touches = event:getTouches()
    if not touches then return false end

    local n, moveDx = 0, 0
    for _, t in pairs(touches) do
        n = n + 1
        if t.phase == "moved" and t.normalizedPosition and t.previousNormalizedPosition then
            moveDx = moveDx + (t.normalizedPosition.x - t.previousNormalizedPosition.x)
        end
    end

    if n ~= lastN then accumDx = 0 end
    lastN = n

    if n ~= FINGERS then return false end

    accumDx = accumDx + (moveDx / n)

    local now = hs.timer.secondsSinceEpoch()
    if math.abs(accumDx) >= THRESHOLD and (now - lastSwipe) > DEBOUNCE then
        local dir = accumDx < 0 and "next" or "prev"
        lastSwipe = now
        accumDx   = 0
        hs.task.new(AEROSPACE, nil, {"workspace", "--no-stdin", dir}):start()
    end

    return false
end)

watcher:start()
hs.alert.show("Hammerspoon loaded ✓")
