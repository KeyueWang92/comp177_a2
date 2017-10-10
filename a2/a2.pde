import processing.sound.*;

Parser p;
ArrayList<Node> nodes;
ArrayList<Line> lines;
float k1, k2;
float t;
float KE;
int mouse_on;
float threshold;
float damping;
Button refresh;
Button addline;
boolean first_draw;
boolean increaseMass;
boolean select_node;
int[] add_line_ids;

AudioIn in;
FFT fft;
int bands = 512;
float[] spectrum = new float[bands];
float music_force;
int redBackground = 0;
int greenBackground = 0;
int blueBackground = 0;

void setup(){
  surface.setResizable(true);
  size(600,400);
  frameRate(100);
  k1 = 10;
  k2 = 10;
  t = 0.01;
  threshold = 5;
  damping = 0.98;
  mouse_on = -1;
  KE = 0;
  first_draw = true;
  increaseMass = true;
  add_line_ids = new int[2];
  p = new Parser("data2.csv");
  refresh = new Button("refresh",30,30);
  addline = new Button("AddLine",30,70);
  // init nodes
  nodes = new ArrayList<Node>();
  for (int i = 0; i < p.maxid+1; i++) nodes.add(i,null);
  for (HashMap.Entry<Integer, Integer> entry : p.mass_map.entrySet()) { 
    Node node = new Node(entry.getKey(), entry.getValue());
    nodes.set(entry.getKey(), node);
  }
  // init lines
  lines = new ArrayList<Line>();
  for (int i = 0; i < p.maxid+1; i++) {
    for (int j = 0; j < p.maxid+1; j++) {
       if (p.edge_map[i][j] != 0) {
         Line line = new Line(i, j, p.edge_map[i][j], nodes.get(i).get_Xpos(), 
                         nodes.get(i).get_Xpos(), nodes.get(j).get_Xpos(), nodes.get(j).get_Ypos());
         nodes.get(i).add_neighbor(j);
         lines.add(line);
       }
    }
  }
  
  in = new AudioIn(this, 0);
  fft = new FFT(this, bands);
  in.start();
  fft.input(in);
  music_force = 0;
}

void backgroundChange(int a) {              //Randomly changes background color
  redBackground = int(random(a));
  greenBackground = int(random(a));
  blueBackground = int(random(a));
}

void draw(){
  stroke(255);
  if(music_force > 3500)
    backgroundChange(100);
  fill(redBackground, greenBackground, blueBackground);
  rect(0,0,width,height);
  refresh.buttondraw();
  addline.buttondraw();
  boolean hl_check = false; // hightlight check
  
  fft.analyze(spectrum);
  //float interval = width/bands;
  music_force = 0;
  for(int i = 0; i < bands; i++){
    if(i > 300 && i < 400) music_force += spectrum[i]*500000;
  // The result of the FFT is normalized
  // draw the line for frequency band i scaling it up by 5 to get more amplitude.
    line( i, height, i, height - spectrum[i]*height*50 );
  }
  
  //draw lines
  for (int i = 0; i < lines.size(); i++) {
    if (lines.get(i) != null) {
      lines.get(i).draw_line();
      int firstId = lines.get(i).get_firstId();
      int secondId = lines.get(i).get_secondId();
      Node firstNode = nodes.get(firstId);
      Node secondNode = nodes.get(secondId);
      lines.get(i).set_pos(firstNode.get_Xpos(), firstNode.get_Ypos(), secondNode.get_Xpos(), secondNode.get_Ypos());
    }
  }
  
  //draw nodes, and detect which node is highlighted
  for (int i = nodes.size()-1; i >= 0; i--){
    if(!hl_check) mouse_on = -1;
    if (nodes.get(i) != null) {
      if(!hl_check) {
        hl_check = on_this_node(nodes.get(i));
        if (hl_check == true) 
          mouse_on = i;
        nodes.get(i).draw_node(hl_check);
      }
      else {
        nodes.get(i).draw_node(false);
      }
    }
  }

  //update nodes' info
  if (first_draw == true || KE > threshold) {
    KE = 0;
    for (int i = 0; i < nodes.size(); i++){
      first_draw = false;
      if (nodes.get(i) != null) {
      // when total Energy is greater than the threshold, update nodes' position
          calc_node(nodes.get(i));
          KE += nodes.get(i).getMass()*0.5*(Math.pow(nodes.get(i).get_X_v(),2) + Math.pow(nodes.get(i).get_Y_v(),2));
      }
    } 
  }
  text(Float.toString(KE), 30, 122);
}

