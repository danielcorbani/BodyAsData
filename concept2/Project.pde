import java.awt.GraphicsEnvironment;
import java.awt.GraphicsDevice;
import java.awt.Rectangle;
import processing.opengl.PGraphics2D;

class Project {
  String projectName; //Name passed by the user
  ArrayList<Screen> screens = new ArrayList<Screen>();  // Screens containing Scenes / external displays only, UI not included here
  ArrayList<Rectangle> availableDisplays = new ArrayList<Rectangle>(); // Stores external displa
  XML config;
  PGraphics2D canvaUI;    // Main PGraphics for UI

  int mainWidth, mainHeight;
  int hx1, hx2, hy1, hy2, r;  // handles for separating panels

  ArrayList<String> mediaFiles = new ArrayList<String>();
  String[] supportedExtensions = {".mp4", ".mov", ".png", ".jpg", ".jpeg", ".gif"};
  ArrayList<MediaButton> mediaButtons = new ArrayList<MediaButton>();
  float mediaButtonHeight = 40; // Height of each media button
  float mediaPanelPadding = 10; // Padding inside panel

  ArrayList<ScreenButton> screenButtons = new ArrayList<ScreenButton>();
  ;
  AddScreenButton addScreenBtn;
  float screenButtonHeight = 25;
  float screenButtonMargin = 5;
  int currentSelectedScreenIndex = 0;

  Project(String name) {
    projectName = (name == null || name.trim().isEmpty()) ? "untitled" : name.trim();
    initializeDisplays();
    scanMediaFiles();
    createScreenButtons(); // Add this line
  }

  void initializeDisplays() {
    GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
    GraphicsDevice[] devices = ge.getScreenDevices();
    //displayBounds = new Rectangle[devices.length];
    availableDisplays.clear(); // Clear previous display info

    for (int i = 0; i < devices.length; i++) {
      Rectangle bounds = devices[i].getDefaultConfiguration().getBounds();
      if (i == 0) { // initialize UI
        mainWidth = bounds.width;
        mainHeight = bounds.height;
        hx1 = mainWidth/6;
        hx2 = mainWidth - hx1;
        hy1 = 30;
        hy2 = 2*mainHeight/4;
        r = 10;
        // Create an offscreen buffer matching main screen size
        canvaUI = (PGraphics2D) createGraphics(mainWidth, mainHeight, P2D);
      } else {
        // Store external display info without creating screens
        availableDisplays.add(bounds);
        println("Found external display #" + i + ": " + bounds.width + "x" + bounds.height);
      }
    }

    // Create at least one screen by default (not assigned to display)
    if (screens.isEmpty()) {
      screens.add(new Screen(0, 1280, 720, 0, 0)); // Default size; must review it later
    }
    println("Number of Screens: " + screens.size());
  }

  // Assign a screen to a specific display
  void assignScreenToDisplay(int screenIndex, int displayIndex) {
    if (screenIndex >= 0 && screenIndex < screens.size() &&
      displayIndex >= 0 && displayIndex < availableDisplays.size()) {
      Rectangle bounds = availableDisplays.get(displayIndex);
      Screen screen = screens.get(screenIndex);

      // Update screen with display properties
      screen.w = bounds.width;
      screen.h = bounds.height;
      screen.x = bounds.x;
      screen.y = bounds.y;

      println("Assigned screen " + screenIndex + " to display " + displayIndex);
    }
  }

  int getDisplayIndexForScreen(Screen screen) {
    for (int i = 0; i < availableDisplays.size(); i++) {
      Rectangle bounds = availableDisplays.get(i);
      if (screen.x == bounds.x && screen.y == bounds.y) {
        return i;
      }
    }
    return -1;
  }
  void selectScreen(int index) {
    if (index >= 0 && index < screens.size()) {
      currentSelectedScreenIndex = index;
    }
  }
  // Create a new screen with default parameters
  void addNewScreen() {
    int newId = screens.size();
    screens.add(new Screen(newId, 1280, 720, 0, 0)); // Default size
    println("Added new screen (ID: " + newId + ")");
  }

  //void createScreenButtons() {
  //  screenButtons.clear();

  //  float buttonsWidth = hx2 - hx1 - 40;
  //  float addButtonWidth = 120; // New narrower width for add button
  //  float startY = hy2 - screenButtonHeight - 20;

  //  for (int i = 0; i < screens.size(); i++) {
  //    Screen s = screens.get(i);
  //    String label = "Screen " + i + (s.isAssigned ? " (Display " + getDisplayIndexForScreen(s) + ")" : "");

  //    screenButtons.add(new ScreenButton(
  //      hx1 + 20,
  //      startY - (i * (screenButtonHeight + screenButtonMargin)),
  //      buttonsWidth,
  //      screenButtonHeight,
  //      label,
  //      i
  //      ));
  //  }

  //  addScreenBtn = new AddScreenButton(
  //    hx1 + 20,
  //    hy2 - screenButtonHeight - 10,
  //    addButtonWidth,
  //    screenButtonHeight
  //    );
  //}

  void createScreenButtons() {
    screenButtons.clear();

    // New narrower width for screen buttons
    float screenButtonWidth = 50; // Half of stage panel width
    float screenButtonSpacing = 5; // Space between buttons
    float buttonsAreaHeight = screenButtonHeight + 20; // Fixed height for button row

    // Calculate vertical positions
    float buttonsStartX = hx1 + 20;
    float buttonsStartY = hy2 - buttonsAreaHeight - 10;


    // Create horizontal row of screen buttons
    for (int i = 0; i < screens.size(); i++) {
      //Screen s = screens.get(i);
      screenButtons.add(new ScreenButton(
        this,
        buttonsStartX + (i * (screenButtonWidth + screenButtonSpacing)),
        buttonsStartY,
        screenButtonWidth,
        screenButtonHeight,
        "" + i, // Just show number
        i
        ));
    }
    // Position Add Screen button below the row
    addScreenBtn = new AddScreenButton(
      this,
      buttonsStartX,
      buttonsStartY + screenButtonHeight + 5, // Below screen buttons
      120,
      screenButtonHeight
      );
  }

