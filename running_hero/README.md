# Running Hero

There are 5 progressive versions of this game numbered 0 - 4 as the game develops through the talk.

Part 0 is just statically drawing the hero on the screen.

Part 1 is moving the hero around, and allowing the hero to jump.

Part 2 is adding animation and alternate poses to the hero.

Part 3 is collision detection with the stationary enemy.

Part 4 is adding logic to move the enemy around and adding a score to the game, along with refactoring the enemy as an independent entity.

# Running this game

You'll need bundler installed, then you can just `bundle install` and e.g. `bundle exec ruby 0.rb` to run the game.

You need to download the Pixeled font directly into the `assets/` folder before the last part of the game will work.  It is available [here](http://www.dafont.com/pixeled.font).

Credits:

The license on the font used for scorekeeping does not allow me to distribute it in this package.  It is available for free here: http://www.dafont.com/pixeled.font

The hero and enemy images used in Running Hero are the work of GrafxKid on OpenGameArt and are available [here](http://opengameart.org/content/classic-hero-and-baddies-pack).