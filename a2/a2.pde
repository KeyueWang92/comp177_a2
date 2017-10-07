Parser p;
ArrayList<Node> nodes;
ArrayList<Line> lines;
void setup(){
  size(600,600);
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