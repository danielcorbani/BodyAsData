import paletai.*;

Project project;

void setup() {
  fullScreen(P2D,SPAN);
  project = new Project("MyProject");
}

void draw() {
  project.show();
  
}

void mouseDragged() {
  project.mousedragged(mouseX, mouseY);
}
