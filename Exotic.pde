class Exotic {
  float x, y;
  float s;
  color myc;
  
  String lbl;
  
  Exotic(float _x, float _y, float _s, color _myc) {
    x = _x;
    y = _y;
    s = _s;
    myc = _myc;
    
    //lbl = str(getGoodChar());
    //lbl = str(getStandardChar());
    lbl = str(getNumberChar());
  }
  
  void render(PGraphics pg) {
    //pg.stroke(255,32);
    //pg.noFill();
    //pg.ellipse(x,y,s,s);
    pg.noFill();
    pg.stroke(255,64);
    pg.arc(x,y,s,s,random(TWO_PI),random(TWO_PI),OPEN);
    //renderChar(pg); 
  }
  
  void renderChar(PGraphics pg) {
    pg.fill(myc);
    pg.noStroke();
    pg.textFont(font);
    pg.textSize(s);
    pg.textAlign(CENTER);
    float leadAdjust = .22*s;
    pg.text(lbl,x,y+leadAdjust);
    //pg.textSize(12);
    //pg.text(int(lbl.charAt(0)),x,y+leadAdjust*3);    // for debugging char codes
    //pg.stroke(255);
    //pg.point(x,y);

  }
  
  char getGoodChar() {
    int idx = floor(random(4608,5017));
    if (idx==4695 || idx==4697 || idx==4702 || idx==4703 || idx==4791 || idx==4799 || idx==4801 || idx==4806 || idx==4807 || idx==4823 || idx==4745 || idx==4750 || idx==4751 || idx==4785 || idx==4955 || idx==4956 || idx==4989 || idx==4990 || idx==4991 || idx==4681 || idx==4684 || idx==4881 || idx==4687 || idx==4790) idx = 4752;
    return char(idx);
  }  
  
  char getStandardChar() {
    int idx = floor(random(32,126));
    return char(idx);
  }
  
  char getNumberChar() {
    int idx = floor(random(48,58));
    return char(idx);
  }
}
