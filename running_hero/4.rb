require 'gosu'

# $DEBUG shows us bounding boxes
$DEBUG = false

# Now let's make enemies with a simple AI, and a score.

class Enemy
  attr_accessor :image, :x, :y, :direction, :alive
  SPEED = 7
  def initialize(window, images, x, y, direction)
    @window = window
    @images = images
    @x = x
    @y = y
    @direction = direction
    @alive = true
  end

  def update
    return unless @alive
    image = current_image
    if(@direction == :left)
      @x -= 5
    else
      @x += 5
    end

    if @x + image.width < 0
      @direction = :right
    elsif @x > @window.width
      @direction = :left
    end
  end

  def draw
    if @alive
      image = current_image
    else
      image = @images.last
    end
    image.draw(@direction == :left ? @x : @x + image.width, @y, 1, @direction == :left ? 1 : -1)
  end

  def body
    image = current_image
    {:x => @x + 6,
     :y => @y + 20,
     :width => image.width - 12,
     :height => image.height - 20}
  end

  def current_image
    @images[(Gosu::milliseconds / 100 % 4)]
  end
end

class RunningHeroWindow < Gosu::Window
  def initialize
    super(960, 480)
    self.caption = "Running Hero Game"

    @background = Gosu::Image.new("assets/background.png")
    @hero_position = [50, 331]
    @enemy_position = [200, 331]
    @hero_direction = :right

    @hero = Gosu::Image::load_tiles("assets/hero_sheet.png", 64, 64)
    @current_hero_image = @hero.first

    @enemy_images = Gosu::Image::load_tiles("assets/enemy_sheet.png", 64, 64)
    @enemies = [Enemy.new(self, @enemy_images, 200, 331, :left)]
    @score = 0
    @font = Gosu::Font.new(64, :name => "assets/Pixeled.ttf")
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

    @enemies.each{|enemy| enemy.update}
    # figure out what our hero should look like right now
    # the hero's sprite sheet looks like this:
    # [standing still, walking1, walking2, walking3, jumping up, falling down]
    if @hurt_until
      @current_hero_image = @hero[6]
      @hurt_until = nil if Gosu::milliseconds > @hurt_until
    elsif @jumping
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
    handle_collisions
  end

  def draw
    @background.draw(0, 0, 0)
    @enemies.each{|enemy| enemy.draw}
    if @hero_direction == :right
      @current_hero_image.draw(@hero_position[0], @hero_position[1], 1)
    else
      # https://www.libgosu.org/cgi-bin/mwf/topic_show.pl?tid=1073
      @current_hero_image.draw(@hero_position[0] + @current_hero_image.width, @hero_position[1], 1, -1)
    end
    draw_collision_bodies
    @font.draw("Score: #{@score}", 5, 0, 10)
  end

  private

  def move(way)
    return if @hurt_until
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
    return if @jumping || @hurt_until
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

  def handle_collisions
    # did the enemy and player collide?
    @player_rectangle =  {:x => @hero_position[0] + 18,
                          :y => @hero_position[1] + 18,
                          :width => @current_hero_image.width - 36,
                          :height => @current_hero_image.height - 18}
    @enemies.each do |enemy|
      return if @hurt_until
      next unless enemy.alive
      collision = check_for_collisions(@player_rectangle, enemy.body)
      if collision == :left
        @hero_position[0] += 30
        @hurt_until = Gosu::milliseconds + 200
      elsif collision == :right
        @hero_position[0] -= 30
        @hurt_until = Gosu::milliseconds + 200
      elsif collision == :bottom
        @jumping = true
        @vertical_velocity = 10
        enemy.alive = false
        @score += 1
      end
    end
  end

  def draw_collision_bodies
    draw_bounding_body(@player_rectangle)
    @enemies.each do |enemy|
      draw_bounding_body(enemy.body)
    end
  end

  def draw_bounding_body(rect, z = 10, color = Gosu::Color::GREEN)
    return unless $DEBUG
    Gosu::draw_line(rect[:x], rect[:y], color, rect[:x], rect[:y] + rect[:height], color, z)
    Gosu::draw_line(rect[:x], rect[:y] + rect[:height], color, rect[:x] + rect[:width], rect[:y] + rect[:height], color, z)
    Gosu::draw_line(rect[:x] + rect[:width], rect[:y] + rect[:height], color, rect[:x] + rect[:width], rect[:y], color, z)
    Gosu::draw_line(rect[:x] + rect[:width], rect[:y], color, rect[:x], rect[:y], color, z)
  end

  def check_for_collisions(rect1, rect2)
    # returns :top, :bottom, :left :right for the most intersected part, relative to
    # rect1 (so you can tell if you're jumping on a bad guy or running into him)
    # nil if no collisions
    intersection = rec_intersection([[rect1[:x], rect1[:y]],
                                     [rect1[:x] + rect1[:width], rect1[:y] + rect1[:height]]],
                                    [[rect2[:x], rect2[:y]],
                                     [rect2[:x] + rect2[:width], rect2[:y] + rect2[:height]]])
    if intersection
      top_left, bottom_right = intersection
      # if wider than tall, which works since our enemies are tallish
      if (bottom_right[0] - top_left[0]) > (bottom_right[1] - top_left[1])
        # top or bottom?
        if rect1[:y] == top_left[1]
          :top
        else
          :bottom
        end
      else
        # left or right?
        if rect1[:x] == top_left[0]
          :left
        else
          :right
        end
      end
    else
      nil
    end
  end

  def rec_intersection(rect1, rect2)
    # http://stackoverflow.com/questions/19442068/how-does-this-code-find-the-rectangle-intersection
    x_min = [rect1[0][0], rect2[0][0]].max
    x_max = [rect1[1][0], rect2[1][0]].min
    y_min = [rect1[0][1], rect2[0][1]].max
    y_max = [rect1[1][1], rect2[1][1]].min
    return nil if ((x_max < x_min) || (y_max < y_min))
    return [[x_min, y_min], [x_max, y_max]]
  end
end

module Hero
  SPEED = 5
end

RunningHeroWindow.new.show