public void calc_node(Node node){
  //calculate the Coulomb's force from each node, f = k/distance
  float cforce_x = 0, cforce_y = 0;
  for (int i = 0; i < nodes.size(); i++) {
    if (nodes.get(i) != null && i != node.getId()) {
      Node n = nodes.get(i);
      float dis_square = pow((n.get_Xpos()-node.get_Xpos()),2) + 
                          pow((n.get_Ypos()-node.get_Ypos()),2);
      
      cforce_x = (float) (cforce_x - (n.get_Xpos()-node.get_Xpos()) * k2/dis_square);
      cforce_y = (float) (cforce_y - (n.get_Ypos()-node.get_Ypos()) * k2/dis_square);
    }   
  } 
  //calculate the force from springs, f = k * distance; 
  double sforce_x = 0, sforce_y = 0;
  ArrayList<Integer> neighbors = node.get_neighbors();
  for (int i = 0; i < neighbors.size(); i++) {
    Node neighbor = nodes.get(neighbors.get(i));
    if (neighbor != null) {
      double default_springl;
      if (node.getId() < p.edge_map.length && neighbors.get(i) < p.edge_map[node.getId()].length)
        default_springl = p.edge_map[node.getId()][neighbors.get(i)];
      else default_springl = 100;
      double springl = Math.sqrt(Math.pow(neighbor.get_Xpos() - node.get_Xpos(), 2) + 
                      Math.pow(neighbor.get_Ypos() - node.get_Ypos(), 2)) - default_springl;
      double sforce = springl * k1;
      double distanceX = neighbor.get_Xpos() - node.get_Xpos();
      double distanceY = neighbor.get_Ypos() - node.get_Ypos();
    
      if ((distanceX > 0 && springl > 0) || (distanceX < 0) && (springl < 0)) 
        sforce_x = sforce_x + music_force + Math.sqrt(Math.pow(distanceX, 2)/(Math.pow(distanceX, 2) + Math.pow(distanceY,2)) * Math.pow(sforce,2));
      else sforce_x = sforce_x - music_force - Math.sqrt(Math.pow(distanceX, 2)/(Math.pow(distanceX, 2) + Math.pow(distanceY,2)) * Math.pow(sforce,2));
      if ((distanceY > 0 && springl > 0) || (distanceY < 0) && (springl < 0)) 
        sforce_y = sforce_y + music_force + Math.sqrt(Math.pow(distanceY, 2)/(Math.pow(distanceX, 2) + Math.pow(distanceY,2)) * Math.pow(sforce,2));
      else sforce_y = sforce_y - music_force - Math.sqrt(Math.pow(distanceY, 2)/(Math.pow(distanceX, 2) + Math.pow(distanceY,2)) * Math.pow(sforce,2));
    }  
  }
  float force_x = (float)(cforce_x + sforce_x);
  float force_y = (float)(cforce_y + sforce_y);
  //calculate a
  float a_x = force_x/node.getMass();
  float a_y = force_y/node.getMass();
  //calculate v
  float v_x = (a_x * t + node.get_X_v()) * damping;
  float v_y = (a_y * t + node.get_Y_v()) * damping;
  //calculate position
  float pos_x = node.get_Xpos() + 0.5 * a_x * t*t + node.get_X_v() * t;
  node.set_x_v(v_x);
  float pos_y = node.get_Ypos() + 0.5 * a_y * t*t + node.get_Y_v() * t;
  node.set_y_v(v_y);
  
  //the next part is to ensure that all nodes are always in the canvas 
  Random rand = new Random();
  if (pos_x < node.get_diameter()/2) {
    pos_x = node.get_diameter()+rand.nextInt(10);
    v_x = 1;
    node.set_x_v(v_x);
  }
  if (pos_y < node.get_diameter()/2) {
    pos_y = node.get_diameter()+rand.nextInt(10);
    v_y = 1;
    node.set_y_v(v_y);
  }
  if (pos_x > width-node.get_diameter()/2) {
    pos_x = width-node.get_diameter()-rand.nextInt(10);
    v_x = -1;
    node.set_x_v(v_x);
  }
  if (pos_y > height - node.get_diameter()/2) {
    pos_y = height-node.get_diameter()-rand.nextInt(10);
    v_y = -1;
    node.set_y_v(v_y);
  }
  node.set_x_pos(pos_x);
  node.set_y_pos(pos_y);
}

public boolean on_this_node(Node node) {
    if(mouseX > node.x_pos-node.diameter/2 && mouseX < node.x_pos+node.diameter/2 &&
        mouseY > node.y_pos-node.diameter/2 && mouseY < node.y_pos+node.diameter/2) {
      return true;
        }
    else {
      return false;
    }
}

