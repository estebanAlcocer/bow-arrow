import javax.swing.JOptionPane;
import processing.serial.*;
import ddf.minim.*;
import saito.objloader.*;
import toxi.geom.*;
import toxi.processing.*;

/////
float[] debug={0,0,0,0};
//////////// serial var
Serial port;                         // The serial port
char[] teapotPacket = new char[17];  // InvenSense Teapot packet
int serialCount = 0;                 // current packet byte position
int synced = 0;
int interval = 0;
int boton = 0;
int flag = 0;
boolean bFlag=false;

/////// calibrar
int calibrar=0;
float acum=0;
int calibrarMax=0;
int calibrarMin=0;
float acumMax=0;
float acumMin=0;

float yaw=0;
float roll=0;

boolean bDraw = true;
boolean pDraw = true;
boolean firstRead= true;


/// DATA variables

float[] q = new float[4];
float[] ypr = new float[4];
float[] euler = new float[3];
float[] gravity = new float[3];
float[] axis = {0,0,0,0};
float distTemp=0;

float posXX=0;
float posYY=0;
   

Quaternion quat = new Quaternion(1, 0, 0, 0);//

//7/////////////// OBJ var

OBJModel model ;
float rotX=0;
float rotY=0;
float rotZ=0;
//Audio var
Minim cadena;
AudioPlayer cancion;
Minim canciones;
AudioPlayer can;


/////////////// media movil var

int n=0;
int i=0;
int j=0;
int m=0;

float promedio =0.0;
float [] datos = new float [10000];

float media=0;
 
///////Graph Variable
 
PImage fondo;
PImage con;
PImage index;
Float distancia=1.0;
float fe=0.0;
float vien=0.0;
int estado=0;

void setup(){
  frameRate (200);
  size (1000,700, P3D);
  canciones=new Minim(this);
  can=canciones.loadFile("Zelda- Ocarina of Time Music - Windmill Hut.mp3");
  cadena=new Minim(this);
  cancion=cadena.loadFile("Zelda- Ocarina of Time Music - Lost Woods.mp3");
  
  
  fe=1.1-(distancia*.01);
  fondo=loadImage("campo.jpg");
  index=loadImage("index.jpg");
  con=loadImage("settings2.jpg");
  
  setupBow();
  
  /////////////setup serialll
      println(Serial.list());
    String portName = Serial.list()[0];
    port = new Serial(this, portName, 115200);
    port.write('r');
  ////////////
  for(int i=0; i<10000;i++);

}

void draw() {
 
  
  /////////////////por si hay reset de MPU
    if (millis() - interval > 1000) {
        port.write('r');
        interval = millis();
    }
     
 if(estado==0) principal();
 if(estado==2) config();
 if (estado==1)
 {   
    image(fondo,0,0);
      distancia=Float.parseFloat(JOptionPane.showInputDialog("Dame la distancia(10-100m)"));
      estado=3;  
 }
 if (estado==3) simu();
  if(estado==4) config2();
}


void mousePressed(){
 if(estado==0)
{ 
  if(mouseX>350 && mouseX<650)
  {
    if(mouseY>250 && mouseY<350)
    {
      estado=1;
    }
  }
  if(mouseX>350 && mouseX<650)
  {
    if(mouseY>400 && mouseY<500)
    {
     estado=2;
    }
  }
}//fin estado 0

if(estado==2){
  if(mouseX>0 && mouseX<200)
  {
    if(mouseY>650 && mouseY<700)
    {
     estado=0;
    }
  }
  if(mouseX>0 && mouseX<300)
  {
    if(mouseY>250 && mouseY<350)
    {
      n=Integer.parseInt(JOptionPane.showInputDialog("Dame el rango de la media movil"));
    }
  }
  
  if(mouseX>0 && mouseX<300)
  {
    if(mouseY>400 && mouseY<500)
    {
bDraw=true;
pDraw=true;
     }
   
  }
  if(mouseX>0 && mouseX<300)
  {
    if(mouseY>520 && mouseY<620)
    {
      estado=4;
     
     }
  }
}//fin estado 2
  
  if(estado==3)
  {  
   if(mouseX>0 && mouseX<200)
    {
      if(mouseY>650 && mouseY<700)
        {
         estado=0;
        }
    }
    
    
  }//fin del estado 3
  
  if(estado==4){

    if(mouseX>0 && mouseX<200)
  {
    if(mouseY>650 && mouseY<700)
    {
     estado=0;
    }
  }
  if(mouseX>0 && mouseX<300)
  {
    if(mouseY>250 && mouseY<350)
    {
      //hint
      calibrar=1;
      acum=0;
      System.out.println("calibrando...");
    /*  calibq[0] = q[0];
      calibq[1] = q[1];
      calibq[2] = q[2];
      calibq[3] = q[3];
      */

      }
  }
  
  if(mouseX>0 && mouseX<300)
  {
    if(mouseY>400 && mouseY<500)
    {
     acumMax=0; 
     calibrarMax=1; 
      System.out.println("Max");   
     }
   
  }
  if(mouseX>0 && mouseX<300)
  {
    if(mouseY>520 && mouseY<620)
    {
      acumMin=0;
      calibrarMin=1;
      System.out.println("Min");   
      
     }
  }
}//fin estado 4


}

 void drawBull(){
fill(255,255,255);
      ellipse(500.0,350.0,400*fe,400*fe);
      ellipse(500.0,350.0,360*fe,360*fe);
    fill(10,10,10);
       ellipse(500.0,350.0,320*fe,320*fe);
       ellipse(500.0,350.0,280*fe,280*fe);
    fill(3,215,255);
       ellipse(500.0,350.0,240*fe,240*fe);
       ellipse(500.0,350.0,200*fe,200*fe);
    fill(255,3,32);
       ellipse(500.0,350.0,160*fe,160*fe);
       ellipse(500.0,350.0,120*fe,120*fe);
    fill(255,230,3);
       ellipse(500.0,350.0,80*fe,80*fe);
       ellipse(500.0,350.0,40*fe,40*fe); 
    fill(211,211,211);
       rect(0,650,200,50);
       fill(0);
       text("MENU",30,680);
       
       
 }

