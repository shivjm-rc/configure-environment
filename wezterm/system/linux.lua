return {
   default_prog = {(os.getenv("HOME") .. "/.nix-profile/bin/zsh")},
   font_size = 12.0,
   initial_rows = 35,
   initial_cols = 100,
   fontName = "JetBrains Mono NL",
   launch_menu = {
      {
         label = "PowerShell",
         args = { "/home/a/.nix-profile/bin/zsh", "-i", "-c", "pwsh" }
      }
   }
};