void mouseDragged() 
{
  if(mouse_on != -1 && mouseButton == RIGHT) {
    Node node = nodes.get(mouse_on);
    node.set_x_pos(mouseX);
    node.set_y_pos(mouseY);
    //node.set_Mass(node.getMass()-1);
    damping = 0.99;
    first_draw = true;
  }

}

void mouseClicked(){
  // refresh
  if (mouseX > refresh.x && mouseX < (refresh.x + refresh.wid) && mouseY > refresh.y && mouseY < (refresh.y + refresh.hgt)) {
    damping = 0.99;
    first_draw = true;
    
    // init nodes
    nodes = new ArrayList<Node>();
    for (int i = 0; i < p.maxid+1; i++) nodes.add(i,null);
    for (HashMap.Entry<Integer, Integer> entry : p.mass_map.entrySet()) { 
      Node node = new Node(entry.getKey(), entry.getValue());
      nodes.set(entry.getKey(), node);
    }
    // init lines
    lines = new ArrayList<Line>();
    for (int i = 0; i < p.maxid+1; i++) {
      for (int j = 0; j < p.maxid+1; j++) {
         if (p.edge_map[i][j] != 0) {
           Line line = new Line(i, j, p.edge_map[i][j], nodes.get(i).get_Xpos(), 
                         nodes.get(i).get_Xpos(), nodes.get(j).get_Xpos(), nodes.get(j).get_Ypos());
           nodes.get(i).add_neighbor(j);
           lines.add(line);
         }
      }
    }
  }
  
  //delete_node feature
  if (mouseButton == RIGHT && mouse_on != -1) {
    delete_node(mouse_on);
  }
  
  //add_node feature
  if (mouseButton == RIGHT && mouse_on == -1 && 
      !(mouseX > refresh.x && mouseX < (refresh.x + refresh.wid) && mouseY > refresh.y && mouseY < (refresh.y + refresh.hgt)) &&
      !(mouseX > addline.x && mouseX < (addline.x + addline.wid) && mouseY > addline.y && mouseY < (addline.y + addline.hgt))) {
    add_node();
  }
  
  //change_mass feature
  if (mouse_on != -1 && mouseButton == LEFT && select_node == false) {
    Node node = nodes.get(mouse_on);
    //detect to increase mass or decrease
    if (node.getMass() == 10) {
      increaseMass = false;
    }
    if (node.getMass() == 1) {
      increaseMass = true;
    }
    //set mass
    if (increaseMass == true) {
      node.set_Mass(node.getMass()+1);
    } else node.set_Mass(node.getMass()-1);
    node.set_diameter((float)Math.sqrt(node.getMass()*200));
  }
  
  //add_line
  if (mouseX > addline.x && mouseX < (addline.x + addline.wid) && mouseY > addline.y && mouseY < (addline.y + addline.hgt)
        && addline.label == "AddLine") {
      select_node = true;
      addline.label = "Adding";
  }

  if (mouse_on != -1 && mouseButton == LEFT && select_node == true) {
    if (add_line_ids[0] == 0) add_line_ids[0] = mouse_on;
    else add_line_ids[1] = mouse_on;
    //println(add_line_ids[0]);
    //println(add_line_ids[1]);
    if (add_line_ids[1] != 0) {
      Line newline = new Line(add_line_ids[0], add_line_ids[1], 100, nodes.get(add_line_ids[0]).get_Xpos(), nodes.get(add_line_ids[0]).get_Ypos(), nodes.get(add_line_ids[1]).get_Xpos(), nodes.get(add_line_ids[1]).get_Ypos());
      lines.add(lines.size(), newline);
      nodes.get(add_line_ids[0]).add_neighbor(add_line_ids[1]);
      nodes.get(add_line_ids[1]).add_neighbor(add_line_ids[0]);
      //p.edge_map.get(add_line_ids[0]).set(add_line_ids[1],100);
      addline.label = "AddLine";
      select_node = false;
      add_line_ids[0] = 0;
      add_line_ids[1] = 0;
    }                                 
  }
  first_draw = true;
}

void delete_node(int id) {
  nodes.set(id, null);
  for (int i = 0; i < lines.size(); i++) {
    Line line = lines.get(i);
    if (line != null) {
      int firstId = line.get_firstId();
      int secondId = line.get_secondId();
      if (firstId == id || secondId == id) {
        lines.set(i, null);
      }
    }
  }
}

void add_node() {
  int id = nodes.size();
  Node node = new Node(id, 1);
  node.set_x_pos(mouseX);
  node.set_y_pos(mouseY);
  nodes.add(id, node);
}