  void handleScreenButtonPress(int index) {
    selectScreen(index);
  }

  // Add this method to scan media files
  void scanMediaFiles() {
    mediaFiles.clear();
    mediaButtons.clear(); // Clear existing buttons

    File dataDir = new File(sketchPath("data"));

    if (dataDir.exists() && dataDir.isDirectory()) {
      File[] files = dataDir.listFiles();
      for (File file : files) {
        if (isMediaFile(file.getName())) {
          mediaFiles.add(file.getName());
        }
      }

      createMediaButtons();
    }
  }

  void createMediaButtons() {
    mediaButtons.clear();
    float buttonWidth = hx1 - 20;
    float buttonHeight = 30;
    float startY = hy1 + 40;

    for (int i = 0; i < mediaFiles.size(); i++) {
      mediaButtons.add(new MediaButton(
        this,
        10,
        startY + (i * (buttonHeight + 5)),
        buttonWidth,
        buttonHeight,
        mediaFiles.get(i)
        ));
    }
  }

  // Helper method to check file extensions
  boolean isMediaFile(String filename) {
    String lowerName = filename.toLowerCase();
    for (String ext : supportedExtensions) {
      if (lowerName.endsWith(ext)) {
        return true;
      }
    }
    return false;
  }

  void mousereleased(int mx, int my) {
    for (Button bt : mediaButtons) {
      bt.checkRelease(mx, my);
    }
    addScreenBtn.checkRelease(mx, my);
    for (ScreenButton btn : project.screenButtons) {
      btn.checkRelease(mx, my);
    }
  }

  void mousepressed(int mx, int my) {
    // Screen buttons
    for (ScreenButton btn : project.screenButtons) {
      btn.checkPress(mx, my);
      if (btn.isPressed) {
        project.handleScreenButtonPress(btn.screenIndex);
      }
    }

    // Add screen button
    addScreenBtn.checkPress(mx, my);
    for (Button bt : mediaButtons) {
      bt.checkPress(mx, my);
    }
  }

  void render(int mx, int my) {
    for (Screen screen : screens) {
      screen.render();
      if (screen.isAssigned) {
        screen.show();
      }
    }

    drawUI();

    for (Button bt : mediaButtons) {
      bt.update(mx, my);
      bt.display();
    }
  }

  void drawUI() {
    canvaUI.beginDraw();
    canvaUI.background(33);

    //title
    canvaUI.textSize(20);
    canvaUI.fill(200);
    canvaUI.textAlign(CENTER, CENTER);
    canvaUI.text(projectName, mainWidth/2, hy1/2);
    canvaUI.text("fps: " + int(frameRate), mainWidth/3, hy1/2);

    //media
    drawPanel(0, hy1, hx1, hy2, canvaUI);
    //canvaUI.image(stageCanva,w/2,0);

    //stage
    //drawPanel(hx1, hy1, hx2, hy2, canvaUI);
    drawStagePanel(0); // Pass the index here

    //effects
    drawPanel(hx2, hy1, mainWidth, hy2, canvaUI);

    //timeline
    drawPanel(0, hy2, mainWidth, mainHeight, canvaUI);

    canvaUI.endDraw();
    image(canvaUI, 0, 0);
  }

  void drawPanel(int x1, int y1, int x2, int y2, PGraphics2D input) {
    input.noStroke();
    input.fill(44);
    input.rect(x1+r, y1+r, x2-x1-2*r, y2-y1-2*r, r);
  }

  void drawStagePanel(int index) {
    // 1. Draw panel background
    drawPanel(hx1, hy1, hx2, hy2, canvaUI);

    // 2. Calculate available preview area (with 20px padding)
    float previewAreaX = hx1 + 20;
    float previewAreaY = hy1 + 40;
    float previewAreaWidth = hx2 - hx1 - 40;
    float previewAreaHeight = hy2 - hy1 - 80; // Room for buttons

    // 3. Draw preview content
    if (index >= 0 && index < screens.size()) {
      Screen screen = screens.get(index);

      // Calculate scale to fit
      float scale = min(
        previewAreaWidth / screen.w,
        previewAreaHeight / screen.h
        );

      float previewWidth = screen.w * scale;
      float previewHeight = screen.h * scale;

      // Center in preview area
      float previewX = previewAreaX + (previewAreaWidth - previewWidth)/2;
      float previewY = previewAreaY + (previewAreaHeight - previewHeight)/2;

      // Draw (with border)
      canvaUI.fill(0);
      canvaUI.rect(previewX-2, previewY-2, previewWidth+4, previewHeight+4);
      canvaUI.image(screen.pg, previewX, previewY, previewWidth, previewHeight);
    }

    // 4. Draw UI elements on top
    canvaUI.fill(200);
    canvaUI.textSize(16);
    canvaUI.textAlign(LEFT, TOP);
    canvaUI.text("Stage Preview", hx1 + 20, hy1 + 15);
    
    // Draw screen buttons row
    for (ScreenButton btn : screenButtons) {
      btn.display(canvaUI, btn.screenIndex == index ? color(100, 150, 255) : btn.defaultColor);
    }

    // Draw Add Screen button
    addScreenBtn.display(canvaUI);
  }
}
