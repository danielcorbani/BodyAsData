import java.awt.GraphicsEnvironment;
import java.awt.GraphicsDevice;
import java.awt.Rectangle;
import processing.opengl.PGraphics2D;
import controlP5.*;
import processing.core.PApplet;

class Project {
  PApplet mainApplet;  //needed for control P5
  String projectName; //Name passed by the user
  ArrayList<Scene> scenes = new ArrayList<Scene>();
  int currentScene  = 0;
  ArrayList<Screen> screens = new ArrayList<Screen>();  // Screens containing Scenes / external displays only, UI not included here
  int currentScreen = 0;
  ArrayList<Rectangle> availableDisplays = new ArrayList<Rectangle>(); // Stores external displays config
  XML config;
  PGraphics2D canvaUI;    // Main PGraphics for UI

  int mainWidth, mainHeight;  //Used for UI drawings
  int hx1, hx2, hy1, hy2, r;  // handles for separating panels

  ArrayList<String> mediaFiles = new ArrayList<String>();

  ControlP5 cp5;
  Group mediaList, screenList, displaysList, sceneList;
  RadioButton screenRadio, sceneRadio;
  float mediaButtonHeight = 40; // Height of each media button
  float mediaPanelPadding = 10; // Padding inside panel
  float screenButtonHeight = 25;
  float screenButtonMargin = 5;
  int screenButtonsArea = 30;
  boolean addSelectScreenBool = false; //to avoid creating a button inside another button
  boolean addSceneBool = false;

  //Preview are for Screen Panel
  float previewAreaX, previewAreaY,
    previewAreaWidth, previewAreaHeight,
    previewWidth, previewHeight,
    previewX, previewY;

  ArrayList<MediaItem> currSceneMedias = new ArrayList<MediaItem>();
  ArrayList<MediaItem> nextSceneMedias = new ArrayList<MediaItem>();

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
    println("Initializing Displays...");
    GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
    GraphicsDevice[] devices = ge.getScreenDevices();
    //displayBounds = new Rectangle[devices.length];
    availableDisplays.clear(); // Clear previous display info

