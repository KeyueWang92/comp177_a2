Parser p;
ArrayList<Node> nodes;
ArrayList<Line> lines;
float k1, k2;

void setup(){
  size(600,600);
  k1 = 1;
  k2 = 1;
  p = new Parser("data2.csv");
  // init nodes
  nodes = new ArrayList<Node>();
  for (int i = 0; i < p.maxid+1; i++) nodes.add(i,null);
  for (HashMap.Entry<Integer, Integer> entry : p.mass_map.entrySet()) { 
    //System.out.println("Key = " + entry.getKey() + ", Value = " + entry.getValue()); 
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
  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).draw_line();
  }
  for (int i = 0; i < nodes.size(); i++) {
    if (nodes.get(i) != null) nodes.get(i).draw_node();
  }
}

public void calc_node(Node node){
  //calculate the Coulomb's force from each node, f = k/distance
  float cforce_x = 0, cforce_y = 0;
  for (int i = 0; i < nodes.size(); i++) {
    if (nodes.get(i) != null && i != node.getId()) {
      Node neighbor = nodes.get(i);
      cforce_x = cforce_x + k2/(neighbor.get_Xpos()-node.get_Xpos());
      cforce_y = cforce_y + k2/(neighbor.get_Ypos()-node.get_Ypos());
    }   
  } 
  //calculate the force from springs, f = k * distance; 
  float sforce_x = 0, sforce_y = 0;
  ArrayList<Node> neighbors = node.get_neighbors();
  for (int i = 0; i < neighbors.size(); i++) {
    Node neighbor = neighbors.get(i);
    int[] ids = new int[2];
    ids[0] = node.getId();
    ids[1] = neighbor.getId();
    double default_springl = p.edge_map.get(ids);
    double springl = Math.sqrt(Math.pow(neighbor.get_Xpos() - node.get_Xpos(), 2) + 
                      Math.pow(neighbor.get_Ypos() - node.get_Ypos(), 2));
    if (default_springl < springl) {
      sforce_x = sforce_x + k1 * (neighbor.get_Xpos() - node.get_Xpos());
      sforce_y = sforce_y + k1 * (neighbor.get_Ypos() - node.get_Ypos());
    }
    else {
      sforce_x = sforce_x - k1 * (neighbor.get_Xpos() - node.get_Xpos());
      sforce_y = sforce_y - k1 * (neighbor.get_Ypos() - node.get_Ypos());
    }
  }
  float force_x = cforce_x + sforce_x;
  float force_y = cforce_y = sforce_y;
  //calculate a
  
  //calculate v
  
  //calculate position
}