local wezterm = require 'wezterm';

-- function recompute_padding(window)
--   local window_dims = window:get_dimensions();
--   local overrides = window:get_config_overrides() or {}

--   if not window_dims.is_full_screen then
--     if not overrides.window_padding then
--       -- not changing anything
--       return;
--     end
--     overrides.window_padding = nil;
--   else
--     -- Use only the middle 33%
--     local third = math.floor(window_dims.pixel_width / 3)
--     local new_padding = {
--       left = third,
--       right = third,
--       top = 0,
--       bottom = 0
--     };
--     if overrides.window_padding and new_padding.left == overrides.window_padding.left then
--       -- padding is same, avoid triggering further changes
--       return
--     end
--     overrides.window_padding = new_padding

--   end
--   window:set_config_overrides(overrides)
-- end

-- wezterm.on("window-resized", function(window, pane)
--   recompute_padding(window)
-- end);

-- wezterm.on("window-config-reloaded", function(window)
--   recompute_padding(window)
-- end);

wezterm.on("update-right-status", function(window, pane)
  -- Each element holds the text for a cell in a "powerline" style << fade
  local cells = {};

  -- Figure out the cwd and host of the current pane.
  -- This will pick up the hostname for the remote host if your
  -- shell is using OSC 7 on the remote host.
  local cwd_uri = pane:get_current_working_dir()
  if cwd_uri then
    cwd_uri = cwd_uri:sub(8);
    local slash = cwd_uri:find("/")
    local cwd = ""
    local hostname = ""
    if slash then
      hostname = cwd_uri:sub(1, slash-1)
      -- Remove the domain name portion of the hostname
      local dot = hostname:find("[.]")
      if dot then
        hostname = hostname:sub(1, dot-1)
      end
      -- and extract the cwd from the uri
      cwd = cwd_uri:sub(slash)

      table.insert(cells, cwd);
      table.insert(cells, hostname);
    end
  end

  -- I like my date/time in this style: "Wed Mar 3 08:14"
  local date = wezterm.strftime("%a %b %-d %H:%M");
  table.insert(cells, date);

  -- An entry for each battery (typically 0 or 1 battery)
  for _, b in ipairs(wezterm.battery_info()) do
    table.insert(cells, string.format("%.0f%%", b.state_of_charge * 100))
  end

  -- The powerline < symbol
  local LEFT_ARROW = utf8.char(0xe0b3);
  -- The filled in variant of the < symbol
  local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

  -- Color palette for the backgrounds of each cell
  local colors = {
    "#3c1361",
    "#52307c",
    "#663a82",
    "#7c5295",
    "#b491c8",
  };

  -- Foreground color for the text across the fade
  local text_fg = "#c0c0c0";

  -- The elements to be formatted
  local elements = {};
  -- How many cells have been formatted
  local num_cells = 0;

  -- Translate a cell into elements
  function push(text, is_last)
    local cell_no = num_cells + 1
    table.insert(elements, {Foreground={Color=text_fg}})
    table.insert(elements, {Background={Color=colors[cell_no]}})
    table.insert(elements, {Text=" "..text.." "})
    if not is_last then
      table.insert(elements, {Foreground={Color=colors[cell_no+1]}})
      table.insert(elements, {Text=SOLID_LEFT_ARROW})
    end
    num_cells = num_cells + 1
  end

  while #cells > 0 do
    local cell = table.remove(cells, 1)
    push(cell, #cells == 0)
  end

  window:set_right_status(wezterm.format(elements));
end);

-- The filled in variant of the < symbol
local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

-- The filled in variant of the > symbol
local SOLID_RIGHT_ARROW = utf8.char(0xe0b0)

local isWindows = wezterm.target_triple == "x86_64-pc-windows-msvc";

--- Expects `wt_lua_dir` to be set by the calling file.
local systemConfig = isWindows and (dofile (wt_lua_dir .. '/system/windows.lua')) or (dofile (wt_lua_dir .. '/system/linux.lua'));

return {
  audible_bell = "Disabled",
  default_prog = systemConfig.default_prog,
  font = wezterm.font_with_fallback({
        "JetBrains Mono NL"
  }),
  font_size = systemConfig.font_size,
  harfbuzz_features = {},
  initial_rows = systemConfig.initial_rows,
  initial_cols = systemConfig.initial_cols,
  tab_max_width = 20,
  -- color_scheme = "primary",
  scrollback_lines = 9999,
  -- tab_bar_style = {
  --   active_tab_left = wezterm.format({
  --     {Background={Color="#0b0022"}},
  --     {Foreground={Color="#2b2042"}},
  --     {Text=SOLID_LEFT_ARROW},
  --   }),
  --   active_tab_right = wezterm.format({
  --     {Background={Color="#0b0022"}},
  --     {Foreground={Color="#2b2042"}},
  --     {Text=SOLID_RIGHT_ARROW},
  --   }),
  --   inactive_tab_left = wezterm.format({
  --     {Background={Color="#0b0022"}},
  --     {Foreground={Color="#1b1032"}},
  --     {Text=SOLID_LEFT_ARROW},
  --   }),
  --   inactive_tab_right = wezterm.format({
  --     {Background={Color="#0b0022"}},
  --     {Foreground={Color="#1b1032"}},
  --     {Text=SOLID_RIGHT_ARROW},
  --   }),
  -- },
  visual_bell = {
     fade_in_duration_ms = 75,
     fade_out_duration_ms = 75,
     target = 'CursorColor',
  },
}