    for (int i = 0; i < devices.length; i++) {
      Rectangle bounds = devices[i].getDefaultConfiguration().getBounds();
      if (i == 0) { // initialize UI
        //println("Main display");
        mainWidth = bounds.width;
        mainHeight = bounds.height;
        hx1 = mainWidth/6;
        hx2 = mainWidth - hx1;
        hy1 = 30;
        hy2 = 2*mainHeight/4;
        r = 10;
        previewAreaX = hx1 + 20;
        previewAreaY = hy1 + 20 ;
        previewAreaWidth = hx2 - hx1 - 40;
        previewAreaHeight = hy2 - hy1 - 40 - screenButtonsArea; // Room for buttons
        // Create an offscreen buffer matching main screen size
        canvaUI = (PGraphics2D) createGraphics(mainWidth, mainHeight, P2D);
      } else {
        // Store external display info without creating screens
        availableDisplays.add(bounds);
        println("Found external display #" + i + ": " + bounds.width + "x" + bounds.height);
      }
    }
  }
  /////// Check Data Folder for readable media files
  void scanMediaFiles() {
    File dataDir = new File(sketchPath("data"));
    if (dataDir.exists() && dataDir.isDirectory()) {
      File[] files = dataDir.listFiles();
      //println("data folder contain: " + files.length + " files");
      for (File file : files) {
        if (isMediaFile(file.getName())) {
          mediaFiles.add(file.getName());
          //println(file.getName() + " added to mediaFiles");
        }
      }
    }
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


  /////// Initilize from XML file
  void initXMLconfig() {
    //println("XML config");
    String filename = "data/" + projectName + ".xml";
    File file = new File(sketchPath(filename));
    if (file.exists()) {
      try {
        config = loadXML(filename);
        screens.clear();
        XML screensParent = config.getChild("Screens");
        XML[] screensXML = screensParent.getChildren("Screen");
        for (XML screenXML : screensXML) {
          Screen screen = new Screen(screenXML);
          screens.add(screen);
        }
        XML scenesParent = config.getChild("Scenes");
        XML[] scenesXML = scenesParent.getChildren("Scene");
        for (XML sceneXML : scenesXML) {
          Scene scene = new Scene(sceneXML);
          //XML mediasParent = sceneXML.getChild("Medias");
          //XML[] mediasXML = mediasParent.getChildren("MediaItem");
          //for (XML mediaXML : mediasXML) {
          //  try {
          //    MediaItem newMedia = new MediaItem(mainApplet, mediaXML.getString("name"), scene.id);
          //    scene.addMedia(newMedia);
          //    screens.get(newMedia.assignedScreen).addMedia(newMedia);
          //    println("added " + mediaXML.getString("name") + "to Scene " + scene.id + "and Screen " + newMedia.assignedScreen); 
          //  }
          //  catch (Exception e) {
          //    println("Error loading media: " + e);
          //  }
          //}
          scenes.add(scene);
        }
        println("Loaded existing project: " + projectName);
      }
      catch (Exception e) {
        println("Error loading project: " + e);
      }
    } else {
      config = new XML(projectName);
      config.setString("name", projectName);
      config.setString("type", "Luna Video Mapping project");  // May be used to check if the existing XML file waas created here
      config.addChild("Screens");
      addNewScreen();
      addSelectScreenBool = false; //avoids duplicated button on initialization
      config.addChild("Scenes");
      addNewScene();
      addSceneBool = false; //avoids duplicated button on initialization
      saveXML(config, "data/" + projectName + ".xml");
      println("New Project created: " + projectName);
    }
  }

  void saveToFile() {
    saveXML(config, "data/" + projectName + ".xml");
    println("Project saved: " + projectName);
  }


  ///// Screen management
  // Create a new screen
  void addNewScreen() {
    int newId = screens.size();
    Screen newScreen = new Screen(newId);
    screens.add(newScreen); // add to ArrayList
    XML Screens = config.getChild("Screens");
    Screens.addChild(newScreen.screenXML); // add to XML
    saveToFile(); // update XML
    addSelectScreenBool = true; // tell ControlP5 to update next time
  }

  // Create a new scene
  void addNewScene() {
    int newId = scenes.size();
    //println("Adding a new Scene with index " + newId);
    Scene newScene = new Scene(newId);
    scenes.add(newScene);
    XML Scenes = config.getChild("Scenes");
    Scenes.addChild(newScene.sceneXML); // add to XML
    saveToFile();
    //println("New Scene added to current Screen");
    addSceneBool = true;
  }

  void addMedia(String name) {
    //create MediaItem with the file
    MediaItem newMedia = new MediaItem(mainApplet, name, currentScene);
    newMedia.assignToDisplay(screens.get(currentScreen).w,
      screens.get(currentScreen).h,
      screens.get(currentScreen).x,
      screens.get(currentScreen).y,
      currentScreen);
    //insert MediaItem into the current Scene
    scenes.get(currentScene).addMedia(newMedia);
    screens.get(currentScreen).addMedia(newMedia);
    saveToFile();
    //println(name + " added to current Scene");
  }


  // This functions updates all buttons
  void updateCP5() {
    if (addSelectScreenBool) {
      addSelectScreenButton(screens.size()-1);
      addSelectScreenBool = false;
    }
    if (addSceneBool) {
      addSelectSceneButton(scenes.size()-1);
      addSceneBool = false;
    }
  }

  void initializeButtons() {
    createAssignDisplayButtons();
    createScreenButtons();
    createSceneButtons();
    createMediaButtons();
  }

  void createAssignDisplayButtons() { //this is executed once when the program check external displays
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
            assignDisplay(b);
          }
        }
      }
      )
      ;
    }
  }

  void assignDisplay(Rectangle b) {
    if (screens.get(currentScreen).isAssigned == false) {
      for (Screen screen : screens) {
        if (screen.x == b.x) { //check if this screen is assigned to display in question
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

    screenRadio = cp5.addRadioButton("ScreenSelector")
      .setPosition(hx1+ 200, hy2-r-screenButtonsArea)
      .setSize(40, screenButtonsArea)
      .setColorActive(color(0, 200, 100))
      .setColorBackground(color(100))
      .setColorForeground(color(50))
      .setItemsPerRow(6)
      .setSpacingColumn(50);

    for (Screen screen : screens) {
      //mediaFiles.add(file.getName());
      addSelectScreenButton(screen.id);
    }
  }

  //void ScreenSelector(int theID) {
  //  println("Screen " + theID + " selected");
  //}

  void addSelectScreenButton(int index) {
    String optionName = "Screen " + index;
    screenRadio.addItem(optionName, index)
      .setSize(30, 20)
      .setColorActive(color(0, 150, 255))
      .setColorBackground(color(100))
      .setColorForeground(color(60));

    // Style the new radio button's label
    //screenRadio.getItem(optionName).getCaptionLabel().setColor(color(255)).setSize(14);
    Toggle t = screenRadio.getItem(optionName);
    t.addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent ev) {
        if (ev.getAction() == ControlP5.ACTION_RELEASE && t.getState()) {
          //println("Screen " + index + " " + t.getState());
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
          addNewScene();
        }
      }
    }
    );

    sceneRadio = cp5.addRadioButton("SceneSelector")
      .setPosition(r+200, mainHeight-4*r)
      .setSize(40, mainWidth-r-300)
      .setColorActive(color(0, 200, 100))
      .setColorBackground(color(100))
      .setColorForeground(color(50))
      .setItemsPerRow(20)
      .setSpacingColumn(50);

    for (Scene scene : scenes) {
      addSelectSceneButton(scene.id);
    }
  }

  void addSelectSceneButton(int index) {
    //println("Scene " + index);
    //int buttonHeight = 20;
    //int buttonWidth  = 30;
    //int buttonX = 80+index*buttonWidth*2;
    String optionName = "Scene " + index;
    sceneRadio.addItem(optionName, index)
      .setSize(30, 20)
      .setColorActive(color(0, 150, 255))
      .setColorBackground(color(100))
      .setColorForeground(color(60));

    // Style the new radio button's label
    //screenRadio.getItem(optionName).getCaptionLabel().setColor(color(255)).setSize(14);
    Toggle t = sceneRadio.getItem(optionName);
    t.addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent ev) {
        if (ev.getAction() == ControlP5.ACTION_RELEASE && t.getState()) {
          //println("Scene " + index + " selected");
          selectScene(index);
        }
      }
    }
    );
  }

  void selectScene(int index) {
    if (index >= 0 && index < scenes.size()) {
      currentScene = index;
      //println("Scene " + index + " selected");
      for (Scene scene : scenes) {
        scene.deactivate();
      }
      scenes.get(currentScene).activate();
      for (Screen screen : screens) {
        screen.currentScene = currentScene;
      }
    }
  }

  void createMediaButtons() {
    mediaList = cp5.addGroup("Media List")
      .setPosition(r, hy1+r)
      .setBackgroundHeight(hy2-hy1-2*r)
      .disableCollapse()
      ;

    for (int i = 0; i< mediaFiles.size(); i++) {
      String name = mediaFiles.get(i);
      //println("Creating button: " + name);
      int buttonHeight = 20;
      int buttonWidth  = hx1-2*r;
      int buttonY = i*buttonHeight;
      cp5.addButton(name)
        .setPosition(0, buttonY)
        .setSize(buttonWidth, buttonHeight)
        .setCaptionLabel(name)
        .setGroup(mediaList)
        .addCallback(new CallbackListener() {
        public void controlEvent(CallbackEvent event) {
          if (event.getAction() == ControlP5.ACTION_RELEASE) {
            addMedia(name);
          }
        }
      }
      );
    }
  }


  void render(int mousex, int mousey) {
    drawUI();
    updateCP5();
    scenes.get(currentScene).render();
    for (Screen screen : screens) {
      screen.render(mousex, mousey);
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

  void updatePreviewArea() {
    // Calculate scale to fit
    float scale = min(
      previewAreaWidth / screens.get(currentScreen).w,
      previewAreaHeight / screens.get(currentScreen).h
      );

    previewWidth = screens.get(currentScreen).w * scale;
    previewHeight = screens.get(currentScreen).h * scale;

    // Center in preview area
    previewX = previewAreaX + (previewAreaWidth - previewWidth)/2;
    previewY = previewAreaY + (previewAreaHeight - previewHeight)/2;
  }


  void drawStagePanel(int index) {
    // 1. Draw panel background
    drawPanel(hx1, hy1, hx2, hy2, canvaUI);


    // 3. Draw preview content
    if (index >= 0 && index < screens.size()) {
      Screen screen = screens.get(index);
      updatePreviewArea();
      screens.get(currentScreen).setPreviewArea(previewX, previewY, previewWidth, previewHeight);
      // Draw (with border)
      canvaUI.fill(0);
      canvaUI.rect(previewX-2, previewY-2, previewWidth+4, previewHeight+4);
      canvaUI.image(screen.getScreen(), previewX, previewY, previewWidth, previewHeight);
      canvaUI.fill(200, 100);
      canvaUI.textSize(48);
      canvaUI.textAlign(CENTER, CENTER);
      canvaUI.text(index, (hx2 + hx1)/2, (hy1 +hy2)/2);
      //canvaUI.text(previewAreaWidth, (hx2 + hx1)/2, (hy1 +hy2)/2);
    }

    // 4. Draw UI elements on top
    canvaUI.fill(200);
    canvaUI.textSize(16);
    canvaUI.textAlign(LEFT, TOP);
    canvaUI.text("Stage Preview", hx1 + 20, hy1 + 15);
  }

  public void moveHoverPoint(float mousex, float mousey) {
    for (Screen screen : screens) {
      screen.moveHoverPoint(mousex, mousey);
    }
  }

  void keyReleased(char k, int kc) {
    if (k == 'c') scenes.get(currentScene).toggleCalibration();
  }
}
