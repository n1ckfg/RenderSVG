//http://forum.processing.org/one/topic/make-a-dot-follow-a-svg-path.html

PShape s; 
ArrayList ve; 
int nve = 1;
float slen = 5.0; // max length of segments 
float sf = 0.8; // scale factor for the image 
String svgFile = "test.svg"; 
boolean loadNewFile = false;
boolean ready = false;
PImage brush;
int brushSize = 10;
int brushSizeMin = 8;
int brushSizeMax = 12;
float brushRandom = 2;
float leakRandom = 0.4; //0-1
float brushScatter = 5;
color brushColor = color(0,255,0);
color bgColor = color(255);

void setup() { 
  brush = loadImage("brush.png");
  imageMode(CENTER);

  ve = new ArrayList(); 
  
  frameRate(120); 
  size(550, 400); 
  if (loadNewFile) {
    selectInput("Select a file to process:", "fileSelected"); 
  } else {
    ready = true;
  }
  s = loadShape(svgFile); 
  s.scale(sf); 
  smooth(); 
  //shape(s); 
  
  exVert(s, sf); 
  println("# of vertex: " + ve.size()); 
  
  background(bgColor);
  shape(s,0,0);
} 

void draw(){
  //background(bgColor);
  stroke(255,0,0);
  strokeWeight(2);
  if(ready){ 
    if (nve < ve.size()) { 
      if(((Point) ve.get(nve)).z != -10.0) {// a way to separate distinct paths 
        PVector p1 = new PVector(((Point) ve.get(nve-1)).x, ((Point) ve.get(nve-1)).y);
        PVector p2 = new PVector(((Point) ve.get(nve)).x, ((Point) ve.get(nve)).y);
        
        PVector pa = new PVector((p1.x + p2.x)/2,(p1.y + p2.y)/2);
        PVector pb = new PVector((p1.x + pa.x)/2,(p1.y + pa.y)/2);
        PVector pc = new PVector((p2.x + pa.x)/2,(p2.y + pa.y)/2);

        PVector paa = new PVector((pa.x + pb.x)/2,(pa.y + pb.y)/2);
        PVector pbb = new PVector((pb.x + pc.x)/2,(pb.y + pc.y)/2);
        PVector pcc = new PVector((pc.x + pa.x)/2,(pc.y + pa.y)/2);
        
        float bs = 0;
        float lr = random(1);
        float dst = dist(p1.x,p1.y,p2.x,p2.y);
        if (lr < leakRandom) {
          bs = brushSize / dst;
        } else {
          bs = brushSize * dst;
        }
        if (bs < brushSizeMin) bs = brushSizeMin;
        if (bs > brushSizeMax) bs = brushSizeMax;
        bs += random(brushRandom) - random(brushRandom);
        doBrush(p1,bs,false,brushColor);
        doBrush(p2,bs,false,brushColor);
        
        doBrush(pa,bs,false,brushColor);
        doBrush(pb,bs,false,brushColor);
        doBrush(pc,bs,false,brushColor);

        doBrush(paa,bs,true,brushColor);
        doBrush(pbb,bs,true,brushColor);
        doBrush(pcc,bs,true,brushColor);
        
        //line(p1.x, p1.y, p2.x, p2.y);
        //ellipse( ((Point) ve.get(nve)).x, ((Point) ve.get(nve)).y, 2, 2 ); 
        nve++; 
      }
    } else { // restart drawing 
      background(200); 
      nve = 1; 
    } 
  }
} 

void doBrush(PVector p, float b, boolean scatter, color c) {
  pushMatrix();
  tint(c);
  if (scatter) {
    translate(p.x + random(brushScatter) - random(brushScatter),p.y + random(brushScatter) - random(brushScatter));
  } else {
    translate(p.x,p.y);
  }
  rotate(radians(random(360)));
  image(brush,0,0,b,b);
  popMatrix();
}


void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    svgFile = selection.getAbsolutePath();
    println("User selected " + svgFile);
    ready = true;
  }
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// recursively find PShape children and trigger function to get existing vertex and fill-in vertex 
// 
void exVert(PShape s, float sf) { 
  PShape[] ch; // children 
  int n, i; 
  n = s.getChildCount(); 
  
  if (n > 0) { 
    for (i = 0; i < n; i++) { 
      ch = s.getChildren(); 
      exVert(ch[i], sf); 
    } 
  } else { // no children -> work on vertex 
    n = s.getVertexCount(); 
    //println("vertex count: " + n + " getFamily():" + s.getFamily()+ " isVisible():" + s.isVisible()); 
    for (i = 0; i < n; i++) { 
      float x = s.getVertexX(i)*sf; 
      float y = s.getVertexY(i)*sf; 
      // println(i + ") getVertexCode:"+s.getVertexCode(i)); 
      if (i>0) { 
        float ox = s.getVertexX(i-1)*sf; 
        float oy = s.getVertexY(i-1)*sf; 
        stepToVert(ox, oy, x, y, slen); 
      } else { 
        ve.add(new Point(x, y, -10.0)); 
      } 
    } 
  } 
} 

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// fill in with points, if needed, from (ox, oy) to (x, y) 
// 
void stepToVert(float ox, float oy, float x, float y, float slen) { 
  int i; 
  float n; 
  float dt = dist(ox, oy, x, y); 
  if ( dt > slen) { 
    n = floor(dt/slen); 
    // println("Adding "+n+" points..."); 
    for (i = 0; i < n; i++) { 
      float nx = lerp(ox, x, (i+1)/(n+1)); 
      float ny = lerp(oy, y, (i+1)/(n+1)); 
      ve.add(new Point(nx, ny, 0)); 
    } 
  } 
  ve.add(new Point(x, y, 0)); 
} 

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// myClass for a 3D point 
// 
class Point { 
  float x, y, z; 
  
  Point(float x, float y, float z) { 
    this.x = x; 
    this.y = y; 
    this.z = z; 
  } 

  void set(float x, float y, float z) { 
    this.x = x; 
    this.y = y; 
    this.z = z; 
  } 
} 