void setupBow(){
    model = new OBJModel(this, "Bow_recurve.obj", "absolute", TRIANGLES);
    //model.enableDebug();
    model.scale(90);
    model.translateToCenter();
    PImage photo;
    photo = loadImage("texture2.jpg");
    
    model.setTexture(photo);
   // stroke(255);
    //noStroke();
}

void drawBow(){
    lights();
    pushMatrix();
    translate(width/2, height/2, 350);
     // (axis order [1, 3, 2] and inversion [-1, +1, +1] is a consequence of
    // different coordinate system orientation assumptions between Processing
    // and InvenSense DMP)
    axis = quat.toAxisAngle();
    //axis[1]=-PI;
    //println(axis[0]+"\t"+axis[1]+"\t"+axis[2]+"\t"+axis[3]);
    rotateX(-ypr[2]+rotY);
    //rotate(axis[0], -axis[1], axis[3], axis[2]);
    rotateY(-ypr[0]+PI+rotX+.7);
    rotateZ(ypr[1]);
    model.draw();
    popMatrix();
}


void drawInfo()
{
          textSize(18);
              fill(0);
               text(degrees( ypr[0]-yaw-.7),100,20);
                text("angulo x:",0,20);
            textSize(18);
             fill(0);
              text(degrees(ypr[2]-roll),100,50);
                text("angulo Y: ",0,50);
           
           textSize(18);
             fill(0);
               text(Datos.posX,100,80);
                 text("desp X (m): ",0,80);
                 
           textSize(18);
             fill(0);
               text(Datos.posY,100,110);
                 text("desp Y (m): ",0,110);   
                 
          textSize(18);
              fill(245,0,0);
               text(Datos.vo,100,140);
                text("VO: ",0,140);
                
            textSize(18);
             fill(245,0,0);
              text(Datos.tiempo,100,170);
                text("Tiempo: ",0,170);
           
           textSize(18);
             fill(245,0,0);
               text(str(pDraw),100,200);
                 text("Puntero: ",0,200);
                 
           textSize(18);
             fill(245,0,0);
               text(ypr[3],100,230);
                 text("Fuerza: ",0,230);                 
                 
           textSize(18);
             fill(255,255,255);
               text(promedio,100,260);
                 text("movil: ",0,260);                 

           textSize(18);
             fill(255,255,255);
               text(Datos.vo,100,290);
                 text("VO: ",0,290); 
}                 

void keyPressed() 
{
  if (key == CODED) {
    if (keyCode == UP)  rotY+=.1;
    if (keyCode == DOWN) rotY-=.1;
    if (keyCode == LEFT) rotX-=.1;
    if (keyCode == RIGHT) rotX+=.1;
     // println("dx: "+rotX+"  "+"dy: "+rotY);
     
     

    }
    if (key == 'c')
     { 
       ypr[3]=distTemp;
       yaw=ypr[0]-0.7;
       //roll=ypr[2];
       rotX=ypr[0]-.7;
       println("x calibrado a: "+yaw+"  y calibrado a: "+roll);
       bFlag=false;
     }
     
     if(key == 'd') {
        if(!bDraw) {
            bDraw = true;
        } 
        else {
            bDraw = false;
        }
    }
    if(key == 'p') {
        if(!pDraw) {
            pDraw = true;
        } 
        else {
            pDraw = false;
        }
    }
     
  }

