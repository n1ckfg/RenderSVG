class Settings {

  String[] data;

  Settings(String _s) {
    try {
      data = loadStrings(_s);
      for (int i=0;i<data.length;i++) {
        /*
        if (data[i].equals("Points Per Pass")) numDrawers = setInt(data[i+1]);
        if (data[i].equals("Strokes Per Point")) numDrawerReps = setInt(data[i+1]);
        if (data[i].equals("Stroke Length")) numStrokes = setInt(data[i+1]);
        if (data[i].equals("Passes Per Image")) numRepsMax = setInt(data[i+1]);
        if (data[i].equals("Save Filename")) fileName = setString(data[i+1]);
        if (data[i].equals("Brush Filename")) brushFile = setString(data[i+1]);
        if (data[i].equals("Brush Alpha Decrease")) alphaDecrease = setInt(data[i+1]);
        if (data[i].equals("Brush Size")) brushSizeOrig = setFloat(data[i+1]);
        if (data[i].equals("Brush Minimum")) brushSizeMin = setFloat(data[i+1]);
        if (data[i].equals("Brush Maximum")) brushSizeMax = setFloat(data[i+1]);
        if (data[i].equals("Leak Chance")) leakRandom = setFloat(data[i+1]);
        if (data[i].equals("Scatter")) scatter = setFloat(data[i+1]);
        if (data[i].equals("Clean Outlines")) cleanOutlines = setBoolean(data[i+1]);
        if (data[i].equals("Use Base Image")) useBase = setBoolean(data[i+1]);
        if (data[i].equals("Brush Shrink Amount")) shrinkAmount = setFloat(data[i+1]);  
         */   
       }
    } 
    catch(Exception e) {
      println("Couldn't load settings file. Using defaults.");
    }
  }

  int setInt(String _s) {
    return int(_s);
  }

  float setFloat(String _s) {
    return float(_s);
  }

  boolean setBoolean(String _s) {
    return boolean(_s);
  }
  
  String setString(String _s) {
    return ""+(_s);
  }
  
  String[] setStringArray(String _s) {
    int commaCounter=0;
    for(int j=0;j<_s.length();j++){
          if (_s.charAt(j)==char(',')){
            commaCounter++;
          }      
    }
    //println(commaCounter);
    String[] buildArray = new String[commaCounter+1];
    commaCounter=0;
    for(int k=0;k<buildArray.length;k++){
      buildArray[k] = "";
    }
    for (int i=0;i<_s.length();i++) {
        if (_s.charAt(i)!=char(' ') && _s.charAt(i)!=char('(') && _s.charAt(i)!=char(')') && _s.charAt(i)!=char('{') && _s.charAt(i)!=char('}') && _s.charAt(i)!=char('[') && _s.charAt(i)!=char(']')) {
          if (_s.charAt(i)==char(',')){
            commaCounter++;
          }else{
            buildArray[commaCounter] += _s.charAt(i);
         }
       }
     }
     println(buildArray);
     return buildArray;
  }

  color setColor(String _s) {
    color endColor = color(0);
    int commaCounter=0;
    String sr = "";
    String sg = "";
    String sb = "";
    String sa = "";
    int r = 0;
    int g = 0;
    int b = 0;
    int a = 0;

    for (int i=0;i<_s.length();i++) {
        if (_s.charAt(i)!=char(' ') && _s.charAt(i)!=char('(') && _s.charAt(i)!=char(')')) {
          if (_s.charAt(i)==char(',')){
            commaCounter++;
          }else{
          if (commaCounter==0) sr += _s.charAt(i);
          if (commaCounter==1) sg += _s.charAt(i);
          if (commaCounter==2) sb += _s.charAt(i); 
          if (commaCounter==3) sa += _s.charAt(i);
         }
       }
     }

    if (sr!="" && sg=="" && sb=="" && sa=="") {
      r = int(sr);
      endColor = color(r);
    }
    if (sr!="" && sg!="" && sb=="" && sa=="") {
      r = int(sr);
      g = int(sg);
      endColor = color(r, g);
    }
    if (sr!="" && sg!="" && sb!="" && sa=="") {
      r = int(sr);
      g = int(sg);
      b = int(sb);
      endColor = color(r, g, b);
    }
    if (sr!="" && sg!="" && sb!="" && sa!="") {
      r = int(sr);
      g = int(sg);
      b = int(sb);
      a = int(sa);
      endColor = color(r, g, b, a);
    }
      return endColor;
  }
}