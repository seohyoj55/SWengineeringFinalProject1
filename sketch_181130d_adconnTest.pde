/*
Thomas Sanchez Lengeling.
 http://codigogenerativo.com/

 KinectPV2, Kinect for Windows v2 library for processing

 Skeleton color map example.
 Skeleton (x,y) positions are mapped to match the color Frame
 */
import processing.serial.*;
import java.awt.*;
import java.awt.event.KeyEvent;

import KinectPV2.KJoint;
import KinectPV2.*;
import processing.serial.*;

import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

Minim minim;
AudioPlayer player;

Serial port;

int lasttimecheck;
int timeinterval;

PrintWriter output;
KinectPV2 kinect;
int cnt=0;
int stcheck = 0;  // exerupper start check flag
int secflag = 0;  // exerupper 2,3 motor check flag
int exerSt = 0;   // exerFull start check flag

void setup() {
  size(1280 , 720, P3D);

  kinect = new KinectPV2(this);

  kinect.enableSkeletonColorMap(true);
  kinect.enableColorImg(true);

  kinect.init();
  output = createWriter("consoletext.txt");
  
  /////////////////////////////////////////// minim player
  //minim = new Minim(this);
  ////player = minim.loadFile("C:\\exc_1.mp3");
  //lasttimecheck =millis();
  //timeinterval=5000;
  //player.play();
  ///////////////////////////////////////////
  
  /////////////////////////////////////modify///////////
  println("Available serial ports:");
  println(Serial.list());
 
   port = new Serial(this, Serial.list()[0], 9600);  
   output.println("conn port");
   output.println();
  /////////////////////////////////////modify///////////
}



void draw() {
  background(0);

  image(kinect.getColorImage(), 0, 0, width, height);

  ArrayList<KSkeleton> skeletonArray =  kinect.getSkeletonColorMap();

  //individual JOINTS
  for (int i = 0; i < skeletonArray.size(); i++) {
    KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
    if (skeleton.isTracked()) {
      KJoint[] joints = skeleton.getJoints();

      color col  = skeleton.getIndexColor();
      fill(col);
      stroke(col);
      drawBody(joints);

      //draw different color for each hand state
      drawHandState(joints[KinectPV2.JointType_HandRight]);
      drawHandState(joints[KinectPV2.JointType_HandLeft]);
      
      if(exerSt==0){
        /////////// standard pose--both hand closed
        if(cnt == 50 && joints[KinectPV2.JointType_HandLeft].getState() == KinectPV2.HandState_Closed && 
                     joints[KinectPV2.JointType_HandRight].getState() == KinectPV2.HandState_Closed )
       {
         //////
           if(angle(joints, KinectPV2.JointType_ElbowLeft)>-0.7 && 
           angle(joints, KinectPV2.JointType_ElbowLeft)< 0.8)
           {
             if(stcheck!=-1)exerUpper(joints);
           }
           else if(angle(joints, KinectPV2.JointType_ElbowRight)>-0.7 && 
           angle(joints, KinectPV2.JointType_ElbowRight)< 0.8)
           {
             if(stcheck!=-1)exerUpper(joints);
           }
           
       } 
       
      }
      //////error exception timeover
       // if(millis()>lasttimecheck +timeinterval)
       //{
       // player = minim.loadFile("C:\\exc_1.mp3");
       // player.play();
       //  lasttimecheck = millis();
       //}

      //////error exception timeover
     
     
      if(cnt == 50 && joints[KinectPV2.JointType_HandLeft].getState() == KinectPV2.HandState_Closed && 
                     joints[KinectPV2.JointType_HandRight].getState() == KinectPV2.HandState_Closed )
       {
         if(stcheck!=-1)exerUpper(joints);
       }

////=====================================================test code===========================================
          //if(cnt == 50 && joints[KinectPV2.JointType_HandLeft].getState() == KinectPV2.HandState_Closed && 
          //                   joints[KinectPV2.JointType_HandRight].getState() == KinectPV2.HandState_Closed )
          //{
          //  int test1 = 100;
          //  println("vibe (no 90') : ",test1);
          //  output.println("vibe (no 90') : " + test1);
          //  //port.write(test1);
            
          //     if(angle(joints, KinectPV2.JointType_ElbowLeft)> -2 && angle(joints, KinectPV2.JointType_ElbowLeft)< 2){
          //       test1 = 200; // 2,3 motor strong(200) vibe 3sec
          //       println("vibe (yes 90') : ",test1);
          //       output.println("vibe (yes 90') : " + test1);
          //       //port.write(test1);
                 
          //      }
                
          //   if(test1 == 200){
          //    //port.write(10);
          //    test1 = 10;
          //    println("vibe change 10 : ",test1);
          //    output.println("vibe change 10 : " + test1);
          //    println();
          //  }
          //}
////======================================================test code=========================================

        
    }
  }
  
  
  if(cnt<50)cnt = cnt+1;
  
  fill(255, 0, 0);
  text(frameRate, 50, 50);
}
void keyPressed() {
  output.flush(); // Writes the remaining data to the file
  output.close(); // Finishes the file
  exit(); // Stops the program
}