void mouseDragged()
{
   rotX += (mouseX - pmouseX) * 0.01;
   rotY -= (mouseY - pmouseY) * 0.01;
   println("x: "+rotX+" "+"y: "+rotY);
}

void principal()
{
 cancion.play();
   can.pause();
   image(index,0,0);
   textSize(80);
       fill(0);
         text("BOW'N'ARROW",230,120);
   textSize(18);
     fill(0);
       text("Por:",830,640);
   textSize(18);
     fill(0);
       text("Uriel Wrvieta",830,658);
  textSize(18);
    fill(0);
      text("Esteban Alcocer",830,685);
  
  fill(211,211,211);
    rect(350,250,300,100);
      textSize(35);
        fill(0);
          text("Play",460,320);
  fill(211,211,211);
    rect(350,400,300,100);
      textSize(35);
        fill(0);
          text("Settings",430,470);

}

void simu()
{
 
    fe=1.1-(distancia*.01);
    
    cancion.pause();
    can.play();
    image(fondo,0,0);
    drawBull();
    if(bDraw)
    drawBow();
    drawInfo();
                
    
    
     // *//////////////////////////////
  //  prueba circulo. y mi codigo
  // *//////////////////////////////////////////////
   Datos.calcular(distancia,promedio,degrees( ypr[0]-yaw-.7) ,degrees(ypr[2]-roll));
     //Datos.calcular(distancia,promedio,0.1 ,5);
     
    //System.out.println(degrees( ypr[0]-yaw)+"  "+degrees(ypr[2]-roll));
    if(pDraw){
    float pixX=Datos.posX*(400*fe/1.22);
    float pixY=Datos.posY*(400*fe/1.22);
    ellipse(500.0+pixX,350.0-pixY,10,10); }
 
    if(bFlag){
    float pixXX=posXX*(400*fe/1.22);
    float pixYY=posYY*(400*fe/1.22);
    ellipse(500.0+pixXX,350.0-pixYY,10,10); }
 ///Fin de mi codigo
}

void config()
 {
 image(con,0,0);
    textSize(80);
      fill(0);
        text("BOW'N'ARROW",230,120);
     textSize(18);
      fill(0);
        text("Por:",830,640);
     textSize(18);
       fill(0);
        text("Uriel Wrvieta",830,658);
     textSize(18);
       fill(0);
         text("Esteban Alcocer",830,685);
  
  fill(211,211,211);
    rect(0,250,300,100);
      textSize(35);
        fill(0);
          text("Movil",0,320);
            textSize(35);
              fill(0);
               text(n,300,320);
  
  fill(211,211,211);
    rect(0,400,300,100);
      textSize(35);
        fill(0);
         text("Principiantes",0,470);
      textSize(35);
        fill(0);
         text(vien,300,470);
      
   fill(211,211,211);
    rect(0,520,300,100);
      textSize(35);
        fill(0);
         text("Calibrar",0,590);
  
  fill(211,211,211);
    rect(0,650,200,50);
      fill(0);
        text("MENU",30,680);
 
}

void config2()
{
 image(con,0,0);
    textSize(80);
      fill(0);
        text("BOW'N'ARROW",230,120);
     textSize(18);
      fill(0);
        text("Por:",830,640);
     textSize(18);
       fill(0);
        text("Uriel Wrvieta",830,658);
     textSize(18);
       fill(0);
         text("Esteban Alcocer",830,685);
  
  fill(211,211,211);
    rect(0,250,300,100);
      textSize(35);
        fill(0);
          text("Posicion del arco",0,320);
            textSize(35);
              fill(0);
               text(n,300,320);
  
  fill(211,211,211);
    rect(0,400,300,100);
      textSize(35);
        fill(0);
         text("Cuerda maximo",0,470);
      textSize(35);
        fill(0);
         text(vien,300,470);
      
   fill(211,211,211);
    rect(0,520,300,100);
      textSize(35);
        fill(0);
         text("Cuerda minimo",0,590);
  
  fill(211,211,211);
    rect(0,650,200,50);
      fill(0);
        text("MENU",30,680);
}



