-- Summon an app: bring its window onto the current space and centre it,
-- launching the app first if needed. Pressed again while the app is frontmost,
-- it quits the app instead. Built for a hotkey:
--
--   hs.hotkey.bind(leader, "n", summon.toggle("md.obsidian"))
--   hs.hotkey.bind(leader, "m", summon.toggle("com.apple.mail", { unit = { 0, 0, 1, 1 } }))
--
-- Find an app's bundle ID with: osascript -e 'id of app "Name"'
--
-- On macOS 26+ a window on another space is out of reach: accessibility does
-- not list it at all (so hs.window never sees it) and hs.spaces.moveWindowToSpace()
-- reports success without moving anything. So when the app is running but shows
-- no window here, it is quit and relaunched, which reopens it on the active
-- space. Merely activating it would switch spaces.
local M = {}

local defaultUnit = { 1/8, 1/8, 3/4, 3/4 }
local waitTimeout = 10 -- seconds to wait for an app to quit or show its window

-- The app's first standard window, or nil if it has none (or is not running).
local function standardWindow(bundleID)
  local app = hs.application.get(bundleID)
  if not app then return nil end
  for _, w in ipairs(app:allWindows()) do
    if w:isStandard() then return w end
  end
end

local function place(win, unit)
  if win:isMinimized() then win:unminimize() end
  win:setFrame(hs.screen.mainScreen():fromUnitRect(unit))
  win:focus()
end

-- Poll until predicate holds, then run action; give up silently after waitTimeout.
local function waitFor(predicate, action)
  local deadline = hs.timer.secondsSinceEpoch() + waitTimeout
  hs.timer.waitUntil(function()
    return predicate() or hs.timer.secondsSinceEpoch() > deadline
  end, function()
    if predicate() then action() end
  end, 0.1)
end

-- Activate the app (launching it if needed) and place its window once it exists.
local function activateAndPlace(bundleID, unit)
  hs.application.launchOrFocusByBundleID(bundleID)
  waitFor(function() return standardWindow(bundleID) ~= nil end,
          function() place(standardWindow(bundleID), unit) end)
end

-- Returns a hotkey action for the app with the given bundle ID.
-- opts.unit: screen unit rect for the window (default: centred, 3/4 of the screen).
function M.toggle(bundleID, opts)
  local unit = opts and opts.unit or defaultUnit
  return function()
    local win, app = standardWindow(bundleID), hs.application.get(bundleID)
    if win and app:isFrontmost() then
      app:kill()
    elseif win then
      place(win, unit)
    elseif app then
      app:kill()
      waitFor(function() return hs.application.get(bundleID) == nil end,
              function() activateAndPlace(bundleID, unit) end)
    else
      activateAndPlace(bundleID, unit)
    end
  end
end

return M
