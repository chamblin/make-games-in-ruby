require 'gosu'


# First, we have a little guy and we want to be able to
# move him around on the ground and maybe to jump.

class RunningHeroWindow < Gosu::Window
  def initialize
    super(960, 480)
    self.caption = "Running Hero Game"

    @hero = Gosu::Image.new("assets/hero.png")
    @background = Gosu::Image.new("assets/background.png")
    @hero_position = [50, 348]
  end

  def update
    if Gosu::button_down?(Gosu::KbRight)
      move(:right)
    elsif Gosu::button_down?(Gosu::KbLeft)
      move(:left)
    end

    jump if Gosu::button_down?(Gosu::KbSpace)

    handle_jump if @jumping
  end

  def draw
    @background.draw(0, 0, 0)
    @hero.draw(@hero_position[0], @hero_position[1], 1)
  end

  private

  def move(way)
    if way == :right
      @hero_position = [@hero_position[0] + Hero::SPEED, @hero_position[1]]
    else
      @hero_position = [@hero_position[0] - Hero::SPEED, @hero_position[1]]
    end
  end

  def jump
    return if @jumping
    @jumping = true
    @vertical_velocity = 30
  end

  def handle_jump
    gravity = 1.75
    ground_level = 348 # y offset where our hero is on the ground
    @hero_position = [@hero_position[0], @hero_position[1] - @vertical_velocity]

    if @vertical_velocity.round == 0 # top of the jump
      @vertical_velocity = -1
    elsif @vertical_velocity < 0 # falling down -- gravity is increasing our speed
      @vertical_velocity = @vertical_velocity * gravity
    else # going up -- gravity is reducing our speed
      @vertical_velocity = @vertical_velocity / gravity
    end

    if @hero_position[1] >= ground_level
      @hero_position[1] = ground_level
      @jumping = false
    end
  end
end

module Hero
  SPEED = 5
end

RunningHeroWindow.new.show