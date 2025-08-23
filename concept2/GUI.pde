class Button {
  float x, y, w, h;
  String label;     // Text label
  boolean isPressed = false;
  boolean isHovered = false;
  color defaultColor, hoverColor, pressedColor, textColor;
  Project project;
  
  Button(Project project_, float x_, float y_, float w_, float h_, String label_) {
    project = project_;
    x = x_;
    y = y_;
    w = w_;
    h = h_;
    label = label_;
    // Default colors (can be overridden)
    defaultColor = color(180);
    hoverColor = color(140);
    pressedColor = color(100);
    textColor = color(0);
  }

  void update(int mx, int my) {
    isHovered = mx > x && mx < x + w && my > y && my < y + h;
  }

  // Display the button
  void display() {
    // Draw button rectangle
    if (isPressed) {
      fill(pressedColor);
    } else if (isHovered) {
      fill(hoverColor);
    } else {
      fill(defaultColor);
    }

    rect(x, y, w, h, 5); // The last parameter adds rounded corners

    // Draw button text
    fill(textColor);
    textAlign(CENTER, CENTER);
    textSize(16);
    text(label, x + w/2, y + h/2);
  }

  
  // Regular display
    void display(PGraphics pg) {
        display(pg, defaultColor);
    }
    
    // Display with custom background color
    void display(PGraphics pg, color bgColor) {
        pg.pushStyle();
        
        // Background with custom color
        pg.fill(isPressed ? pressedColor : (isHovered ? hoverColor : bgColor));
        pg.rect(x, y, w, h, 3);
        
        // Text
        pg.fill(textColor);
        pg.textAlign(CENTER, CENTER);
        pg.textSize(14);
        pg.text(label, x + w/2, y + h/2);
        
        // Add small indicator for assigned screens
        //if (project.screens.get(screenIndex).isAssigned) {
        //    pg.fill(100, 255, 100);
        //    pg.ellipse(x + w - 8, y + 8, 6, 6);
        //}
        
        pg.popStyle();
    }

  void checkPress(int mx, int my) {
    update(mx, my);
    if (isHovered) {
      isPressed = true;
      onPress();
    }
  }

  void checkRelease(int mx, int my) {
    boolean wasPressed = isPressed;
    update(mx, my);
    isPressed = false;
    if (wasPressed && isHovered) {
      onRelease();
    }
  }

  void onPress() {
  } // To be overridden
  void onRelease() {
  } // To be overridden
}

class ScreenButton extends Button {
  int screenIndex;

  ScreenButton(Project project, float x, float y, float w, float h, String label, int index) {
    super(project,x, y, w, h, label);
    this.screenIndex = index;
    // Custom colors for screen buttons
    defaultColor = color(60);
    hoverColor = color(80);
    pressedColor = color(100);
    textColor = color(220);
  }

  void onPress() {
    println("Selected screen " + screenIndex);
    // This will be handled by Project class
  }

  void onRelease() {
    // Additional behavior if needed
  }
}

class AddScreenButton extends Button {
  AddScreenButton(Project project,float x, float y, float w, float h) {
    super(project,x, y, w, h, "+ Add Screen");
    // Custom colors
    defaultColor = color(80, 120, 200);
    hoverColor = color(60, 100, 180);
    pressedColor = color(40, 80, 160);
    textColor = color(255);
  }

  //void onPress() {
  //  println("Add screen requested");
  //}
  void onPress() {
    if (project != null) {
      project.addNewScreen();
      project.createScreenButtons();
    }
  }
  
}

class MediaButton extends Button {
  String filename;
  boolean isSelected;
  
  MediaButton(Project project, float x, float y, float w, float h, String filename) {
    super(project,x, y, w, h, shortenFilename(filename, w - 20));
    this.filename = filename;
    
    // Custom colors for media buttons
    defaultColor = color(60);
    hoverColor = color(80);
    pressedColor = color(100);
    textColor = color(220);
    isSelected = false;
  }
  
  void display(PGraphics pg) {
    pg.pushStyle();
    
    // Background - show selection state
    if (isSelected) {
      pg.fill(100, 150, 255);
    } else {
      pg.fill(isPressed ? pressedColor : (isHovered ? hoverColor : defaultColor));
    }
    pg.rect(x, y, w, h, 3);
    
    // File icon
    pg.fill(textColor);
    pg.textAlign(LEFT, CENTER);
    pg.textSize(12);
    pg.text(label, x + 25, y + h/2);
    
    // File type icon
    drawFileIcon(pg, filename);
    
    pg.popStyle();
  }
  
  void drawFileIcon(PGraphics pg, String filename) {
    pg.pushStyle();
    pg.noStroke();
    
    if (filename.toLowerCase().matches(".*\\.(mp4|mov|avi)$")) {
      // Video file icon
      pg.fill(255, 80, 80);
      pg.rect(x + 5, y + 5, 15, h - 10, 2);
      pg.fill(255);
      pg.triangle(x + 8, y + 8, x + 8, y + h - 8, x + 17, y + h/2);
    } 
    else if (filename.toLowerCase().matches(".*\\.(png|jpg|jpeg|gif)$")) {
      // Image file icon
      pg.fill(80, 180, 80);
      pg.rect(x + 5, y + 5, 15, h - 10, 2);
      pg.fill(255);
      pg.rect(x + 8, y + 8, 9, 4);
      pg.rect(x + 8, y + 14, 9, 4);
    }
    
    pg.popStyle();
  }
  
  void onPress() {
    // Toggle selection state
    isSelected = !isSelected;
    println("Selected media: " + filename);
  }
  
  void onRelease() {
    // Add any additional behavior
  }
}

// Helper function to shorten long filenames
String shortenFilename(String name, float maxWidth) {
  if (textWidth(name) <= maxWidth) return name;
  
  String shortened = name;
  while (textWidth(shortened + "...") > maxWidth && shortened.length() > 3) {
    shortened = shortened.substring(0, shortened.length() - 1);
  }
  return shortened + "...";
}
