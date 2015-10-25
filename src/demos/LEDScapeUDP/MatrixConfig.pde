public class MatrixConfig {
  private int width, height;
  private boolean originalConfig = true;
  private ArrayList<Matrix> matrices = new ArrayList<Matrix>();
  public MatrixConfig() {
    for (int y = 0; y < 8; y++) {
      for (int x = 0; x < 8; x++) {
       matrices.add(new Matrix(224-x*32, y*16, 7-x, y));
       //println(y+","+(7-x)+" N "+(x*32)+","+(y*16));
      }
    }
    calculateSize();
  }
  public int getX(int matrix) {
    return matrices.get(matrix).getX();
  }
  public int getX(int channel, int chain) {
    return getX(channel*8+7-chain);
  }
  public int getY(int matrix) {
    return matrices.get(matrix).getY();
  }
  public int getY(int channel, int chain) {
    return getY(channel*8+7-chain);
  }
  public int getChain(int matrix) {
    return matrices.get(matrix).getChain();
  }
  public int getChannel(int matrix) {
    return matrices.get(matrix).getChannel();
  }
  public void setX(int matrix, int x) {
    if (x >= 0) {
      matrices.get(matrix).setX(x);
    } else {
      matrices.get(matrix).setX(0);
      for (int i=0; i<64; i++) {
        setX(i, getX(i)+abs(x));
      }
    }
    calculateSize();
  }
  public void setX(int channel, int chain, int x) {
    setX(channel*8+7-chain, x);
  }
  public void setY(int matrix, int y) {
    if (y >= 0) {
      matrices.get(matrix).setY(y);
    } else {
      matrices.get(matrix).setY(y);
      for (int i=0; i<64; i++) {
        setY(i, getY(i)+abs(y));
      }
    }
    calculateSize();
  }
  public void setY(int channel, int chain, int y) {
    setY(channel*8+7-chain, y);
  }
  public int getWidth() {
    return width;
  }
  public int getHeight() {
    return height;
  }
  private void calculateSize() {
    this.originalConfig = true;
    width = 0;
    height = 0;
    for (int i = 0; i < 64; i++) {
      int x = getX(i);
      int y = getY(i);
      if (x != 224-i%8*32 | y != i/8*16)
        this.originalConfig = false;
      width = max(width, x+32);
      height = max(height, y+16);
    }
  }
  public String toString() {
    String s = "";
    for (int i = 0; i < 64; i++) {
      s += getChannel(i) + "," + getChain(i) + " N " + getX(i) + "," +getY(i) + '\n';
    }
    return s;
  }
  /**
   * Standard is to resize without black bars.
   */
  PImage resizeImage(PImage pi) {
    return resizeImage(pi,0);
  }
  /**
   * resize the image to fit screen
   * mode could be either 0 (fit outline) or 1 (fit inline)
   */
  PImage resizeImage(PImage pi, int mode) {
    if (pi.width == width && pi.height == height)
      return pi; //no resize needed
    PImage tmp = new PImage(width,height);
    //Image wider than screen
    if (mode == 1) {
      double w_ratio = width/(double)pi.width;
      double h_ratio = height/(double)pi.height;
      double ratio = (w_ratio<h_ratio)?w_ratio:h_ratio;
      int n_w = (int)(pi.width*ratio);
      int n_h = (int)(pi.height*ratio);
      tmp.copy(pi, 0, 0, pi.width, pi.height, (width-n_w)/2, (height-n_h)/2, n_w, n_h);
    } else {
      double w_ratio = pi.width/(double)width;
      double h_ratio = pi.height/(double)height;
      double ratio = (w_ratio<h_ratio)?w_ratio:h_ratio;
      int n_w = (int)(width*ratio);
      int n_h = (int)(height*ratio);
      tmp.copy(pi, (pi.width-n_w)/2, (pi.height-n_h)/2, n_w, n_h, 0, 0, width, height);
    }
    return tmp;
  }
  
  PImage reconfigurePanels(PImage pi) {
    if (pi.width != width || pi.height != height) {
      pi = resizeImage(pi);
    }
    if (originalConfig) return pi;
    PImage tmp = new PImage(256,128);
    for (int i = 0; i < 64; i++) {
      tmp.copy(pi, getX(i), getY(i), 32, 16, getChain(i)*32, getChannel(i)*16, 32, 16);
    }
    return tmp;
  }
}