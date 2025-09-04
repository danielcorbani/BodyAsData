import paletai.mapping.*;

Project project;

void setup() {
  fullScreen(P2D, SPAN); //Always
  project = new Project(this, "NewProject");
}

void draw() {
  background(0);
  project.render();
}
