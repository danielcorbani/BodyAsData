import paletai.mapping.*;

Project project;

void setup() {
  fullScreen(P2D,SPAN);
  project = new Project("NewProject");
}

void draw() {
  background(0);
  project.render(mouseX,mouseY);
  
}

//void mouseDragged() {
//  project.mousedragged(mouseX, mouseY);
//}

void mouseReleased() {
  project.mousereleased(mouseX, mouseY);
}

void mousePressed(){
  project.mousepressed(mouseX, mouseY);
}
//void keyPressed() {
//  project.keypressed();
//}
