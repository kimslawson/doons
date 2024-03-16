REM DOONS (like snood but, you know, reversed)
REM built with Turban (TURboBAsic Nifty)
REM obsfuscated using tbxlparser
REM requires Turbo-BASIC XL
REM by Kim Slawson
REM initial idea and doon shapes 2021-08-22
REM development began for competition 2024-02-xx

REM TODO OR DIE for compo:
REM   Playtest the fuck out of it
REM   REARRANGE CODE! avoid procs when possible or fit into whole line. if/then is the line-kiler ig?
REM   check for extra parens, needed not needed for comparison, assignment, etc
REM   check for superfluous/redundant variables/program code 
REM   comment
REM   screenshots
REM   story

REM the doons look like this
REM
REM  # # # #
REM ########
REM  ## # ## 
REM ########
REM  #######
REM ########
REM  #######
REM ########

REM define characters for doons and cannon, array to hold stack of xy vals for floodcheck routine
dim f$(64), ax(255),ay(255)
REM  # # # #                                         ######                                         ########                                        ########                  ###
REM ########                      #                 ########                 #                      ########                # # # #                 #######                  #####
REM  ## # ##                      ##                ########                ##                      ########                                        ########                #######
REM ########                      ##                ########                ##                      ########                                        #######                 #######
REM  #######                      #                 ########                 #                      ########                                        ## # ###                ### # #
REM ########                                        ########                                         ######                                         ## # ##                  ### #
REM  #######                                        ########                                         ######                                         ########                  ### #
REM ########                                        ########                                        ########                                        # # # #                       #
REM DOON (eyes move in code)CANNON WHEEL LEFT       CANNON BODY REAR        CANNON WHEEL RIGHT      CANNON BODY FRONT       DOON TIP (HAIR)         DOON IN FLIGHT          BOMB (fuse flickers in code)
f$="\55\FF\6B\FF\7F\FF\7F\FF\00\02\03\03\02\00\00\00\7E\FF\FF\FF\FF\FF\FF\FF\00\40\C0\C0\40\00\00\00\FF\FF\FF\FF\FF\7E\7E\FF\00\AA\00\00\00\00\00\00\FF\FE\FF\FE\D7\D6\FF\AA\38\7C\FE\F6\EA\74\3A\02"
gr.2

REM get screen location -- like scrlo=PEEK(88):scrhi=PEEK(89) but better
scrmem=DPEEK(88)

REM set up colors
dpoke 708, 65009:rem same as poke 708, 241:poke 709, 253
dpoke 710, 63483:rem same as poke 710, 251:poke 711, 247
poke 712, 31

REM title
pos.7,1:?#6;["~d~Oo~Ns~!"]
pause 200
cls#6

REM redefine characters A-G
CH=(PEEK(106)-16)*256:MOVE 57344,CH,1024
MOVE ADR(F$),CH+264,64:POKE 756,CH/256

REM no cursor
poke 752,1

REM initialize color, cannon/doon position
exec col
x=1:y=2

REM mtime is cannon movement timer, dtime is doon movement timer, etime is eye movement timer
REM rtime is row timer, ltime is level timer, btime is bomb timer

