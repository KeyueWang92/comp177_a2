Parser p;
ArrayList<Node> nodes;
ArrayList<Line> lines;
float k1, k2;
float t;
double KE;
int mouse_on;
float damping;
Button refresh;

void setup(){
  surface.setResizable(true);
  size(600,400);
  frameRate(100);
  k1 = 10;
  k2 = 1;
  t = 0.01;
  KE = 0;
  damping = 0.99;
  mouse_on = -1;
  p = new Parser("data2.csv");
  refresh = new Button("refresh");
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

void draw(){
  KE = 0;
  fill(120);
  rect(0,0,width,height);
  refresh.buttondraw();
  boolean hl_check = false; // hightlight check
  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).draw_line();
    int firstId = lines.get(i).get_firstId();
    int secondId = lines.get(i).get_secondId();
    Node firstNode = nodes.get(firstId);
    Node secondNode = nodes.get(secondId);
    lines.get(i).set_pos(firstNode.get_Xpos(), firstNode.get_Ypos(), secondNode.get_Xpos(), secondNode.get_Ypos());
  }
  //for (int i = nodes.size()-1; i >=0 ; i--) {
  for (int i = 0; i < nodes.size(); i++){
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
      // when total Energy is greater than the threshold, update nodes' position
      calc_node(nodes.get(i));
      KE += nodes.get(i).getMass()*0.5*(Math.pow(nodes.get(i).get_X_v(),2) + Math.pow(nodes.get(i).get_Y_v(),2));
    }
  }
  if(!hl_check) mouse_on = -1;
  //println(KE);
  if (KE < 5) noLoop();
}

public void calc_node(Node node){
  
  //calculate the Coulomb's force from each node, f = k/distance
  float cforce_x = 0, cforce_y = 0;
  for (int i = 0; i < nodes.size(); i++) {
    if (nodes.get(i) != null && i != node.getId()) {
      Node n = nodes.get(i);
      cforce_x = (float) (cforce_x - k2/(n.get_Xpos()-node.get_Xpos()));
      cforce_y = (float) (cforce_y - k2/(n.get_Ypos()-node.get_Ypos()));
    }   
  } 
  //calculate the force from springs, f = k * distance; 
  double sforce_x = 0, sforce_y = 0;
  ArrayList<Integer> neighbors = node.get_neighbors();
  for (int i = 0; i < neighbors.size(); i++) {
    Node neighbor = nodes.get(neighbors.get(i));
    double default_springl = p.edge_map[node.getId()][neighbors.get(i)];
    double springl = Math.sqrt(Math.pow(neighbor.get_Xpos() - node.get_Xpos(), 2) + 
                      Math.pow(neighbor.get_Ypos() - node.get_Ypos(), 2)) - default_springl;
    double sforce = springl * k1;
    double distanceX = neighbor.get_Xpos() - node.get_Xpos();
    double distanceY = neighbor.get_Ypos() - node.get_Ypos();
    
    if ((distanceX > 0 && springl > 0) || (distanceX < 0) && (springl < 0)) 
      sforce_x = sforce_x + Math.sqrt(Math.pow(distanceX, 2)/(Math.pow(distanceX, 2) + Math.pow(distanceY,2)) * Math.pow(sforce,2));
    else sforce_x = sforce_x - Math.sqrt(Math.pow(distanceX, 2)/(Math.pow(distanceX, 2) + Math.pow(distanceY,2)) * Math.pow(sforce,2));
    if ((distanceY > 0 && springl > 0) || (distanceY < 0) && (springl < 0)) 
      sforce_y = sforce_y + Math.sqrt(Math.pow(distanceY, 2)/(Math.pow(distanceX, 2) + Math.pow(distanceY,2)) * Math.pow(sforce,2));
    else sforce_y = sforce_y - Math.sqrt(Math.pow(distanceY, 2)/(Math.pow(distanceX, 2) + Math.pow(distanceY,2)) * Math.pow(sforce,2));
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
  
  //update the damping ratio
  if (damping >0 ) damping = damping - 0.0000001;
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
  loop();
  if(mouse_on != -1) {
    nodes.get(mouse_on).set_x_pos(mouseX);
    nodes.get(mouse_on).set_y_pos(mouseY);
    damping = 0.99;
  }
}

void mouseClicked(){
  if (mouseX > refresh.x && mouseX < (refresh.x + refresh.wid) && mouseY > refresh.y && mouseY < (refresh.y + refresh.hgt)) {
    loop();
    Random rand = new Random();
    for (int i = 0; i < nodes.size(); i++) {
      if (nodes.get(i) != null) {
        Node node = nodes.get(i);
        node.set_x_pos(rand.nextInt(int(width/2))+width/4);
        node.set_y_pos(rand.nextInt(int(height/2))+height/4);
      }
    }
  }
}