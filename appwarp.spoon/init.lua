-- openApplication borrowed from fabiomcosta (https://github.com/fabiomcosta/keyboard/blob/main/hammerspoon/hyper.lua)
-- (https://github.com/fabiomcosta/keyboard/blob/73b22906b31dfc12cc834c382515e30c4450d0f5/hammerspoon/hyper.lua)
-- kept the associated table functions as well

local obj={}

obj.__index = obj

-- Metadata
obj.name = "appWarp"
obj.version = "0.1"
obj.author = "j <to-json@proton.me>"
obj.homepage = "https://github.com/to-json/hammer-spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- these functions are conveniences for openApplication and are not, as such
-- documented as exposed methods

local function tableLength(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end

local function tableFindIndex(t, fn)
  for i, item in ipairs(t) do
    print(item)
    if (fn(item, i)) then
      print(i)
      print(t[i])
      return i
    end
  end
  return nil
end

-- obj structures that are not just metadata
obj.bindings = {}

--- appWarp:openApplication
--- Method
--- opens an application, or, teleports focus to it if it is already open
---
--- Parameters:
--- * app_id - A string containing the name of the application to open/focus
---
--- Returns: nil; this is not really suitable for chaining
function obj:openApplication(app_id)
  if (type(app_id) ~= 'string') then
    hs.logger.new('hyper'):e('Invalid application id ', app_id)
    return
  end

  local application = hs.application.get(app_id)

  -- First time we try to either open or focus on this application
  if application == nil or not application:isFrontmost() then
    hs.application.open(app_id)
    return
  end

  -- this is here because, hypothetically, it should include windows that are not currently
  -- in the visible space. it does not. i don't fucking know why. i got bored of fighting with
  -- it because for my usecase, it's mostly fine. however, there is a simpler, faster, application:allWindows
  -- function that i might return to later. that more reasonable version was in the original code;
  -- the goofy shit below is all on me. -j
  local filter = function(w)
    local a = w:application()
    local name = nil
    if a then
      name = a:name()
    end
    if name then
      return name == app_id
    end
    return false
  end
  local windowFilter = hs.window.filter.new(filter)
  windowFilter:setAppFilter(app_id, {})
  local allWindows = windowFilter:getWindows()

  table.sort(allWindows, function(a, b) return a:id() < b:id() end)

  local windowsLength = tableLength(allWindows)

  -- If there are more than 1 windows for this application we try to focus
  -- the window on the next index.
  if (windowsLength > 1) then
    local focusedWindow = application:focusedWindow()
    local focusedIndex = tableFindIndex(
      allWindows,
      function(window) return window == focusedWindow end
    ) or 0
    local nextIndex = (focusedIndex % windowsLength) + 1
    allWindows[nextIndex]:unminimize()
    allWindows[nextIndex]:focus()
  end
  return nil
end

--- appWarp:bindHotKeys
--- Method
--- Binds hotkeys according to a conventional hotkey binding table for hammerspoon
---
--- Parameters:
--- * mapping - A table containing key combinations and application names to associate to them
--      importantly, there should be a key combination for 'appWarp', as this activates the
--      transient appWarp mode, which is the only time the other bindings are active.
--      Non modal bindings may be supported later, but, this is unlikely
--
--      It is strongly suggested you wrap all of the 'names' in your binding in a
--      table like so
--      ['application']={nil, 'a'}
--      ['other application']={nil, 'b'}
--      the syntactic sugar that allows bare word keys does not work for
--      several valid MacOS application names, and cannot be mixed with
--      desugared names in a single table
function obj:bindHotKeys(mapping)
  self:bindModalHotKeys(mapping)
  return self
end

-- This method is "private", it is the actual keybinding mechanism, but, the conventional spoon
-- public api requires bindHotKeys to do that work
function obj:bindModalHotKeys(mapping)
  if (self.modeKey) then
      self.modeKey:delete()
  end
  local warp_mapping = mapping["appWarp"]
  mapping["appWarp"] = nil
  for app_name, binding in pairs(mapping) do
    local binding_string = ""
    if binding[1] then
      binding_string = string.format("%s : %s + %s", app_name, binding[1], binding[2])
    else
      binding_string = string.format("%s : %s", app_name, binding[2])
    end
    table.insert(self.bindings, binding_string)
  end
  local msg = table.concat(self.bindings, " - ")
  self.modeKey = hs.hotkey.modal.new(warp_mapping[1], warp_mapping[2], msg)
  for app_name, binding in pairs(mapping) do
    local func = function()
      self.modeKey:exit()
      self:openApplication(app_name)
    end
    self:bindModalHotKey(app_name, binding, func)
  end
end

-- This method is "private", it binds an individual hotkey
function obj:bindModalHotKey(app_name, binding, func)
  self.modeKey:bind(binding[1], binding[2], app_name, func)
end

return obj
