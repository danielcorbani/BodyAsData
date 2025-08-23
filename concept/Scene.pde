class Scene {
  int id;
  ArrayList<MediaItem> mediaItems;
  
  Scene(int id) {
    this(id, null);
  }
  
  Scene(int id, XML xml) {
    this.id = id;
    this.mediaItems = new ArrayList<MediaItem>();
    
    if (xml != null) {
      XML[] mediaXMLs = xml.getChildren("MediaItem");
      for (XML mediaXML : mediaXMLs) {
        mediaItems.add(new MediaItem(mediaXML));
      }
    }
  }
  
  void addMediaItem(MediaItem item) {
    mediaItems.add(item);
  }
  
  XML toXML() {
    XML xml = new XML("Scene");
    xml.setInt("id", id);
    
    for (MediaItem item : mediaItems) {
      xml.addChild(item.toXML());
    }
    
    return xml;
  }
  
  void show(float x, float y) {
    text("- Scene " + id + " (" + mediaItems.size() + " media items)", x, y);
    y += 15;
    
    for (MediaItem item : mediaItems) {
      text("  - " + item.type + ": " + item.path, x, y);
      y += 15;
    }
  }
}
