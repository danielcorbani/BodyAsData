//import paletai.mapping.*;

Project project;

void setup() {
  fullScreen(P2D, SPAN); //Always
  project = new Project(this, "NewProject");
}

void draw() {
  background(0);
  project.render(mouseX,mouseY);
}


void keyReleased() {
  project.keyreleased(key, keyCode);  // call method on the instance
}

void mouseDragged() {
  project.moveHoverPoint(mouseX, mouseY);  // Move hovered point while dragging
}
