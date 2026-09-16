-- Focused-window helpers: cycling through the current space and snapping to
-- screen fractions. Behaviour only; the key bindings live in init.lua.
local M = {}

-- Windows in the current space. hs.window.orderedWindows() is on-screen windows
-- only, i.e. the current space of every display, minus minimized and hidden
-- ones. Sorted by window id, which macOS hands out in creation order, so the
-- order never shifts and repeated presses visit every window once.
local function spaceWindows()
  local wins = {}
  for _, w in ipairs(hs.window.orderedWindows()) do
    if w:isStandard() then wins[#wins + 1] = w end
  end
  table.sort(wins, function(a, b) return a:id() < b:id() end)
  return wins
end

-- Focus the next (dir = 1) or previous (dir = -1) window in the current space.
function M.cycle(dir)
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

-- Move the focused window to a screen unit rect, e.g. { 0, 0, 1, 1 } for full.
function M.moveFocused(unit)
  local win = hs.window.focusedWindow()
  if win then win:moveToUnit(unit) end
end

local snapTolerance = 8 -- px; apps with size constraints rarely land on the exact pixel

local function frameMatches(frame, target)
  return math.abs(frame.x - target.x) <= snapTolerance
     and math.abs(frame.y - target.y) <= snapTolerance
     and math.abs(frame.w - target.w) <= snapTolerance
     and math.abs(frame.h - target.h) <= snapTolerance
end

-- Snap the focused window to units[1]; if it already sits at units[i], move it
-- to units[i+1] (wrapping), so repeated presses cycle through the sizes.
function M.snapCycle(units)
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

return M
