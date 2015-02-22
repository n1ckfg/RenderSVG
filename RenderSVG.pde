//http://forum.processing.org/one/topic/make-a-dot-follow-a-svg-path.html

//to do: 
//add batching, directory selection, and saving to disk

int sW = 1920;
int sH = 1080;

PShape img; 
ArrayList ve; 
int nve = 1;
float slen = 2.0; // 5.0 max length of segments 
float sf = 1.0; // 0.8 scale factor for the image 
String svgFile = "test.svg"; 
String brushFile = "brush2.png";
PImage brush;
int brushSize = 18;
int brushSizeMin = 5;
int brushSizeMax = 42;
float brushRandom = 2;
float leakRandom = 0.75; //0-1
float brushScatter = 4;
color brushColor = color(255, 0, 0, 150);
boolean useBrushColor = false;
int alphaOffset = -50;
color bgColor = color(155);
float distLimit = 1.95; //10.0;
float gravity = 10.01;
PGraphics alphaImg;
PGraphics alphaImgOrig;
boolean firstRun = true;
int rotCounter = 0;
boolean useBase = false;
int counter = 0;

void setup() { 
  Settings settings = new Settings("settings.txt");
  if (!filesLoaded) loadFiles();
  nextImage(counter);
  sW = (int) img.width;
  sH = (int) img.height;
  size(sW, sH); 

  brush = loadImage(brushFile);
  brush.filter(INVERT);
  frameRate(60); 
  smooth();
} 

void draw() {

    //prep graphics
    if (firstRun) {
      prepGraphics();
      firstRun = false;
    } else {

    while (nve < ve.size ()) { 
      //replaced with distLimit check...we want to keep looking for paths
      //if(((Point) ve.get(nve)).z != -10.0) {// a way to separate distinct paths 
      PVector p1 = new PVector(((Point) ve.get(nve-1)).x, ((Point) ve.get(nve-1)).y);
      PVector p2 = new PVector(((Point) ve.get(nve)).x, ((Point) ve.get(nve)).y);

      PVector pa = new PVector((p1.x + p2.x)/2, (p1.y + p2.y)/2);
      PVector pb = new PVector((p1.x + pa.x)/2, (p1.y + pa.y)/2);
      PVector pc = new PVector((p2.x + pa.x)/2, (p2.y + pa.y)/2);

      PVector paa = new PVector((pa.x + pb.x)/2, (pa.y + pb.y)/2);
      PVector pbb = new PVector((pb.x + pc.x)/2, (pb.y + pc.y)/2);
      PVector pcc = new PVector((pc.x + pa.x)/2, (pc.y + pa.y)/2);

      float bs = 0;
      float lr = random(1);
      float dst = dist(p1.x, p1.y, p2.x, p2.y);

      if (lr < leakRandom) {
        bs = brushSize / dst;
      } else {
        bs = brushSize * dst;
      }
      if (bs < brushSizeMin) bs = brushSizeMin;
      if (bs > brushSizeMax) bs = brushSizeMax;
      bs += random(brushRandom) - random(brushRandom);

      if (dst <= distLimit) {
        doBrush(p1, bs, false, brushColor);
        doBrush(p2, bs, false, brushColor);

        doBrush(pa, bs, false, brushColor);
        doBrush(pb, bs, false, brushColor);
        doBrush(pc, bs, false, brushColor);

        doBrush(paa, bs, true, brushColor);
        doBrush(pbb, bs, true, brushColor);
        doBrush(pcc, bs, true, brushColor);
      }

      nve++;
    }

    alphaImg.endDraw();
    image(alphaImg, 0, 0);

    if (counter<imgNames.size()-1) {
      saveGraphics(alphaImg, false); //don't exit
      counter++;
      nextImage(counter);
      prepGraphics();
    } else {
      saveGraphics(alphaImg, true); //exit
    }
    }

} 

void prepGraphics() {
  nve=1;
  alphaImg = createGraphics(width, height, JAVA2D);
  alphaImgOrig = createGraphics(width, height, JAVA2D);  
  ve = new ArrayList(); 
  //String target = (String) imgNames.get(counter);
  //img = loadShape(target); 
  img.scale(sf); 
  exVert(img, sf); 
  println("# of vertex: " + ve.size());
  
  alphaImg.beginDraw();    
  // make sure its alpha is set to 0
  alphaImg.loadPixels();
  for (int i=0; i<alphaImg.pixels.length; i++) {
    alphaImg.pixels[i] = color(0, 0);
  }
  alphaImg.updatePixels();
  shapeMode(CORNER);
  alphaImg.shape(img, 0, 0);
  alphaImg.endDraw();

  alphaImgOrig.beginDraw();    
  alphaImgOrig.loadPixels();
  for (int i=0; i<alphaImgOrig.pixels.length; i++) {
    alphaImgOrig.pixels[i] = color(0, 0);
  }
  alphaImgOrig.updatePixels();
  alphaImgOrig.image(alphaImg,0,0);
  alphaImgOrig.endDraw();

  firstRun = false;
}

