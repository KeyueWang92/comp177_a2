class Parser{
  public HashMap<Integer, Integer> mass_map; //id - mass
  public HashMap<int[], Integer> edge_map; //[id, id] - string
  public int maxid;
  public Parser(String filename){
    maxid = 0;
    mass_map = new HashMap<Integer, Integer>();
    edge_map = new HashMap<int[], Integer>();
    String[] lines;
    int count1, count2;
    lines = loadStrings(filename);
    count1 = int(lines[0]);
    int iterate = 1;
    for (int i = 0; i < count1; i++) {
      String[] data = split(lines[iterate], ",");
      if (maxid < int(data[0])) maxid = int(data[0]);
      if (maxid < int(data[1])) maxid = int(data[1]);
      mass_map.put(int(data[0]), int(data[1]));
      iterate++;
    }
    count2 = int(lines[iterate]);
    iterate++;
    for (int i = 0; i < count2; i++) {
      String[] data = split(lines[iterate], ",");
      int[] node_pair = new int[2];
      node_pair[0] = int(data[0]);
      node_pair[1] = int(data[1]);
      edge_map.put(node_pair, int(data[2]));
      iterate++;
    }
  }
}