import paletai.mapping.*;
import processing.video.Capture;
import processing.video.Movie;

public class VidMap {
  /** The parent Processing applet */
  PApplet p;
  /** Shader for applying homography transformations */
  PShader mapInOut;
  int resolutionX, resolutionY;
  /** Graphics buffers for input and output */
  PGraphics2D pgCanvas, pgInput;
  /** Normalized coordinates for shader (0-1 range) */
  PVector[] xyN = new PVector[4]; // Normalized coordinates for Shader
  PVector[] uvN = new PVector[4]; // Normalized coordinates for Shader
  /** Pixel coordinates for Processing display */
  PVector[] xyP = new PVector[4]; // Pixel coordinates for Processing (for drawing)
  PVector[] uvP = new PVector[4]; // Pixel coordinates for Processing (for drawing)
  /** Math utility for homography calculations */
  MathHomography mat;
  /** 3D matrix for shader transformations */
  PMatrix3D H;
  /** Calibration state flags */
  boolean calibrate = false;
  public boolean checkInput = false;
  /** Point interaction tracking */
  int hoverPoint = -1; // Point index to highlight when hovering
  int selectedPoint = -1; // New variable to store the selected point for live adjustment

  /** Unique identifier for this mapping */
  String objectName; // Unique name for the VidMap object
  /** Image dragging state */
  private boolean movingImage = false;
  private PVector initialMousePos;
  private PVector[] initialCorners;
  int screenX, screenY;
  /**
   * Constructs a new VidMap instance.
   *
   * @param p The parent Processing applet
   * @param name Unique identifier for this mapping
   */
  public VidMap(PApplet p, String name) {
    println("starting VidMap");
    this.p = p;
    this.objectName = name;
    mapInOut = p.loadShader("homography.glsl");
    assignToDisplay(1280, 720,0,0);
    mat = new MathHomography();
    //resetHomography();
    println("Finishing VidMap");
  }

  void assignToDisplay(int w, int h, int x, int y) {
    
    this.resolutionX = w;
    this.resolutionY = h;
    screenX = x;
    screenY = y;
    println("screen position in VidMap: " + screenX + "," + screenY);
    pgCanvas = (PGraphics2D) p.createGraphics(resolutionX, resolutionY, PConstants.P2D);
    pgInput = (PGraphics2D) p.createGraphics(resolutionX, resolutionY, PConstants.P2D);
    //resetHomography();
    mapInOut.set("resolution", resolutionX, resolutionY);
  }

  void assignToDisplay(PGraphics2D pgScreen, int x, int y) {
    assignToDisplay(pgScreen.width, pgScreen.height,x,y);
  }


  /**
   * Resets the homography to identity transformation.
   * Initializes all points to the corners of the display.
   */
  public void resetHomography() {
    // Initialize Processing points in pixel coordinates
    xyP[0] = new PVector(0, 0);
    xyP[1] = new PVector(resolutionX, 0);
    xyP[2] = new PVector(resolutionX, resolutionY);
    xyP[3] = new PVector(0, resolutionY);

    uvP[0] = new PVector(0, 0);
    uvP[1] = new PVector(resolutionX, 0);
    uvP[2] = new PVector(resolutionY, resolutionY);
    uvP[3] = new PVector(0, resolutionY);

    // Initialize normalized points for the shader (ensure xyN and uvN are assigned
    // properly)
    for (int i = 0; i < 4; i++) {
      xyN[i] = Pixel2Nornal(xyP[i]);
      uvN[i] = Pixel2Nornal(uvP[i]);
    }

    updateHomography(xyN, uvN);
  }

  /**
   * Updates the homography matrix from pixel-space coordinates.
   *
   * @param xyPP Source points in pixel coordinates
   * @param uvPP Destination points in pixel coordinates
   * @throws IllegalArgumentException If arrays don't contain exactly 4 points
   */
  public void updateHomographyFromPixel(PVector[] xyPP, PVector[] uvPP) {
    for (int i = 0; i < 4; i++) {
      xyP[i] = xyPP[i];
      uvP[i] = uvPP[i];
      xyN[i] = Pixel2Nornal(xyPP[i]);
      uvN[i] = Pixel2Nornal(uvPP[i]);
    }

    updateHomography(xyN, uvN);
  }

