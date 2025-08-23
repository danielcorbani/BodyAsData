import java.awt.GraphicsEnvironment;
import java.awt.GraphicsDevice;
import java.awt.Rectangle;
import processing.opengl.PGraphics2D;
import controlP5.*;

class Project {
  PApplet mainApplet;  //needed for control P5
  String projectName; //Name passed by the user
  ArrayList<Screen> screens = new ArrayList<Screen>();  // Screens containing Scenes / external displays only, UI not included here
  ArrayList<Rectangle> availableDisplays = new ArrayList<Rectangle>(); // Stores external displays config
  XML config;
  PGraphics2D canvaUI;    // Main PGraphics for UI

  int mainWidth, mainHeight;  //Used for UI drawings
  int hx1, hx2, hy1, hy2, r;  // handles for separating panels

  ArrayList<String> mediaFiles = new ArrayList<String>();

  //ArrayList<MediaButton> mediaButtons = new ArrayList<MediaButton>();
  float mediaButtonHeight = 40; // Height of each media button
  float mediaPanelPadding = 10; // Padding inside panel

  //ArrayList<ScreenButton> screenButtons = new ArrayList<ScreenButton>();
  //AddScreenButton addScreenBtn;
  float screenButtonHeight = 25;
  float screenButtonMargin = 5;
  int currentScreen = 0;
  int currentScene  = 0;

  ControlP5 cp5;
  Group mediaList, screenList, displaysList, sceneList;
  int screenButtonsArea = 30;
  boolean addSelectScreenBool = false; //to avoid creating a button inside another button
  boolean addSceneBool = false;

  Project(PApplet p, String name) {
    mainApplet = p;
    projectName = (name == null || name.trim().isEmpty()) ? "untitled" : name.trim();
    cp5 = new ControlP5(mainApplet); //must be called before creating buttons;
    initializeDisplays();
    scanMediaFiles();
    initXMLconfig();
    initializeButtons();
  }

