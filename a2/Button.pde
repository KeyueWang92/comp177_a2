class Button {
  public String label;
  public Float x = 30.0;
  public Float y = 30.0;
  public Float wid = 50.0;
  public Float hgt = 30.0;
  public Button(String text) {
    this.label = text;
  }
  public void buttondraw(){
    fill(200,100,50);
    rect(x,y,wid,hgt);
    fill(255);
    text(label,35,50);
  }   
}