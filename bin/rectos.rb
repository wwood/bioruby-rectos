require 'pp'


class MySketch < Processing::App
  @@sizeX = 600;
  @@sizeY = 600;
  @@level_width = 70
  @@rect_height = @@level_width * 0.8
  @@empty_angle = PI/20
    
  def setup
    #// set the background color
    background(255);

    @@middleX = @@sizeX/2;
    @@middleY = @@sizeY/2;
    


    #// canvas size (Variable aren't evaluated. Integers only, please.)
    size(@@sizeX, @@sizeY);

    #// smooth edges
    smooth();

    #// limit the number of frames per second
    frameRate(30);

    #//draw a line to archaea
    background_stroke_weight = 2;
    foreground_stroke_weight = 10;


    strokeWeight(background_stroke_weight);

    
    drawRectos hierarchy1
  end
  
  def hierarchy2
    hierarchy2 = [
      ["bacteria", 5],
      ["archaea", 20,
        ["eury", 20]
      ]
    ]
    
    root = Rectode.new
    archaea = Rectode.new 20
    bacteria = Rectode.new 5
    eury = Rectode.new 20
    
    root.children = [bacteria, archaea]
    archaea.children = [eury]
    
    return root
  end
  
  def hierarchy1
    hierarchy1 = [
      ["bacteria", 5,
        [
          ["epsilons", 5],
          ["clostridium", 10],
        ]
      ],
      ["archaea", 20,
        [
          ["eury", 20,
            [
              ["nano", 1],
              ['obsolete',10]
            ]
          ],
          ["crenarchs", 5]
        ]
      ]
    ]
    
    root = Rectode.new
    archaea = Rectode.new 20, 'archaea'
    bacteria = Rectode.new 5, 'bacteria'
    epsilons = Rectode.new 5, 'epsilons'
    clostridium = Rectode.new 10, 'clostridium'
    eury = Rectode.new 20, 'eury'
    nano = Rectode.new 1, 'nano'
    obsolete = Rectode.new 10, 'obsolete'
    crenarchs = Rectode.new 5, 'crenarchs'
    
    root.children = [bacteria, archaea]
    bacteria.children = [epsilons, clostridium]
    archaea.children = [eury, crenarchs]
    eury.children = [nano, obsolete]
    
    return root
  end

  def drawRectos(root)
    puts '***************************************************'
    pp root
    
    child_angles = getChildrenAngles root.children, 0, 2*PI-@@empty_angle
    p child_angles
    
    # Draw each child. drawTree draws a box first, but the root itself has no box
    root.children.each_with_index do |child, i|
      puts "printing #{child}"
      drawBranch child, child_angles[i][0], child_angles[i][1], 0
    end
  end
  
  # Return an array of arrays. First is an array of children, underneath are 2-element arrays with starts and stops defined
  def getChildrenAngles(children, start_angle, end_angle, options={})
    angles = []
    
    # Work out the positions of each of the children, angle-wise, as well as their beginnings and ends
    total_childrens_weight = children.collect{|child| child.weight}.inject{|sum, i| sum+=i}
    
    # Arc weight multiplier * weight of the child = the length of arc associated with that child 
    total_empty_angle = @@empty_angle*children.length
    arc_weight_multiplier = (end_angle-start_angle-total_empty_angle)/total_childrens_weight
    
    child_start_angle = start_angle+@@empty_angle
    children.each do |child|
      child_arc_length = child.weight*arc_weight_multiplier
      child_end_angle = child_start_angle+child_arc_length
      
      angles.push [
        child_start_angle,
        child_end_angle
      ]
      
      # For next loop
      child_start_angle += @@empty_angle+child_arc_length
    end
    
    return angles
  end
  
  # Draw the entirety of a subtree. Draw a box for the top level, and then an arc.
  # Then draw each of the children recursively.
  def drawBranch(tree, start_angle, end_angle, level)
    puts '=================== drawBranch'
    pp tree
    puts start_angle*180/PI
    puts end_angle*180/PI
    puts level
    # Angle the box comes out at
    middle_angle = (start_angle+end_angle).to_f/2
    
    if tree.terminal?
      # Draw a box with size relative to the weight of this node
      drawRectangle level, middle_angle, tree.weight
    else
      # Internal branch. Draw a box for the node itself, and then an arc for its children to go on
      drawRectangle level, middle_angle, tree.weight
      drawArc level, start_angle, end_angle

      child_angles = getChildrenAngles tree.children, start_angle, end_angle
      
      tree.children.each_with_index do |child, i|
        child_start_angle = child_angles[i][0]
        child_end_angle = child_angles[i][1]
        
        # Recurse through the children's children
        drawBranch child, child_start_angle, child_end_angle, level+1
      end
    end
  end

  def drawRectangle(level, angle, rect_size)
    fill(155,0,0);
    
    pushMatrix();

    #// where to translate depends on the angle - simple trigonometry
    extraX = Math.cos(angle)*level
    extraX = extraX*@@level_width
    extraY = Math.sin(angle)*level
    extraY = extraY*@@level_width

    translate(@@middleX+extraX, @@middleY+extraY);
    rotate(angle);
    rect(0,-rect_size/2*3, @@rect_height, rect_size*3);

    popMatrix();
  end
  
  def drawArc(level, start_angle, end_angle)
    noFill()
    puts "------- drawArc #{level}, #{start_angle*180/PI}, #{end_angle*180/PI}"
    arc(@@middleX, @@middleY, (level+1)*@@level_width*2, (level+1)*@@level_width*2, start_angle, end_angle)
  end

