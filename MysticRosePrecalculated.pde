// Mystic Rose
//   Jared S Tarbell
//   April 19, 2021
//   Levitated
//   Albuquerque, New Mexico USA

float radius;
color[] fColor = {#ff9966, #ccff00, #ff9933, #ff00cc, #ee34d3, #4fb4e5, #abf1cf, #ff6037, #ff355e, #66ff66, #ffcc33, #ff6eff, #ffff66, #fd5b78};

int maxNodes = 500;

int progress = 0;

ArrayList<Node> nodes = new ArrayList<Node>();
ArrayList<Chord> crds = new ArrayList<Chord>();

PFont font;

boolean gettingRegion = true;
boolean drawingRegion = false;
float ex, ey;
float fx, fy;
float gx, gy;
float hx, hy;

float zoomX, zoomY;   // zoom translation coordinates
float ratio;          // zooming ratio
float w, h;           // rectangle width and height

void setup() {
  //size(1000,1000,FX2D);
  fullScreen();
  background(0);
  //blendMode(SCREEN);
  //noSmooth();

//  font = createFont("ebrima.ttf",48);
  //font = createFont("victoriandeco_regular.otf",48);  // dA .224
  font = createFont("tourette-extreme.otf",48);
  textFont(font);
  
  radius = height*.42;
  
  init();
}

void init() {
  progress = 0;
  gettingRegion = true;
  drawingRegion = false;
  ex = 0;
  ey = 0;
  fx = 0;
  fy = 0;
  gx = 0;
  gy = 0;
  hx = 0;
  hy = 0;
  background(0);
}

void draw() {
  if (gettingRegion) {
    // draw a selection box until the user makes a rectangular selection
    background(0);
    pushMatrix();
    translate(width/2,height/2);
    stroke(128);
    noFill();
    ellipse(0,0,radius*2,radius*2);
    stroke(32);
    line(-width/2,0,width/2,0);
    line(0,-height/2,0,height/2);
    if (ex!=0) {
      Pnt temp = getConstrainedRegion(mouseX-width/2,mouseY-height/2);
      fill(32);
      stroke(192);
      rect(ex,ey,temp.x,temp.y);
    }
    popMatrix();
  }
  
  if (drawingRegion) {
    for (int k=0;k<100;k++) {
      if (progress>=crds.size() || crds.size()==0) { drawingRegion = false; return; }
      crds.get(progress).render();
      progress++;
    }
    renderStatus((progress*1.0)/crds.size());
  }

}

Pnt getConstrainedRegion(float mx, float my) {
  float tempw = mx - ex;
  float temph = my - ey;
  
  // keep ratio proportional
  float tempr = tempw/temph;
  float dispr = width/height;
  
  if (tempr<dispr) {
    // constrain wdith
    tempw = temph*(1.0*width)/height; 
  } else {
    // constrain height
    temph = tempw*(1.0*height)/width;
  }
  
  return new Pnt(tempw,temph);

}

void doRender() {
  background(0);
  drawingRegion = true;
  progress = 0;
}

void renderStatus(float t) {
  // render progress indicator as green line that slowly disappears
  int pin = floor(width*t);
  //blendMode(BLEND);
  stroke(0);
  line(0,height-1,pin,height-1);
  stroke(0,255,0);
  line(pin+1,height-1,width-1,height-1);
 // blendMode(SCREEN);
}

void precalculateChords() {
  // check for intersection chords with viewing rectangle
  crds.clear();
  for (Node a:nodes) {
    for (Node d:a.connections) {
      ArrayList<Pnt> pnts = new ArrayList<Pnt>();
      Pnt pe = lineLineIntersection(ex,ey,fx,fy,a.x,a.y,d.x,d.y);
      Pnt pf = lineLineIntersection(fx,fy,gx,gy,a.x,a.y,d.x,d.y);
      Pnt pg = lineLineIntersection(gx,gy,hx,hy,a.x,a.y,d.x,d.y);
      Pnt ph = lineLineIntersection(hx,hy,ex,ey,a.x,a.y,d.x,d.y);
      
      if (pe!=null) pnts.add(pe);
      if (pf!=null) pnts.add(pf);
      if (pg!=null) pnts.add(pg);
      if (ph!=null) pnts.add(ph);
      
      // check for inscribed points
      if (a.x>ex && a.x<gx) {
        if (a.y>ey && a.y<gy) {
          pnts.add(new Pnt(a.x,a.y));
        }
          
      }
      if (d.x>ex && d.x<gx) {
        if (d.y>ey && d.y<gy) {
          pnts.add(new Pnt(d.x,d.y));
        }
      }
      
      if (pnts.size()==2) {
        float bx = pnts.get(0).x;
        float by = pnts.get(0).y;
        float cx = pnts.get(1).x;
        float cy = pnts.get(1).y;
        
        // translate and scale to display resolution
        bx -= ex;
        by -= ey;
        cx -= ex;
        cy -= ey;
        
        bx *=ratio;
        by *=ratio;
        cx *=ratio;
        cy *=ratio;
        
        Chord crd = new Chord(bx,by,cx,cy);
        crds.add(crd);
      }
    }
  }
}


Pnt lineLineIntersection(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4) {
  float denom = ((y4 - y3) * (x2 - x1)) - ((x4 - x3) * (y2 - y1));
  float numeA = ((x4 - x3) * (y1 - y3)) - ((y4 - y3) * (x1 - x3));
  float numeB = ((x2 - x1) * (y1 - y3)) - ((y2 - y1) * (x1 - x3));

  if (denom == 0) {
    if (numeA == 0 && numeB == 0) {
      // COLINEAR
      return null;
    }
    // PARALLEL;
    return null;
  }

  float uA = numeA / denom;
  float uB = numeB / denom;

  if (uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1) {
    // INTERSECTING
    float ix = x1 + (uA * (x2 - x1));
    float iy = y1 + (uA * (y2 - y1));
    return new Pnt(ix,iy);
  }

  return null;
}

void makeNodes(int count) {
  nodes.clear();
  if (count==0) return;
  float theta = TWO_PI/count;
  for (int i=0;i<count;i++) {
    float omega = theta*i-HALF_PI;
    float x = radius*cos(omega);
    float y = radius*sin(omega);
    Node n = new Node(x,y,4,radius,omega,#FFFFFF);
    nodes.add(n);
  }
}

void connectNodes() {
  for (int i=0;i<nodes.size()-1;i++) {
    for (int j=i+1;j<nodes.size();j++) {
      Node a = nodes.get(i);
      Node b = nodes.get(j);
      a.connections.add(b);
      b.connections.add(a);
      
    }
  }
}

void noiseWave() {
  float tf = random(100.0);
  float tc = random(100.0);
  float mag = 20.0;
  float time = 0;
  int ci = 0;
  for (Chord c:crds) {
    c.ax+=mag*noise(tf+time);
    //c.ay+=mag*noise(tc+time+c.ay*.05);
    c.bx+=mag*noise(tc+time);
    //c.by+=mag*noise(tc+time+c.by*.05);
    float val = 64*noise(tf+time);
    val = 64;
    c.myc = color(255,val);
    
    //float ccx = (1.0*width*ci)/crds.size();
    //stroke(0,0,255);
    //line(ccx,0,ccx,val);
    
    time+=.0055;
    ci++;
  }
  doRender();
}

void chordCut() {
  print("chordCut...");
  /*
  // cycle through every chord, cut at some intersection
  for (int i=0;i<crds.size()-1;i++) {
    for (int j=i+1;j<crds.size();j++) {
      Chord a = crds.get(i);
      Chord b = crds.get(j);
      Pnt p = lineLineIntersection(a.ax,a.ay,a.bx,a.by,b.ax,b.ay,b.bx,b.by);
      if (p!=null) {
        cutLine(a,p);
        cutLine(b,p);
      }
    }
  }
  */
  
  /*
  // try a fixed number of times to cut a chord
  for (int i=0;i<10000;i++) {
    Chord a = crds.get(floor(random(crds.size())));
    Chord b = crds.get(floor(random(crds.size())));
    if (a!=b) {
      Pnt p = lineLineIntersection(a.ax,a.ay,a.bx,a.by,b.ax,b.ay,b.bx,b.by);
      if (p!=null) {
        cutLine(a,p);
        cutLine(b,p);
      }
    }
  }
  */
  
  // pick a chord and cut every intersection along it
  Chord a = crds.get(floor(random(crds.size())));
  
  // shorten test length
  float t0 = random(1.0);
  float t1 = random(t0,1.0);
  float sax = a.ax+t0*(a.bx-a.ax);
  float say = a.ay+t0*(a.by-a.ay);
  float sbx = a.ax+t1*(a.bx-a.ax);
  float sby = a.ay+t1*(a.by-a.ay);
  for (Chord b:crds) {
    if (a!=b) {
      Pnt p = lineLineIntersection(sax,say,sbx,sby,b.ax,b.ay,b.bx,b.by);
      if (p!=null) cutLine(b,p);
    }
  }

  doRender();
  println("done");
}

void cutLine(Chord c, Pnt p) {
  // move closest chord endpoint to p
  float da = dist(c.ax,c.ay,p.x,p.y);
  float db = dist(c.bx,c.by,p.x,p.y);
  if (da<db) {
    c.ax = p.x;
    c.ay = p.y;
    //c.ahot = true;
  } else {
    c.bx = p.x;
    c.by = p.y;
    //c.bhot = true;
  }
}

void setRegion() {
  background(0);
  println("setregion");
  // complete rectangular view coordinates
  fx = gx;
  fy = ey;
  hx = ex;
  hy = gy;

  // compute the rendering zoom
  zoomX = -ex;
  zoomY = -ey;
  ratio = width/(gx-ex);

  println("makeNodes");
  // create the node objects
  radius = height*.45;
  makeNodes(maxNodes);
  
  println("connectNodes");
  
  connectNodes();
  
  println("precalculateChords");

  precalculateChords();
  
  gettingRegion = false;
  
  println("doRender");

  doRender();

}

void enhance() {
  // scan the screen and brighten already bright points
  println("enhancing...");
  
  int cnt = 0;
  PGraphics pg = createGraphics(width,height);
  pg.smooth(8);
  pg.beginDraw();
  for (int x=0;x<width;x++) {
    for (int y=0;y<height-1;y++) {
      color c = get(x,y);
      if (brightness(c)>(255.0*mouseY)/height) {
        // a bright spot has been found
        float w = 6-20*log(random(1.0));
        //pg.fill(32);
        //pg.ellipse(x,y,w,w);
        pg.noStroke();
        pg.fill(255,11);
        pg.ellipse(x,y,w,w);        // halo
        pg.fill(255,192);
        pg.ellipse(x,y,2,2);        // bright dot

        color eyc = 0x33FFFFFF;
        Exotic ex = new Exotic(x,y,w*random(1,3.0),eyc);
        ex.render(pg);            // character

        // count the occurrence
        cnt++;
      }
      
    }
    // render progress indicator as red line that slowly disappears
    //blendMode(BLEND);
    //stroke(0);
    //line(0,height-1,x,height-1);
    //stroke(255,0,0);
    //line(x+1,height-1,width-1,height-1);
    //blendMode(SCREEN);
  }
  pg.endDraw();
  println(cnt+" done.");
  image(pg,0,0);
}


void enhanceBlur() {
  // copy scene into a new image
  PImage bg = createImage(width,height,ARGB);
  bg.loadPixels();
  for (int x=0;x<width;x++) {
    for (int y=0;y<height;y++) {
      color c = get(x,y);
      bg.set(x,y,c);
    }
  }

  // blur new image
  bg.filter(BLUR,4);
  
  blendMode(SCREEN);
  // stamp blur back on top
  image(bg,0,0);
  blendMode(BLEND);
  
  println("enhanceBlur done.");
}

void enhanceDarkness() {
  print("enhanceDarkness...");
  PImage bg = createImage(width,height,ARGB);
  
  float waterLevel = (1.0*mouseY)/height;
  // generate noise terrain
  float fx = random(1000);
  float fy = random(1000);
  float ft = map(mouseX,0,width,.001,.01);
  for (int x=0;x<bg.width;x++) {
    for (int y=0;y<bg.height;y++) {
      float val = noise(fx+x*ft,fy+y*ft);
      if (val>waterLevel) {
        // darkness
        float darkness = map(val,waterLevel,1.0,0,255);
        bg.set(x,y,color(0,darkness));
      }
    }
  }
  
  // stamp darkness back on top
 // blendMode(BLEND);
  image(bg,0,0);
 // blendMode(SCREEN);
  println("done.");
    
}

void enhanceContrast() {
  print("enhanceContrast...");
  PImage bg = createImage(width,height,ARGB);

  // find maximum brightness
  float bmax = 0;
  float bmin = 255;
  for (int x=0;x<bg.width;x++) {
    for (int y=0;y<bg.height;y++) {
      color c = get(x,y);
      float brt = brightness(c);
      if (brt>bmax) bmax = brt;
      if (brt<bmin) bmin = brt;
    }
  }
  
  if (bmin>bmax) bmin = bmax;
  
  println("brightness min:"+bmin+"    max:"+bmax);
  // write normalized image
  bg.loadPixels();
  for (int x=0;x<bg.width;x++) {
    for (int y=0;y<bg.height;y++) {
      color c = get(x,y);
      float brt = brightness(c);
      float bnew = map(brt,0,bmax,-16,288);
      if (bnew>255) bnew=255;
      if (bnew<0) bnew=0;
      bg.set(x,y,color(bnew));
    }
  }
  bg.updatePixels();
  
  image(bg,0,0);
  println("done.");
  
}

void redrawChords() {
  progress = 0;
  drawingRegion = true;
}

color somecolor() {
  int i=floor(random(fColor.length));
  return fColor[i];
}

void keyPressed() {
  if (key==' ') init();
  if (key=='e' || key=='E') enhance();
  if (key=='b' || key=='B') enhanceBlur();
  if (key=='d' || key=='D') enhanceDarkness();
  if (key=='w' || key=='W') noiseWave();
  if (key=='c' || key=='C') chordCut();
  if (key=='n' || key=='N') enhanceContrast();
  if (key=='r' || key=='R') redrawChords();
  
}

void mousePressed() {
  if (ex==0) {
    ex = mouseX - width/2;
    ey = mouseY - height/2;
  } 
}

void mouseReleased() {
  if (gx==0) {
    Pnt temp = getConstrainedRegion(mouseX-width/2,mouseY-height/2);
    gx = ex + temp.x;
    gy = ey + temp.y;
    // start rendering process
    setRegion();
  }
}
