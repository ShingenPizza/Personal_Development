
### Personal Development

This is a Factorio mod that slowly increases your skills the more you use them.

The idea was born in response to the couple of RPG-style mods, with which you
earned experience points for various things, which increased your levels, which
in turn gave you points to spend on things like increased movement speed or
reach.
I find that concept ridiculous, so I decided to make a mod of my own with a
system that better reflects how it IMO should work.

With this mod your character will slowly increase:
* its reach by placing and deconstructing entities (buildings) and tiles,
picking up items from the ground, and mining resources
* its mining speed by mining resources and deconstructing entities,
* its crafting speed by crafting items,
* its running speed by running around,
* and its health by receiving damage.

Each bonus increase value per unit* is configurable per-world.
In case any of the bonuses starts being annoying, like walking too fast, you
can limit them in per-player mod settings.
An admin of a multiplayer server can further limit them for everyone too, to for example
prevent griefing over long distances, or just as a matter of not making the mod
too OP.\
\*per action/time spent moving/each hp lost

You can view your bonuses using a /PD_stats command, and an admin can reset
them using /PD_reset.
Each of the above commands will be /Personal_Development_* instead if the mod
finds an already declared /PD_* command.

##### WARNING:
Simply disabling this mod in Factorio's main menu will not remove your gained
bonuses.
If you want to get rid of them, you will have to:

1. check the "Disable Personal Development" in PD mod settings ("Map" tab),
2. use the /PD_reset command,
3. save the game, exit to main menu,
4. disable the mod in Factorio's mod manager, or delete it.

(this may still not work for people currently in the editor/god mode etc.)

or

1. disable the mod in Factorio's mod manager, or delete it,
2. back in the save file play around with console commands resetting everyone's bonuses, or let/make all characters die.

##### KNOWN ISSUES:

1. Creating a character with `/c game.player.create_character()` while in the god mode will not apply any bonuses to the new character.
As a workaround you need to perform an action that will update each bonus first (or die and respawn).
I couldn't find the event (if there's any) that fires when that happens - if anyone knows it, please let me know.

##### FOOTNOTE:
This is the first time I'm playing around with scripts running during gameplay,
and while I tried to find various combinations of cases that could break,
I'm quite sure this is not perfect, so sorry in advance for all the possible
crashes, especially in weird combinations like trying to change mod settings
after some player who died while driving a car left the game before respawning.
