import java.util.*;

int numtiles = 50;
int numRectangles = 10; // number of rectangles or "rooms" to draw
int[][] rects; // array to store coordinates of rectangles or "rooms"
int[][] tiles;

Sprite player;
float targetX, targetY;
PVector pTargetVel;

Sprite[] monsters;
float[] monsterTargets;
PVector[] monsterVelocities;


boolean debug = false; //change to true to see some debugging print statements


//movement booleans
boolean movingLeft = false ;
boolean movingRight = false ;
boolean movingUp = false ;
boolean movingDown = false ;

//inventory variables
boolean inventoryOpen = false; // flag to indicate if the inventory is open
int inventorySize = 16;
boolean[] inventory = new boolean[inventorySize]; // array to hold the player's potions, true is potion, false is empty
int nextInventorySlot = 0; // the next available slot in the inventory

//fighting variables
boolean fighting = false;
int monsterFighting = 0;
boolean playerTurn = true;

int dungeonLevel = 1;



//player images
PImage playerRight, playerLeft, playerRunLeft, playerRunRight, playerAttack, playerBlock;

//monster images
PImage monsterRight, monsterLeft, monsterAggroRight, monsterAggroLeft, monsterAttack;

//item images
PImage sword, armour, potion;

boolean popup = false;
String popupMsg;
int popupTimer;

boolean levelUp = false;

boolean gamefinished = false;

String fightMsg = "";

boolean blocking;


