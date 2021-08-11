class Chord {
  float ax, ay;
  float bx, by;
  color myc;
  
  boolean ahot = false;
  boolean bhot = false;
  
  Chord(float _ax, float _ay, float _bx, float _by) {
    ax = _ax;
    ay = _ay;
    bx = _bx;
    by = _by;
    myc = color(255,16);
    
    topSort();
  }
  
  void topSort() {
    // move point A before B (top down A->B)
    if (by<ay) {
      float tempx = bx;
      float tempy = by;
      bx = ax;
      by = ay;
      ax = tempx;
      ay = tempy;
    }
  }
  
  void render() {
    noFill();
    stroke(myc);
    line(ax,ay,bx,by);
    if (ahot) {
      stroke(255);
      point(ax,ay);
    }
    if (bhot) {
      stroke(255);
      point(bx,by);
    }
      
    //renderDot();
    //if (random(1.0)<.05) renderShadow();
  }
  
  void renderShadow() {
    fill(0,32);
    noStroke();
    beginShape();
    vertex(ax,ay);
    vertex(bx,by);
    float cx = (ax+bx)/2;
    float cy = (ay+by)/2;
    float theta = atan2(by-ay,bx-ax) + HALF_PI;
    cx += 50*cos(theta);
    cy += 50*sin(theta);
    vertex(cx,cy);
    endShape(CLOSE);
    
  }
  
  void renderDot() {
    float t = random(1.0);
    float tx = ax + t*(bx-ax);
    float ty = ay + t*(by-ay);
    fill(255,192);
    noStroke();
    ellipse(tx,ty,5,5);
  }
  
  void fuzz(float f) {
    ax+=random(-f,f);
    ay+=random(-f,f);
    bx+=random(-f,f);
    by+=random(-f,f);
  }
  
  void truncate(float t0, float t1) {
    // clip a segment out of the chord
    if (t0>t1) return;
    
    // t0 0..1.0
    // t1 0..1.0
    
    float nax = ax + t0*(bx-ax);
    float nay = ay + t0*(by-ay);
    float nbx = ax + t1*(bx-ax);
    float nby = ay + t1*(by-ay);

    ax = nax;
    ay = nay;
    bx = nbx;
    by = nby;
    
  }
}
