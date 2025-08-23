class Screen {
  int id;
  ArrayList<Scene> scenes;
  
  Screen(int id) {
    this(id, null);
  }
  
  Screen(int id, XML xml) {
    this.id = id;
    this.scenes = new ArrayList<Scene>();
    
    if (xml != null) {
      XML[] sceneXMLs = xml.getChildren("Scene");
      for (XML sceneXML : sceneXMLs) {
        scenes.add(new Scene(sceneXML.getInt("id"), sceneXML));
      }
    }
  }
  
  XML toXML() {
    XML xml = new XML("Screen");
    xml.setInt("id", id);
    
    for (Scene scene : scenes) {
      xml.addChild(scene.toXML());
    }
    
    return xml;
  }
  
  void show(float x, float y) {
    text("Screen " + id, x, y);
    y += 15;
    
    for (Scene scene : scenes) {
      scene.show(x + 20, y);
      y += 15 * (scene.mediaItems.size() + 2); // Adjust vertical spacing
    }
  }
}