// 1 m vibe slow : 1 | 2,3m vibe slow: 2 | 2,3m vibe strong: 3
// 1,4m vibe slow: 4 | 1,4m vibe strong : 5
void exerUpper(KJoint[] joints){
  // voice 
  
  int imp=0;int cnt=0,i=0;
  float temp=0.0;
  
  // start check==0 motor1 vibe
  if(stcheck==0){
    // motor 1 vibe(100), voice
    imp = 1;
    port.write(imp);
    //delay(000); // 2sec delay
    stcheck = stcheck+1;
    
    // voice : 5
  }
  
  // 5 loop
  if(stcheck>=1 && stcheck <6){
    imp = 2; // 2,3 motor slow vib
    port.write(imp);
    
    //standard form : handstate closed + delay

        int test1 = 100;
        
        if(secflag==0){
          println("2, 3 motor vibe 100 : ",test1);
          output.println("2, 3 motor vibe 100 : " + test1);
          port.write(2); //2,3m vibe slow: 2
          //delay(2000);
        }
        
        // 90' ->  2,3 motor strong(200) vibe 3sec
       if(secflag==0 && angle(joints, KinectPV2.JointType_ElbowLeft)>0.9 && angle(joints, KinectPV2.JointType_ElbowLeft)< 2){
         test1 = 200; 
         println("2, 3 motor vibe 200 : ",test1);
         output.println("2, 3 motor vibe 200 : " + test1);
         port.write(3);  // 2,3 motor strong(200) vibe 3sec
         //delay(2000);   /// 2~3sec delay
         secflag=1;
         
         //imp = 2036; // 2,3 motor strong(200) vibe 3sec
         //port.write(imp);

        }

          // 1,4 slow vibe   
        if(secflag==1){
                   
         // 1,4 motor vibe 100
          test1 = 100;
          println("1,4 motor vibe 100 : ",test1);
          output.println("1,4 motor vibe 100 : " + test1);
          port.write(4);
          println();

        
        //1,4 strong vibe  180'
        if(secflag==1 && angle(joints, KinectPV2.JointType_ElbowLeft)> -0.7 && angle(joints, KinectPV2.JointType_ElbowLeft)< 0.5){
                   
         // 1,4 motor vibe 100
          test1 = 200;
          println("1,4 motor vibe 200 : ",test1);
          output.println("1,4 motor vibe 200 : " + test1);
          println();
          port.write(5);

          // loop flag++
          stcheck = stcheck + 1;
          output.println("stcheck:  " + stcheck);
          output.println();
          println("stcheck:  " + stcheck
          );
          println();
          
          secflag=0;
          }
        }
  }// 5 loop if end 
  else if(stcheck == 6){ // loop stop
    output.println("kcal: 9");
    output.println();
    println("kcal: 9");
    println();
    stcheck = -1;
    exerSt = 1;
    port.write(0);
  }
  
  if(cnt<50) cnt= cnt+1;
  
}//func exerUpper end

float angle(KJoint[] joints, int jointType) {
  // lShoulder, lElbow, lHand
  // KinectPV2.JointType_ShoulderLeft  KinectPV2.JointType_ElbowLeft  
  // KinectPV2.JointType_HandLeft
  
  // rShoulder, lShoulder, lElbow
  // KinectPV2.JointType_ShoulderRight  KinectPV2.JointType_ElbowLeft
  // KinectPV2.JointType_ShoulderLeft
  float angle01=0.0;
  float angle02=0.0;
  float ang;
  int j1=0,j2=0,j3=0;
  if(jointType == KinectPV2.JointType_ElbowLeft)
  {  
    j1 = KinectPV2.JointType_ShoulderLeft;
    j2 = KinectPV2.JointType_ElbowLeft;
    j3 = KinectPV2.JointType_WristLeft;
  }
  else if(jointType == KinectPV2.JointType_ShoulderLeft){
    j1 = KinectPV2.JointType_SpineShoulder;
    j2 = KinectPV2.JointType_ElbowLeft;
    j3 = KinectPV2.JointType_ShoulderLeft;
  }
  angle01 = atan2(joints[j1].getY() - joints[j2].getY(), joints[j1].getX() - joints[j2].getX());
  angle02 = atan2(joints[j2].getY() - joints[j3].getY(), joints[j2].getX() - joints[j3].getX());
  ang = angle02 - angle01;
  return ang;
}

