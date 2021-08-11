class Node {
  float x, y;
  float w;
  float rad;
  float theta;
  color myc;
  
  ArrayList<Node> connections = new ArrayList<Node>();
  
  Node(float _x, float _y, float _w, float _rad, float _theta, color _myc) {
    x = _x;
    y = _y;
    w = _w;
    rad = _rad;
    theta = _theta;
    myc = _myc;
    
  }
  
  void renderConnections(int interval) {
    // draw connections to other stations
    stroke(myc,22);
    for (int i=0;i<connections.size();i+=interval) {
      Node b = connections.get(i);
      line(x,y,b.x,b.y);
    }
  }
 
}
