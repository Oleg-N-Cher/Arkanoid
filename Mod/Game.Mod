MODULE Game; (*$MAIN*)
IMPORT g := Graph, Sound, Strings := powStrings;

CONST
  BOARD_W = 500.0;
  BOARD_H = 500.0;
  BAT_W   = 104.0;
  BAT_H   =  24.0;
  BALL_R  =  11.0;
  BRICK_W =    64;
  BRICK_H =    32;
  NROWS   =     4;
  NCOLS   =     5;

TYPE
  Ball = RECORD posx, posy, velx, vely: REAL END;
  Brick = RECORD posx, posy: REAL; colour: INTEGER; hidden: BOOLEAN END;

VAR
  screen, bat_img, ball_img, bricks_img: g.Bitmap;
  font_img: g.Font;
  ball: Ball;
  batx, prev_batx, baty: REAL;
  quit: BOOLEAN; event: g.Event;
  hit_sfx, smash_sfx: Sound.Rsrc;
  bricks: ARRAY NROWS*NCOLS OF Brick;
  score, cleared: INTEGER;

PROCEDURE (VAR self: Ball) New (x, y: REAL);
BEGIN
  self.posx := x;
  self.posy := y;
  self.velx := 0.0;
  self.vely := 4.0;
  IF ball_img = NIL THEN ball_img := g.LoadBitmap("Data/ball.png") END;
END New;

PROCEDURE (VAR self: Ball) Update;
BEGIN
  self.posx := self.posx + self.velx;
  self.posy := self.posy + self.vely;
  IF (self.posx > BOARD_W) & (self.velx > 0) THEN self.velx := -self.velx END;
  IF (self.posx < 0) & (self.velx < 0) THEN self.velx := -self.velx END;
  IF (self.posy > BOARD_H) & (self.vely > 0) THEN self.vely := -self.vely END;
  IF (self.posy < 0) & (self.vely < 0) THEN self.vely := -self.vely END;
END Update;

PROCEDURE (VAR self: Ball) Draw;
BEGIN
  g.BlitWhole(
    ball_img, screen,
    SHORT(ENTIER(self.posx - 11.0)),
    SHORT(ENTIER(self.posy - 11.0))
  );
END Draw;

PROCEDURE (VAR self: Brick) New (x, y: REAL; c: INTEGER);
BEGIN
  self.posx := x; self.posy := y; self.colour := c;
  IF bricks_img = NIL THEN bricks_img := g.LoadBitmap("Data/bricks.png") END;
END New;

PROCEDURE (VAR self: Brick) Draw;
BEGIN
  g.Blit(bricks_img, screen,
    0, self.colour*BRICK_H, BRICK_W, BRICK_H,
    SHORT(ENTIER(self.posx - BRICK_W/2)), SHORT(ENTIER(self.posy - BRICK_H/2))
  );
END Draw;

PROCEDURE OnCreate;
VAR
  b, r: INTEGER;
BEGIN
  g.Randomize;
  score := 0; cleared := 0;
  bat_img := g.LoadBitmap("Data/bat.png"); ASSERT(bat_img # NIL);
  ball.New(250, 250);
  batx := 250.0; prev_batx := 25.0; baty := 450.0;
  FOR b := 0 TO NROWS-1 DO
    FOR r := 0 TO NCOLS-1 DO
      bricks[r + b*NCOLS].New(100 + r*BRICK_W, 100 + b*BRICK_H, g.Random(6));
    END;
  END;
  Sound.Load(hit_sfx, "Data/hit.wav");
  Sound.Load(smash_sfx, "Data/smash.wav");
  font_img := g.LoadFont("Data/font.png", 20, 35); ASSERT(font_img # NIL);
END OnCreate;

PROCEDURE ResetBoard;
VAR
  n: INTEGER;
BEGIN
  FOR n := 0 TO LEN(bricks)-1 DO bricks[n].hidden := FALSE END;
END ResetBoard;

PROCEDURE OnUpdate;
VAR
  x, y, n: INTEGER; xd, yd: REAL;
BEGIN
  prev_batx := batx;
  g.GetMousePos(x, y);
  IF x > 0 THEN batx := x END;
  ball.Update;
  IF (ABS(ball.posx - batx) < BAT_W/2)
   & (ABS(ball.posy - baty) < BAT_H)
   & (ball.vely > 0)
  THEN
    ball.vely := -ball.vely;
    Sound.Play(hit_sfx);
    ball.velx := ball.velx + 0.25*(batx - prev_batx);
  END;

  FOR n := 0 TO LEN(bricks)-1 DO
    IF ~ bricks[n].hidden THEN
      xd := ABS(ball.posx - bricks[n].posx);
      yd := ABS(ball.posy - bricks[n].posy);
      IF (xd <= BRICK_W/2 + BALL_R) & (yd < BRICK_H/2) THEN
        ball.velx := -ball.velx;
        bricks[n].hidden := TRUE;
        INC(score, 100);
        Sound.Play(smash_sfx);
        INC(cleared);
      ELSIF (yd <= BRICK_H/2 + BALL_R) & (xd < BRICK_W/2) THEN
        ball.vely := -ball.vely;
        bricks[n].hidden := TRUE;
        INC(score, 100);
        Sound.Play(smash_sfx);
        INC(cleared);
      END;
    END;
  END;

  IF cleared >= NROWS*NCOLS THEN
    ResetBoard;
    INC(score, 1000);
    cleared := 0;
  END;

  IF ball.posy > 470 THEN
    ResetBoard;
    cleared   :=   0;
    score     :=   0;
    ball.posx := 250;
    ball.posy := 250;
    ball.velx :=   0;
    ball.vely :=   4;
  END;

END OnUpdate;

PROCEDURE OnRender;
VAR
  n: INTEGER; str: ARRAY 12 OF CHAR;
BEGIN
  g.ClearScreenToColor(50505050H);
  g.BlitWhole(bat_img, screen,
    SHORT(ENTIER(batx-BAT_W/2)), SHORT(ENTIER(baty-BAT_H/2))
  );
  ball.Draw();

  (* bricks.Draw *)
  FOR n := 0 TO LEN(bricks)-1 DO
    IF ~bricks[n].hidden THEN bricks[n].Draw END;
  END;

  Strings.Str(score, str);
  g.DrawString(screen, font_img, 230, 23, str, 0BBBBBBH);
END OnRender;

BEGIN
  g.Settings(640, 480, {g.spread, g.initMouse});
  screen := g.Init(); g.SetFPS(60);
  OnCreate;
  quit := FALSE; g.ShowMouse(TRUE);
  REPEAT
    g.WaitEvents(0);
    WHILE g.PollEvent(event) DO
      CASE event.type OF
      | g.quit:
          quit := TRUE;
      | g.keyDown:
          IF (event.key.code = g.kEsc) OR (event.key.code = g.kF10) THEN
            quit := TRUE;
          END;
          IF (event.key.code = g.kEnter) & (event.key.mod * g.mAlt # {}) THEN
            g.ToggleFullscreen;
          END;
      ELSE
      END;
    END;
    OnUpdate; OnRender; g.Flip;
  UNTIL quit;
  g.Close;
  Sound.Free(hit_sfx); Sound.Free(smash_sfx);
  Sound.Quit
END Game.
