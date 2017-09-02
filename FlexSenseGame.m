clc; close all; clearvars -except a;
 
 
if ~exist('a','var')
    a = arduino('/dev/tty.usbserial-DN00MTJF', 'Uno', 'Libraries', 'ExampleLCD/LCDAddon');
end
 
lcd = addon(a,'ExampleLCD/LCDAddon',{'D7','D6','D5','D4','D3','D2'});
initializeLCD(lcd,'Rows',2,'Columns',16);
printLCD(lcd,'LCD Matlab');
cursorRow = 1;8
printLCD(lcd,'initializing');
pause(2);
clearLCD(lcd);

%Initializing Variables
x = 3;
game = true;
pot = 0;
button = 0;
score = 0;
scoreCount = 0;
absScore = 0;
jumpCount = 0;
xscore = num2str(score);  % xscore is the string score
baseV1 = readVoltage(a,0)
ps = readDigitalPin(a,10)


        
%Rows
row1 = [' ',' ',' ',' ',' ',' ',' ',' ',' ','S','c','o','r','e', ' ', ' '];
row2 = [' ',' ','P',' ',' ',' ',' ',' ',' ',' ', ' ',' ',' ',' ',' ', ' '];

%Converts Array to String for LCD
TR = mat2str(row1);
BR = mat2str(row2);

%Random position for blocks
B1 = randi([17,32],1);
B2 = randi([17,32],1);

%Assigns B2 and B1 not next to each other
if B2 == B1
    B2 = B1+5;
end

%Displays Initialization of Game
printLCD(lcd, '   Block Jump ');
printLCD(lcd, 'Jump to Survive');
pause(2);
printLCD(lcd, '     Game   ');
printLCD(lcd, '     Start   ');
pause(.7);


%Starts Game
while game == true
    
    ps = readDigitalPin(a,10);
    if ps == 1
        pause(0.5);
        printLCD(lcd, '  GAME PAUSED ');
        printLCD(lcd, '     Resume?');
        ps = readDigitalPin(a,10);
        while ps ~= 1
            ps = readDigitalPin(a,10);
        end
    end
    
    %Configure Digital Push Button
    jump = abs(readVoltage(a,0) - baseV1)
    
    %Erases Previous Blocks
    count = 1;
    while count < 17
        if strcmp(' ', row2(count)) == 0
            row2(count) = ' ';
        end
    count = count + 1;
    end
    
    %Erases Jumping Character
    count = 1;
    while count < 7
        if strcmp(' ', row1(count)) == 0
            row1(count) = ' ';
        end
    count = count + 1;
    end
    
    
    %P Placement
    if jump > 0.14 && jumpCount < 3
        row1(3) = 'P';
        jumpCount = jumpCount + 1;
    else
        row2(3) = 'P';
        jumpCount = 0;
        jump = 0;
    end
    
    %Sets Block position
    if B1 < 17
        row2(B1) = 2;
    end
    
    if B2 < 17
        row2(B2) = 2;
    end
    
    %Displays Game on LCD
    TR = mat2str(row1);
    BR = mat2str(row2);
    printLCD(lcd,TR(2:17));
    printLCD(lcd,BR(2:17));
    
    %Collisions
    if B1 == 3
        if jump == 0
            game = false;
        end
    end
    
    %Block 2 collision
    if B2 == 3
        if jump == 0
            game = false;
        end
    end
    
    %Subtracting for loop
    B1 = B1 - 1;
    B2 = B2 - 1;
    
    %Placing block once it gets to left side
    if B1 < 1
        B1 = randi([17,27],1);
        score = score +1;
        absScore = absScore + 1;
    end
    if B2 < 1
        B2 = randi([17,32],1);
        score = score +1;
        absScore = absScore + 1;
    end
    
    %Setting Score
    xscore = num2str(score);
    if score < 10
        row1(16) = xscore;
    else
        scoreCount = scoreCount+1;
        score = 0;
        row1(15) = num2str(scoreCount);
    end
    
    %Ending Game at specific score
    if absScore > 100
        game = false;
    end
    
    %Setting Speed
    
         pause(0.1^(0.01*(absScore+10)^3));
    
end

if absScore == 0
    printLCD(lcd, '   GAME OVER ');
    printLCD(lcd, 'You are terrible');
    elseif absScore < 20
    
    printLCD(lcd, '   GAME OVER ');
    printLCD(lcd, ' Basic Jumping');
    pause(2);
    printLCD(lcd, 'Your Score Was:');
    printLCD(lcd, num2str(absScore));
    
    elseif absScore < 40
    
    printLCD(lcd, '   GAME OVER ');
    printLCD(lcd, '   Basketball');
    pause(2);
    printLCD(lcd, 'Your Score Was:');
    printLCD(lcd, num2str(absScore));
    
    elseif absScore < 60
    
    printLCD(lcd, '   GAME OVER ');
    printLCD(lcd, '   Kangaroo');
    pause(2);
    printLCD(lcd, 'Your Score Was:');
    printLCD(lcd, num2str(absScore));
    
    elseif absScore < 80
    
    printLCD(lcd, '   GAME OVER ');
    printLCD(lcd, '     Mario');
    pause(2);
    printLCD(lcd, 'Your Score Was:');
    printLCD(lcd, num2str(absScore));
    
    else
    
    printLCD(lcd, '   GAME OVER ');
    printLCD(lcd, '    Godly');
    pause(2);
    printLCD(lcd, 'Your Score Was:');
    printLCD(lcd, num2str(absScore));
    
    
end