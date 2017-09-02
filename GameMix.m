clc; close all; clearvars -except a;   %clears all variables
 
% Initializes arduino 
if ~exist('a','var')
    a = arduino('/dev/tty.usbserial-DN00MTJF', 'Uno', 'Libraries', 'ExampleLCD/LCDAddon');
end

%Initializes the LCD display
lcd = addon(a,'ExampleLCD/LCDAddon',{'D7','D6','D5','D4','D3','D2'});
initializeLCD(lcd,'Rows',2,'Columns',16);
printLCD(lcd,'LCD Matlab');
cursorRow = 1;
printLCD(lcd,'initializing');
pause(2);
clearLCD(lcd);

choice = 0;
totalGame = true;

%starts the main game loop
while totalGame == true
    ps = readDigitalPin(a,10);
    while ps ~= 1
        ps = readDigitalPin(a,10);
        gameSel = readVoltage(a,3);  %gameSel reads potentiometer value
        choice = round(gameSel); %rounds gameSel to nearest int
        if choice <= 1
            printLCD(lcd,'  Game Select');
            printLCD(lcd,'    Jump Man');
        elseif choice <= 3
            printLCD(lcd,'  Game Select');
            printLCD(lcd,'     RPS');
        else
            printLCD(lcd,'  Game Select');
            printLCD(lcd,'   End Game?');
        end
    end
    
    pause(0.1);
    
    if choice <= 1
        printLCD(lcd,'    Jump Man');
        printLCD(lcd,'Jump to Survive!');
        pause(2);
        ps = readDigitalPin(a,10);
        while ps ~= 1
            ps = readDigitalPin(a,10);
            gameSel = readVoltage(a,3);  %gameSel reads potentiometer value
            choice = round(gameSel); %rounds gameSel to nearest int
            if choice <= 0
                printLCD(lcd,'Difficulty Level');
                printLCD(lcd,'    Easy');
            elseif choice <= 1
                printLCD(lcd,'Difficulty Level');
                printLCD(lcd,'    Medium');
            elseif choice <= 2
                printLCD(lcd,'Difficulty Level');
                printLCD(lcd,'     Hard');
            else
                printLCD(lcd,'Difficulty Level');
                printLCD(lcd,'   Go Back?');
            end
        end
        game = true;
        if choice <= 0 
            difficulty = 1.2;
        elseif choice <= 1
            difficulty = 2;
        elseif choice <= 2
            difficulty = 2.5;
        else
            game = false;
        end
        %% main jump game start
        
x = 3;
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
if game == true
    printLCD(lcd, '   Block Jump ');
    printLCD(lcd, 'Jump to Survive');
    pause(2);
    printLCD(lcd, '     Game   ');
    printLCD(lcd, '     Start   ');
    pause(.7);
end


%Starts Game
while game == true
    
    ps = readDigitalPin(a,10);
    if ps == 1
        pause(0.5);
        ps = readDigitalPin(a,10);
        while ps ~= 1
                ps = readDigitalPin(a,10);
                gameSel = readVoltage(a,3);  %gameSel reads potentiometer value
                choice = round(gameSel); %rounds gameSel to nearest int
                if choice <= 2
                    printLCD(lcd,'  Game Paused');
                    printLCD(lcd,'    Resume?');
                else
                    printLCD(lcd,'  Game Paused');
                    printLCD(lcd,'     Quit?');
                end
                    
                    
        end
        if choice > 3
            game = false;
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
    if absScore >= 100
        game = false;
    end
    
    %Setting Speed
    
         pause(0.1^(0.01*(absScore+10)^difficulty));
    
end