  /**
   * Updates the homography transformation from normalized coordinates.
   *
   * @param xyNew Source points in normalized coordinates (0-1)
   * @param uvNew Destination points in normalized coordinates (0-1)
   */
  public void updateHomography(PVector[] xyNew, PVector[] uvNew) {

    for (int i = 0; i < uvN.length; i++) {
      String xyNum = "xy" + Integer.toString(i);
      mapInOut.set(xyNum, uvNew[i].x, uvNew[i].y); // input points set cropping mask
    }
    float[][] h = mat.calculateHomography(xyNew, uvNew); // get the homograhy matrix cconsidering the normalized
    // points
    float[][] hinv = mat.invertMatrix(h); // the OpenGl coordinates requires the inverse Homography matrix
    hinv = mat.transpose(hinv); // for some reason, it must be transposed
    H = mat.getMatrix(hinv); // it converts float[][] into the PMatrix#D for the OpenGL filter
    mapInOut.set("H", H, true); // true = use3x3
  }

  public void toggleInput() {
    checkInput = !checkInput;
    //System.out.println("checkInput = " + vidMap.checkInput);
  }

  private void makeGrid(PVector[] corners, boolean isInput) {
    int gridSize = 10; // Number of cells in the grid
    pgCanvas.stroke(0, 255, 0);
    if (isInput)pgCanvas.stroke(0, 0, 255);
    pgCanvas.strokeWeight(1);
    pgCanvas.noFill();

    // Interpolating horizontal and vertical grid lines
    for (int i = 0; i <= gridSize; i++) {
      float t = i / (float) gridSize;

      // Horizontal lines interpolation
      PVector startH = PVector.lerp(corners[0], corners[1], t);
      PVector endH = PVector.lerp(corners[3], corners[2], t);
      pgCanvas.line(startH.x, startH.y, endH.x, endH.y);

      // Vertical lines interpolation
      PVector startV = PVector.lerp(corners[0], corners[3], t);
      PVector endV = PVector.lerp(corners[1], corners[2], t);
      pgCanvas.line(startV.x, startV.y, endV.x, endV.y);
    }
  }

  /**
   * Renders the mapped content to the screen.
   *
   * @param input The graphics buffer to transform and display
   */
  public void show(PGraphics2D input) {
    if (pgCanvas == null) {
      System.out.println("Initializing pgCanvas late...");
      pgCanvas = (PGraphics2D) p.createGraphics(resolutionX, resolutionY, PConstants.P2D);
    }
    pgCanvas.beginDraw();
    pgCanvas.image(input, 0, 0, pgCanvas.width, pgCanvas.height);

    if (calibrate) {
      // Draw the green grid inside pgCanvas
      makeGrid(xyP, checkInput);
    }

    pgCanvas.endDraw();

    if (!checkInput)
      pgCanvas.filter(mapInOut);
    p.image(pgCanvas, 0, 0);

    if (calibrate) {

      if (!checkInput) {
        // Highlight the corners on the main canvas
        p.beginShape();
        p.stroke(0, 255, 0);
        p.strokeWeight(2);
        p.noFill();
        for (int i = 0; i < uvN.length; i++) {
          if (i == hoverPoint) {
            p.fill(255, 0, 0); // Highlight hovered point
            p.ellipse(p.width * uvN[i].x + screenX, p.height * (1 - uvN[i].y) + screenY, 10, 10);
            p.noFill();
          }
          p.vertex(p.width * uvN[i].x, p.height * (1 - uvN[i].y));
        }
        p.endShape(PConstants.CLOSE);
      } else {
        // Highlight the corners on the main canvas
        p.beginShape();
        p.stroke(0, 0, 255);
        p.strokeWeight(2);
        p.noFill();
        for (int i = 0; i < uvN.length; i++) {
          if (i == hoverPoint) {
            p.fill(255, 0, 0); // Highlight hovered point
            p.ellipse(p.width * xyN[i].x + screenX, p.height * (1 - xyN[i].y) + screenY, 10, 10);
            p.noFill();
          }
          p.vertex(p.width * xyN[i].x + screenX, p.height * (1 - xyN[i].y) + screenY);
        }
        p.endShape(PConstants.CLOSE);
      }
    }
  }

