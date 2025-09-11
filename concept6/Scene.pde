class Scene {
  int id;
  public ArrayList<MediaItem> mediaItems = new ArrayList<MediaItem>();
  public XML sceneXML;
  boolean isActive;
  int currentMediaCalibration = -1;

  Scene(int id) {
    this.id = id;
    sceneXML = new XML("Scene");
    sceneXML.setInt("id", id);
    sceneXML.addChild("Medias");
    isActive = false;
  }

  Scene(XML scene) {
    id = scene.getInt("id");
    sceneXML = scene;
    isActive = false;
    //XML mediasParent = sceneXML.getChild("Medias");
    //XML[] mediasXML = mediasParent.getChildren("MediaItem");
    //for (XML mediaXML : mediasXML) {
    //  try {
    //    MediaItem newMedia = new MediaItem(mainApplet,
    //      mediaXML.getString("name"),
    //      id,
    //      mediaXML.getInt("Screen"),
    //      mediaXML.getInt("id"));
    //    newMedia.assignToDisplay(screens.get(mediaXML.getInt("Screen")).w,
    //      screens.get(mediaXML.getInt("Screen")).h,
    //      mediaXML.getInt("Screen"));
    //    //newMedia.fromXML(mediaXML);
    //    addMedia(newMedia);
    //    println("added " + mediaXML.getString("name") + "to Scene " + id + "and Screen " + newMedia.assignedScreen);
    //  }
    //  catch (Exception e) {
    //    println("Error loading media: " + e);
    //  }
    //}
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
    if (currentMediaCalibration <0) currentMediaCalibration = 0;
    if (!newMedia.fromxml) {
      XML mediasXML = sceneXML.getChild("Medias");
      mediasXML.addChild(newMedia.mediaXML);
      //println("new Media added successfully");
    }
  }

  void updateXML() {
    XML mediasParent = sceneXML.getChild("Medias");
    XML[] mediasXML = mediasParent.getChildren("MediaItem");
    for (XML mediaXML : mediasXML) {
      int i = mediaXML.getInt("id");
      for (MediaItem media : mediaItems) {
        if (media.mediaId == i) {
          mediasParent.removeChild(mediaXML);
          mediasParent.addChild(media.mediaXML);
        }
      }
    }
    //println("Scene XML updated?");
  }

  public void toggleCalibration() {
    //for (MediaItem media : mediaItems) {
    //  media.toggleCalibration();
    //}
    mediaItems.get(currentMediaCalibration).toggleCalibration();
    println("currentMediaCalibration: " + currentMediaCalibration);
  }

  public void changeMediaToCalibrate() {
    if (mediaItems.get(currentMediaCalibration).calibrate) {
      mediaItems.get(currentMediaCalibration).offCalibration();
      currentMediaCalibration = (currentMediaCalibration+1)%mediaItems.size();
      mediaItems.get(currentMediaCalibration).onCalibration();
    }
  }

  public void deactivate() {
    for (MediaItem media : mediaItems) {
      media.stopMedia();
      media.offCalibration();
    }
    isActive = false;
  }

  public void activate() {
    for (MediaItem media : mediaItems) {
      media.playMedia();
    }
    isActive = true;
  }

  public void toggleActivation() {
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
