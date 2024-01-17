import ddf.minim.*;//import for sound

Minim minim;
AudioPlayer playerShootSound;
AudioPlayer explosionSound;
AudioPlayer gameoverSound;
AudioPlayer backgroundMusic;
AudioPlayer lifelostSound;


Button StartButton;
Button EasyMode;
Button MediumMode;
Button HardMode;
PImage backdrop1;
int menu = 0;
int difficultyLevel = 1;

int playerPosition = 0;

int score = 0;
int best = 0;


int cycleFail = 0;
boolean lost = false;

int cycle = 0;
int cyclePos = 0;
int cycleSpeed = 40;

boolean bullet = false;
int bulletX = 0;
int bulletY = 0;

int lives = 3;

boolean aliensRight = true;
int downIterations = 0;
int alienPosX = 76;

boolean over = false;


boolean left = false;
boolean right = false;
boolean up = false;


Blockade blockades[] = new Blockade[36];
boolean blockadeIs[] = new boolean[36];

Alien aliens[] = new Alien[55];
boolean alienExists[] = new boolean[55];

Bullet bullets[] = new Bullet[100];
boolean bulletExists[] = new boolean[100];

PImage images[] = new PImage[19];



void setup() {
  size(460, 600);
  minim = new Minim(this);
  //load sounds
  playerShootSound = minim.loadFile("player_shoot.mp3");
  explosionSound = minim.loadFile("explosion.mp3");
  gameoverSound = minim.loadFile("gameover.mp3");
  backgroundMusic = minim.loadFile("background_music.mp3");
  lifelostSound = minim.loadFile("life_lost.mp3");
  backgroundMusic.loop();
  //set volume
  backgroundMusic.setGain(-20.0);
  explosionSound.setGain(-15.0);
  //load game data and initialize game elements
  chargeData();
  setupBlockadeA();
  setupAliens();
  best = int(loadStrings("score.txt")[0]);
  playerPosition = width/2-13; 
  backdrop1 = loadImage("Space-Background-Image-2.jpg");
  
  //initialize buttons for game menu
  StartButton = new Button(175,350,100,50,"Start!",0,200,200);
  EasyMode = new Button(50,390,100,50,"Easy",0,200,0);
  MediumMode = new Button(175,390,100,50,"Medium",150,200,200);
  HardMode = new Button(300,390,100,50,"Insane!",200,0,0);
}

void keyPressed() {
  if (keyCode == LEFT) {
    
    left = true;
  }
  if (keyCode == RIGHT) {
    right = true;
  }
  if (keyCode == UP) {
    up = true;
  }
}


void keyReleased() {
  if (keyCode == LEFT) {
    left = false;
  }
  if (keyCode == RIGHT) {
    right = false;
  }
  if (keyCode == UP) {
    up = false;
  }
}


