import processing.opengl.PGraphics2D;

class Screen {
  int id;
  int w, h, x, y;  //Screen dimensions and position in virtual space
  XML screenXML;
  ArrayList<Scene> scenes = new ArrayList<Scene>();
  public PGraphics2D pg; // Offscreen buffer for this screen
  boolean isAssigned;

  Screen(int id) {
    this.id = id;
    unassign();
    screenXML = new XML("Screen");
    screenXML.setInt("id", id);
  }
  
  Screen(XML screen){
    this.id = screen.getInt("id");
    unassign();
    screenXML = screen;
  }
  
  void unassign() {
    this.w = 1280;
    this.h = 720;
    this.x = 0;
    this.y = 0;
    isAssigned = false;
    pg = (PGraphics2D) createGraphics(w, h, P2D);
  }

  void assignToDisplay(Rectangle bounds) {
    this.w = bounds.width;
    this.h = bounds.height;
    this.x = bounds.x;
    this.y = bounds.y;
    isAssigned = true;
    pg = (PGraphics2D) createGraphics(w, h, P2D);
  }
  
  void addScene(int id){
    scenes.add(new Scene(id));
  }
  //void getScenesXML(XML input){
  //  scenesXML = input;
  //  //scenes.clear();
    
  //}
  void render() {
    // Update the offscreen buffer
    updateGraphics();
  }
  
  void show(){
    // Draw the buffer at the correct position
    image(pg, x, y);
  }

  void updateGraphics() {
    pg.beginDraw();
    // Example: Different content per screen
    pg.background(id == 1 ? color(200, 0, 0) : color(0, 0, 200));
    pg.fill(255);
    pg.textSize(24);
    pg.text("Screen " + id + "\n" + w + "x" + h, 20, 40);
    pg.endDraw();
  }

  PGraphics2D getScreen() {
    return pg;
  }
}