void serialEvent(Serial port) {
    interval = millis();
    while (port.available() > 0) {
        int ch = port.read();

        if (synced == 0 && ch != '$') return;   // initial synchronization - also used to resync/realign if needed
        synced = 1;
        //print ((char)ch);

        if ((serialCount == 1 && ch != 2)
            || (serialCount == 15 && ch != '\r')
            || (serialCount == 16 && ch != '\n'))  {
            serialCount = 0;
            synced = 0;
            return;
        }

        if (serialCount > 0 || ch == '$') {
            teapotPacket[serialCount++] = (char)ch;
            if (serialCount == 17) {
                serialCount = 0; // restart packet byte position
                
                // get quaternion from data packet
                q[0] = ((teapotPacket[2] << 8) | teapotPacket[3]) / 16384.0f;
                q[1] = ((teapotPacket[4] << 8) | teapotPacket[5]) / 16384.0f;
                q[2] = ((teapotPacket[6] << 8) | teapotPacket[7]) / 16384.0f;
                q[3] = ((teapotPacket[8] << 8) | teapotPacket[9]) / 16384.0f;
                /*q[0] = q[0]-calibq[0] ;
                q[1] = q[1]-calibq[1] ;
                q[2] = q[2]-calibq[2] ;
                q[3] = q[3]-calibq[3] ;*/
                 
               
                distTemp = ((teapotPacket[10] << 8) | teapotPacket[11]);
                boton=teapotPacket[12];  
                if(boton==1) {
                  bFlag=true;
                  posXX=Datos.posX;
                  posYY=Datos.posY;
                }
                
                
                
               if(abs(distTemp-ypr[3])<35 || firstRead){
                firstRead=false; 
                ypr[3]=distTemp;
                }
                //println("temp: "+distTemp+"lectura: "+ypr[3]);
                for (int i = 0; i < 4; i++) if (q[i] >= 2) q[i] = -4 + q[i];
                
                // set our toxilibs quaternion to new data
                quat.set(q[0], q[1], q[2], q[3]);

                
                // below calculations unnecessary for orientation only using toxilibs
                
                // calculate gravity vector
                gravity[0] = 2 * (q[1]*q[3] - q[0]*q[2]);
                gravity[1] = 2 * (q[0]*q[1] + q[2]*q[3]);
                gravity[2] = q[0]*q[0] - q[1]*q[1] - q[2]*q[2] + q[3]*q[3];
                
    
                // calculate Euler angles
                euler[0] = atan2(2*q[1]*q[2] - 2*q[0]*q[3], 2*q[0]*q[0] + 2*q[1]*q[1] - 1);
                euler[1] = -asin(2*q[1]*q[3] + 2*q[0]*q[2]);
                euler[2] = atan2(2*q[2]*q[3] - 2*q[0]*q[1], 2*q[0]*q[0] + 2*q[3]*q[3] - 1);
                
                // calculate yaw/pitch/roll angles
                ypr[0] = atan2(2*q[1]*q[2] - 2*q[0]*q[3], 2*q[0]*q[0] + 2*q[1]*q[1] - 1);
                ypr[1] = atan(gravity[0] / sqrt(gravity[1]*gravity[1] + gravity[2]*gravity[2]));
                ypr[2] = atan(gravity[1] / sqrt(gravity[0]*gravity[0] + gravity[2]*gravity[2]));
    
                // output various components for debugging
                //println("q:\t" + round(q[0]*100.0f)/100.0f + "\t" + round(q[1]*100.0f)/100.0f + "\t" + round(q[2]*100.0f)/100.0f + "\t" + round(q[3]*100.0f)/100.0f);
                //println("euler:\t" + euler[0]*180.0f/PI + "\t" + euler[1]*180.0f/PI + "\t" + euler[2]*180.0f/PI);
                //println("ypr:\t" + ypr[0]*180.0f/PI + "\t" + ypr[1]*180.0f/PI + "\t" + ypr[2]*180.0f/PI + "\t" + ypr[3]);
                
                media();
                
                ///////////////////////////calibrar
                calibrar();
                ///////////////media MOVIL
           
        
           
                /////////////////
                
            }
        }
    }
}

void media ()
{
  n=10;
  if (m==0)
  {
    
   datos[i]=ypr[3];
    m=1;
      i=0;
  }

  if(m==1)
  {
      media=media+datos[i];
      i=i+1;
    if(i==n)
    {
      m=2;
    }
  }
  if(m==2)
  {
    promedio=media/n;
    j=j+1;
    i=j;
    media=0;
    if(j==n)
    {
      i=0;
       j=0;
       m=0;
       media=0;
    }
   m=0; 
  }

  }
  
  void calibrar(){
    if(0<calibrar)
                {
                  
                  axis = quat.toAxisAngle();
                  acum=acum+axis[0];
                  println(axis[0]);
                  calibrar++;
                }
                if(100<calibrar)
                {
                  calibrar=0;
                  acum=acum/100;
                  println("new "+acum);
                }
                
                if(0<calibrarMax)
                {
                  
                  acumMax=acumMax+ypr[3];
                  calibrarMax++;
                }
                if(100==calibrarMax)
                {
                  //calibrarMax=0;
                  acumMax=acumMax/100;
                  println("new "+acumMax);
                  Datos.maxCuer=acumMax;

                }
                
                if(0<calibrarMin)
                {
                  
                  acumMin=acumMin+ypr[3];
                  calibrarMin++;
                }
                if(100==calibrarMin)
                {
                  calibrarMin=0;
                  acumMin=acumMin/100;
                  println("new "+acumMin);
                  Datos.minCuer=acumMin;
                }
    
  }
  