  public void render(PGraphics2D input) {
    if (pgCanvas == null) {
      System.out.println("Initializing pgCanvas late...");
      pgCanvas = (PGraphics2D) p.createGraphics(resolutionX, resolutionY, PConstants.P2D);
    }
    pgCanvas.beginDraw();
    pgCanvas.image(input, 0, 0, pgCanvas.width, pgCanvas.height);

    if (calibrate) {
      // Draw the green grid inside pgCanvas
      makeGrid(xyP, checkInput);
    }

    pgCanvas.endDraw();

    if (!checkInput) {
      pgCanvas.filter(mapInOut);
    }
    //p.image(pgCanvas, 0, 0);

    if (calibrate) {

      if (!checkInput) {
        // Highlight the corners on the main canvas
        p.beginShape();
        p.stroke(0, 255, 0);
        p.strokeWeight(2);
        p.noFill();
        for (int i = 0; i < uvN.length; i++) {
          if (i == hoverPoint) {
            p.fill(255, 0, 0); // Highlight hovered point
            p.ellipse(pgCanvas.width * uvN[i].x, pgCanvas.height * (1 - uvN[i].y), 10, 10);
            p.noFill();
          }
          p.vertex(pgCanvas.width * uvN[i].x, pgCanvas.height * (1 - uvN[i].y));
        }
        p.endShape(PConstants.CLOSE);
      } else {
        // Highlight the corners on the main canvas
        p.beginShape();
        p.stroke(0, 0, 255);
        p.strokeWeight(2);
        p.noFill();
        for (int i = 0; i < uvN.length; i++) {
          if (i == hoverPoint) {
            p.fill(255, 0, 0); // Highlight hovered point
            p.ellipse(pgCanvas.width * xyN[i].x , pgCanvas.height * (1 - xyN[i].y), 10, 10);
            p.noFill();
          }
          p.vertex(pgCanvas.width * xyN[i].x, pgCanvas.height * (1 - xyN[i].y));
        }
        p.endShape(PConstants.CLOSE);
      }
    }
  }

  //public void show(PImage input) {
  //  pgInput.beginDraw();
  //  pgInput.image(input, 0, 0, pgCanvas.width, pgCanvas.height);
  //  pgInput.endDraw();

  //  show(pgInput);
  //}

  public void render(PImage input) {
    pgInput.beginDraw();
    pgInput.image(input, 0, 0, pgCanvas.width, pgCanvas.height);
    pgInput.endDraw();

    render(pgInput);
  }

  public PGraphics2D getMediaCanvas() {
    return pgCanvas;
  }

  /**
   * Converts pixel coordinates to normalized shader coordinates.
   *
   * @param in Input point in pixel coordinates
   * @return Point in normalized coordinates (0-1, Y inverted)
   */
  public PVector Pixel2Nornal(PVector in) {
    return new PVector(in.x / pgCanvas.width, 1.0f - (in.y / pgCanvas.height)); // Normalize and invert Y-axis for shader
  }

  /**
   * Converts pixel coordinates to pixel in the Preview.
   *
   * @param in Input point in pixel coordinates
   * @return Point in pixel coordinates meant for the Preview in the main window
   */
  //public PVector Pixel2Preview(PVector in, PVector op, float wp, float hp) {
  //  return new PVector(op.x + wp*in.x / pgCanvas.width, op.y + hp*in.y / pgCanvas.height);
  //}

  /**
   * Converts pixel in the Preview to pixel coordinates.
   *
   * @param in Input point in pixel coordinates from the Preview in the main window
   * @return Point in pixel coordinates
   */
  //public PVector Preview2Pixel(PVector in, PVector op, float wp, float hp) {
  //  return new PVector(pgCanvas.width*(in.x-op.x)/wp, pgCanvas.height*(in.y-op.y)/hp);
  //}

  /**
   * Converts normalized coordinates back to pixel space.
   *
   * @param in Input point in normalized coordinates
   * @return Point in pixel coordinates
   */
  public PVector Nornal2Pixel(PVector in) {
    return new PVector(in.x * pgCanvas.width, (1.0f - in.y) * pgCanvas.height); // Convert back to Processing coordinates
  }