//DRAW BODY
void drawBody(KJoint[] joints) {
  drawBone(joints, KinectPV2.JointType_Head, KinectPV2.JointType_Neck);
  drawBone(joints, KinectPV2.JointType_Neck, KinectPV2.JointType_SpineShoulder);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_SpineMid);
  drawBone(joints, KinectPV2.JointType_SpineMid, KinectPV2.JointType_SpineBase);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderRight);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderLeft);

  // Right Arm
  drawBone(joints, KinectPV2.JointType_ShoulderRight, KinectPV2.JointType_ElbowRight);
  drawBone(joints, KinectPV2.JointType_ElbowRight, KinectPV2.JointType_WristRight);
  drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_HandRight);
  drawBone(joints, KinectPV2.JointType_HandRight, KinectPV2.JointType_HandTipRight);
  drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_ThumbRight);

  // Left Arm
  drawBone(joints, KinectPV2.JointType_ShoulderLeft, KinectPV2.JointType_ElbowLeft);
  drawBone(joints, KinectPV2.JointType_ElbowLeft, KinectPV2.JointType_WristLeft);
  drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_HandLeft);
  drawBone(joints, KinectPV2.JointType_HandLeft, KinectPV2.JointType_HandTipLeft);
  drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_ThumbLeft);

  drawJoint(joints, KinectPV2.JointType_HandTipLeft);
  drawJoint(joints, KinectPV2.JointType_HandTipRight);
  drawJoint(joints, KinectPV2.JointType_ThumbLeft);
  drawJoint(joints, KinectPV2.JointType_ThumbRight);

  drawJoint(joints, KinectPV2.JointType_Head);
 
}


//draw joint
void drawJoint(KJoint[] joints, int jointType) {
  pushMatrix();
  translate(joints[jointType].getX(), joints[jointType].getY(), joints[jointType].getZ());
  ellipse(0, 0, 25, 25);
  /////////////////////////////////////modify///////////
  if(joints[jointType].getX()<500 &&joints[jointType].getY() > 100 && secflag != 1){
    println(joints[jointType].getX(),joints[jointType].getY());
    float temp = map(joints[jointType].getX(), 0, 500, 0, 255); 
    int imp = (int)temp;
    println(imp);
    temp = angle(joints, KinectPV2.JointType_ElbowLeft);
    println("angle elbow "+ temp);
    output.println("angle elbow "+ temp);
    temp = angle(joints, KinectPV2.JointType_ShoulderLeft);
    println("angle shoulder "+ temp);
    output.println("angle shoulder "+temp);
    
  /////////////////////////////////////modify///////////
  
    
  }
   
  popMatrix();
}

//draw bone
void drawBone(KJoint[] joints, int jointType1, int jointType2) {
  pushMatrix();
  //translate(joints[jointType1].getX(), joints[jointType1].getY(), joints[jointType1].getZ());
  ellipse(0, 0, 25, 25);
  popMatrix();
  line(joints[jointType1].getX(), joints[jointType1].getY(), joints[jointType1].getZ(), joints[jointType2].getX(), joints[jointType2].getY(), joints[jointType2].getZ());
}

//draw hand state
void drawHandState(KJoint joint) {
  noStroke();
  handState(joint.getState());
  pushMatrix();
  translate(joint.getX(), joint.getY(), joint.getZ());
  ellipse(0, 0, 70, 70);
  popMatrix();
}

/*
Different hand state
 KinectPV2.HandState_Open
 KinectPV2.HandState_Closed
 KinectPV2.HandState_Lasso
 KinectPV2.HandState_NotTracked
 */
void handState(int handState) {
  switch(handState) {
  case KinectPV2.HandState_Open:
    fill(0, 255, 0);
    break;
  case KinectPV2.HandState_Closed:
    fill(255, 0, 0);
    break;
  case KinectPV2.HandState_Lasso:
    fill(0, 0, 255);
    break;
  case KinectPV2.HandState_NotTracked:
    fill(255, 255, 255);
    break;
  }
}
