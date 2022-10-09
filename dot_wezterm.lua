local wezterm = require("wezterm")

return {
  color_scheme = "MaterialOcean",
  --window_background_image = "media/wallpapers/distrotube/0042.jpg",
  --window_background_image = "media/wallpapers/distrotube/0188.jpg",
  window_decorations = "NONE",
  window_background_image_hsb = {
    -- Darken the background image by reducing it to 1/3rd
    brightness = 0.3,
    -- You can adjust the hue by scaling its value.
    -- a multiplier of 1.0 leaves the value unchanged.
    hue = 1.0,
    -- You can adjust the saturation also.
    saturation = 1.0,
  },
  font_size = 12.00,
  font = wezterm.font("MesloLGS NF"),
  font_antialias = "None", -- None, Greyscale, Subpixel
  font_hinting = "None", -- None, Vertical, VerticalSubpixel, Full
  line_height = 1.1,
  --window_background_opacity = 0.7,
  enable_tab_bar = false,
  scrollback_lines = 10000,
  enable_scroll_bar = false,
  disable_default_key_bindings = true,
  disable_default_mouse_bindings = false,
  use_dead_keys = false,
  window_padding = {
    left = 2,
    -- This will become the scrollbar width if you have enabled the scrollbar!
    right = 2,
    top = 0,
    bottom = 0,
  },
  keys = {
    { key = "c", mods = "ALT", action = wezterm.action({ CopyTo = "Clipboard" }) },
    { key = "v", mods = "ALT", action = wezterm.action({ PasteFrom = "Clipboard" }) },
    { key = "+", mods = "CTRL", action = "IncreaseFontSize" },
    { key = "-", mods = "CTRL", action = "DecreaseFontSize" },
    { key = "0", mods = "CTRL", action = "ResetFontSize" },
    { key = "PageUp", mods = "SHIFT", action = wezterm.action({ ScrollByPage = -1 }) },
    { key = "PageDown", mods = "SHIFT", action = wezterm.action({ ScrollByPage = 1 }) },
    { key = "F", mods = "SHIFT|CTRL", action = wezterm.action({ Search = { CaseInSensitiveString = "" } }) },
  },
  mouse_bindings = {
    --{
    --  event={Down={streak=1, button="Middle"}},
    --  mods="NONE",
    --  action=wezterm.action{PasteFrom="PrimarySelection"}
    --},
    --{
    --  event={Down={streak=1, button="Left"}},
    --  mods="NONE",
    --  action=wezterm.action{CompleteSelectionOrOpenLinkAtMouseCursor="PrimarySelection"}
    --},
    -- Change the default click behavior so that it only selects
    -- text and doesn't open hyperlinks
    {
      event = { Up = { streak = 1, button = "Left" } },
      mods = "NONE",
      action = wezterm.action({ CompleteSelection = "PrimarySelection" }),
    },
    -- and make CTRL-Click open hyperlinks
    {
      event = { Up = { streak = 1, button = "Left" } },
      mods = "CTRL",
      action = "OpenLinkAtMouseCursor",
    },
  },
}
