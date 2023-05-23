{ inputs, outputs, lib, config, pkgs, ... }: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      (final: prev: {
        zellij = pkgs.unstable.zellij;
        sensible = pkgs.unstable.vimPlugins.sensible;
      })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = (_: true);
    };
  };

  home = {
    username = "a";
    homeDirectory = "/home/a";
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    KEYTIMEOUT = "1";
  };

  home.packages = with pkgs; [
    ffmpeg
    curl
    zsh-fzf-tab
    hadolint
    kubernetes-helm
    openssl
    plantuml
    ruby
    sops
    watchexec
    wavpack
    yq
    kubectl
    kustomize
    helmfile
    exiftool
    kind
    shellcheck
    doctl
    rclone
    step-cli
    shfmt
    graphviz
    gitleaks
    tflint
    cargo-edit
    cargo-make
    cargo-outdated
    cargo-sweep
    cargo-update
    cargo-audit
    cargo-watch
    fd
    fselect
    loc
    ripgrep
    amber
    xh
    du-dust
    lsd
    gping
    tidy-viewer
    sd
    xsv
    just
    cargo-feature
    cargo-nextest
    taplo
    procs
    choose
    miniserve
    lfs
    htmlq
    wasm-pack
    cargo-unused-features
    # cargo-run-bin
    nodePackages.pnpm
    yarn
    nodePackages.js-beautify
    nodePackages.prettier
    netlify-cli
    nodePackages.vscode-json-languageserver
    nodePackages.yaml-language-server
    nodePackages.bash-language-server
    nodePackages.svelte-language-server
    typescript
    nodePackages.typescript-language-server
    nodePackages.mermaid-cli
    nodePackages.stylelint
    nodePackages.postcss
    black
    pdm
    pre-commit
    yamale
    yamllint
    python310Packages.python-lsp-server
    mypy
    # fonttools
    s4cmd
    pgcli
    gopls
    gitleaks
    jsonnet-bundler
    go-jsonnet
    kustomize-sops
    gojsontoyaml
    godef
    dsq
    duf
    terraform-ls
    perl
    git-filter-repo
    gomplate
    difftastic
    # erdtree
    dogdns
    sad
    deno
    jdk17
    tree-sitter
    android-tools
    sqlite
    k9s
    popeye
    magic-wormhole

    # pulldown-cmark

    trippy
  ];

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;
  programs.git.lfs.enable = true;
  programs.git.delta = {
    enable = true;
    options = {
      navigate = true;
      side-by-side = true;
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      directory.truncate_to_repo = false;
      directory.truncation_length = 0;
      directory.truncation_symbol = ".../";

      character.success_symbol = "[❯](green)[❯](bold green)";
      character.error_symbol = " [✗](bold red)";

      cmd_duration.min_time = 500;
      cmd_duration.show_milliseconds = true;

      # In WSL with systemd, this keeps showing `[Systemd]`.
      container.disabled = true;
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    autocd = false;
    dotDir = ".config/zsh";
    enableAutosuggestions = true;
    enableCompletion = true;
    shellAliases = {
      sl = "exa";
      ls = "exa";
      l = "exa -l";
      la = "exa -la";

      remount-x11 = "sudo mount -o remount,rw /tmp/.X11-unix";

      pp = "p -";

      g = "git";
      n = "npm";
    };

    history = {
      expireDuplicatesFirst = true;
      save = 100000000;
      size = 1000000000;
    };

    zplug = {
      enable = true;
      plugins = [
        { name = "zdharma-continuum/fast-syntax-highlighting"; }
        { name = "jeffreytse/zsh-vi-mode"; }
        { name = "Aloxaf/fzf-tab"; }
        { name = "chisui/zsh-nix-shell"; }
      ];
    };

    initExtra = ''
    bindkey -v

    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
    zstyle ':completion:*:descriptions' format '[%d]'
    zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
    '';
  };

  programs.exa.enable = true;

  programs.bat.enable = true;

  programs.gpg.enable = true;

  programs.pandoc.enable = true;

  programs.gh.enable = true;

  programs.mercurial.enable = true;
  programs.mercurial.userName = "shivjm";
  programs.mercurial.userEmail = "shivjm@example.com";

  programs.yt-dlp.enable = true;

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [
      "--cmd"
      "p"
    ];
  };

  programs.lazygit = {
    enable = true;
  };

  programs.neovim = {
    enable = true;
    # defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = [ pkgs.unstable.vimPlugins.LazyVim ];

    # TODO: Stop letting lazy.vim download and install everything.
    extraLuaConfig = ''
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
  spec = { "LazyVim/LazyVim", dir = "${pkgs.unstable.vimPlugins.LazyVim}", import = "lazyvim.plugins" },
  defaults = { lazy = false },
  install = { colorscheme = { "tokyonight", "habamax" } },
}, {})
'';
  };

  programs.bottom = {
    enable = true;
  };

  programs.zellij = {
    enable = true;

    # TODO: Enable this with home-manager from 2023-05-12 or newer.
    # enableZshIntegration = true;
  };

  services.pueue.enable = true;
  # The service fails to start with an empty configuration.
  services.pueue.settings = {
    shared = {};

    client = {};

    server = {};
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "22.11";
}