void setup(){
 
    loadTextures();

    fullScreen();
    background(#000000);

    //make world
    makeRooms();
    makeCorridors();

    //repeat until layout is valid
    while(!checkLayout()){
        makeRooms();
        makeCorridors();
    }
   
    //make sprites
    spawnPlayer();
    spawnMonsters();

   
    setSpecialTiles();

    popup = true;
    popupMsg = "Welcome to the dungeon!\nUse the WASD keys to move.\nPress E to open your inventory at any time.\nPress 'esc' to close the game.";
    popupMsg += "\n\nDefeat all goblins before reaching the green tile to progress.\n\n Red sword tiles will repair your sword. \n Blue armour tiles will repair your armour. \n Potions can be used mid fight to replenish health.";
    popupMsg += "\n\nTry to get as much gold as you can before either dying\nor completing the dungeon.\n\n Good luck!!";
    popupTimer = -400;

}

void setSpecialTiles(){


    //set end tile to bottom right corner of last room
    int endX = rects[numRectangles-1][2]-1;
    int endY = rects[numRectangles-1][3]-1;
    if(endX >= numtiles) endX = numtiles-1;
    if(endY >= numtiles) endY = numtiles-1;
    tiles[endX][endY] = 2;

    //set sword tiles to middle of 2nd, 5th and 8th room
    setSpecialTile(1, 3);
    setSpecialTile(4, 3);
    setSpecialTile(7, 3);

    //set armour tile to middle of 3rd, 6th and 9th room
    setSpecialTile(2, 4);
    setSpecialTile(5, 4);
    setSpecialTile(8, 4);


    //set potion tile to middle of 4th,7th, 10th and corner of 1st room
    setSpecialTile(3, 5);
    setSpecialTile(6, 5);
    setSpecialTile(9, 5);

    int itemX = rects[0][2]-1;
    int itemY = rects[0][3]-1;
    if(itemX >= numtiles) itemX = numtiles-1;
    if(itemY >= numtiles) itemY = numtiles-1;
    tiles[itemX][itemY] = 5;
   

  
}

void setSpecialTile(int room, int item){
    //sets middle tile of given room to the given item
    int itemX = rects[room][0] + (((rects[room][2] -1)- rects[room][0]) / 2);
    int itemY = rects[room][1] + (((rects[room][3] -1) - rects[room][1])/2);
    if(itemX >= numtiles) itemX = numtiles-1;
    if(itemY >= numtiles) itemY = numtiles-1;
    tiles[itemX][itemY] = item;
}


void loadTextures(){
  //https://camkoalatixd.itch.io/2d-knight-platformer
  playerRight = loadImage("textures/playerRight.png", "png");
  playerLeft = loadImage("textures/playerLeft.png", "png");
  playerRunRight = loadImage("textures/playerRunRight.png", "png");
  playerRunLeft = loadImage("textures/playerRunLeft.png", "png");
  playerAttack = loadImage("textures/playerAttack.png", "png");
  playerBlock = loadImage("textures/playerBlock.png", "png");
  
  //https://camkoalatixd.itch.io/2d-goblin-enemies
  monsterLeft = loadImage("textures/monsterLeft.png", "png");
  monsterRight = loadImage("textures/monsterRight.png", "png");
  monsterAggroLeft = loadImage("textures/monsterAggroLeft.png", "png");
  monsterAggroRight = loadImage("textures/monsterAggroRight.png", "png");
  monsterAttack = loadImage("textures/monsterAttack.png", "png");

  //https://game-icons.net/1x1/lorc/breastplate.html#download
  armour = loadImage("textures/armour.png", "png");

  //https://game-icons.net/1x1/delapouite/two-handed-sword.html#download
  sword = loadImage("textures/sword.png", "png");

  //https://game-icons.net/1x1/caro-asercion/round-potion.html#download
  potion = loadImage("textures/potion.png", "png");

}

void draw(){


    if(!fighting && !levelUp){
      drawTiles();
      drawPlayer();
      drawMonsters();
      drawStats();
    } else if (fighting) {
      drawFight();
    } 

    if(popup) drawPopup();


    
    if (inventoryOpen) drawInventory();
 
}   

void drawStats(){
  //grey background
  fill(#3a3b3c, 100);
  rect(0, 0, numtiles*10, numtiles*10);

 

  //draw player health bar from health out of max health
  fill(#00ff00);
  textSize(numtiles/2);
  text("Health: ", numtiles/2, numtiles);

  stroke(#00ff00);
  noFill();
  rect(numtiles*3, numtiles/2, player.maxHealth *numtiles/12, numtiles/2);
  stroke(#00ff00);
  fill(#00ff00);
  rect(numtiles*3, numtiles/2, player.health *numtiles/12, numtiles/2);

  //draw player power bar
  fill(#ff0000);
  textSize(numtiles/2);
  text("Sword: ", numtiles/2, numtiles*2);


  stroke(#ff0000);
  noFill();
  rect(numtiles*3, numtiles + numtiles/2, player.maxPower *numtiles/12, numtiles/2);
  stroke(#ff0000);
  fill(#ff0000);
  rect(numtiles*3, numtiles + numtiles/2, player.power *numtiles/12, numtiles/2);
  

  //draw player defence bar
  fill(#48BAFF);
  textSize(numtiles/2);
  text("Armour: ", numtiles/2, numtiles*3);

  stroke(#48BAFF);
  noFill();
  rect(numtiles*3, numtiles*2 + numtiles/2, player.maxDefence *numtiles/12, numtiles/2);
  stroke(#48BAFF);
  fill(#48BAFF);
  rect(numtiles*3, numtiles*2 + numtiles/2, player.defence *numtiles/12, numtiles/2);

  //draw player luck bar
  fill(#ffff00);
  textSize(numtiles/2);
  text("Luck: ", numtiles/2, numtiles*4);


  stroke(#ffff00);
  fill(#ffff00);
  rect(numtiles*3, numtiles*3 + numtiles/2, player.luck*numtiles/12, numtiles/2);

  //draw player speed bar

  fill(#D3D3D3);
  textSize(numtiles/2);
  text("Speed: ", numtiles/2, numtiles*5);


  stroke(#D3D3D3);
  fill(#D3D3D3);
  rect(numtiles*3, numtiles*4 + numtiles/2, player.MAX_SPEED*numtiles/12, numtiles/2);



  //draw player level as number
  fill(255);
  textSize(numtiles);
  text("Level: " + player.level, numtiles/2, numtiles*6 + numtiles/2);

    //draw player experience bar
  stroke(#023020);
  noFill();
  rect(numtiles/2, numtiles*6 + numtiles, player.maxExperience*numtiles/12, numtiles/2);
  stroke(#023020);
  fill(#023020);
  rect(numtiles/2, numtiles*6 + numtiles, player.experience*numtiles/12, numtiles/2);


  //draw player gold as number
  fill(255);
  textSize(numtiles*2/3);
  text("Gold: " + player.gold, numtiles/2, numtiles*8 + numtiles/2);

  //draw dungeon level
  fill(255);
  textSize(numtiles/2);
  text("Dungeon Level: " + dungeonLevel +"/5", numtiles/2, numtiles*9 + numtiles/2);

  noStroke();

}

void drawFight(){

  //grey background
  fill(#3a3b3c, 20);
  rect(numtiles*5, numtiles*5, displayWidth - numtiles*10, displayHeight - numtiles*10);


  // draw player and enemy health bars
  stroke(#00ff00);
  noFill();
  rect(numtiles*6, displayHeight - numtiles*10, player.maxHealth*numtiles/10, numtiles/2);
  noStroke();
  fill(0, 255, 0, 20);
  rect(numtiles*6, displayHeight - numtiles*10, player.health*numtiles/10, numtiles/2);

  stroke(#ff0000);
  noFill();
  rect(displayWidth - numtiles*15, displayHeight - numtiles*10, monsters[monsterFighting].maxHealth*numtiles/10, numtiles/2);
  noStroke();
  fill(255, 0, 0, 20);
  rect(displayWidth - numtiles*15, displayHeight - numtiles*10, monsters[monsterFighting].health*numtiles/10, numtiles/2);
  

  // draw player and enemy sprites
  image(player.img, numtiles*6, numtiles*10, numtiles*8, numtiles*8);
  image(monsters[monsterFighting].img, numtiles*35, numtiles*10, numtiles*8, numtiles*8);
  
  fill(#FFFFFF);
  textSize(numtiles);
  text("An angry goblin approaches you!\n\tPress 1 to attack\n\tPress 2 to block\n\tPress 3 to use a potion", displayWidth/2 - numtiles*6, numtiles*8);

  textSize(numtiles/2);
  text(fightMsg, displayWidth/2 - numtiles*6, numtiles*15);

}

void drawPopup(){



  //if(popupTimer < 100){
    fill(100, 200);
    rect(displayWidth/2 - numtiles*2, displayHeight/2  - numtiles*2 , numtiles * 8, numtiles * 8);
    textSize(15);
    fill(255);
    text(popupMsg, displayWidth/2 - numtiles*2, displayHeight/2 - numtiles*3/2);
  //}


  

    if(popupTimer >= 100 && !levelUp && !gamefinished){
    popup = false;
    popupTimer = 0;
    }

    popupTimer++;

}

void monsterDead() {
  // fill(0);
  // textSize(30);
  // text(message, width/2, height/2);
  monsters[monsterFighting].alive = false;
  fighting = false;
  fightMsg = "";

  player.gold += 10;
  player.experience += 34;
  player.power *=(0.8);
  player.defence *=(0.8);

  player.img = playerRight;

 popup = true;
 popupMsg = "You have defeated the goblin!\nYou have gained 10 gold and some level experience!";
 popupTimer = 0;



 //luck check
 if(random(0,100) <= player.luck){
   player.gold += 100;
   popupMsg += "\n\nYou must be lucky...\nthe goblin was carrying some valuable treasure worth 100 gold!";
 }

 //level up check
  if(player.experience >= player.maxExperience){
    levelUp = true;
    player.level++;
    player.experience = 0;
    if(player.maxExperience < 100) player.maxExperience += 20; else player.maxExperience = 100;
    popupMsg += "\n\nYou have leveled up!\nChoose a stat to increase by clicking on its meter in the top left";

      drawTiles();
      drawPlayer();
      drawMonsters();
      drawStats();

  }

}

void spawnPlayer(){
    player = initCharacter(0, 6f, 10, 50);
    targetX = player.position.x ;
    targetY = player.position.y ;
    pTargetVel = new PVector(0, 0) ;
    player.img = playerRight;
}

Sprite initCharacter(int room, float maxSpeed, int power, int health){
    //set character starting coordinate to the center of the given room
    int startX = rects[room][0] + (((rects[room][2] -1)- rects[room][0]) / 2);
    int startY = rects[room][1] + (((rects[room][3] -1) - rects[room][1])/2) ;
   
    //convert from tiles to pixels
    startX*=(displayWidth/numtiles);
    startY*=(displayHeight/numtiles);

    //check over bounds
    if(startX > displayWidth) startX = displayWidth-numtiles/5;
    if(startY > displayHeight) startY = displayHeight-numtiles/5;
    if(startX < 0) startX = numtiles/5;
    if(startY < 0) startY = numtiles/5;

    return new Sprite(startX, startY, 0f, 1f, 1f, tiles, maxSpeed, power, health);
}

void spawnMonsters(){
   
    //one monster for each room other than the first
    monsters = new Sprite[numRectangles-1];
   

    //two targets for each monster
    monsterTargets = new float[monsters.length*2];

    int firstPair = 0;
    for(int i = 0; i < monsters.length; i++){

        //create a monster
        monsters[i] = initCharacter(i+1, 2f+dungeonLevel, 4 * dungeonLevel, 30 + (dungeonLevel * 10));

        //set targets to the starting position of the monster
        monsterTargets[firstPair] = monsters[i].position.x;
        monsterTargets[firstPair+1] = monsters[i].position.y;

        //set image
        monsters[i].img = monsterLeft;

        firstPair+=2;
    }


    //one velocity for each monster
    monsterVelocities = new PVector[monsters.length];


    //set all velocities to 0
    for(int i = 0; i < monsterVelocities.length; i++){
        monsterVelocities[i] = new PVector(0, 0);
    }

}

void drawPlayer(){

    float oldTargetX = targetX ;
    float oldTargetY = targetY ;


      if(movingLeft){
                                      targetX = player.position.x - numtiles/10 - player.MAX_SPEED;
                                      player.img = playerRunLeft;
      }     
      if(movingRight){
                                      targetX = player.position.x + numtiles/10 + player.MAX_SPEED;
                                      player.img = playerRunRight;
      }   
      if(movingUp)                    targetY = player.position.y - numtiles/10 - player.MAX_SPEED;
      if(movingDown)                  targetY = player.position.y + numtiles/10 + player.MAX_SPEED;  



      if(!movingLeft && !movingRight && !movingUp && !movingDown){
        if(player.orientation > 0 && player.orientation < PI/2){
        player.img = playerRight;
        }
        else if(player.orientation > PI/2 && player.orientation < PI){
          player.img = playerLeft;
        }
        else if(player.orientation > -PI && player.orientation < -PI/2){
          player.img = playerLeft;
        }
        else if(player.orientation > -PI/2 && player.orientation < 0){
          player.img = playerRight;
        }
      }


    color c = get((int) targetX,(int) targetY);
      if( c == #000000){
        targetX = oldTargetX;
        targetY = oldTargetY;
      }
     else if (targetX >= displayWidth-numtiles/10 || targetX <= 0 || targetY >= displayHeight-numtiles/10 || targetY <= 0){
        targetX = oldTargetX;
        targetY = oldTargetY;
      }


    //from studres "KinematicArriveSketch" https://studres.cs.st-andrews.ac.uk/CS4303/Lectures/W6/AI3/KinematicArriveSketch/
    float xe = player.position.x, ye = player.position.y ;
    fill(0,0,255) ;
    //ellipse(xe, ye, 30, 30) ;
    image(player.img, xe-numtiles/2, ye-numtiles/2, numtiles*1.2, numtiles*1.2);

    // Show orientation
    // int newxe = (int)(xe + 10 * cos(player.orientation)) ;
    // int newye = (int)(ye + 10 * sin(player.orientation)) ;
    // fill(0);
    // ellipse(newxe, newye, 10, 10) ;
   
    //ellipse(newxe, newye, 10, 10) ; 
   
    // Update Eno
    pTargetVel.x = targetX - xe ;
    pTargetVel.y = targetY - ye ;
    player.integrate(pTargetVel, tiles) ;
    //end from studres


    //check if player is on end tile
    int tileX = (int) player.position.x/(displayWidth/numtiles);
    int tileY = (int) player.position.y/(displayHeight/numtiles);

    if(tileX >= numtiles) tileX = numtiles-1;
    if(tileY >= numtiles) tileY = numtiles-1;


    if(tiles[tileX][tileY] == 2){
    boolean monsterAlive = false;
      for(int i = 0; i < monsters.length; i++){
        if(monsters[i].alive){
          monsterAlive = true;
        }
      }
      if(!monsterAlive){
        if(dungeonLevel == 5){
          popup = true;
          popupMsg = "Well done! You made it through all five dungeon levels.\nYou made it to level " + player.level + " and collected " + player.gold + " gold.\nClick anywhere on the screen to restart."; 
          popupTimer = 0;
          gamefinished = true;
        } else {
            dungeonLevel +=1;
            popup = true;
            popupTimer = -100;
            popupMsg = "Well done on completing dungeon level " + (dungeonLevel-1) + "!\nComplete the next " + (5-dungeonLevel) + " levels to win the game";
            popupMsg += "\n\n As you go deeper into the dungeon, \nyou notice the goblins to be a bit faster and tougher than before...";
            popupMsg += "\n\n Luckily the break from goblin killing\n has given you time to restore your health\n and repair your sword and armour.";
            player.power = player.maxPower;
            player.defence = player.maxDefence;
            player.health = player.maxHealth;
            nextLevel();
        }
      }else {
        popup = true;
        popupMsg = "You must kill all the monsters before you can leave this level.";
        popupTimer = 50;
      }
    } else if (tiles[tileX][tileY] == 3){
      if(player.power < player.maxPower){
        //repair sword
        player.power = player.maxPower;
        tiles[tileX][tileY] = 1;

        popup = true;
        popupMsg = "Your sword has been repaired and now deals its full damage.";
        popupTimer = 30;

      } else {
        popup = true;
        popupMsg = "Your sword is already fully repaired.";
        popupTimer = 30;
      }

    } else if (tiles[tileX][tileY] == 4){
      if(player.defence < player.maxDefence){
        //repair armour
        player.defence = player.maxDefence;
        tiles[tileX][tileY] = 1;

        popup = true;
        popupMsg = "Your armour has been repaired and now provides its full defence";
        popupTimer = 30;


      } else {
        popup = true;
        popupMsg = "Your armour is already fully repaired.";
        popupTimer = 30;
      }
    } else if (tiles[tileX][tileY] == 5){
      //potion
      if(nextInventorySlot <= inventorySize-1){
       inventory[nextInventorySlot] = true;
      nextInventorySlot++;
      tiles[tileX][tileY] = 1;
      } else {
        popup = true;
        popupMsg = "Your inventory is full. You must use a potion before you can pick up another.";
        popupTimer = 30;
      }
     
    } 

}

void nextLevel(){
    //make world
    makeRooms();
    makeCorridors();

    //repeat until layout is valid
    while(!checkLayout()){
        makeRooms();
        makeCorridors();
    }

    spawnMonsters();

    //update player 
    int startX = rects[0][0] + (((rects[0][2] -1)- rects[0][0]) / 2);
    int startY = rects[0][1] + (((rects[0][3] -1) - rects[0][1])/2) ;
   
    //convert from tiles to pixels
    startX*=(displayWidth/numtiles);
    startY*=(displayHeight/numtiles);

    //check over bounds
    if(startX > displayWidth) startX = displayWidth-numtiles/5;
    if(startY > displayHeight) startY = displayHeight-numtiles/5;
    if(startX < 0) startX = numtiles/5;
    if(startY < 0) startY = numtiles/5;

    player.position.x = startX;
    player.position.y = startY;
    targetX = player.position.x ;
    targetY = player.position.y ;
    player.img = playerRight;

    setSpecialTiles();

}

void drawMonsters(){

 int firstPair = 0;
    for(int i = 0; i < monsters.length; i++){
      if(monsters[i].alive){
        if(monsters[i].monsterAggro){
          drawAggro(i, firstPair);
        } else {
          drawIdle(i, firstPair);
        }
      }
      firstPair += 2;
    }

}

void drawIdle(int i, int firstPair){
    float oldTargetX = monsterTargets[firstPair];
    float oldTargetY = monsterTargets[firstPair + 1];
 

    switch((int) random(0,100)){
      case 0:
        monsterTargets[firstPair] = monsters[i].position.x + (random(0,numtiles));
        monsters[i].img = monsterRight;
        break;
      case 1:
        monsterTargets[firstPair] = monsters[i].position.x - (random(0,numtiles));
        monsters[i].img = monsterLeft;
        break;
      case 2:
        monsterTargets[firstPair + 1] = monsters[i].position.y + (random(0,numtiles));
        break;
      case 3:
        monsterTargets[firstPair + 1] = monsters[i].position.y - (random(0,numtiles));
        break;
      default :
      break; 
    }

    color c = get((int) monsterTargets[firstPair],(int) monsterTargets[firstPair + 1]);
      //if( c == #000000 || c == #FF0000 || c == #00FF00){
      if( c == #000000){
        monsterTargets[firstPair] = oldTargetX;
        monsterTargets[firstPair + 1] = oldTargetY;
      }else if (monsterTargets[firstPair] >= displayWidth-numtiles/10 || monsterTargets[firstPair] <= 0 || monsterTargets[firstPair + 1] >= displayHeight-numtiles/10 || monsterTargets[firstPair + 1] <= 0){
        monsterTargets[firstPair] = oldTargetX;
        monsterTargets[firstPair + 1] = oldTargetY;
      }

 
  //from studres "KinematicArriveSketch" https://studres.cs.st-andrews.ac.uk/CS4303/Lectures/W6/AI3/KinematicArriveSketch/
  float xe = monsters[i].position.x, ye = monsters[i].position.y ;
  fill(0,255,0) ;
  //ellipse(xe, ye, 30, 30) ;
  image(monsters[i].img, xe-numtiles/2, ye-numtiles/2, numtiles*1.1, numtiles*1.1);



  // Show orientation
  // int newxe = (int)(xe + 10 * cos(monsters[i].orientation)) ;
  // int newye = (int)(ye + 10 * sin(monsters[i].orientation)) ;
  // fill(0);
  // ellipse(newxe, newye, 10, 10) ; 
 
  // Update Eno
  monsterVelocities[i].x =  monsterTargets[firstPair] - xe;
  monsterVelocities[i].y =  monsterTargets[firstPair + 1] -ye;
 
  //print(mTargetVel);

  monsters[i].integrate(monsterVelocities[i], tiles);
  //end from studres





  if(monsters[i].position.x >=  player.position.x - numtiles*4 && monsters[i].position.x <=  player.position.x ){
      if (monsters[i].position.y >=  player.position.y - numtiles*4 && monsters[i].position.y <=  player.position.y ){
       monsters[i].monsterAggro = true;
       monsters[i].MAX_SPEED = 8f + 2*dungeonLevel;
    } else if (monsters[i].position.y <=  player.position.y + numtiles*4 && monsters[i].position.y >=  player.position.y ){
        monsters[i].monsterAggro = true;
           monsters[i].MAX_SPEED =  8f + 2*dungeonLevel;
    }
  }
  
  
  if (monsters[i].position.x <=  player.position.x + numtiles*4 && monsters[i].position.x >=  player.position.x ){
       if (monsters[i].position.y >=  player.position.y - numtiles*4 && monsters[i].position.y <=  player.position.y ){
       monsters[i].monsterAggro = true;
          monsters[i].MAX_SPEED =  8f + 2*dungeonLevel;
    } else if (monsters[i].position.y <=  player.position.y + numtiles*4 && monsters[i].position.y >=  player.position.y ){
        monsters[i].monsterAggro = true;
           monsters[i].MAX_SPEED =  8f + 2*dungeonLevel;
    }
  } 
  


}

void drawAggro(int i, int firstPair){
     
    float oldTargetX = monsterTargets[firstPair];
    float oldTargetY = monsterTargets[firstPair + 1];
 
    if(player.position.x > monsters[i].position.x){
        monsterTargets[firstPair] = monsters[i].position.x + numtiles/10;
        monsters[i].img = monsterAggroRight;
    }     
    if(player.position.x < monsters[i].position.x){
        monsterTargets[firstPair] = monsters[i].position.x - numtiles/10;
        monsters[i].img = monsterAggroLeft;
    }    
    if(player.position.y > monsters[i].position.y)     monsterTargets[firstPair + 1] = monsters[i].position.y + numtiles/10;
    if(player.position.y < monsters[i].position.y)     monsterTargets[firstPair + 1] = monsters[i].position.y - numtiles/10;
 

    color c = get((int) monsterTargets[firstPair],(int) monsterTargets[firstPair + 1]);
      //if( c == #000000 ||  c == #FF0000 || c == #00FF00){
      if( c == #000000){
        monsterTargets[firstPair] = oldTargetX;
        monsterTargets[firstPair + 1] = oldTargetY;
      }else if (monsterTargets[firstPair] >= displayWidth-numtiles/10 || monsterTargets[firstPair] <= 0 || monsterTargets[firstPair + 1] >= displayHeight-numtiles/10 || monsterTargets[firstPair + 1] <= 0){
        monsterTargets[firstPair] = oldTargetX;
        monsterTargets[firstPair + 1] = oldTargetY;
      }

 
  //from studres "KinematicArriveSketch" https://studres.cs.st-andrews.ac.uk/CS4303/Lectures/W6/AI3/KinematicArriveSketch/
  float xe = monsters[i].position.x, ye = monsters[i].position.y ;
  fill(255,0,0) ;
 //  ellipse(xe, ye, 30, 30) ;
  image(monsters[i].img, xe-numtiles/2, ye-numtiles/2, numtiles*1.1, numtiles*1.1);

  // Show orientation
  // int newxe = (int)(xe + 10 * cos(monsters[i].orientation)) ;
  // int newye = (int)(ye + 10 * sin(monsters[i].orientation)) ;
  // fill(0);
  // ellipse(newxe, newye, 10, 10) ; 
 
  // Update Eno
  monsterVelocities[i].x =  monsterTargets[firstPair] - xe;
  monsterVelocities[i].y =  monsterTargets[firstPair + 1] -ye;
 
  //print(mTargetVel);

  monsters[i].integrate(monsterVelocities[i], tiles);
  //end from studres

  if(monsters[i].position.x >=  player.position.x + numtiles*5 || monsters[i].position.x <= player.position.x - numtiles*5){
      monsters[i].monsterAggro = false;
         monsters[i].MAX_SPEED = 1f + 2*dungeonLevel;
  } else if (monsters[i].position.y >=  player.position.y + numtiles*5 || monsters[i].position.y <= player.position.y - numtiles*5){
      monsters[i].monsterAggro = false;
         monsters[i].MAX_SPEED = 1f + 2*dungeonLevel;
  } 

  if(abs(monsters[i].position.x - player.position.x) <= numtiles/3 && abs(monsters[i].position.y - player.position.y) <= numtiles/3){
      player.img = playerRight;
      monsters[i].img = monsterLeft;
      fighting = true;
      popup = false;
      monsterFighting = i;
  }


}

void drawTiles(){
    float tileWidth = (float) displayWidth/numtiles;
    float tileHeight = (float) displayHeight/numtiles;

    //draw tiles
    for(int i = 0; i < numtiles; i++){
        for(int j = 0; j < numtiles; j++){
            if(tiles[i][j] == 0){
            stroke(#000000);
            fill(#000000);
            rect(i*tileWidth, j*tileHeight, tileWidth, tileHeight);
            }else if(tiles[i][j] == 1){
            stroke(#FFFFFF);
            fill(#FFFFFF);
            rect(i*tileWidth, j*tileHeight, tileWidth, tileHeight);
            } else if(tiles[i][j] == 2){
            fill(#00FF00);
            rect(i*tileWidth, j*tileHeight, tileWidth, tileHeight);
            } else if (tiles[i][j] == 3){
            image(sword, i*tileWidth, j*tileHeight, tileWidth, tileHeight);
            } else if (tiles[i][j] == 4){
            image(armour, i*tileWidth, j*tileHeight, tileWidth, tileHeight);
            } else if (tiles[i][j] == 5){
            image(potion, i*tileWidth, j*tileHeight, tileWidth, tileHeight);
            } 
        }
    }
}

void drawInventory(){
  int slotSize = numtiles*2; // size of each inventory slot
  int padding = numtiles; // padding between slots
  int inventoryX = displayWidth/2 - numtiles *5; // x position of the inventory
  int inventoryY = displayHeight/2 - numtiles *5; // y position of the inventory


    // draw inventory background
    fill(100, 200);
    rect(inventoryX, inventoryY, (slotSize + padding) * 4, (slotSize + padding) * 4);
    
    // draw inventory slots
    for (int i = 0; i < inventorySize; i++) {
      int row = i / 4;
      int col = i % 4;
      stroke(255);
      rect(inventoryX + col * (slotSize + padding), inventoryY + row * (slotSize + padding), slotSize, slotSize);
      
      // draw item in slot, if there is one
      if (inventory[i]) {

        //draw potion
        image(potion, inventoryX + col * (slotSize + padding), inventoryY + row * (slotSize + padding), slotSize, slotSize);
     

        // // replace this with your own code to draw the item
        // fill(255, 0, 0);
        // ellipse(inventoryX + col * (slotSize + padding) + slotSize/2, inventoryY + row * (slotSize + padding) + slotSize/2, slotSize/2, slotSize/2);
      }
    }
  

}

void mousePressed() {

 
  if(gamefinished){
    gamefinished = false;
    dungeonLevel = 1;
    fightMsg = "";
    fighting = false;
    popup = false;
    popupMsg = "";
    playerTurn = true;
    setup();
  }else if(levelUp){
      color c = get(mouseX, mouseY) ;
      if (c == #00ff00){
        player.health += 10;
        player.maxHealth += 10;
        levelUp = false;
      } else if (c == #ff0000){
        player.power += 5;
        player.maxPower += 5;
        levelUp = false;
      } else if (c == #48BAFF){
        player.defence += 5;
        player.maxDefence += 5;
        levelUp = false;
      } else if (c == #D3D3D3){
        player.MAX_SPEED += 3;
        levelUp = false;
      } else if (c == #ffff00){
        player.luck += 10;
        levelUp = false;
      }
  } 

}

void keyPressed() { 


  if (key == 'd'){
    movingRight  = true;
  } else if (key == 'a'){
    movingLeft = true;
  } else if (key == 'w'){
    movingUp = true;
  } else if (key == 's'){
    movingDown = true;
  } else if (key == 'e'){
    inventoryOpen = true;
  }

  if(playerTurn && fighting){
  if (key == '1') { 
      int damage = (int) random(player.power*0.5, player.power*1.5);
      monsters[monsterFighting].health -= damage;

      fightMsg = "You swing your sword and strike the goblin for " + damage + " damage!";

      if (monsters[monsterFighting].health <= 0) {
        monsterDead();
      } else {
        playerTurn = false;
        player.img = playerAttack;
        monsterAttack(); // enemy attacks after player's turn
      }
    } else if (key == '2'){
      fightMsg = "You ready your shield and prepare for the goblin's attack";

      blocking = true;
      playerTurn = false;
      player.img = playerBlock;
      monsterAttack();
    } else if (key == '3'){
      if(nextInventorySlot > 0){
        fightMsg = "You drink a potion and restore 50 health";
      player.health += 50;
      if(player.health > player.maxHealth){
        player.health = player.maxHealth;
      }
      playerTurn = false;
      inventory[nextInventorySlot-1] = false;
      nextInventorySlot--;

      monsterAttack();
      } else {
        popup= true;
        popupMsg = "You don't have any potions left!";
        popupTimer = 75;
      }
     
    }
  }
  

}

void monsterAttack() {

  int damage = (int) random(monsters[monsterFighting].power*0.5, monsters[monsterFighting].power*1.5) * 1 - (player.defence / 100);

  if(blocking){
    monsters[monsterFighting].img = monsterLeft;
    blocking = false;
     if(random(0,100) <= player.luck){
      fightMsg += "\nYou must be lucky... you blocked the goblin's attack\nand caused it to hit itself for " + damage + " damage!";
      monsters[monsterFighting].health -= damage;
     } else {
      damage = damage/2;
      player.health -= damage;
      fightMsg += "\nYour shield absorbed some of the goblin's attack, but you still took " + damage + " damage";
     }
    
  } else {
      monsters[monsterFighting].img = monsterAttack;
      player.health -= damage;
      fightMsg += "\nThe goblin hits you for " + damage + " damage!";
  }



  if (player.health <= 0) {
    popup = true;
    popupMsg = "You were slain by the goblin\n GAME OVER \n You made it to level " + player.level + " and collected " + player.gold + " gold.\nClick anywhere on the screen to restart."; 
    popupTimer = 0;
    gamefinished = true;


  } else {
    
    playerTurn = true;
    
  }
}

void keyReleased() {
  if (key == 'd'){
    movingRight = false;
  } else if (key == 'a'){
    movingLeft = false;
  } else if (key == 'w'){
    movingUp = false;
  } else if (key == 's'){
    movingDown = false;
  } else if (key == 'e'){
    inventoryOpen = false;
  }


}

void makeRooms(){

 //make 2D array of tiles, 0 is black, 1 is white
 tiles = new int[numtiles][numtiles];
 for(int i = 0; i < numtiles; i++){
  for(int j = 0; j < numtiles; j++){
   tiles[i][j] = 0;
  }  
 }

 
 

    //
    int numCols = numtiles;
    int numRows = numtiles;


  rects = new int[numRectangles][5];
  for (int i = 0; i < numRectangles; i++) {
    int x = (int) random(0, numtiles - numtiles/10); // choose a random x-coordinate
    int y = (int) random(0, numtiles - numtiles/10); // choose a random y-coordinate
    int w = (int) random(numtiles/10, numtiles/2); // choose a random width
    int h = (int) random(numtiles/10, numtiles/2); // choose a random height
    while (checkOverlap(x, y, w, h)) { // check for overlap
      x = (int) random(0, numtiles - numtiles/10);
      y = (int) random(0, numtiles - numtiles/10);
      w = (int) random(numtiles/10, numtiles/2);
      h = (int) random(numtiles/10, numtiles/2);
    }
    rects[i][0] = x; // store coordinates of top left and bottom right corners
    rects[i][1] = y;
    rects[i][2] = x + w;
    rects[i][3] = y + h;
    for (int j = x; j < x + w && j < numtiles; j++) {
      for (int k = y; k < y + h && k < numtiles; k++) {
        tiles[j][k] = 1; // set tile to white
      }
    }
  }
 
}

void makeCorridors(){

    for(int r = 0; r < numRectangles; r++){
       
    int thisX = rects[r][0];
    int thisY = rects[r][1];

        int closestRectIndex;

        if(r == 0){
            closestRectIndex = r + 1;
        } else if (r == numRectangles -1){
            closestRectIndex = r - 1;
        } else {
            closestRectIndex = r + 1;
        }

    float closestDistance = 100000;
        for(int j = 0; j < numRectangles; j++){
            if(j != r && pointsTo(j, r) == false){

                int x2 = rects[j][0];
                int y2 = rects[j][1];
                float distance = dist(thisX, thisY, x2, y2);
                if(distance < closestDistance){
                    closestDistance = distance;
                    closestRectIndex = j;
                }
            }
        }


    if(debug){
      print("\ncurrent index: " + r);
      print("\nclosest rect index: " + closestRectIndex);
    }


    int startX = rects[r][0] + (((rects[r][2] -1)- rects[r][0]) / 2);
    int startY = rects[r][1] + (((rects[r][3] -1) - rects[r][1])/2) ;
   
    //print("\n\nx: " + startX + " y: " + startY);
   
    int desX = rects[closestRectIndex][0] + (((rects[closestRectIndex][2]-1) - rects[closestRectIndex][0]) / 2);
    int desY = rects[closestRectIndex][1] + (((rects[closestRectIndex][3]-1) - rects[closestRectIndex][1])/2);

    //print("\nx: " + desX + " y: " + desY);

    if(startX >= numtiles) startX = numtiles-1;
    if(startY >= numtiles) startY = numtiles-1;
    if(desX >= numtiles) desX = numtiles-1;
    if(desY >= numtiles) desY = numtiles-1;

    if(startY > desY){
        for(int i = startY; i > desY && i < numtiles; i--){
            tiles[startX][i] = 1;
        }
    } else {
        for(int i = startY; i < desY && i < numtiles; i++){
            tiles[startX][i] = 1;
        }
    }

    if(startX > desX){
        for(int i = startX; i > desX && i < numtiles; i--){
            tiles[i][desY] = 1;
        }
    } else {
        for(int i = startX; i < desX && i < numtiles; i++){
            tiles[i][desY] = 1;
        }
    }
        //point to nearest rectangle
        rects[r][4] = closestRectIndex;
    }

}   

boolean checkLayout(){

          Set<Integer> indices = new HashSet<Integer>();
          indices.add(0);
         int nextRoom = 0;
         int i = 0;
          while(i<numRectangles*2){
             int pointsTo = rects[nextRoom][4];
             indices.add(pointsTo);
             nextRoom = pointsTo;
             i++;
          }
         
         
         
          int c = 0;
        while(c < numRectangles*2){


        for(int j = 0; j < numRectangles; j++){
            if(indices.contains(rects[j][4]))
                indices.add(j);
        }
        c++;
        }

 
       if(debug) print("check");
       return indices.size() == numRectangles;

}

boolean pointsTo(int potentialClosest, int currentRectangle){
        //if the potential closest rectangle is already pointing to the current rectangle, return true
        if(rects[potentialClosest][4] == currentRectangle)
            return true;
        else
            return false;
}

boolean checkOverlap(int x, int y, int w, int h) {
  for (int i = 0; i < numRectangles; i++) {
    int rx1 = rects[i][0];
    int ry1 = rects[i][1];
    int rx2 = rects[i][2];  
    int ry2 = rects[i][3];
    if (x+w >= rx1 && x <= rx2 && y+h >= ry1 && y <= ry2) {
      return true;
    }
  }
  return false;
}
