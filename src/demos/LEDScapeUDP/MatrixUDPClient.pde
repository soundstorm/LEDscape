public class MatrixUDPClient {
  private int width, height;
  private static final int packets = 2;
  private java.net.DatagramSocket udpSocket;
  private byte pixels[];
  private String ip;
  private int port;
  private int[] gammaTable = new int[256];

  public MatrixUDPClient(String ip) {
    this(ip, 9999);
  }
  public MatrixUDPClient(String ip, int port) {
    this(ip, port, 256, 128);
  }
  public MatrixUDPClient(String ip, int width, int height) {
    this(ip, 9999, width, height);
  }
  public MatrixUDPClient(String ip, int port, int width, int height) {
    this(ip, port, width, height, 0.7);
  }
  public MatrixUDPClient(String ip, int port, int width, int height, float gamma) {
    this.width = width;
    this.height = height;
    this.ip = ip;
    this.port = port;
    pixels = new byte[this.width*this.height*3+1];
    buildGammaTable(gamma);
  }
  public boolean connect() {
    this.udpSocket = connectUDP(ip, port);
    if (udpSocket == null) return false;
    return udpSocket.isConnected();
  }
  public boolean connected() {
    return this.udpSocket != null && this.udpSocket.isConnected();
  }

  public int getWidth() {
    return this.width;
  }

  public int getHeight() {
    return this.height;
  }
  
  public void setGamma(float gamma) {
    buildGammaTable(gamma);
  }

  private synchronized void buildGammaTable(float gamma) {
    float ginv = 1 / gamma;
    double colors = 255.0; //COLORS;
    for (int i = 0; i < gammaTable.length; i++) {
      gammaTable[i] = (int) Math.round(colors * Math.pow(i / colors, ginv));
    }
    int col = 0xFFAACC;
    int p[] = new int[3];
    p[0] = (gammaTable[(col>>16)&0xFF]);
    p[1] = (gammaTable[(col>>8)&0xFF]);
    p[2] = (gammaTable[col&0xFF]);
    println(col);
    println((int)p[0]);
    println((int)p[1]);
    println((int)p[2]);
    println((((int)p[0] << 8) | (int)p[1]) << 8 | p[2]);
  }

  public synchronized PImage sendImage(PImage pi) {
    PImage p = pi;
    if (pi.width != this.width | pi.height != this.height) {
      println("Image size does not match size of videowall.");
      return p;
    }
    pi.loadPixels();
    int[] rgb = new int[3];
    for (int i = 0; i < this.width*this.height; i++) {
      rgb[0] = gammaTable[(pi.pixels[i] >> 16) & 0xFF];
      rgb[1] = gammaTable[(pi.pixels[i] >> 8) & 0xFF];
      rgb[2] = gammaTable[pi.pixels[i] & 0xFF];
      pixels[i*3+1] = (byte)rgb[0];
      pixels[i*3+2] = (byte)rgb[1];
      pixels[i*3+3] = (byte)rgb[2];
      p.pixels[i] = ((rgb[0] << 8) | rgb[1]) << 8 | rgb[2];
    }
    if (!connected()) {
      //println("UDP Socket is not connected to server."+udpSocket);
      return p;
    }
    for (int packet = 0; packet < packets; packet++) {
      byte dataPacket[] = java.util.Arrays.copyOfRange(pixels, this.width*(this.height/this.packets)*packet*3, 
      this.width*(this.height/this.packets*(packet+1))*3+1);
      dataPacket[0] = (byte) packet;
      try {
        this.udpSocket.send(new java.net.DatagramPacket(dataPacket, dataPacket.length));
      } 
      catch (java.io.IOException e) {
        // println("Length: "+dp.getLength());
        //e.printStackTrace();
      }
    }
    return p;
  }

  java.net.DatagramSocket connectUDP(String ip, int port) {
    java.net.InetAddress IPAddress;
    try {
      IPAddress = java.net.InetAddress.getByName(ip);
      System.out.println("Connecting to "+IPAddress.getHostAddress());
    } 
    catch (java.net.UnknownHostException e) {
      System.out.println("Could not resolve Host.");
      return null;
    }
    try {
      java.net.DatagramSocket socket = new java.net.DatagramSocket();
      socket.connect(IPAddress, port);
      socket.setSendBufferSize(1+this.width*(this.height/packets)*3);
      if (socket.isConnected())
        System.out.println("Connected to UDP Port "+port+".");
      return socket;
    } 
    catch (java.net.SocketException e) {
      e.printStackTrace();
      return null;
    }
  }
}