require 'gosu'


# Now, he moves around but just like a cut out doll.
# With some animation, we can make him look more legit

class RunningHeroWindow < Gosu::Window
  def initialize
    super(960, 480)
    self.caption = "Running Hero Game"

    @background = Gosu::Image.new("assets/background.png")
    @hero_position = [50, 331]

    @hero_direction = :right

    # Gosu::Image::load_tiles will cut all the images out of a big image for us of a certain size
    # and stuff them into an Array
    # in our case @hero[0] will be the hero standing still, and @hero[1..-1] will be the hero walking
    # animation.
    @hero = Gosu::Image::load_tiles("assets/hero_sheet.png", 64, 64)
    @current_hero_image = @hero.first
  end

  def update
    if Gosu::button_down?(Gosu::KbRight)
      move(:right)
    elsif Gosu::button_down?(Gosu::KbLeft)
      move(:left)
    else
      @walking = false
    end

    jump if Gosu::button_down?(Gosu::KbSpace)

    handle_jump if @jumping

    # figure out what our hero should look like right now
    # the hero's sprite sheet looks like this:
    # [standing still, walking1, walking2, walking3, jumping up, falling down]
    if @jumping
      # use the velocity to figure out if we're rising or falling
      @current_hero_image = @vertical_velocity > 0 ? @hero[4] : @hero[5]
    elsif @walking
      # Gosu::milliseconds returns the number of millis since the game started.  We want to see
      # a new animation frame about every 100 milliseconds or so, and we have three animation frames
      step = (Gosu::milliseconds / 100 % 3) + 1
      @current_hero_image  = @hero[step]
    else
      # just standing still
      @current_hero_image = @hero[0]
    end
  end

  def draw
    @background.draw(0, 0, 0)
    if @hero_direction == :right
      @current_hero_image.draw(@hero_position[0], @hero_position[1], 1)
    else
      # https://www.libgosu.org/cgi-bin/mwf/topic_show.pl?tid=1073
      @current_hero_image.draw(@hero_position[0] + @current_hero_image.width, @hero_position[1], 1, -1)
    end
  end

  private

  def move(way)
    @walking = true
    if way == :right
      @hero_position = [@hero_position[0] + Hero::SPEED, @hero_position[1]]
      @hero_direction = :right
    else
      @hero_position = [@hero_position[0] - Hero::SPEED, @hero_position[1]]
      @hero_direction = :left
    end
  end

  def jump
    return if @jumping
    @jumping = true
    @vertical_velocity = 30
  end

  def handle_jump
    gravity = 1.5
    ground_level = 331 # y offset where our hero is on the ground
    @hero_position = [@hero_position[0], @hero_position[1] - @vertical_velocity]

    if @vertical_velocity.round == 0 # top of the jump
      @vertical_velocity = -1
    elsif @vertical_velocity < 0 # falling down
      @vertical_velocity = @vertical_velocity * gravity
    else
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