end


class Rectode
  attr_accessor :children, :weight
  
  attr_accessor :label
  
  def initialize(weight=nil, label=nil)
    @weight = weight
    @children = []
    @label = label
  end
  
  def terminal?
    @children.empty?
  end
end


MySketch.new :title => "My Sketch", :width => 800, :height => 600

    #// An arc is represented in the array by a list of one or more entries
    #// Recursive algorithm:
    #// Inputs:
    #//  * level to draw at
    #//  * array of array entries to be drawn here and at lower levels
    #//  * angle to start at
    #//  * angle to end at
    #//
    #// algorithm:
    ##// Work out the begin and end angles for each entry
    #// For each entry:
    #//   draw rectangle for this position => drawRectangle()
    #//   draw arc for this position => drawArc()
    #//   call the next level of recursion for this entry (if they exist)

  #//archaeal out rectangles
  # empty_rectangle_angle=empty_angle
  # start_of_arc_angle = arc_angle_from
  # end_of_arc_angle = arc_angle_to
  # multiplier = (end_of_arc_angle-start_of_arc_angle-1*empty_rectangle_angle)/(40+5)
  #
  # from_angle = start_of_arc_angle
  # to_angle = from_angle+(multiplier*40)
  # middle_angle = (from_angle+to_angle)/2
  # drawRectangle(level, middle_angle, 40)
  # from_angle = to_angle+empty_rectangle_angle
  # to_angle = from_angle+(multiplier*5)
  # middle_angle = (from_angle+to_angle)/2
  # drawRectangle(level, middle_angle, 5)
  #
  #
  #
  #
  # #//bacteria arc
  # arc_angle_from = arc_angle_to+empty_angle
  # arc_angle_to = arc_angle_to+arc_multiplier*5
  # stroke(153)
  # #//bacteria rectangle
  # level=0
  # middle_angle = (arc_angle_from+arc_angle_to)/2
  # fill(0,153,0)
  # stroke(153)
  # drawRectangle(level, middle_angle, 5)
  # level=1
  #
  # noFill()
  # arc(middleX, middleY, level*level_width*2, level*level_width*2, arc_angle_from, arc_angle_to);
  # fill(0,153,0)
  #
  #
  # empty_rectangle_angle=empty_angle
  # start_of_arc_angle = arc_angle_from
  # end_of_arc_angle = arc_angle_to
  # multiplier = (end_of_arc_angle-start_of_arc_angle-1*empty_rectangle_angle)/(10+5)
  #
  # from_angle = start_of_arc_angle
  # to_angle = from_angle+(multiplier*10)
  # middle_angle = (from_angle+to_angle)/2
  # drawRectangle(level, middle_angle, 10)
  # from_angle = to_angle+empty_rectangle_angle
  # to_angle = from_angle+(multiplier*5)
  # middle_angle = (from_angle+to_angle)/2
  # drawRectangle(level, middle_angle, 5)