void draw() {
  background(200);
  switch(menu)
    {
      case 0:
      {
        fill(200);
        image(backdrop1,0,0);
        textSize(50);
        textAlign(CENTER,CENTER);
        text("SpaceInvaders" ,width/2, 100);
        StartButton.update();
        StartButton.render();
        if(StartButton.isClicked())
        {
          menu = 1;
        }
}break;
     case 1:{
       fill(200);
        image(backdrop1,0,0);
        textSize(50);
        textAlign(CENTER,CENTER);
        text("Choose Difficulty" ,width/2, 100);
        EasyMode.update();
        EasyMode.render();
        MediumMode.update();
        MediumMode.render();
        HardMode.update();
        HardMode.render();
        if(EasyMode.isClicked())
        {
          menu = 2;
        }
        if(MediumMode.isClicked())
        {
          menu = 3;
        }
        if(HardMode.isClicked())
        {
          menu = 4;
        }
        
     }break;
     case 2:{
      background(0);
      image(backdrop1,0,0);
  if (!lost) {
    image(images[14], playerPosition, 525, 50, 50);
  } else {
    fill(255, 0, 0);
    rect(playerPosition - 2, 546, 30, 30); //draw a red rectangle
    cycleFail--;
    if (cycleFail == 0 && !over) lost = false;
  }
  
  for (int i = 0; i < 36; i++) {
    if (blockadeIs[i]) {
      int remainingHealth = 3 - blockades[i].getDamages(); //calculate remaining health

      //draw the blockadekade with remaining health
      for (int healthBar = 0; healthBar < remainingHealth; healthBar++) {
        //draw a rectangle representing the remaining health
        fill(170, 255, 0);
        rect(blockades[i].getX() + healthBar * 4, blockades[i].getY(), 4, 12); //adjust rectangle size and position as needed
      }
      if (!over && bullet && bulletX < blockades[i].getX()+12 && bulletX+2 > blockades[i].getX() && bulletY < blockades[i].getY()+12 && bulletY+6 > blockades[i].getY()) {
        blockades[i].setDamages(blockades[i].getDamages()+1);
        if (blockades[i].getDamages() > 3) blockadeIs[i] = false;
        bullet = false;
      }
    }
  }

  int c = 0;


//do until variable i is still less than 55, incriment i by 1 every loop.
for (int i = 0; i < 55; i++) {
  
    if (alienExists[i]) {
      
      c++;
      
      if (aliens[i].getExplode() > 0) {
        
        //play sounds for play and rewind 
        explosionSound.play();
        explosionSound.rewind();
        
        int delta = aliens[i].getType();
        image(images[10], aliens[i].getX()-delta, aliens[i].getY());
        
        
        aliens[i].setExplode(aliens[i].getExplode()-1);
        if (aliens[i].getExplode() == 0) alienExists[i] = false;
      } else {
        image(images[aliens[i].getType()], aliens[i].getX(), aliens[i].getY());
        int size = 25;
        if (aliens[i].getType() == 1) {
          size = 24;
        }
        
        if (aliens[i].getType() == 2) {
          size = 17; 
        }
        
         if (!over && bullet && bulletX < aliens[i].getX()+size && bulletX+2 > aliens[i].getX() && bulletY < aliens[i].getY()+16 && bulletY+6 > aliens[i].getY()) {
          aliens[i].explode();
          
          
          //if its first type of alien incriment score by 10
          if (aliens[i].getType() == 0) {
            score+=10; 
          }
          
          //else if its second type of alien incriment score by 20
          else if (aliens[i].getType() == 1) {
            score+=20; 
          }
          
          //else if its first type of alien incriment score by 40
          else {
            score+=40; 
          }
          
          //set bullet equal to false 
          bullet = false;
        }
        
        //if random number is less than .2 and its not over then continue the statement
        if (random(1000) < 0.2 && !over) {
          
          //initialize addingOne to 0
          int addingOne = 0;
          
          while (bulletExists[addingOne])
          
            //incriment the variable addingOne by 1
            addingOne++;
            
            //update positing of the bullet and then set to true if bullet exists at the point 
            bullets[addingOne] = new Bullet(aliens[i].getX()+size/2-1, aliens[i].getY()+16);
            bulletExists[addingOne] = true;
        }
      }
    }
  }


  if (c == 0) {
    setupAliens();
    cycleSpeed = 40;
  }

  for (int i = 0; i < 100; i++) {
    
    //if there is a bullet
    if (bulletExists[i]) {
      image(images[15+bullets[i].getTex()], bullets[i].getX(), bullets[i].getY());
      bullets[i].setTex(bullets[i].getTex()+1);
      if (bullets[i].getTex() > 2) bullets[i].setTex(0);
      bullets[i].setY(bullets[i].getY()+6);
      if (bullets[i].getY() > 590) bulletExists[i] = false;
      
      for (int j = 0; j < 36; j++) {//for each blockade strip
        if (blockadeIs[j]) {//if it exists
          if (bullets[i].getX() < blockades[j].getX()+12 && bullets[i].getX()+6 > blockades[j].getX() && bullets[i].getY() < blockades[j].getY()+12 && bullets[i].getY()+10 > blockades[j].getY()) {
            blockades[j].setDamages(blockades[j].getDamages()+1);
            if (blockades[j].getDamages() > 3) blockadeIs[j] = false;
            bulletExists[i] = false;
          }
        }
      }
      
      if (!over && !lost && bullets[i].getX() < playerPosition+26 && bullets[i].getX()+6 > playerPosition && bullets[i].getY() < 564 && bullets[i].getY()+10 > 550) {
        lost = true;
        cycleFail = 60;
        lives--;
        lifelostSound.rewind();
        lifelostSound.play();

        
        if (lives == 0) {
          gameoverSound.rewind();
          gameoverSound.play();
          over = true;
          if (score > best) {
            String d[] = {Integer.toString(score)};
            saveStrings("score.txt", d);
            best = score;
          }
        }
        bulletExists[i] = false;
      }
    }
  }


  cycle++;
  if (cycle > cycleSpeed) {
    cycle = 0;
    if (!over) {
      int delta = -4;
      if (aliensRight) delta = 4;
      for (int i = 0; i < 55; i++) {
        if (alienExists[i]) {
          aliens[i].setX(aliens[i].getX()+delta);
        }
      }
      alienPosX+=delta;
      if (aliensRight && alienPosX == 132) {
        downIterations++;
        aliensRight = false;
        for (int i = 0; i < 55; i++) {
          if (alienExists[i]) {
            aliens[i].setY(aliens[i].getY()+4);
          }
        }
        if (cycleSpeed > 5) cycleSpeed-=2;
      }
      if (!aliensRight && alienPosX == 20) {
        downIterations++;
        aliensRight = true;
        for (int i = 0; i < 55; i++) {
          if (alienExists[i]) {
            aliens[i].setY(aliens[i].getY()+4);
          }
        }
        if (cycleSpeed > 5) cycleSpeed-=2;
      }
      if (downIterations > 57) {
        downIterations = 0;
        for (int i = 0; i < 55; i++) {
          if (alienExists[i]) {
            aliens[i].setY(aliens[i].getY()-4*57);
          }
        }
      }
    }
    cyclePos++;
    if (cyclePos > 1) cyclePos = 0;
  }

  if (bullet) {
    image(images[13], bulletX, bulletY);
    bulletY-=9;
    if (bulletY < 60) bullet = false;
  }

  if (!over && !lost) {
    if (left && playerPosition > 30) playerPosition-=2;
    if (right && playerPosition < width-56) playerPosition+=2;

    if (!bullet && up) {
      bullet = true;
      bulletX = playerPosition + 22;
      bulletY = 544;
      playerShootSound.rewind();
      playerShootSound.play();
    }
  }
  
  if(over){
    fill(0, 200);
    rect(0, 0, width, height);
    textSize(50);
    textAlign(CENTER, CENTER);
    fill(255);
    text("GAME OVER", width/2, height/2);
    textSize(30);
    text("Score : "+score, width/2, height/2+50);
  }
  else{
    textSize(20);
    textAlign(LEFT, UP);
    fill(255);
    text("Score   : "+score, 30, 30);
    textAlign(RIGHT, UP);
    text("Best : "+max(best, score), width-30, 30);
    for(int i = 0; i < lives; i++){
      image(images[18], 175+i*30, 10);
    }
  }
      
      
}break;
case 3:
{
   background(0);
      image(backdrop1,0,0);
  if (!lost) {
    image(images[14], playerPosition, 525, 50, 50);
  } else {
    fill(255, 0, 0);
    rect(playerPosition - 2, 546, 30, 30); //draw a red rectangle
    cycleFail--;
    if (cycleFail == 0 && !over) lost = false;
  }
  
  for (int i = 0; i < 36; i++) {
    if (blockadeIs[i]) {
      int remainingHealth = 3 - blockades[i].getDamages(); //calculate remaining health

      //draw the blockadekade with remaining health
      for (int healthBar = 0; healthBar < remainingHealth; healthBar++) {
        //draw a rectangle representing the remaining health
        fill(170, 255, 0);
        rect(blockades[i].getX() + healthBar * 4, blockades[i].getY(), 4, 12); //adjust rectangle size and position as needed
      }
      if (!over && bullet && bulletX < blockades[i].getX()+12 && bulletX+2 > blockades[i].getX() && bulletY < blockades[i].getY()+12 && bulletY+6 > blockades[i].getY()) {
        blockades[i].setDamages(blockades[i].getDamages()+1);
        if (blockades[i].getDamages() > 3) blockadeIs[i] = false;
        bullet = false;
      }
    }
  }

  int c = 0;


//do until variable i is still less than 55, incriment i by 1 every loop.
for (int i = 0; i < 55; i++) {
  
    if (alienExists[i]) {
      
      c++;
      
      if (aliens[i].getExplode() > 0) {
        
        //play sounds for play and rewind 
        explosionSound.play();
        explosionSound.rewind();
        
        int delta = aliens[i].getType();
        image(images[10], aliens[i].getX()-delta, aliens[i].getY());
        
        
        aliens[i].setExplode(aliens[i].getExplode()-1);
        if (aliens[i].getExplode() == 0) alienExists[i] = false;
      } else {
        image(images[aliens[i].getType()], aliens[i].getX(), aliens[i].getY());
        int size = 25;
        if (aliens[i].getType() == 1) {
          size = 24;
        }
        
        if (aliens[i].getType() == 2) {
          size = 17; 
        }
        
         if (!over && bullet && bulletX < aliens[i].getX()+size && bulletX+2 > aliens[i].getX() && bulletY < aliens[i].getY()+16 && bulletY+6 > aliens[i].getY()) {
          aliens[i].explode();
          
          
          //if its first type of alien incriment score by 10
          if (aliens[i].getType() == 0) {
            score+=10; 
          }
          
          //else if its second type of alien incriment score by 20
          else if (aliens[i].getType() == 1) {
            score+=20; 
          }
          
          //else if its first type of alien incriment score by 40
          else {
            score+=40; 
          }
          
          //set bullet equal to false 
          bullet = false;
        }
        
        //if random number is less than .2 and its not over then continue the statement
        if (random(1000) < 0.2 && !over) {
          
          //initialize addingOne to 0
          int addingOne = 0;
          
          while (bulletExists[addingOne])
          
            //incriment the variable addingOne by 1
            addingOne++;
            
            //update positing of the bullet and then set to true if bullet exists at the point 
            bullets[addingOne] = new Bullet(aliens[i].getX()+size/2-1, aliens[i].getY()+16);
            bulletExists[addingOne] = true;
        }
      }
    }
  }


  if (c == 0) {
    setupAliens();
    cycleSpeed = 40;
  }

  for (int i = 0; i < 100; i++) {
    if (bulletExists[i]) {
      image(images[15+bullets[i].getTex()], bullets[i].getX(), bullets[i].getY());
      bullets[i].setTex(bullets[i].getTex()+1);
      if (bullets[i].getTex() > 2) bullets[i].setTex(0);
      bullets[i].setY(bullets[i].getY()+6);
      if (bullets[i].getY() > 590) bulletExists[i] = false;
      for (int j = 0; j < 36; j++) {
        if (blockadeIs[j]) {
          if (bullets[i].getX() < blockades[j].getX()+12 && bullets[i].getX()+6 > blockades[j].getX() && bullets[i].getY() < blockades[j].getY()+12 && bullets[i].getY()+10 > blockades[j].getY()) {
            blockades[j].setDamages(blockades[j].getDamages()+1);
            if (blockades[j].getDamages() > 3) blockadeIs[j] = false;
            bulletExists[i] = false;
          }
        }
      }
      if (!over && !lost && bullets[i].getX() < playerPosition+26 && bullets[i].getX()+6 > playerPosition && bullets[i].getY() < 564 && bullets[i].getY()+10 > 550) {
        lost = true;
        cycleFail = 60;
        lives--;
        lifelostSound.rewind();
        lifelostSound.play();

        if (lives == 0) {
          over = true;
          if (score > best) {
            String d[] = {Integer.toString(score)};
            saveStrings("score.txt", d);
            best = score;
          }
        }
        bulletExists[i] = false;
      }
    }
  }


  cycle++;
  if (cycle > cycleSpeed) {
    cycle = 0;
    if (!over) {
      int delta = -4;
      if (aliensRight) delta = 4;
      for (int i = 0; i < 55; i++) {
        if (alienExists[i]) {
          aliens[i].setX(aliens[i].getX()+delta);
        }
      }
      alienPosX+=delta;
      if (aliensRight && alienPosX == 132) {
        downIterations++;
        aliensRight = false;
        for (int i = 0; i < 55; i++) {
          if (alienExists[i]) {
            aliens[i].setY(aliens[i].getY()+4);
          }
        }
        if (cycleSpeed > 5) cycleSpeed-=2;
      }
      if (!aliensRight && alienPosX == 20) {
        downIterations++;
        aliensRight = true;
        for (int i = 0; i < 55; i++) {
          if (alienExists[i]) {
            aliens[i].setY(aliens[i].getY()+4);
          }
        }
        if (cycleSpeed > 5) cycleSpeed-=2;
      }
      if (downIterations > 57) {
        downIterations = 0;
        for (int i = 0; i < 55; i++) {
          if (alienExists[i]) {
            aliens[i].setY(aliens[i].getY()-4*57);
          }
        }
      }
    }
    cyclePos++;
    if (cyclePos > 1) cyclePos = 0;
  }

  if (bullet) {
    image(images[13], bulletX, bulletY);
    bulletY-=6;
    if (bulletY < 60) bullet = false;
  }

  if (!over && !lost) {
    if (left && playerPosition > 30) playerPosition-=2;
    if (right && playerPosition < width-56) playerPosition+=2;

    if (!bullet && up) {
      bullet = true;
      bulletX = playerPosition + 22;
      bulletY = 544;
      playerShootSound.rewind();
      playerShootSound.play();
    }
  }
  
  if(over){
    fill(0, 200);
    rect(0, 0, width, height);
    textSize(50);
    textAlign(CENTER, CENTER);
    fill(255);
    text("GAME OVER", width/2, height/2);
    textSize(30);
    text("Score : "+score, width/2, height/2+50);
  }
  else{
    textSize(20);
    textAlign(LEFT, UP);
    fill(255);
    text("Score   : "+score, 30, 30);
    textAlign(RIGHT, UP);
    text("Best : "+max(best, score), width-30, 30);
    for(int i = 0; i < lives; i++){
      image(images[18], 175+i*30, 10);
    }
  }
      
  
}break;
case 4:
{
   background(0);
      image(backdrop1,0,0);
  if (!lost) {
    image(images[14], playerPosition, 525, 50, 50);
  } else {
    fill(255, 0, 0);
    rect(playerPosition - 2, 546, 30, 30); //draw a red rectangle
    cycleFail--;
    if (cycleFail == 0 && !over) lost = false;
  }


  int c = 0;


//do until variable i is still less than 55, incriment i by 1 every loop.
for (int i = 0; i < 55; i++) {
  
    if (alienExists[i]) {
      
      c++;
      
      if (aliens[i].getExplode() > 0) {
        
        //play sounds for play and rewind 
        explosionSound.play();
        explosionSound.rewind();
        
        int delta = aliens[i].getType();
        image(images[10], aliens[i].getX()-delta, aliens[i].getY());
        
        
        aliens[i].setExplode(aliens[i].getExplode()-1);
        if (aliens[i].getExplode() == 0) alienExists[i] = false;
      } else {
        image(images[aliens[i].getType()], aliens[i].getX(), aliens[i].getY());
        int size = 25;
        if (aliens[i].getType() == 1) {
          size = 24;
        }
        
        if (aliens[i].getType() == 2) {
          size = 17; 
        }
        
         if (!over && bullet && bulletX < aliens[i].getX()+size && bulletX+2 > aliens[i].getX() && bulletY < aliens[i].getY()+16 && bulletY+6 > aliens[i].getY()) {
          aliens[i].explode();
          
          
          //if its first type of alien incriment score by 10
          if (aliens[i].getType() == 0) {
            score+=10; 
          }
          
          //else if its second type of alien incriment score by 20
          else if (aliens[i].getType() == 1) {
            score+=20; 
          }
          
          //else if its first type of alien incriment score by 40
          else {
            score+=40; 
          }
          
          //set bullet equal to false 
          bullet = false;
        }
        
        //if random number is less than .2 and its not over then continue the statement
        if (random(1000) < 0.2 && !over) {
          
          //initialize addingOne to 0
          int addingOne = 0;
          
          while (bulletExists[addingOne])
          
            //incriment the variable addingOne by 1
            addingOne++;
            
            //update positing of the bullet and then set to true if bullet exists at the point 
            bullets[addingOne] = new Bullet(aliens[i].getX()+size/2-1, aliens[i].getY()+16);
            bulletExists[addingOne] = true;
        }
      }
    }
  }


  if (c == 0) {
    setupAliens();
    cycleSpeed = 40;
  }

  for (int i = 0; i < 100; i++) {
    if (bulletExists[i]) {
      image(images[15+bullets[i].getTex()], bullets[i].getX(), bullets[i].getY());
      bullets[i].setTex(bullets[i].getTex()+1);
      if (bullets[i].getTex() > 2) bullets[i].setTex(0);
      bullets[i].setY(bullets[i].getY()+6);
      if (bullets[i].getY() > 590) bulletExists[i] = false;

      
      
      if (!over && !lost && bullets[i].getX() < playerPosition+26 && bullets[i].getX()+6 > playerPosition && bullets[i].getY() < 564 && bullets[i].getY()+10 > 550) {
        lost = true;
        cycleFail = 60;
        lives--;
        lifelostSound.rewind();
      lifelostSound.play();

        if (lives == 0) {
          over = true;
          if (score > best) {
            String d[] = {Integer.toString(score)};
            saveStrings("score.txt", d);
            best = score;
          }
        }
        bulletExists[i] = false;
      }
    }
  }


  cycle++;
  if (cycle > cycleSpeed) {
    cycle = 0;
    if (!over) {
      int delta = -4;
      if (aliensRight) delta = 4;
      for (int i = 0; i < 55; i++) {
        if (alienExists[i]) {
          aliens[i].setX(aliens[i].getX()+delta);
        }
      }
      alienPosX+=delta;
      if (aliensRight && alienPosX == 132) {
        downIterations++;
        aliensRight = false;
        for (int i = 0; i < 55; i++) {
          if (alienExists[i]) {
            aliens[i].setY(aliens[i].getY()+4);
          }
        }
        if (cycleSpeed > 5) cycleSpeed-=2;
      }
      if (!aliensRight && alienPosX == 20) {
        downIterations++;
        aliensRight = true;
        for (int i = 0; i < 55; i++) {
          if (alienExists[i]) {
            aliens[i].setY(aliens[i].getY()+4);
          }
        }
        if (cycleSpeed > 5) cycleSpeed-=2;
      }
      if (downIterations > 57) {
        downIterations = 0;
        for (int i = 0; i < 55; i++) {
          if (alienExists[i]) {
            aliens[i].setY(aliens[i].getY()-4*57);
          }
        }
      }
    }
    cyclePos++;
    if (cyclePos > 1) cyclePos = 0;
  }

  if (bullet) {
    image(images[13], bulletX, bulletY);
    bulletY-=4;
    if (bulletY < 60) bullet = false;
  }

  if (!over && !lost) {
    if (left && playerPosition > 30) playerPosition-=2;
    if (right && playerPosition < width-56) playerPosition+=2;

    if (!bullet && up) {
      bullet = true;
      bulletX = playerPosition + 22;
      bulletY = 544;
      playerShootSound.rewind();
      playerShootSound.play();
    }
  }
  
  if(over){
    fill(0, 200);
    rect(0, 0, width, height);
    textSize(50);
    textAlign(CENTER, CENTER);
    fill(255);
    text("GAME OVER", width/2, height/2);
    textSize(30);
    text("Score : "+score, width/2, height/2+50);
  }
  else{
    textSize(20);
    textAlign(LEFT, UP);
    fill(255);
    text("Score   : "+score, 30, 30);
    textAlign(RIGHT, UP);
    text("Best : "+max(best, score), width-30, 30);
    for(int i = 0; i < lives; i++){
      image(images[18], 175+i*30, 10);
    }
  }
      
}
}
}
void setupBlockadeA() {
  int blockadeNbre = 0;
  for (int i = 0; i < 21; i++) {
    for (int j = 0; j < 3; j++) {
      if (int(i/3)%2 == 0) {
        blockades[blockadeNbre] = new Blockade(104+i*12, 470+j*12);
        blockadeIs[blockadeNbre] = true;
        blockadeNbre++;
      }
    }
  }
}

