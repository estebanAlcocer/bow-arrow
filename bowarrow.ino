
#include "I2Cdev.h"

#include "MPU6050_6Axis_MotionApps20.h"

#if I2CDEV_IMPLEMENTATION == I2CDEV_ARDUINO_WIRE
    #include "Wire.h"
#endif


MPU6050 mpu;

//push botton
int estado=0;
int val=0;


// quaternion components in a [w, x, y, z] format 
//#define OUTPUT_READABLE_QUATERNION

//Salida en Yaw,pitch, Roll.
//#define OUTPUT_READABLE_YAWPITCHROLL

//para comunicacion serial con processing (FIFO BUFFER)
#define OUTPUT_TEAPOT



#define LED_PIN 13 // parpadea
bool estadoBlink = false;

// MPU control/status variables
bool dmpListo = false;  // TRUE si DMP tiene correcta conexion
uint8_t mpuIntStatus;  
uint8_t devStatus;     
uint16_t packetSize;   
uint16_t fifoCount;    
uint8_t fifoBuffer[64];

//  variables para el DMP
Quaternion q;           // [w, x, y, z]         quaternion container
VectorInt16 aa;         // [x, y, z]            accel sensor 
VectorInt16 aaReal;     // [x, y, z]            gravity-free accel sensor 
VectorInt16 aaWorld;    // [x, y, z]            world-frame accel sensor 
VectorFloat gravity;    // [x, y, z]            gravity vector
float euler[3];         // [psi, theta, phi]    Euler angle
float ypr[3];           // [yaw, pitch, roll]   yaw/pitch/roll

// Estructura de la comunicacion serial.
uint8_t teapotPacket[17] = { '$', 0x02, 0,0, 0,0, 0,0, 0,0, 0,0,  0, 0x00, 0x00, '\r', '\n' };


// ===               INTERRUPT DETECT
volatile bool mpuInterrupt = false;     // indicates whether MPU interrupt pin has gone high
void dmpDataReady() {
    mpuInterrupt = true;
}


void setup() {
    #if I2CDEV_IMPLEMENTATION == I2CDEV_ARDUINO_WIRE
        Wire.begin();
        TWBR = 24;
    #elif I2CDEV_IMPLEMENTATION == I2CDEV_BUILTIN_FASTWIRE
        Fastwire::setup(400, true);
    #endif

     Serial.begin(115200);
    while (!Serial); 
    Serial.println(F("Inicializar I2C ..."));
    mpu.initialize();

    // espera el ready
    Serial.println(F("\Envia cualquier caracter para empezar: "));
    while (Serial.available() && Serial.read()); // vacia el buffer
    while (!Serial.available());                 // espera la data
    while (Serial.available() && Serial.read()); // vacia el buffer

    Serial.println(F("Inicializar DMP..."));
    devStatus = mpu.dmpInitialize();

    // gyro offsets sugeridos 
    mpu.setXGyroOffset(220);
    mpu.setYGyroOffset(76);
    mpu.setZGyroOffset(-85);
    mpu.setZAccelOffset(1788); //

    if (devStatus == 0) {
        Serial.println(F("DMP Enable"));
        mpu.setDMPEnabled(true);

        // Arduino interrupt.
        attachInterrupt(0, dmpDataReady, RISING);
        mpuIntStatus = mpu.getIntStatus();

        dmpListo = true;

        packetSize = mpu.dmpGetFIFOPacketSize();
    } 

    // LED para output
    pinMode(LED_PIN, OUTPUT);
    pinMode(4,INPUT);
 }


//=======================================================

void loop() {
//si falla el dmp no hagas nada
  if (!dmpListo) return;

    // wait MPU interrupt 
    while (!mpuInterrupt && fifoCount < packetSize) {
        
    }

    // reset interrupt
    mpuInterrupt = false;
    mpuIntStatus = mpu.getIntStatus();

    //  FIFO count
    fifoCount = mpu.getFIFOCount();
    
    if (mpuIntStatus & 0x02) {
        while (fifoCount < packetSize) fifoCount = mpu.getFIFOCount();

        mpu.getFIFOBytes(fifoBuffer, packetSize);
        fifoCount -= packetSize;



//posibles salidas para comprobar datos o enviar a processing
        #ifdef OUTPUT_READABLE_QUATERNION
        //quaternions
            mpu.dmpGetQuaternion(&q, fifoBuffer);
            Serial.print("quat\t");
            Serial.print(q.w);
            Serial.print("\t");
            Serial.print(q.x);
            Serial.print("\t");
            Serial.print(q.y);
            Serial.print("\t");
            Serial.println(q.z);
        #endif


        #ifdef OUTPUT_READABLE_YAWPITCHROLL
   //yaw pitch roll
            mpu.dmpGetQuaternion(&q, fifoBuffer);
            mpu.dmpGetGravity(&gravity, &q);
            mpu.dmpGetYawPitchRoll(ypr, &q, &gravity);
            Serial.print("ypr\t");
            Serial.print(ypr[0] * 180/M_PI);
            Serial.print("\t");
            Serial.print(ypr[1] * 180/M_PI);
            Serial.print("\t");
            Serial.println(ypr[2] * 180/M_PI);
        #endif

    
        #ifdef OUTPUT_TEAPOT
            // para processing en serial:
            teapotPacket[2] = fifoBuffer[0];
            teapotPacket[3] = fifoBuffer[1];
            teapotPacket[4] = fifoBuffer[4];
            teapotPacket[5] = fifoBuffer[5];
            teapotPacket[6] = fifoBuffer[8];
            teapotPacket[7] = fifoBuffer[9];
            teapotPacket[8] = fifoBuffer[12];
            teapotPacket[9] = fifoBuffer[13];
            
            /////////////////////////mi codigo
            
            int analog= analogRead(A0);
            
            
            
            
            estado= digitalRead(4);
            if(estado==HIGH)
              val=1;
              else val=0;
            ///////////////////////////////
            //guarda la info del sensor de fuerza
            
            teapotPacket[10] = highByte(analog);
            teapotPacket[11] = lowByte(analog);
            teapotPacket[12] = val;
             //Serial.print(val);
            
            Serial.write(teapotPacket, 17);
            
            
            ////////////debugging ignorar
       /*  Serial.print("   ");
            Serial.print(analog);
            Serial.print("   ");
            Serial.print((teapotPacket[10] << 8) | teapotPacket[11]);*/
           
           ///////debugging ignorar
            /*Serial.println();
            int serial = ((teapotPacket[10] << 8) | teapotPacket[11]);
            Serial.println(serial);
            Serial.print("Real:");
            */
            teapotPacket[13]++;
        #endif

        estadoBlink = !estadoBlink;
        digitalWrite(LED_PIN, estadoBlink);
    }
}