if absScore == 0
    printLCD(lcd, '   GAME OVER ');
    printLCD(lcd, 'You are terrible');
    pause(2);
    
    elseif absScore < 20
    
    printLCD(lcd, '   GAME OVER ');
    printLCD(lcd, ' Basic Jumping');
    pause(2);
    printLCD(lcd, 'Your Score Was:');
    printLCD(lcd, num2str(absScore));
    pause(2);
    
    elseif absScore < 40
    
    printLCD(lcd, '   GAME OVER ');
    printLCD(lcd, '   Basketball');
    pause(2);
    printLCD(lcd, 'Your Score Was:');
    printLCD(lcd, num2str(absScore));
    pause(2);
    
    elseif absScore < 60
    
    printLCD(lcd, '   GAME OVER ');
    printLCD(lcd, '   Kangaroo');
    pause(2);
    printLCD(lcd, 'Your Score Was:');
    printLCD(lcd, num2str(absScore));
    pause(2);
    
    elseif absScore < 80
    
    printLCD(lcd, '   GAME OVER ');
    printLCD(lcd, '     Mario');
    pause(2);
    printLCD(lcd, 'Your Score Was:');
    printLCD(lcd, num2str(absScore));
    pause(2);
    
    else
    
    printLCD(lcd, '   GAME OVER ');
    printLCD(lcd, '    Godly');
    pause(2);
    printLCD(lcd, 'Your Score Was:');
    printLCD(lcd, num2str(absScore));
    pause(2);
    
    
end






    elseif choice <= 3
        %% RPS game start
        
        
game = true;
score = 0;
RPScount = 0;
baseV1 = readVoltage(a,0);
baseV2 = readVoltage(a,1);
baseV3 = readVoltage(a,2);
f1 = 0;
f2 = 0;
f3 = 0;
choice = 0;
shake = 0;
ps = readDigitalPin(a,10);


%Rows
row1 = [' ',' ',' ',' ',' ',' ',' ',' ',' ','S','c','o','r','e', ' ', ' '];
row2 = [' ','S','c','o','r','e',':',' ',' ',' ', ' ',' ',' ',' ',' ', ' '];

%Converts Array to String for LCD
TR = mat2str(row1);
BR = mat2str(row2);

%Displays Initialization of Game
printLCD(lcd, '   Rock Paper ');
printLCD(lcd, '    Scissors  ');
pause(2);
printLCD(lcd, '     Game   ');
printLCD(lcd, '     Start   ');
pause(.7);

%printLCD(lcd, TR);
%printLCD(lcd, BR);

