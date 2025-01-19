{
  description = "tgstation-discord-bot";

  inputs = { };

  outputs =
    { self, ... }:
    {
      nixosModules = {
        default =
          { ... }:
          {
            imports = [ ./tgstation-discord-bot.nix ];
          };
      };
    };
}
