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

include Common

class Tree
  
  def initialize(world, colour, bot_margin, x_coords, layer)
    @world = world
    
    @colour = colour
    @bot_margin = bot_margin
    @x = x_coords
    @layer = layer
    
    # Initialize a new tree
    new_tree
  end
  
  def new_tree
    # Some Ranome Values
    angle_list = (40..45).to_a
    shrink_list = (55..60).to_a
    split_list = (5..7).to_a
    initial_branch_length = (175..250).to_a
    
    @max_splits = split_list[rand(split_list.length)]
    @shrink     = "0.#{shrink_list[rand(shrink_list.length)]}".to_f
    @degree_shrink = angle_list[rand(angle_list.length)]
    
    # Multi Dimentional Array = Tree -> Branch Section -> Branch
    @branches = []
    @branches << [ [[@x, Screen::HEIGHT - @bot_margin], [@x, Screen::HEIGHT - initial_branch_length[rand(initial_branch_length.length)]]] ] # First Branch    
  end
  
  def update
    last_section = @branches.last
        
    if @branches.length < @max_splits
      new_section  = []
      
      last_section.each do |b|
        old_x1, old_y1 = b[0][0], b[0][1]
        old_x2, old_y2 = b[1][0], b[1][1]
        old_length     = Gosu::distance(old_x1, old_y1, old_x2, old_y2)
        
        angle = (Gosu::angle(old_x1, old_y1, old_x2, old_y2)).to_i

        split_angle = (@degree_shrink / 3) * 2
        far_angle = angle - @degree_shrink
        
        new_x, new_y = old_x2, old_y2
                
        skip = [true, true, true, true, true, true, false] # 1/4 chance of no branch (could be better to reduce the chance the further you get up the tree)
        
        4.times do |t|
          if skip[rand(skip.length)]
            new_length = (old_length * @shrink).to_i
                        
            branch_angle = far_angle + (split_angle * t)
          
            branch_x = new_x + Gosu::offset_x(branch_angle, new_length)
            branch_y = new_y + Gosu::offset_y(branch_angle, new_length)
      
            new_section << [[new_x, new_y], [branch_x.to_i, branch_y.to_i]]
          end
        end
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
    
    self.caption = "Random Branch Recursion Tree"
    # Gosu Logo
    @gosulogo = Gosu::Image.new(self, "media/gosu_logo.png", false)
    # text and bg colours
    @text = Gosu::Font.new(self, 'media/bitlow.ttf', 10)
    @colors = {:white => 0xFFFFFFFF, :gray => 0xFF333333}
  end
  
  def update
    @tree.update    
  end
  
  def draw
    @tree.draw
    
    # Background gradient
    self.draw_quad(0, 0, @colors[:white],
                   Screen::WIDTH, 0, @colors[:white],
                   0, Screen::HEIGHT, @colors[:gray],
                   Screen::WIDTH, Screen::HEIGHT, @colors[:gray],
                   0)
    
    # Drawing the Logos
    @gosulogo.draw(10, Screen::HEIGHT - 43, 1)
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