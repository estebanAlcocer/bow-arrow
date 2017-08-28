import javax.swing.JOptionPane;


static class Datos {
//Datos recibidos

/*
float distPrimera;

float sensorCuer;
float anguloX;
float anguloY;
*/

//Datos calculados
static float distFinal;
static float vo;
static float voY;
static float voX;
static float tiempo;
static float posY;
static float posX;

//para calcular la formula de distancia a Vo
static float maxCuer=50;
static float minCuer=35;
static float maxVel=56;
static float g = 9.8;

 static void calcular(float distPrimera, float sensorCuer, float anguloX, float anguloY) 
{
  //prueba pidiendo datos
  
  /*distPrimera=Float.parseFloat(JOptionPane.showInputDialog("Dame la distancia (10-100m)"));
  sensorCuer=Float.parseFloat(JOptionPane.showInputDialog("Dame sensor cuerda"));
  anguloX=Float.parseFloat(JOptionPane.showInputDialog("Dame angulo X"));
  anguloY=Float.parseFloat(JOptionPane.showInputDialog("Dame angulo Y"));*/
  
  //de la primera distancia a la distancia con ajuste del angulo x
  // y formula para X 
  
  distFinal=distPrimera/cos(2*PI*anguloX/360);
  posX=distPrimera*tan(2*PI*anguloX/360);
  
  //formula d sensor a VO
  if(minCuer >= sensorCuer)
  vo = (maxVel*(sensorCuer-minCuer))/(maxCuer-minCuer);
  else vo=0;
  
  if(maxCuer >= sensorCuer )
  vo=56;
  //print(vo+",")
  
  //formula para el tiempo
  voX = vo*cos(2*PI*anguloY/360);
  voY = vo*sin(2*PI*anguloY/360);
  tiempo = distFinal/voX; 
  
  //formula para Y
  
  posY= voY*tiempo-(g*pow(tiempo, 2.0)/2);
  
  
  println("vo: "+vo);
  println("angulo x: "+anguloX);
  println("angulo y: "+anguloY);  
  println("tiempo: "+ tiempo);
  println("pos x: "+ posX);
  println("pos y: "+posY);
  println("nueva dist: "+ distFinal);
  

  
}

}


