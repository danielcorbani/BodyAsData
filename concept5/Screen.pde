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
    screenXML.addChild("Medias");
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
    for (MediaItem media : mediaItems) {
      media.assignToDisplay(w, h, x, y, id);
    }
  }

  void assignToDisplay(Rectangle bounds) {
    this.w = bounds.width;
    this.h = bounds.height;
    this.x = bounds.x;
    this.y = bounds.y;
    isAssigned = true;
    pg = (PGraphics2D) createGraphics(w, h, P2D);
    for (MediaItem media : mediaItems) {
      media.assignToDisplay(w, h, x, y, id);
    }
  }

  void addMedia(MediaItem newMedia) {
    mediaItems.add(newMedia);
    //println("new Media added successfully");
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
  
  public void setPreviewArea(float px, float py, float pw, float ph) {
    for (MediaItem media : mediaItems) {
        media.setPreviewArea(px, py, pw, ph);
        //media.moveHoverPoint(mousex, mousey);
    }
  }

  public void moveHoverPoint(float mousex, float mousey) {
    for (MediaItem media : mediaItems) {
        media.moveHoverPoint(mousex,mousey);
    }
  }

  PGraphics2D getScreen() {
    return pg;
  }
}
