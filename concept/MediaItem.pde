class MediaItem {
  String type;
  String path;
  
  MediaItem(int mediaType) {
    this.type = new String[] {"image", "video", "audio"}[mediaType];
    this.path = "media/" + type + "_" + (int)random(1000) + 
               (type.equals("image") ? ".jpg" : 
                type.equals("video") ? ".mp4" : ".mp3");
  }
  
  MediaItem(XML xml) {
    this.type = xml.getString("type");
    this.path = xml.getString("path");
  }
  
  XML toXML() {
    XML xml = new XML("MediaItem");
    xml.setString("type", type);
    xml.setString("path", path);
    return xml;
  }
}
