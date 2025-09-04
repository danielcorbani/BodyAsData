import processing.opengl.PGraphics2D;

class Screen {
  int id;
  int w, h, x, y;  //Screen dimensions and position in virtual space
  XML screenXML;
  ArrayList<MediaItem> mediaItems = new ArrayList<MediaItem>();
  public PGraphics2D pg; // Offscreen buffer for this screen
  boolean isAssigned;
  int currentScene;

  Screen(int id) {
    this.id = id;
    unassign();
    screenXML = new XML("Screen");
    screenXML.setInt("id", id);
    currentScene = 0;
  }

  Screen(XML screen) {
    this.id = screen.getInt("id");
    unassign();
    screenXML = screen;
    currentScene = 0;
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

  void addMedia(MediaItem newMedia) {
    mediaItems.add(newMedia);
    println("new Media added successfully");
  }

  void render(int mousex, int mousey) {
    int localMousex = mousex;
    int localMousey = mousey;
    // Update the offscreen buffer
    updateGraphics(localMousex, localMousey);
    show();
  }

  void show() {
    // Draw the buffer at the correct position
    if (isAssigned) image(pg, x, y);
  }

  void updateGraphics(int mousex, int mousey) {
    pg.beginDraw();
    // Example: Different content per screen
    pg.background(id == 1 ? color(200, 0, 0) : color(0, 0, 200));
    for (MediaItem media : mediaItems) {
      if (media.sceneIndex == currentScene) {
        media.checkHover(mousex, mousey);
        //media.moveHoverPoint(mousex, mousey);
        pg.image(media.getMediaCanvas(), 0, 0);
      }
    }
    pg.endDraw();
  }

  //boolean isMouseInsideCorners(PVector mouse, PVector[] cc){
  //  float minX = Math.min(Math.min(cc[0].x, cc[1].x), Math.min(cc[2].x, cc[3].x));
  //  float maxX = Math.max(Math.max(cc[0].x, cc[1].x), Math.max(cc[2].x, cc[3].x));
  //  float minY = Math.min(Math.min(cc[0].y, cc[1].y), Math.min(cc[2].y, cc[3].y));
  //  float maxY = Math.max(Math.max(cc[0].y, cc[1].y), Math.max(cc[2].y, cc[3].y));

  //  return mouse.x > minX && mouse.x < maxX && mouse.y > minY && mouse.y < maxY;
  //}
  public void moveHoverPoint(float mousex, float mousey) {
    for (MediaItem media : mediaItems) {
        media.moveHoverPoint(mousex,mousey);
    }
  }

  PGraphics2D getScreen() {
    return pg;
  }
}