%Starts Game
while game == true && score < 10
    
    %Reads flex sensor values
    f1 = abs(readVoltage(a,0) - baseV1);
    f2 = abs(readVoltage(a,1) - baseV2);
    f3 = abs(readVoltage(a,2) - baseV3);
    shake = readDigitalPin(a,9);
    ps = readDigitalPin(a,10);
    
    if ps == 1
        pause(0.5);
        ps = readDigitalPin(a,10);
        while ps ~= 1
                ps = readDigitalPin(a,10);
                gameSel = readVoltage(a,3);  %gameSel reads potentiometer value
                choice = round(gameSel); %rounds gameSel to nearest int
                if choice <= 1
                    printLCD(lcd,'  Game Paused');
                    printLCD(lcd,'    Resume?');
                elseif choice <= 3
                    printLCD(lcd,'  Game Paused');
                    printLCD(lcd,'   Calibrate?');
                else
                    printLCD(lcd,'  Game Paused');
                    printLCD(lcd,'     Quit?');
                end   
        end
        if choice > 3
            game = false;
        elseif choice > 1
            printLCD(lcd,'  Calibrating');
            printLCD(lcd,'      ...');
            pause(1.5);
            baseV1 = readVoltage(a,0);
            baseV2 = readVoltage(a,1);
            baseV3 = readVoltage(a,2);
            printLCD(lcd,'  Calibrated!');
            printLCD(lcd,'      ');
        end
    end
        
    
    RPScount = 0;
    
    if f1 > 0.14 && f2 > 0.14 && f3 > 0.14 
        choice = 1;
        printLCD(lcd, ' Current Choice ');
        printLCD(lcd, '      Rock      ');
    elseif f1 < 0.14 && f2 < 0.14 && f3 > 0.14
        choice = 2;
        printLCD(lcd, ' Current Choice ');
        printLCD(lcd, '    Scissors    ');
    elseif f1 < 0.14 && f2 < 0.14 && f3 < 0.14
        choice = 3;
        printLCD(lcd, ' Current Choice ');
        printLCD(lcd, '      Paper    ');
    else
        choice = 0;
        printLCD(lcd, ' Current Choice ');
        printLCD(lcd, ' Invalid Choice ');
    end
    
    %When you shake your hand the rock, paper, scissors count starts
    %On the last shake you have one second to choose
    %If you wait 5 seconds between shakes it cancels out
    
    if shake == 0
        printLCD(lcd, '      Rock! ');
        printLCD(lcd, '            ');
        pause(.15);
        tic;
        while RPScount < 5
            RPScount = toc;
            if RPScount <1 
                pause(.15);
            end
            shake = readDigitalPin(a,9);
            printLCD(lcd, '      ..... ');
            printLCD(lcd, '            ');
            if shake == 0
                printLCD(lcd, '      Paper! ');
                printLCD(lcd, '             ');
                pause(.15);
                tic;
                while RPScount < 5
                    RPScount = toc;
                    if RPScount <1 
                        pause(.15);
                    end
                    shake = readDigitalPin(a,9);
                    printLCD(lcd, '      ..... ');
                    printLCD(lcd, '            ');
                    if shake == 0
                        printLCD(lcd, '    Scissors! ');
                        printLCD(lcd, '             ');
                        pause(.15);
                        tic;
                        while RPScount < 5
                            RPScount = toc;
                            if RPScount <1 
                                pause(.15);
                            end
                            shake = readDigitalPin(a,9);
                            printLCD(lcd, '      ..... ');
                            printLCD(lcd, '            ');
                            if shake == 0
                                printLCD(lcd, '      Shoot! ');
                                printLCD(lcd, '             ');
                                %pause(2);
                                pause(2);
                                f1 = abs(readVoltage(a,0) - baseV1);
                                f2 = abs(readVoltage(a,1) - baseV2);
                                f3 = abs(readVoltage(a,2) - baseV3);
                                if f1 > 0.14 && f2 > 0.14 && f3 > 0.14 
                                    choice = 1;
                                elseif f1 < 0.14 && f2 < 0.14 && f3 > 0.14
                                    choice = 3;
                                elseif f1 < 0.14 && f2 < 0.14 && f3 < 0.14
                                    choice = 2;
                                else
                                    choice = 0;
                                end
                                
                                compChoice = randi([1,3],1);
                                if choice == 1
                                    printLCD(lcd, 'You:   Rock ');
                                elseif choice == 2
                                    printLCD(lcd, 'You:   Paper ');
                                elseif choice == 3
                                    printLCD(lcd, 'You: Scissors');
                                else
                                    printLCD(lcd, 'You:   Invalid');
                                    printLCD(lcd, '   Try Again  ');
                                    pause(2);
                                end
                                
                                if choice ~= 0 && compChoice == 1
                                    printLCD(lcd, 'comp:  Rock ');
                                    pause(2);
                                elseif choice ~= 0 && compChoice == 2
                                    printLCD(lcd, 'comp:  Paper ');
                                    pause(2);
                                elseif choice ~= 0 && compChoice == 3
                                    printLCD(lcd, 'comp: Scissors');
                                    pause(2);
                                end
                                
                                if choice ~= 0
                                    if choice - compChoice == 0
                                        printLCD(lcd, '   Game Tied   ');
                                        row2(8) = num2str(score);
                                        printLCD(lcd, row2);
                                        pause(2);
                                    elseif choice - compChoice == 1 || choice - compChoice == -2
                                        printLCD(lcd, '   You win!   ');
                                        score = score+1;
                                        row2(8) = num2str(score);
                                        printLCD(lcd, row2);
                                        pause(2);
                                    elseif choice - compChoice == -1 || choice - compChoice == 2
                                        printLCD(lcd, '   You lose   ');
                                        score = score-1;
                                        if score < 0
                                            score = 0;
                                        end
                                        row2(8) = num2str(score);
                                        printLCD(lcd, row2);
                                        pause(2);
                                    end
                                end
                                RPScount = 6;
                            end
                        end
                    end
                end
            end
        end
    end
end

                                
             
        
        
    else
        disp('ending game');
        totalGame = false;
    end
end