{pkgs, ...}: {
  imports = [];

  programs.pay-respects.enable = true;

  home.packages = with pkgs; [
    zsh-autocomplete
    zsh-autosuggestions
    zsh-completions
    zsh-fast-syntax-highlighting
    zsh-z
    zsh-history-search-multi-word
    zsh-history-substring-search
    zsh-powerlevel10k

    pay-respects
  ];

  programs.zsh = {
    # promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = ./.; # Assumes p10k.zsh is in the same folder as home.nix
        file = "p10k.zsh";
      }
    ];

    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch";
    };

    initContent = ''
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
    '';

    history.size = 10000;

    oh-my-zsh = {
      enable = true;
      plugins = ["git" "z" "history-search-multi-word" "history-substring-search"];
    };
  };
}
