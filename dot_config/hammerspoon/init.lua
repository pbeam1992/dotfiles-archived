-- Lets the `hs` command line tool talk to this instance (`hs -c "<lua>"`).
require("hs.ipc")

local leader = { "cmd", "alt", "ctrl" }
local leaderShift = { "cmd", "alt", "ctrl", "shift" }

-- Cycle through windows in the current space: leader+tab next, leader+shift+tab
-- previous. hs.window.orderedWindows() is on-screen windows only, i.e. the
-- current space of every display, minus minimized and hidden ones. Sorted by
-- window id, which macOS hands out in creation order, so the order never
-- shifts and repeated presses visit every window once.
local function spaceWindows()
  local wins = {}
  for _, w in ipairs(hs.window.orderedWindows()) do
    if w:isStandard() then wins[#wins + 1] = w end
  end
  table.sort(wins, function(a, b) return a:id() < b:id() end)
  return wins
end

local function cycle(dir)
  local wins = spaceWindows()
  if #wins == 0 then return end

  local cur, idx = hs.window.focusedWindow(), 1
  if cur then
    for i, w in ipairs(wins) do
      if w:id() == cur:id() then idx = i break end
    end
  end

  wins[(idx - 1 + dir) % #wins + 1]:focus()
end

hs.hotkey.bind(leader, "tab", function() cycle(1) end)
hs.hotkey.bind(leaderShift, "tab", function() cycle(-1) end)

-- Window management
hs.window.animationDuration = 0

local function moveFocused(unit)
  local win = hs.window.focusedWindow()
  if win then win:moveToUnit(unit) end
end

-- Snap the focused window to units[1]; if it already sits at units[i], move it
-- to units[i+1] (wrapping), so repeated presses cycle through the sizes.
local snapTolerance = 8 -- px; apps with size constraints rarely land on the exact pixel

local function frameMatches(frame, target)
  return math.abs(frame.x - target.x) <= snapTolerance
     and math.abs(frame.y - target.y) <= snapTolerance
     and math.abs(frame.w - target.w) <= snapTolerance
     and math.abs(frame.h - target.h) <= snapTolerance
end

local function snapCycle(units)
  local win = hs.window.focusedWindow()
  if not win then return end
  local screen, frame = win:screen(), win:frame()
  local next = 1
  for i, unit in ipairs(units) do
    if frameMatches(frame, screen:fromUnitRect(unit)) then
      next = i % #units + 1
      break
    end
  end
  win:moveToUnit(units[next])
end

local leftCycle  = { { 0, 0, 1/2, 1 }, { 0, 0, 2/3, 1 } }
local rightCycle = { { 1/2, 0, 1/2, 1 }, { 1/3, 0, 2/3, 1 } }

hs.hotkey.bind(leader, "h", function() snapCycle(leftCycle) end)
hs.hotkey.bind(leader, "l", function() snapCycle(rightCycle) end)
hs.hotkey.bind(leader, "return", function() moveFocused({ 0, 0, 1, 1 }) end)

-- Reload: leader+R, and automatically on any .lua change in the config dir
hs.hotkey.bind(leader, "r", hs.reload)

local watcher = hs.pathwatcher.new(hs.configdir, function(files)
  for _, file in ipairs(files) do
    if file:sub(-4) == ".lua" then
      hs.reload()
      return
    end
  end
end)
watcher:start()

hs.alert.show("Hammerspoon config loaded")
