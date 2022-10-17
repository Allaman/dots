{
  packageOverrides = pkgs: with pkgs; {
    myPackages = pkgs.buildEnv {
      name = "my-packages";
      paths = [
        act
        argo
        argocd
        awscli2
        cmake
        codespell
        direnv
        dog
        dos2unix
        dua
        duf
        entr
        exa
        fd
        ffmpeg
        figlet
        fluxcd
        fluxctl
        gh
        git
        delta
        git-filter-repo
        gitui
        glow
        go
        goreleaser
        grip
        gron
        hadolint
        helm
        hledger
        htop
        httpie
        hugo
        imagemagick
        #ipython
        isync
        #jenv
        jq
        #node
        nodejs
        #pandoc
        #jupyterlab
        k6
        k9s
        khal
        khard
        kind
        kube-linter
        kubeconform
        kubectx
        kubeseal
        kubeval
        kustomize
        kyverno
        #latexindent
        lazydocker
        lazygit
        lf
        luarocks
        nodePackages.markdownlint-cli
        #markdownlint-cli
        mdbook
        msmtp
        mtr
        mariadb-client
        neofetch
        notmuch
        neomutt
        neovim
        neovim-remote
        newsboat
        nmap
        nnn
        notmuch-mutt
        pdfgrep
        pulumi-bin
        #python
        pwgen
        ranger
        restic
        ripgrep
        s4cmd
        #showkey
        slides
        stern
        tectonic
        thefuck
        tig
        tmux
        tokei
        trash-cli
        urlview
        vdirsyncer
        viddy
        vifm
        w3m
        watch
        wget
        xclip
        youtube-dl
        yq-go
        zoxide
      ];
    };
  };
}