  /**
   * Toggles calibration mode on/off.
   */
  public void toggleCalibration() {
    calibrate = !calibrate;
    System.out.println("calibrate " + objectName + "= " + calibrate);
  }

  public void offCalibration() {
    calibrate = false;
    System.out.println("calibrate " + objectName + "= " + calibrate);
  }

  public void onCalibration() {
    calibrate = true;
    System.out.println("calibrate " + objectName + "= " + calibrate);
  }

  /**
   * Checks if mouse is hovering over control points.
   *
   * @param x Mouse x position
   * @param y Mouse y position
   */
  public void checkHover(float mousex, float mousey) {
    PVector offset = new PVector(screenX,screenY);
    PVector mouse = new PVector(mousex, mousey); // Use Processing coordinates for checking hover
    //mouse.sub(offset);
    hoverPoint = -1; // Reset hover point
    movingImage = false;

    if (calibrate) {
      if (!checkInput) {
        for (int i = 0; i < uvP.length; i++) {
          float dist = PVector.dist(mouse, uvP[i]);
          if (dist < 10) { // Set hover if within a certain distance threshold
            hoverPoint = i;
            break;
          }
        }
        // Check if clicking inside the image
        if (isMouseInsideImage(mouse, uvP)) {
          movingImage = true;
          initialMousePos = new PVector(mouse.x, mouse.y);
          initialCorners = new PVector[4];
          for (int i = 0; i < 4; i++) {
            initialCorners[i] = uvP[i].copy(); // Store initial corners
          }
        }
      } else {
        for (int i = 0; i < xyP.length; i++) {
          float dist = PVector.dist(mouse, xyP[i]);
          if (dist < 10) { // Set hover if within a certain distance threshold
            hoverPoint = i;
            break;
          }
        }
      }
    }
  }

  // Helper method to check if mouse is inside the quadrilateral formed by uvP[]
  private boolean isMouseInsideImage(PVector mouse, PVector[] cc) {
    float minX = Math.min(Math.min(cc[0].x, cc[1].x), Math.min(cc[2].x, cc[3].x));
    float maxX = Math.max(Math.max(cc[0].x, cc[1].x), Math.max(cc[2].x, cc[3].x));
    float minY = Math.min(Math.min(cc[0].y, cc[1].y), Math.min(cc[2].y, cc[3].y));
    float maxY = Math.max(Math.max(cc[0].y, cc[1].y), Math.max(cc[2].y, cc[3].y));

    return mouse.x > minX && mouse.x < maxX && mouse.y > minY && mouse.y < maxY;
  }

  /**
   * Move control points.
   *
   * @param x Mouse x position
   * @param y Mouse y position
   */
  public void moveHoverPoint(float x, float y) {
    if (!checkInput) {
      if (hoverPoint != -1) {
        uvP[hoverPoint] = new PVector(x, y); // Update in Processing coordinates
        uvN[hoverPoint] = Pixel2Nornal(uvP[hoverPoint]); // Convert to normalized coordinates for the shader
        updateHomography(xyN, uvN);
      } else if (movingImage) {
        PVector delta = new PVector(x - initialMousePos.x, y - initialMousePos.y);
        for (int i = 0; i < 4; i++) {
          uvP[i] = PVector.add(initialCorners[i], delta);
          uvN[i] = Pixel2Nornal(uvP[i]);
        }
        updateHomography(xyN, uvN);
      }
    } else {
      if (hoverPoint != -1) {
        xyP[hoverPoint] = new PVector(x, y); // Update in Processing coordinates
        xyN[hoverPoint] = Pixel2Nornal(xyP[hoverPoint]); // Convert to normalized coordinates for the shader
        updateHomography(xyN, uvN);
      } else if (movingImage) {
        PVector delta = new PVector(x - initialMousePos.x, y - initialMousePos.y);
        for (int i = 0; i < 4; i++) {
          xyP[i] = PVector.add(initialCorners[i], delta);
          xyN[i] = Pixel2Nornal(xyP[i]);
        }
        updateHomography(xyN, uvN);
      }
    }
  }

  public void mouseReleased() {
    movingImage = false;
  }
}
