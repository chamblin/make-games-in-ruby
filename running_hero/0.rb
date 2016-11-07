require 'gosu'

class RunningHeroWindow < Gosu::Window
  def initialize
    super(960, 480)
    self.caption = "Running Hero Game"

    @hero = Gosu::Image.new("assets/hero.png")
    @background = Gosu::Image.new("assets/background.png")
  end

  def draw
    @background.draw(0, 0, 0)
    @hero.draw(50, 348, 1)
  end
end

RunningHeroWindow.new.show