//class MediaItem {
//  int id;
//  String name;
//  String filePath;
//  PVector[] corners = new PVector[4];
  
//  MediaItem(String name, String path, int id) {
//    this.name = name;
//    this.filePath = path;
//    this.id = id;
    
//    // Default corners (normalized coordinates)
//    corners[0] = new PVector(0, 0);
//    corners[1] = new PVector(1, 0);
//    corners[2] = new PVector(1, 1);
//    corners[3] = new PVector(0, 1);
//  }
  
//  MediaItem(XML xml) {
//    parseConfig(xml);
//  }
  
//  void parseConfig(XML xml) {
//    id = xml.getInt("id");
//    name = xml.getString("name", "Media " + id);
//    filePath = xml.getString("path", "");
    
//    // Parse corners if available
//    XML cornersNode = xml.getChild("corners");
//    if (cornersNode != null) {
//      for (int i = 0; i < 4; i++) {
//        XML cornerNode = cornersNode.getChild("corner" + i);
//        if (cornerNode != null) {
//          corners[i] = new PVector(cornerNode.getFloat("x"), cornerNode.getFloat("y"));
//        }
//      }
//    }
//  }
  
//  XML toXML() {
//    XML xml = new XML("media");
//    xml.setInt("id", id);
//    xml.setString("name", name);
//    xml.setString("path", filePath);
    
//    // Add corners
//    XML cornersNode = xml.addChild("corners");
//    for (int i = 0; i < 4; i++) {
//      XML cornerNode = cornersNode.addChild("corner" + i);
//      cornerNode.setFloat("x", corners[i].x);
//      cornerNode.setFloat("y", corners[i].y);
//    }
    
//    return xml;
//  }
//}
