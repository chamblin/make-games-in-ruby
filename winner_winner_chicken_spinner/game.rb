require 'gosu'

class GameWindow < Gosu::Window
  def initialize
    super(480, 480)
    self.caption = "Winner Winner Chicken Spinner"

    @chicken_plate = Gosu::Image.new("assets/chicken_plate.png")
    @arrow = Gosu::Image.new("assets/arrow.png")
    @win_image = Gosu::Image.new("assets/win.png")
    @lose_image = Gosu::Image.new("assets/lose.png")

    @chicken_angle = 0
    @gameover = false
    @won = false
  end

  def update
    return if @gameover

    if Gosu::button_down?(Gosu::KbSpace)
      @gameover = true
      @won = did_we_win?
      return
    end

    @chicken_angle += 10
    @chicken_angle %= 360
  end

  def draw
    @arrow.draw(320, 200, 1)
    @chicken_plate.draw_rot(240, 240, 0, @chicken_angle)


    if @gameover
      image = @won ? @win_image : @lose_image
      image.draw(0, 120, 2)
    end
  end

  private

  def did_we_win?
    return @chicken_angle > 290 || @chicken_angle < 21
  end
end

window = GameWindow.new
window.show