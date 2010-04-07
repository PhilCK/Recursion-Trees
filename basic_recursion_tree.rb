# This is a basic example of recursion trees or fractle tree
# Simpley this will split the branch at a given angle at the end of each branch

require 'rubygems'
require 'gosu'

module Common
  
  module Screen
    MODE   = false # THIS SETS FULLSCREEN OR NOT
    WIDTH  = 800
    HEIGHT = 600        
  end
  
end

class Numeric 
  def gosu_to_radians
    (self - 90) * Math::PI / 180.0
  end
  
  def radians_to_gosu
    self * 180.0 / Math::PI + 90
  end

end

include Common

class Tree
  
  def initialize(world, colour, bot_margin, x_coords, layer)
    @world = world
    
    @colour = colour
    @bot_margin = bot_margin
    @x = x_coords
    @layer = layer
    
    new_tree
  end
  
  def new_tree
    angle_list = (20..90).to_a
    shrink_list = (2..6).to_a
    split_list = (5..12).to_a
    initial_branch_length = (75..300).to_a
    
    @max_splits = split_list[rand(split_list.length)]         # how many times the branches have split
    @angle      = (Math::PI / 4)      # the angle of the splits
    @shrink     = "0.#{shrink_list[rand(shrink_list.length)]}".to_f
    @degree_shirink = angle_list[rand(angle_list.length)]
    
    @branches = []
    
    @branches << [ [[@x, Screen::HEIGHT - @bot_margin], [@x, Screen::HEIGHT - initial_branch_length[rand(initial_branch_length.length)]]] ] # First Branch
  end
  
  def update
    last_section = @branches.last
    new_section  = []    
    
    if @branches.length < @max_splits
    
      last_section.each do |b|
        old_x1, old_y1 = b[0][0], b[0][1]
        old_x2, old_y2 = b[1][0], b[1][1]
        old_length     = Gosu::distance(old_x1, old_y1, old_x2, old_y2)
            
        new_x, new_y = old_x2, old_y2
        new_length = (old_length * @shrink).to_i
        
        angle = (Gosu::angle(old_x1, old_y1, old_x2, old_y2)).to_i
        
        first_branch_angle  = angle + @degree_shirink
        second_branch_angle = angle - @degree_shirink
        
        first_branch_x = new_x + Gosu::offset_x(first_branch_angle, new_length)
        first_branch_y = new_y + Gosu::offset_y(first_branch_angle, new_length)
      
        second_branch_x = new_x + Gosu::offset_x(second_branch_angle, new_length)
        second_branch_y = new_y + Gosu::offset_y(second_branch_angle, new_length)
        
        new_section << [[new_x, new_y], [first_branch_x.to_i, first_branch_y.to_i]]
        new_section << [[new_x, new_y], [second_branch_x.to_i, second_branch_y.to_i]]        
      end
      
      @branches << new_section
    end
  end
  
  def draw
    @branches.each do |tree_section|
      tree_section.each do |b|
        @world.draw_line(b[0][0], b[0][1], @colour, b[1][0], b[1][1], @colour, @layer)
      end
    end
  end
  
end

class Game < Gosu::Window
  
  def initialize
    super(Screen::WIDTH, Screen::HEIGHT, Screen::MODE)
    @tree = Tree.new(self, 0xFF000000, 10, Screen::WIDTH / 2, 2)
        
    self.caption = "Basic Recursion Tree"
    # Gosu and Moot Logos
    @mootlogo = Gosu::Image.new(self, "media/moot.png", false)    
    @gosulogo = Gosu::Image.new(self, "media/gosu_logo.png", false)
    
    @text = Gosu::Font.new(self, 'media/bitlow.ttf', 10)
    @colors = {:white => Gosu::white, :gray => Gosu::gray}
  end
  
  def update
    @tree.update    
  end
  
  def draw
    @tree.draw
    
    self.draw_quad(0, 0, @colors[:white],
                   Screen::WIDTH, 0, @colors[:white],
                   0, Screen::HEIGHT, @colors[:gray],
                   Screen::WIDTH, Screen::HEIGHT, @colors[:gray],
                   0)
    
    # Drawing the Logos
    @gosulogo.draw(10, Screen::HEIGHT - 43, 1)
    @mootlogo.draw(Screen::WIDTH - 83, Screen::HEIGHT - 43, 1)
    @text.draw("PRESS SPACE TO GENERATE A NEW TREE", 10, 10, 1, 1.5, 1.5, 0xFF000000)
  end
  
  def button_down(id)
     if button_down? Gosu::KbEscape
       close
     end

     if button_down? Gosu::KbSpace
       @tree.new_tree
     end

   end
  
end

Game.new.show