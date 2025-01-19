{
  self,
  pkgs,
  lib,
  config,
  mkIf,
  ...
}:

let
  cfg = config.services.tgstation-discord-bot;
  package = pkgs.callPackage ./package.nix { };

in
{
  options = {
    services.tgstation-discord-bot = {
      username = lib.mkOption {
        type = lib.types.str;
        default = "tgstation-discord-bot";
        description = ''
          The username for the system user running tgstation-discord-bot.
        '';
      };

      port = lib.mkOption {
        type = lib.types.number;
        default = 22122;
        description = ''
          The port the container will be bound to.
        '';
      };

      discord_api_key = lib.mkOption {
        type = lib.types.str;
        default = "NOTSET";
        description = ''
        The discord API key for the discord bot account
        ''
      }
      bot_store = lib.mkOption{
        type = lib.types.path;
        default = "/persist";
        description = ''
        Location on disk where the bot stores any configuration settings and data
        This will be mounted into the docker container
        ''
      }
      bot_prefix = lib.mkOption {
        type = lib.types.str;
        default = ".";
        description = ''
        The Prefix that bot commands must start with, should be unique for each bot
        ''
    };
  };

  config = {
    users.groups."${cfg.username}" = { };
    users.users."${cfg.username}" = {
      group = "${cfg.username}";
      isSystemUser = true;
      extraGroups = [ "docker" ];
    };

    systemd.services.tgstation-discord-bot = {
      description = "tgstation-discord-bot";
      serviceConfig = {
        User = cfg.username;
        WorkingDirectory = pkgs.fetchFromGitHub {
          owner = "tgstation-operations";
          repo = "tgstation-discord-bot";
          rev = "d78a39e58fccdcca6f39c45672c9cf9cbb7da190";
          sha256 = "sha256:KoGRVu7u8la/uac1EO62IS7Izn+WJaQ31kuey5iky/8=";
        };
        ExecStart = "${pkgs.docker}/bin/docker compose -f ./package/docker-compose.yml up --build";
        WantedBy = [ "multi-user.target" ];
        Environment = [
          "DISCORD_TOKEN=${cfg.discord_api_key}",
          "BOT_PREFIX=${cfg.bot_prefix}",
          "BOT_STORE_PATH"=${cfg.bot_store}
        ];
      };
    };
  };
}