  /////// External Displays Management

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
  }

  void initXMLconfig() {
    String filename = "data/" + projectName + ".xml";
    File file = new File(sketchPath(filename));
    if (file.exists()) {
      try {
        config = loadXML(filename);
        screens.clear();
        XML[] screenXMLs = config.getChildren("Screen");
        println("Loaded Screens: " + screenXMLs.length);
        for (XML screenXML : screenXMLs) {
          //screens.add(new Screen(screenXML.getInt("id")));
          Screen screen = new Screen(screenXML);
          screens.add(new Screen(screen.screenXML));
          XML[] scenes = screenXML.getChildren("Scene");
          println("Loaded Screen number of scenes: " + scenes.length);
        }
        println("Loaded existing project: " + projectName);
      }
      catch (Exception e) {
        println("Error loading project: " + e);
      }
    } else {
      XML xml = new XML(projectName);
      xml.setString("name", projectName);
      saveXML(xml, "data/" + projectName + ".xml");
      println("New Project created: " + projectName);
    }
  }

  void saveToFile() {
    saveXML(config, "data/" + projectName + ".xml");
    println("Project saved: " + projectName);
  }


  ///// Screen management

  // Create a new screen with default parameters
  void addNewScreen() {
    int newId = screens.size();
    Screen newScreen = new Screen(newId);
    screens.add(newScreen); // Default size
    config.addChild(newScreen.screenXML);
    saveToFile();
    println("Added new screen (ID: " + newId + ")");
    //addSelectScreenButton(newId);  //can't do that in here!!!!!
    addSelectScreenBool = true;
  }

  // Create a new screen with default parameters
  void addNewScene() {
    int newId = screens.get(currentScreen).scenes.size();
    println("Adding a new Scene with index " + newId);
    Scene newScene = new Scene(newId);
    screens.get(currentScreen).addScene(newScene.sceneXML);
    XML[] screensXML = config.getChildren("Screen");
    screensXML[currentScreen].addChild(newScene.sceneXML);
    saveToFile();
    //println("New Scene added to current Screen");
    addSceneBool = true;
  }

  ///// Control P5 Management

  void initializeButtons() {
    createAssignDisplayButtons();
    createScreenButtons();
    createSceneButtons();
  }

  void updateCP5() {
    if (addSelectScreenBool) {
      addSelectScreenButton(screens.size()-1);
      addSelectScreenBool = false;
    }
    if (addSceneBool) {
      int index = screens.get(currentScreen).scenes.size();
      println("Is this the next Scene index? -> " + index);
      addSelectSceneButton(index);
      addSceneBool = false;
    }
  }

  void createAssignDisplayButtons() {
    int DisplayButtonX = hx2 -8*r;
    int DisplayButtonheight = 30;
    displaysList = cp5.addGroup("Display List")
      .setPosition(DisplayButtonX, hy1+2*r)
      .setBackgroundHeight(hy2-hy1)
      .disableCollapse()
      .hideBar();
    ;

    for (int i = 0; i < availableDisplays.size(); i++) {
      Rectangle b = availableDisplays.get(i);
      cp5.addBang("Display " + i)
        .setPosition(0, DisplayButtonheight*i*2)
        .setSize(30, DisplayButtonheight)
        .setGroup(displaysList)
        .addCallback(new CallbackListener() {
        public void controlEvent(CallbackEvent event) {
          if (event.getAction() == ControlP5.ACTION_RELEASE) {
            AssignDisplay(b);
          }
        }
      }
      )
      ;
    }
  }

  void AssignDisplay(Rectangle b) {
    if (screens.get(currentScreen).isAssigned == false) {
      for (Screen screen : screens) {
        if (screen.x == b.x) {
          screen.unassign();
        }
      }
      screens.get(currentScreen).assignToDisplay(b);
    } else {
      screens.get(currentScreen).unassign();
    }
  }

  void createScreenButtons() {
    screenList = cp5.addGroup("Screen List")
      .setPosition(hx1+ r, hy2-2*r-screenButtonsArea)
      .setBackgroundHeight(screenButtonsArea)
      .disableCollapse()
      ;

    cp5.addButton("Add Screen")
      .setPosition(r, r)
      .setSize(20, screenButtonsArea)
      .setCaptionLabel("Add Screen")
      .setGroup(screenList)
      .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent event) {
        if (event.getAction() == ControlP5.ACTION_RELEASE) {
          //println("Bang released: " + event.getController().getName());
          // Your function call here
          addNewScreen();
        }
      }
    }
    );

    for (Screen screen : screens) {
      //mediaFiles.add(file.getName());
      addSelectScreenButton(screen.id);
    }
  }

  void addSelectScreenButton(int index) {
    int buttonHeight = 20;
    int buttonWidth  = 30;
    int buttonX = 80+index*buttonWidth*2;
    cp5.addButton("screen "+index)
      .setPosition(buttonX, r)
      .setSize(buttonWidth, buttonHeight)
      .setCaptionLabel("screen "+index)
      .setGroup(screenList)
      .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent event) {
        if (event.getAction() == ControlP5.ACTION_RELEASE) {
          //println(event.getController().getName());
          // Your function call here
          selectScreen(index);
        }
      }
    }
    );
  }

  void selectScreen(int index) {
    if (index >= 0 && index < screens.size()) {
      currentScreen = index;
    }
  }

  void createSceneButtons() {
    sceneList = cp5.addGroup("Scene List")
      .setPosition(r, mainHeight-4*r)
      .setBackgroundHeight(200)
      .disableCollapse()
      ;
    cp5.addButton("Add Scene")
      .setPosition(r, r)
      .setSize(20, screenButtonsArea)
      .setCaptionLabel("Add Scene")
      .setGroup(sceneList)
      .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent event) {
        if (event.getAction() == ControlP5.ACTION_RELEASE) {
          //println("Bang released: " + event.getController().getName());
          // Your function call here
          addNewScene();
        }
      }
    }
    );

    ArrayList<Scene> scenes = screens.get(currentScreen).scenes;
    println("Current Screen number of scenes: " + scenes.size());
    for (Scene scene : scenes) {
      //mediaFiles.add(file.getName());
      addSelectSceneButton(scene.id);
      println("Scene buttons initialized");
    }
  }

  void addSelectSceneButton(int index) {

    int buttonHeight = 20;
    int buttonWidth  = 30;
    int buttonX = 80+index*buttonWidth*2;
    cp5.addButton("scene "+index)
      .setPosition(buttonX, r)
      .setSize(buttonWidth, buttonHeight)
      .setCaptionLabel("scene "+index)
      .setGroup(sceneList)
      .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent event) {
        if (event.getAction() == ControlP5.ACTION_RELEASE) {
          println(event.getController().getName());
          // Your function call here
          //selectScreen(index);
        }
      }
    }
    );
  }

  // Add this method to scan media files
  void scanMediaFiles() {
    mediaFiles.clear();
    mediaList = cp5.addGroup("Media List")
      .setPosition(r, hy1+r)
      .setBackgroundHeight(hy2-hy1-2*r)
      .disableCollapse()
      ;
    File dataDir = new File(sketchPath("data"));

    if (dataDir.exists() && dataDir.isDirectory()) {
      File[] files = dataDir.listFiles();
      for (File file : files) {
        if (isMediaFile(file.getName())) {
          mediaFiles.add(file.getName());
          int buttonHeight = 20;
          int buttonWidth  = hx1-2*r;
          int buttonY = mediaFiles.size()*buttonHeight;
          cp5.addButton(file.getName())
            .setPosition(0, buttonY)
            .setSize(buttonWidth, buttonHeight)
            .setCaptionLabel(file.getName())
            .setGroup(mediaList)
            .addCallback(new CallbackListener() {
            public void controlEvent(CallbackEvent event) {
              if (event.getAction() == ControlP5.ACTION_RELEASE) {
                //println("Bang released: " + event.getController().getName());
                // Your function call here
                addMedia(file.getName());
              }
            }
          }
          );
        }
      }

      //createMediaButtons();
    }
  }

  void addMedia(String name) {
    //check active Screen > active Scene
    //create MediaItem with the file
    //insert MediaItem into the current Scene
    println(name + " added to current Scene");
  }

  // Helper method to check file extensions
  boolean isMediaFile(String filename) {
    String[] supportedExtensions = {".mp4", ".mov", ".png", ".jpg", ".jpeg", ".gif"};
    String lowerName = filename.toLowerCase();
    for (String ext : supportedExtensions) {
      if (lowerName.endsWith(ext)) {
        return true;
      }
    }
    return false;
  }

  void mousereleased(int mx, int my) {
  }

  void mousepressed(int mx, int my) {
  }

  void render(int mx, int my) {
    for (Screen screen : screens) {
      screen.render();
      if (screen.isAssigned) {
        screen.show();
      }
    }

    drawUI();
    updateCP5();
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
    drawStagePanel(currentScreen); // Pass the index here

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
    float previewAreaY = hy1 + 20 ;
    float previewAreaWidth = hx2 - hx1 - 40;
    float previewAreaHeight = hy2 - hy1 - 40 - screenButtonsArea; // Room for buttons

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
  }
}
