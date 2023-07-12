
final float ORIENTATION_INCREMENT = PI/32 ;
final float SAT_RADIUS = 0.1f ;


class Sprite{

 float MAX_SPEED;
 int x;
 int y;
 int[][] tiles;


 boolean monsterAggro = false;
 boolean alive = true;

 PImage img; //current image of sprite


 int health, maxHealth, power, maxPower, defence, maxDefence, luck, experience, maxExperience, level, gold;



  // Static Data
   PVector position ;
  float orientation ;
  // Kinematic Data
  PVector velocity ;

 Sprite(int x, int y, float orientation, float xVel, float yVel, int[][] tiles, float maxSpeed, int power, int givenHealth){

    position = new PVector(x, y) ;
  this.tiles = tiles;
  this.orientation = orientation ;
  velocity = new PVector(xVel, yVel) ;
  this.MAX_SPEED = maxSpeed;
  this.power = power;
  maxPower = power;

  this.health = givenHealth;
  maxHealth = health;

  defence = 10;
  maxDefence = defence;

  luck = 10;

  experience = 0;
  maxExperience = 25;

  level = 0;
  
  gold = 0;

 }




  //update position and orientation
  //from studres "KinematicArriveSketch" https://studres.cs.st-andrews.ac.uk/CS4303/Lectures/W6/AI3/KinematicArriveSketch/
  void integrate(PVector targetVel, int[][] tiles) {
    this.tiles = tiles;

    float distance = targetVel.mag() ;
   
    // If close enough, done.
    if (distance < SAT_RADIUS) return ;
   
    velocity = targetVel.get() ;
    if (distance > MAX_SPEED) {
      velocity.normalize() ;
      velocity.mult(MAX_SPEED) ;
    }

    PVector oldPos = new PVector(position.x, position.y);

    position.add(velocity) ;
    // Apply an impulse to bounce off the edge of the screen
    if ((position.x < 0) || (position.x > width)) velocity.x = -velocity.x ;
    if ((position.y < 0) || (position.y > height)) velocity.y = -velocity.y ;
       
    //move a bit towards velocity:
    // turn vel into orientation
    float targetOrientation = atan2(velocity.y, velocity.x) ;
   
    // Will take a frame extra at the PI boundary
    if (abs(targetOrientation - orientation) <= ORIENTATION_INCREMENT) {
      orientation = targetOrientation ;
      return ;
    }

    // if it's less than me, then how much if up to PI less, decrease otherwise increase
    if (targetOrientation < orientation) {
      if (orientation - targetOrientation < PI) orientation -= ORIENTATION_INCREMENT ;
      else orientation += ORIENTATION_INCREMENT ;
    }
    else {
     if (targetOrientation - orientation < PI) orientation += ORIENTATION_INCREMENT ;
     else orientation -= ORIENTATION_INCREMENT ; 
    }
   
    // Keep in bounds
    if (orientation > PI) orientation -= 2*PI ;
    else if (orientation < -PI) orientation += 2*PI ; 



  }



};