void doBrush(PVector p, float _b, boolean scatter, color c) {

  alphaImg.pushMatrix();
  //int loc = int(p.x + p.y * grab.width);
  color cc0, cc1, cc2, cc3, cc4, cc5, cc6, cc7, cc8;

  if (useBase) { 
    cc0 = alphaImgOrig.pixels[int((p.x+0) + (p.y+0) * alphaImgOrig.width)];
    cc1 = alphaImgOrig.pixels[int((p.x+1) + (p.y+0) * alphaImgOrig.width)];
    cc2 = alphaImgOrig.pixels[int((p.x-1) + (p.y+0) * alphaImgOrig.width)];
    cc3 = alphaImgOrig.pixels[int((p.x+0) + (p.y+1) * alphaImgOrig.width)];
    cc4 = alphaImgOrig.pixels[int((p.x+0) + (p.y-1) * alphaImgOrig.width)];
    cc5 = alphaImgOrig.pixels[int((p.x+1) + (p.y+1) * alphaImgOrig.width)];
    cc6 = alphaImgOrig.pixels[int((p.x+1) + (p.y-1) * alphaImgOrig.width)];
    cc7 = alphaImgOrig.pixels[int((p.x-1) + (p.y+1) * alphaImgOrig.width)];
    cc8 = alphaImgOrig.pixels[int((p.x-1) + (p.y-1) * alphaImgOrig.width)];
  } else {
    cc0 = alphaImg.pixels[int((p.x+0) + (p.y+0) * alphaImg.width)];
    cc1 = alphaImg.pixels[int((p.x+1) + (p.y+0) * alphaImg.width)];
    cc2 = alphaImg.pixels[int((p.x-1) + (p.y+0) * alphaImg.width)];
    cc3 = alphaImg.pixels[int((p.x+0) + (p.y+1) * alphaImg.width)];
    cc4 = alphaImg.pixels[int((p.x+0) + (p.y-1) * alphaImg.width)];
    cc5 = alphaImg.pixels[int((p.x+1) + (p.y+1) * alphaImg.width)];
    cc6 = alphaImg.pixels[int((p.x+1) + (p.y-1) * alphaImg.width)];
    cc7 = alphaImg.pixels[int((p.x-1) + (p.y+1) * alphaImg.width)];
    cc8 = alphaImg.pixels[int((p.x-1) + (p.y-1) * alphaImg.width)];
  }
  int r = int((red(cc0) + red(cc1) + red(cc2) + red(cc3) + red(cc4) + red(cc5) + red(cc6) + red(cc7) + red(cc8))/9);
  int g = int((green(cc0) + green(cc1) + green(cc2) + green(cc3) + green(cc4) + green(cc5) + green(cc6) + green(cc7) + green(cc8))/9);
  int b = int((blue(cc0) + blue(cc1) + blue(cc2) + blue(cc3) + blue(cc4) + blue(cc5) + blue(cc6) + blue(cc7) + blue(cc8))/9);
  int a = int((alpha(cc0) + alpha(cc1) + alpha(cc2) + alpha(cc3) + alpha(cc4) + alpha(cc5) + alpha(cc6) + alpha(cc7) + alpha(cc8))/9);

  a += alphaOffset;
  if (a < 0) a = 0;
  if (a > 255) a = 255;

  if (scatter) {
    alphaImg.translate(p.x + random(brushScatter) - random(brushScatter), p.y + random(brushScatter) - random(brushScatter) + random(gravity));
  } else {
    alphaImg.translate(p.x, p.y);
  }
  alphaImg.rotate(radians(random(360)));
  if (useBrushColor) {
    alphaImg.tint(color(r, g, b, a) + brushColor);
  } else {
    alphaImg.tint(r, g, b, a);
  }
  alphaImg.imageMode(CENTER);
  alphaImg.image(brush, 0, 0, _b, _b);

  alphaImg.popMatrix();


}


/*
void fileSelected(File selection) {
 if (selection == null) {
 println("Window was closed or the user hit cancel.");
 } else {
 svgFile = selection.getAbsolutePath();
 println("User selected " + svgFile);
 ready = true;
 }
 }
 */
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

