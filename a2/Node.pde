import java.util.Random;

class Node {
  private int id, mass;
  private float x_pos, y_pos, x_force, y_force, x_a, y_a, x_v, y_v, diameter;
  private ArrayList<Integer> neighbors; //neighbor's id
  public Node(int id, int mass){
    Random rand = new Random();
    
    this.id = id;
    this.mass = mass;
    this.neighbors = new ArrayList<Integer>();
    this.x_v = 0;
    this.y_v = 0;

    this.diameter = (float)Math.sqrt(mass*200);  // should be updated later

    this.x_pos = rand.nextInt(int(width/2))+width/4; //randomly choose a position
    this.y_pos = rand.nextInt(int(height/2))+height/4;
  }
  
  public void draw_node(boolean isHighlight){
    if (!isHighlight) {
      fill(#ababab);
      ellipse(x_pos, y_pos, diameter, diameter);
    }
    else {
      fill(#f4e32f);
      ellipse(x_pos, y_pos, diameter, diameter);
      fill(255);
      text(""+id, x_pos + diameter/2, y_pos + diameter/2);
    }
  }
  
  public void drag_node(){
  }
  
  public int getId(){
    return id;
  }
  
  public int getMass(){
    return mass;
  }
  
  public float get_Xpos(){
    return x_pos;
  }
  
  public float get_Ypos(){
    return y_pos;
  }
  
  public float get_Xforce(){
    return x_force;
  }
  
  public float get_Yforce(){
    return y_force;
  }
  
  public float get_X_a(){
    return x_a;
  }
  
  public float get_Y_a(){
    return y_a;
  }
  
  public float get_X_v(){
    return x_v;
  }
  
  public float get_Y_v(){
    return y_v;
  }
  
  public float get_diameter(){
    return diameter;
  }
  public ArrayList<Integer> get_neighbors(){
    return neighbors;
  }
  
  public void add_neighbor(int id){
    neighbors.add(id);
  }
  public void delete_node(int id){
  }
  
  public void add_singel_node(int id, int mass){
  }
  
  public void set_x_pos(float xor){
    x_pos = xor;
  }
  
  public void set_y_pos(float yor){
    y_pos = yor;
  }
  
  public void set_x_v(float xv){
    x_v = xv;
  }
  
  public void set_y_v(float yv){
    y_v = yv;
  }
}