void setupAliens() {
  int alienNbre = 0;
  for (int i = 0; i < 11; i++) {
    for (int j = 0; j < 5; j++) {
      int type = 0;
      int deltaX = 0;
      if (j == 0) {
        type = 2;
        deltaX = 6;
      } else if (j < 3) {
        type = 1;
        deltaX = 4;
      } else {
        type = 0;
        deltaX = 2;
      }
      aliens[alienNbre] = new Alien(76+i*28+deltaX, 100+j*28, type);
      alienExists[alienNbre] = true;
      alienNbre++;
    }
   
  }
}

void chargeData() {


  images[0] = loadImage("assets/alien_One.png");
  images[1] = loadImage("assets/alien_Two.png");
  images[2] = loadImage("assets/alien_Three.png");


  images[10] = loadImage("assets/explosion.png");
  images[13] = loadImage("assets/BulletPlayer.png");
  images[14] = loadImage("assets/player1.png");

  images[15] = loadImage("assets/BulletOne.png");
  images[16] = loadImage("assets/BulletTwo.png");
  images[17] = loadImage("assets/BulletThree.png");
  images[18] = loadImage("assets/lives.png"); 
}

class BaseClass {
    int x, y;

    BaseClass(int x_, int y_) {
        x = x_;
        y = y_;
    }

