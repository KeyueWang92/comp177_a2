Parser p;
ArrayList<Node> nodes;
ArrayList<Line> lines;
float k1, k2;
float t;
double KE;
int mouse_on;

void setup(){
  size(1000,700);
  frameRate(100);
  k1 = 10;
  k2 = 10;
  t = 0.01;
  KE = 0;
  mouse_on = -1;
  p = new Parser("data2.csv");

  // init nodes
  nodes = new ArrayList<Node>();
  for (int i = 0; i < p.maxid+1; i++) nodes.add(i,null);
  for (HashMap.Entry<Integer, Integer> entry : p.mass_map.entrySet()) { 
    Node node = new Node(entry.getKey(), entry.getValue());
    nodes.set(entry.getKey(), node);
  }
  // init lines
  lines = new ArrayList<Line>();
  for (HashMap.Entry<int[], Integer> entry : p.edge_map.entrySet()) {
    int[] ids = entry.getKey();
    Line line = new Line(ids[0], ids[1], entry.getValue(), 
                  nodes.get(ids[0]).get_Xpos(), nodes.get(ids[0]).get_Ypos(),
                  nodes.get(ids[1]).get_Xpos(), nodes.get(ids[1]).get_Ypos());
    lines.add(line);
  }
}

void draw(){
  KE = 0;
  fill(120);
  rect(0,0,width,height);
  boolean hl_check = false; // hightlight check
  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).draw_line();
    int firstId = lines.get(i).get_firstId();
    int secondId = lines.get(i).get_secondId();
    Node firstNode = nodes.get(firstId);
    Node secondNode = nodes.get(secondId);
    lines.get(i).set_pos(firstNode.get_Xpos(), firstNode.get_Ypos(), secondNode.get_Xpos(), secondNode.get_Ypos());
  }
  for (int i = 0; i < nodes.size(); i++) {
    if (nodes.get(i) != null) {
      if(!hl_check) {
        hl_check = on_this_node(nodes.get(i));
        mouse_on = i;
        nodes.get(i).draw_node(hl_check);
      }
      else {
        nodes.get(i).draw_node(false);
      }
      calc_node(nodes.get(i));
      KE += nodes.get(i).getMass()*0.5*(Math.pow(nodes.get(i).get_X_v(),2) + Math.pow(nodes.get(i).get_Y_v(),2));
    }
  }
  if(!hl_check) mouse_on = -1;
}

public void calc_node(Node node){
  //calculate the Coulomb's force from each node, f = k/distance
  float cforce_x = 0, cforce_y = 0;
  for (int i = 0; i < nodes.size(); i++) {
    if (nodes.get(i) != null && i != node.getId()) {
      Node n = nodes.get(i);
      cforce_x = cforce_x - k2/(n.get_Xpos()-node.get_Xpos());
      cforce_y = cforce_y - k2/(n.get_Ypos()-node.get_Ypos());
    }   
  } 
  //calculate the force from springs, f = k * distance; 
  double sforce_x = 0, sforce_y = 0;
  ArrayList<Node> neighbors = node.get_neighbors();
  for (int i = 0; i < neighbors.size(); i++) {
    Node neighbor = neighbors.get(i);
    int[] ids = new int[2];
    ids[0] = node.getId();
    ids[1] = neighbor.getId();
    double default_springl = p.edge_map.get(ids);
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
  println(a_x);
  println(a_y);
  //calculate v
  float v_x = a_x * t + node.get_X_v();
  float v_y = a_y * t + node.get_Y_v();
  //calculate position
  float pos_x = node.get_Xpos() + 0.5 * a_x * t*t + node.get_X_v() * t;
  node.set_x_v(v_x);
  float pos_y = node.get_Ypos() + 0.5 * a_y * t*t + node.get_Y_v() * t;
  node.set_y_v(v_y);
  
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
  if(mouse_on != -1) {
    nodes.get(mouse_on).set_x_pos(mouseX);
    nodes.get(mouse_on).set_y_pos(mouseY);
  }
}