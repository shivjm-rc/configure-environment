{ inputs, outputs, lib, config, pkgs, ... }: {
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      inputs.rust-overlay.overlays.default

      (final: prev: {
        zellij = pkgs.unstable.zellij;
        sensible = pkgs.unstable.vimPlugins.sensible;
      })
    ];
    config = {
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

  home.packages =
    let
      latestRustNightly = pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default.override {
        extensions = [ "rust-src" "rust-analyzer" ];
      });
    in
    with pkgs; [
      age
      git-agecrypt

      ffmpeg
      curl
      zsh-fzf-tab
      hadolint
      kubernetes-helm
      openssl
      openssl.dev
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
      # cargo-edit
      # cargo-make
      # cargo-outdated
      # cargo-sweep
      # cargo-update
      # cargo-audit
      # cargo-watch
      fd
      fselect
      loc
      amber
      xh
      du-dust
      # dysk # this causes collisions in completions
      lsd
      gping
      tidy-viewer
      sd
      xsv
      pkgs.unstable.just
      # cargo-feature
      # cargo-nextest
      taplo
      procs
      choose
      miniserve
      pkgs.unstable.dysk
      htmlq
      wasm-pack
      # cargo-unused-features
      # cargo-run-bin
      unstable.nodePackages_latest.pnpm
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
      terraform
      perl
      git-filter-repo
      gomplate
      difftastic
      pkgs.unstable.erdtree
      dogdns
      sad
      pkgs.unstable.deno
      jdk17
      tree-sitter
      android-tools
      sqlite
      pkgs.unstable.k9s
      popeye
      magic-wormhole

      pkgs.unstable.pulldown-cmark

      pkgs.unstable.trippy
      miller

      captive-browser

      trivy
      grype
      syft
      cosign

      clang
      nodejs

      nixpkgs-fmt

      qpdf

      vivid

      pkgs.unstable.hledger

      zenith # alternative to `top` and `bottom`

      pkg-config
      openssl.dev

      poppler_utils
      powershell

      pkgs.unstable.eza

      docker-compose
      buildah

      ipmitool
      nmap

      # latestRustNightly
      rustup
      rust-script

      imagemagick_light

      # This is not yet available.
      # posting

      rsync

      ansible

      pkgs.unstable.srgn
    ];

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
    autosuggestion = {
      enable = true;
    };
    enableCompletion = true;
    shellAliases = {
      sl = "eza";
      ls = "eza";
      l = "eza -l";
      la = "eza -la";
      pdf-decrypt = "qpdf --decrypt --password=$1 $2 $3";

      remount-x11 = "sudo mount -o remount,rw /tmp/.X11-unix";

      pp = "p -";

      d = "docker";
      g = "git";
      n = "npm";
      k = "kubectl";
      tf = "terraform";
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
        {
          name = "wez/wezterm";
          tags = [
            "from:github"
            ''use:"assets/shell-integration/wezterm.sh"''
            "at:1d3427dc7748eaa0f07c8b3ec3202230233ad1a1"
          ];
        }
      ];
    };

    initExtra = ''
      bindkey -v

      export LS_COLORS="$(vivid generate dracula)"

      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
      zstyle ':completion:*:descriptions' format '[%d]'
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
      setopt extendedglob

      source ~/.config/zsh/update-window-title.zsh
    '';

    envExtra = ''
      [[ -f ~/.cargo/env ]] && source ~/.cargo/env
    '';
  };

  home.file.".config/zsh/update-window-title.zsh".text = (builtins.readFile ./zsh-window-title.sh);
  home.file.".config/powershell/Microsoft.PowerShell_profile.ps1".text = ''
    '. "~/src/my/powershell/profile.ps1"' | Invoke-Expression
  '';

  programs.nushell.enable = true;
  programs.nushell.package = pkgs.unstable.nushell;

  programs.bat.enable = true;

  programs.gpg.enable = true;

  programs.pandoc.enable = true;

  programs.gh.enable = true;

  programs.mercurial.enable = true;
  programs.mercurial.userName = "shivjm";
  programs.mercurial.userEmail = "shivjm@example.com";

  programs.yt-dlp.enable = true;
  programs.yt-dlp.package = pkgs.unstable.yt-dlp;

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [ "--cmd" "p" ];
  };

  programs.lazygit = { enable = true; };

  programs.neovim = {
    enable = true;
    # defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    # Use newer Neovim from nixpkgs-unstable. (The stable version is
    # v0.8.1.)
    package = pkgs.unstable.neovim-unwrapped;

    plugins = [
      pkgs.vimPlugins.surround-nvim
      pkgs.vimPlugins.gitgutter
      pkgs.vimPlugins.ctrlp-vim
      pkgs.vimPlugins.ale
      pkgs.vimPlugins.vim-airline
      pkgs.vimPlugins.neovim-sensible

      pkgs.unstable.vimPlugins.nvim-treesitter.withAllGrammars
    ];

    extraLuaConfig = "";
  };

  programs.bottom = {
    enable = true;
    settings = {
      flags = {
        temperature_type = "c";
        current_usage = true;
        tree = true;
        network_use_binary_prefix = true;
      };
    };
  };

  programs.zellij = {
    enable = true;

    # TODO: Enable this with home-manager from 2023-05-12 or newer.
    # enableZshIntegration = true;
  };

  programs.texlive.enable = true;

  services.pueue.enable = true;
  # The service fails to start with an empty configuration.
  services.pueue.settings = {
    shared = { };

    client = { };

    server = { };
  };

  programs.ripgrep = {
    enable = true;
    arguments = lib.strings.splitString "\n" (lib.trim (builtins.readFile ./ripgreprc));
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "22.11";
}
