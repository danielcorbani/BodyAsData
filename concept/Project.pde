class Project {
  private String name;
  private ArrayList<Screen> screens;

  Project(String projectName) {
    this.name = projectName;
    this.screens = new ArrayList<Screen>();

    // Try to load existing project
    if (!loadFromFile()) {
      // Create new project with one screen if file doesn't exist
      screens.add(new Screen(1));
      println("Created new project: " + name);
    }
  }

  boolean loadFromFile() {
    String filename = "data/" + name + ".xml";
    File file = new File(sketchPath(filename));

    if (file.exists()) {
      try {
        XML xml = loadXML(filename);
        this.name = xml.getString("name");
        screens.clear();

        XML[] screenXMLs = xml.getChildren("Screen");
        for (XML screenXML : screenXMLs) {
          screens.add(new Screen(screenXML.getInt("id"), screenXML));
        }

        println("Loaded existing project: " + name);
        return true;
      }
      catch (Exception e) {
        println("Error loading project: " + e);
      }
    }
    return false;
  }

  void saveToFile() {
    XML xml = new XML("Project");
    xml.setString("name", name);

    for (Screen screen : screens) {
      xml.addChild(screen.toXML());
    }

    saveXML(xml, "data/" + name + ".xml");
    println("Project saved: " + name);
  }

  void addSceneToCurrentScreen() {
    if (!screens.isEmpty()) {
      Screen currentScreen = screens.get(0); // Using first screen only for now
      int newSceneId = currentScreen.scenes.size() + 1;
      currentScreen.scenes.add(new Scene(newSceneId));
    }
  }

  void addMediaToLastScene() {
    if (!screens.isEmpty()) {
      Screen currentScreen = screens.get(0);
      if (!currentScreen.scenes.isEmpty()) {
        Scene lastScene = currentScreen.scenes.get(currentScreen.scenes.size()-1);
        int mediaType = (int)random(3); // 0=image, 1=video, 2=audio
        lastScene.addMediaItem(new MediaItem(mediaType));
      }
    }
  }

  void show() {
    float y = 30;
    text("Project: " + name, 20, y);
    y += 20;

    if (!screens.isEmpty()) {
      screens.get(0).show(20, y); // Show first screen only for now
    }
  }

  void mousedragged(int x, int y) {
    
  }
}
