class Scene {
  int id;
  String name;
  ArrayList<MediaItem> mediaItems = new ArrayList<MediaItem>();
  
  Scene(String name, int id) {
    this.name = name;
    this.id = id;
    mediaItems.add(new MediaItem("Placeholder", "none", 0));
  }
  
  Scene(XML xml) {
    parseConfig(xml);
  }
  
  void parseConfig(XML xml) {
    id = xml.getInt("id");
    name = xml.getString("name", "Scene " + id);
    
    // Parse media items
    mediaItems.clear();
    XML[] mediaNodes = xml.getChildren("media");
    for (XML mediaNode : mediaNodes) {
      mediaItems.add(new MediaItem(mediaNode));
    }
  }
  
  XML toXML() {
    XML xml = new XML("scene");
    xml.setInt("id", id);
    xml.setString("name", name);
    
    // Add media items
    for (MediaItem media : mediaItems) {
      xml.addChild(media.toXML());
    }
    
    return xml;
  }
}
