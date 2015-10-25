public class Matrix {
  private int x,y;
  private int channel,chain;
  public Matrix(int x, int y, int chain, int channel) {
    this.x = x;
    this.y = y;
    this.channel = channel;
    this.chain = chain;
  }
  public int getChain() {
    return chain;
  }
  public int getChannel() {
    return channel;
  }
  public int getX() {
    return x;
  }
  public int getY() {
    return y;
  }
  public void setX(int x) {
    this.x = x;
  }
  public void setY(int y) {
    this.y = y;
  }
}