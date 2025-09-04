class Scene {
  int id;
  ArrayList<MediaItem> mediaItems = new ArrayList<MediaItem>();
  XML sceneXML;
  boolean isActive = false;

  Scene(int id) {
    this.id = id;
    sceneXML = new XML("Scene");
    sceneXML.setInt("id", id);
  }

  Scene(XML scene) {
    id = scene.getInt("id");
    sceneXML = scene;
  }

  void render() {
    if (isActive) {
      for (MediaItem media : mediaItems) {
        media.render();
      }
    }
  }

  void addMedia(MediaItem newMedia) {
    mediaItems.add(newMedia);
    println("new Media added successfully");
  }

  public void toggleCalibration() {
    for (MediaItem media : mediaItems) {
      media.toggleCalibration();
    }
  }
  
  public void deactivate() {
    for (MediaItem media : mediaItems) {
      media.stopMedia();
    }
    isActive = false;
  }
  
  public void activate() {
    for (MediaItem media : mediaItems) {
      media.playMedia();
    }
    isActive = true;
  }

  public void toggleActivsation() {
    isActive = !isActive;
    if (isActive) {
      for (MediaItem media : mediaItems) {
        media.playMedia();
      }
    } else {
      for (MediaItem media : mediaItems) {
        media.stopMedia();
      }
    }
  }
}
