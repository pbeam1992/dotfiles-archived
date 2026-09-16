-- Lets the `hs` command line tool talk to this instance (`hs -c "<lua>"`).
require("hs.ipc")

local windows = require("windows")
local summon = require("summon")

hs.window.animationDuration = 0

-- Every binding hangs off one leader chord.
local leader = { "cmd", "alt", "ctrl" }
local leaderShift = { "cmd", "alt", "ctrl", "shift" }

-- Cycle through the windows of the current space: next, previous
hs.hotkey.bind(leader, "tab", function() windows.cycle(1) end)
hs.hotkey.bind(leaderShift, "tab", function() windows.cycle(-1) end)

-- Snap the focused window; repeated presses cycle 1/2 -> 2/3
local leftCycle  = { { 0, 0, 1/2, 1 }, { 0, 0, 2/3, 1 } }
local rightCycle = { { 1/2, 0, 1/2, 1 }, { 1/3, 0, 2/3, 1 } }
hs.hotkey.bind(leader, "h", function() windows.snapCycle(leftCycle) end)
hs.hotkey.bind(leader, "l", function() windows.snapCycle(rightCycle) end)
hs.hotkey.bind(leader, "return", function() windows.moveFocused({ 0, 0, 1, 1 }) end)

-- Summon an app to the current space, centred; press again to quit it
hs.hotkey.bind(leader, "n", summon.toggle("md.obsidian"))
hs.hotkey.bind(leader, "r", summon.toggle("com.apple.reminders"))

-- Focus an app, launching it if needed; never quits it
local function focus(bundleID)
  hs.application.launchOrFocusByBundleID(bundleID)
end

-- The default browser is looked up on each press, so changing it in System Settings just works
hs.hotkey.bind(leader, "b", function() focus(hs.urlevent.getDefaultHandler("http")) end)
hs.hotkey.bind(leader, "t", function() focus("com.mitchellh.ghostty") end)
hs.hotkey.bind(leader, "c", function() focus("com.tinyspeck.slackmacgap") end)

-- Reload: leader+shift+R, and automatically on any .lua change in the config dir
hs.hotkey.bind(leaderShift, "r", hs.reload)

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
