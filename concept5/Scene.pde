class Scene {
  int id;
  ArrayList<MediaItem> mediaItems = new ArrayList<MediaItem>();
  XML sceneXML;
  
  Scene(int id) {
    this.id = id;
    sceneXML = new XML("Scene");
    sceneXML.setInt("id", id);
  }
  
  Scene(XML scene) {
    id = scene.getInt("id");
    sceneXML = scene;
  }
  
  void render(){
    
  }
  
}