REM game loop
while 1
  rem allow for two jiffies between movements of the cannon
  if s<>15 and time-mtime>2
 
    rem clear text window, display new score
    cls
    ? score
 
    REM copy 2 lines of blank space from page 6, leave room for bomb at start of second line
    move 1536,scrmem,20
    move 1536,scrmem+21,19
    color 32:plot x,2

    rem move left or right based upon stick position
    x=x+(S=7)*(x<18)-(s=11)*(X>1)

    if peek(scrmem+40+x)
      rem if the cannon hit a doon, game over. turn off the lights. close the eyes.
      poke 712,0
      poke 45322,127
      pause 400
      pos.6,0:?#6;["~RIP. 1UP?~"]
      while strig(0)=1
      wend
      run
    endif

    rem draw cannon
    pos.x-1,0
    ? #6;"BCD":REM body of cannon
    poke scrmem+20+x,37:REM tip of cannon
    if fired=0
      REM draw doon in cannon
      color c-1
      plot x,2
    endif

    rem prevent attract
    poke 77,0

    mtime=time
  endif

  if bomb
    REM every second, change the bomb color
    if time-btime>60
      color 72+rand(2)*128+rand(2)*32
      plot 0,1
      btime=time
    endif

    REM if the cannon is next to the bomb and the trigger is pressed...
    if trig and x=1
      REM In AD 2024, war was beginning.

      REM Doons: What happen ?
      REM Doons: Somebody set up us the bomb.
      REM Doons: We get signal.
      REM Doons: What !
      REM Doons: Main screen turn on.
      REM Doons: It's you !!

      REM Bomb: How are you gentlemen !!
      REM Bomb: All your Doons are belong to us.
      REM Bomb: You are on the way to destruction.
      REM Doons: What you say !!
      REM Bomb: You have no chance to survive make your time.
      REM Bomb: Ha ha ha ha ....

      for checky=0 to 9
        for checkx=0 to 19
          REM peek the spot next to the cannon in the first row, first column, where the bomb goes
          REM if it's the same color as the doon, the doon gets set up the bomb
          if peek(scrmem+checky*20+checkx)=peek(scrmem+20)-7
             exec lookup
          endif
        next checkx
      next checky

      REM now is the time for all good bombs to go away
      bomb=0
      poke scrmem+20,0
      sound:REM shh...
    endif
  endif

  rem if the doon is loaded, but not fired, fire on trigger press
  if trig and fired=0
    fired=1
    rem set doon x coordinate, doon movement timer, and firing timer
    dx=x
    dtime=time

    rem some days you just can't get rid of a bomb!
    rem every one in fifty shots you get a bomb
    rem if you already have one bomb, too bad,
    rem dem's the breaks, that's all you get.
    rem (you should be happy you get one bomb.
    rem  when I was your age, I never got any bombs...)
    bomb=(bomb or (rand(50)=0))
  endif

  rem if the doon has been fired and it's been an appropriate number of jiffies, move the doon
  rem the speed varies by level. There are nominally 16 levels, until it's all the same speed
  if fired and time-dtime>(5-(lev/4))
    rem move the doon doon until it lands
    if y<9
      sound 0,200,8,10-y
      REM *BOOM*

      color 32:plot dx,y
      y=y+1
      color c:plot dx,y:REM going.... doon?
    endif

    rem look doon to see if we hit any other doons
    if y=9 or peek(scrmem+(y+1)*20+dx)<>0
      rem flip the doon right-side up for best landing pose
      c=c-6
      color c
      plot dx,y

      rem explode the same colored doons if they're touching
      counter=0
      checkx=dx
      checky=y
      exec floodcheck
      sound:REM shh...

      rem reset the state for next doon to be shot out of the cannon, pick a new doon color
      fired=0
      y=2
      exec col
      color c-1:plot x,2
    endif

    dtime=time:REM reset doon movement timer
  endif

  rem doons got shifty eyes, bro
  eyes=rand(5)*10-10
  if time-etime>50 and eyes
    poke 45322, 97+eyes
    etime=time
  endif

  rem the doons just never stop getting taller, man
  rem every so often, make a new line of doons.
  rem at first 30 seconds between lines, but it gets quicker
  if time-rtime>1800-lev*100 and fired=0
    cc=c:REM save current color
    for i=0 to 19
      exec col
      color c-6
      plot i,10
    next i
    move scrmem+60,scrmem+40,180
    rtime=time
    c=cc:REM restore previous color
    color c-1:plot x,2:REM draw doon in cannon
  endif

  rem increment the background color through the atari spectrum
  rem 16 hues, 16 minutes, then it loops
  if time-ltime>3200
    poke 712,(31+lev*16) MOD 256
    lev=lev+1
    ltime=time
  endif

  rem get stick direction (only use horizontal) and trigger status
  S=STICK(0)
  trig=1-strig(0)
wend


proc col
  REM four colors: dark, med-dark, med-light, and light
  c=71+rand(2)*128+rand(2)*32 
endproc


proc lookup
  sy=checky

  REM erase current position
  color 32
  plot checkx,checky
  score=score+1

  sy=sy-(sy>0)*.5
  sound 0,200-rand(200),8,sy
  REM *BANG*
  REM (if it's a bomb going off then it's a BIG bang)

  REM this is kind of like a wile-coyote cartoon so the gravity takes a while
  locate checkx, checky-1, cc
  if cc<>32 and cc<>c-1 and checky>2
    color cc
    plot checkx, checky
    color 32
    plot checkx, checky-1
    checky=checky-1
    exec lookup
  endif
endproc


proc floodcheck
  REM say what? recursion in basic without local variables?
  REM yes, viriginia, there is a stack counter
  REM good thing mode 2 is lowrez so we don't need to allocate too much memory

  REM don't go out of bounds
  if checkx<0 or checkx>19 then endproc

  REM if it's the same color, blow it up and make it rain doon
  locate checkx,checky,cc
  if cc = c 
    if counter>0
      exec lookup
    endif

    REM push current position onto the stack
    ax(counter)=checkx
    ay(counter)=checky
    counter=counter+1

    REM let's do the floodfill time warp:
    REM it's just a jump to the left
    checkx=checkx-1
    exec floodcheck
    checkx=checkx+1

    REM and then a step to the right
    checkx=checkx+1
    exec floodcheck
    checkx=checkx-1

    REM but it's the (upward) thrust
    checky=checky-1
    exec floodcheck
    checky=checky+1

    REM that really drives you (doon)
    checky=checky+1
    exec floodcheck
    checky=checky-1

    REM decrement counter to point to previous position on the stack
    counter=counter-1

  endif
endproc