    int getX() {
        return x;
    }

    int getY() {
        return y;
    }

    void setX(int v) {
        x = v;
    }

    void setY(int v) {
        y = v;
    }
}

class Blockade extends BaseClass {
    int damages;

    Blockade(int x, int y) {
        super(x, y);
        this.damages = 0;
    }

    int getDamages() {
        return damages;
    }

    void setDamages(int damages) {
        this.damages = damages;
    }
}

class Bullet extends BaseClass {
    int tex;

    Bullet(int x, int y) {
        super(x, y);
        this.tex = 0;
    }

    int getTex() {
        return tex;
    }

    void setTex(int tex) {
        this.tex = tex;
    }
}

class Alien extends BaseClass {
    int type;
    int explode;
    boolean left;

    Alien(int x, int y, int type) {
        super(x, y);
        this.type = type;
        this.explode = 0;
        this.left = false;
    }

    void explode() {
        explode = 20;
    }

    int getType() {
        return type;
    }

    int getExplode() {
        return explode;
    }

    void setExplode(int explode) {
        this.explode = explode;
    }
}

class Button

{
  PVector Pos = new PVector(0,0);
  float Width = 0;
  float Height = 0;
  color Color;
  String Text;
  Boolean Pressed = false;
  Boolean Click = false;
  
  Button(int x, int y, int w, int h, String t, int r, int g, int b)
  {
    Pos.x = x;
    Pos.y = y;
    Width = w;
    Height = h;
    Color = color(r,g,b);
    Text = t;
  }
  
  void update()
  {
    if(mousePressed == true && mouseButton == LEFT && Pressed ==false)
    {
      Pressed = true;
      if(mouseX >= Pos.x && mouseX <= Pos.x + Width && mouseY >= Pos.y && mouseY <= Pos.y + Height)
      {
        Click = true;
      }
    } else 
    {
      Click = false;
      Pressed = false;
    }
  }
  
  void render() //also within voidDraw
  {
    fill(Color);
    rect(Pos.x,Pos.y,Width,Height);
    
    fill(0);
    textAlign(CENTER,CENTER);
    textSize(30);
    text(Text, Pos.x +(Width/2), Pos.y +(Height/2));
  }
  
  boolean isClicked() //returns if the button is clicked from previous if statement
  {
    return Click;
  }
}
  
