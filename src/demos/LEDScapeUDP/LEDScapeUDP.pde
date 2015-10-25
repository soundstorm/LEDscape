import controlP5.*;
import processing.video.*;

int scale = 2;
MatrixUDPClient matrix;
PImage pi;
MatrixConfig config = new MatrixConfig();
//ScreenCapturer capturer;
import processing.opengl.*;
PImage heart[] = new PImage[60];
PImage names[] = new PImage[5];
PImage movieImg;
Movie movie;
int activeMovie;

PImage screenShot;
int name = 0;
boolean demo = true;

void setup() {
  frameRate(24);
  matrix = new MatrixUDPClient("videowall.local");
  if (!matrix.connect() && !demo) {
    println("not connected");
    //exit();
  }
  pi = new PImage(config.getWidth(),config.getHeight(),RGB);
  size(config.getWidth()*scale+10,config.getHeight()*scale+50);
  movie = new Movie(this,dataPath("test.mp4"));
  movie.play();
}

void draw() {
  background(color(255,255,255));
  if (movie.available()) {
    movie.read();
    movieImg = resizeImage(movie,0,256,112);
    pi.copy(movieImg,0,16,movieImg.width,movieImg.height,0,64,movieImg.width,movieImg.height);
  }
  image(matrix.sendImage(config.reconfigurePanels(pi)), 5, 45);
}


/**
 * Standard is to resize without black bars.
 */
PImage resizeImage(PImage pi) {
  return resizeImage(pi, 0, config.getWidth(), config.getHeight());
}
/**
 * resize the image to fit screen
 * mode could be eiter 0 (fit outline) or 1 (fit inline)
 */
PImage resizeImage(PImage pi, int mode, int w, int h) {
  if (pi.width == w && pi.height == h)
    return pi; //no resize needed
  PImage tmp = new PImage(w,h);
  //Image wider than screen
  if (mode == 1) {
    double w_ratio = h/(double)pi.width;
    double h_ratio = h/(double)pi.height;
    double ratio = (w_ratio<h_ratio)?w_ratio:h_ratio;
    int n_w = (int)(pi.width*ratio);
    int n_h = (int)(pi.height*ratio);
    tmp.copy(pi, 0, 0, pi.width, pi.height, (w-n_w)/2, (h-n_h)/2, n_w, n_h);
  } else {
    double w_ratio = pi.width/(double)w;
    double h_ratio = pi.height/(double)h;
    double ratio = (w_ratio<h_ratio)?w_ratio:h_ratio;
    int n_w = (int)(w*ratio);
    int n_h = (int)(w*ratio);
    tmp.copy(pi, (pi.width-n_w)/2, (pi.height-n_h)/2, n_w, n_h, 0, 0, w, h);
  }
  return tmp;
}

/**
 * scale image pixel per pixel
 */
public PImage scaleImage(PImage pi, int factor) {
  PImage tmp = createImage(pi.width * factor, pi.height * factor, RGB);
  for (int i=0; i < pi.width; i++) {
    for (int j=0; j < pi.height; j++) {
      for (int k=0; k<factor; k++) {
        for (int l=0; l<factor; l++) {
          tmp.set(i*factor+k,j*factor+l,pi.get(i,j));
        }
      }
    }
  }
  return tmp;
}


import java.awt.image.BufferedImage;
import java.awt.*;
PImage getScreen() {
  GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
  GraphicsDevice[] gs = ge.getScreenDevices();
  DisplayMode mode = gs[0].getDisplayMode();
  Rectangle bounds = new Rectangle(0, 0, 256, 112);
  BufferedImage desktop = new BufferedImage((int)bounds.getWidth(),(int)bounds.getHeight(), BufferedImage.TYPE_INT_RGB);

  try {
    desktop = new Robot(gs[0]).createScreenCapture(bounds);
  }
  catch(AWTException e) {
    System.err.println("Screen capture failed.");
  }

  return (new PImage(desktop));
}