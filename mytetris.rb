=begin

Rubyの課題で作ったTetris擬きをTetrisに昇華させたい。

=end

require 'ruby2d'

set title: "Tetris: Ruby 2D", background: 'navy', width: 800, height: 680

#####################
## set instance variable method
#####################

def fieldxyset()
  # fieldxyをセットする。10*20の二次元配列で中身は[x,y]の座標。
  a = []
  10.times do |i|
    a.push([])
    20.times { |j| a[i].push([]) }
  end
  10.times do |i|
    20.times { |j| a[i][j] = [@fieldoffset[0]+@blocksize*i, @fieldoffset[1]+@blocksize*j] }
  end
  a
end

def wallsset()
  walls = []
  tmp = Rectangle.new(x: @walloffset[0], y: @walloffset[1],width: @wallwidth, height: @wallwidth*2 + @blocksize*20,color: @wallcolor, z: 100)
  walls.push(tmp)
  tmp = Rectangle.new(x: @walloffset[0] + @wallwidth + @blocksize * 10, y: @walloffset[1],width: @wallwidth, height: @wallwidth*2 + @blocksize*20,color: @wallcolor, z: 100)
  walls.push(tmp)
  tmp = Rectangle.new(x: @walloffset[0], y: @walloffset[1] + @wallwidth + @blocksize*20,width: @wallwidth*2 + @blocksize*10, height: @wallwidth,color: @wallcolor, z: 100)
  walls.push(tmp)
  tmp = Rectangle.new(x: @walloffset[0], y: @walloffset[1],width: @wallwidth*2 + @blocksize*10, height: @wallwidth,color: @wallcolor, z: 100)
  walls.push(tmp)
  tmp = Rectangle.new(x: @walloffset[0] + @wallwidth + @blocksize*2, y: @walloffset[1],width: @blocksize*6, height: @wallwidth,color: (get :background), z: 200)
  walls.push(tmp)
  walls
end

def setfieldnowbool()
  a = []; b = []
  10.times do |i|
    a.push([])
    20.times { |j| a[i].push(false) }
  end
  a
end

def nextsholdframedepict()
  # nextとholdの枠を作っておく
  ntcolor = 'silver'
  # fromfieldmargin = 20
  ntx = 340; nty = 115; ntsize = 60
  Square.new(x: ntx, y: nty,               size: ntsize, color: ntcolor, z: 10)
  Square.new(x: ntx, y: nty+(ntsize+10),   size: ntsize, color: ntcolor, z: 10)
  Square.new(x: ntx, y: nty+(ntsize+10)*2, size: ntsize, color: ntcolor, z: 10)
  hdx = 40
  Square.new(x: hdx, y: nty, size: ntsize, color: ntcolor, z: 10)
  marginx = 9; marginy = -25
  Text.new('Next', x: ntx+marginx, y: nty+marginy, size: 20, color: 'white', z: 10)
  Text.new('Hold', x: hdx+marginx, y: nty+marginy, size: 20, color: 'white', z: 10)
end

def nextholdtetrimino(x, y, minonum)
  # nextやholdの中身に表示するテトリミノ(位置も適切に)を作成。
  # nextやholdの枠の大きさは決まっているとする
  # 枠の左上頂点の座標をx,yで受け取り、作成するテトリミノをminonumで受け取る
  # 枠のサイズは上のメソッドのntsize = 60とする。
  margin = 10 # ミノを描画する4*4の領域の枠からのmargin
  framex = x + margin; framey = y + margin
  unitij = (60 - margin*2) / 4
  # 順にO,I,T,S,Z,J,Lを表す
  a = [[[1,1],[1,2],[2,1],[2,2]], [[0,1],[1,1],[2,1],[3,1]], [[0,1],[1,0],[1,1],[2,1]],
       [[0,1],[1,0],[1,1],[2,0]], [[0,0],[1,0],[1,1],[2,1]],
       [[0,0],[0,1],[1,1],[2,1]], [[0,1],[1,1],[2,0],[2,1]]]
  tmpc = ['yellow','teal','purple','green','red','blue','orange']
  tempmino = []
  a[minonum].each do |xy|
    tmpx = framex+unitij*xy[0]; tmpy = framey+unitij*xy[1]
    tmpblock = Square.new(x: tmpx, y: tmpy, size: unitij, color: tmpc[minonum], z:20)
    tempmino.push(tmpblock)
  end
  tempmino
end

def nextminoset(n)
  # nextminoのn個目をセットする。
  # n == 1ならnextmino1.
  ntx = 340; nty = 115 + (n-1) * (60+10)
  tmpnext = []
  7.times do |minonum|
    tempmino = nextholdtetrimino(ntx,nty,minonum)
    tempmino.each { |block| block.remove }
    tmpnext.push(tempmino)
  end
  tmpnext
end

def holdminoset()
  # holdminoをセットする。
  hdx = 40; nty = 115
  tmphold = []
  7.times do |minonum|
    tempmino = nextholdtetrimino(hdx,nty,minonum)
    tempmino.each { |block| block.remove }
    tmphold.push(tempmino)
  end
  tmphold
end

#####################
## instance variable
#####################

@blocksize = 20 # 1ブロックのサイズ
@wallwidth = 5           # 壁の幅
@wallcolor = 'gray'      # 壁の色
@walloffset  = [115,115] # 壁の左上の座標
@fieldoffset = [120,120] # フィールドの左上の座標
@fieldxy = fieldxyset()  # @fieldxy[i][j]...フィールドのxがi個目、yがj個目の位置の座標[x,y]を格納。
@fieldcolor = 'brown'    # フィールドの背景色
@fieldback = Rectangle.new(x: @fieldoffset[0], y: @fieldoffset[1], width: @blocksize*10, height: @blocksize*20, color: @fieldcolor, z: 0)
                         # フィールド背景の図形
@walls = wallsset()               # フィールドの上下左右にある壁
@fieldnow = []                    # 現時点でフィールドに残っているブロック
@fieldnowbool = setfieldnowbool() # 現時点でフィールドに残っているブロックの位置をtrueで格納
@randomtetri = [0,1,2,3,4,5,6]
@randomtetri.sort_by! {rand}
  # 7つのテトリミノを表す。使う時はarrayをシャッフルする
@nextsnum = [[],[],[]]; 3.times { |i| @nextsnum[i].push(@randomtetri.pop) }
  # 順にnext1,next2,next3のミノの種類
@nextsmino = []
@nextsmino.push(nextminoset(1))
@nextsmino.push(nextminoset(2))
@nextsmino.push(nextminoset(3))
  # 順にnext1,next2,next3に表示する7種類のミノ(とその位置)が格納されている

@holdnum = -1 # holdされているミノの種類。holdしたことないなら-1になる
@holdmino = holdminoset() # holdに表示する7種類のミノ(とその位置)が格納されている
@hold   = false # ホールドの入力はしたがまだホールドの判定をしていないときtrue。
@holded = false # 直前にホールドを行ったか。ホールド2連続はできない

@nowminonum = 0 # 今のミノが何かを0~6で格納。O,I,T,S,Z,J,L

@move = false # 移動の入力はしたがまだ移動の判定をしていないときtrue。moveなんとかの競合を防ぐ
@moveleft = false # 左へ移動するか
@moveright = false # 右へ移動するか
@harddrop = false # ハードドロップするか

@softdrop = false # ソフトドロップするか。こいつだけ上のやつらとは挙動が異なる

@rotate = false # 回転の入力はしたがまだ回転の判定をしていないときtrue。rotateなんとかの競合を防ぐ
@rotateleft  = false # 右回り(時計回り)で回転するか
@rotateright = false # 左回り(反時計回り)で回転するか
@rotatestate = 0 # ミノの回転状態を0,1,2,3で格納。North,East,South,West。右回りで+1, 左回りで-1。
# 以下、rotateXはXミノの@rotatestate=iのときの各々のブロックの相対位置を格納したもの。
@rotateO = [[[0,0],[0,1],[1,0],[1,1]],
            [[0,0],[0,1],[1,0],[1,1]],
            [[0,0],[0,1],[1,0],[1,1]],
            [[0,0],[0,1],[1,0],[1,1]]]
@rotateI = [[[0,1],[1,1],[2,1],[3,1]],
            [[2,0],[2,1],[2,2],[2,3]],
            [[3,2],[2,2],[1,2],[0,2]],
            [[1,3],[1,2],[1,1],[1,0]]]
@rotateT = [[[0,1],[1,0],[1,1],[2,1]],
            [[1,0],[2,1],[1,1],[1,2]],
            [[2,1],[1,2],[1,1],[0,1]],
            [[1,2],[0,1],[1,1],[1,0]]]
@rotateS = [[[0,1],[1,0],[1,1],[2,0]],
            [[1,0],[2,1],[1,1],[2,2]],
            [[2,1],[1,2],[1,1],[0,2]],
            [[1,2],[0,1],[1,1],[0,0]]]
@rotateZ = [[[0,0],[1,0],[1,1],[2,1]],
            [[2,0],[2,1],[1,1],[1,2]],
            [[2,2],[1,2],[1,1],[0,1]],
            [[0,2],[0,1],[1,1],[1,0]]]
@rotateJ = [[[0,0],[0,1],[1,1],[2,1]],
            [[2,0],[1,0],[1,1],[1,2]],
            [[2,2],[2,1],[1,1],[0,1]],
            [[0,2],[1,2],[1,1],[1,0]]]
@rotateL = [[[0,1],[1,1],[2,0],[2,1]],
            [[1,0],[1,1],[2,2],[1,2]],
            [[2,1],[1,1],[0,2],[0,1]],
            [[1,2],[1,1],[0,0],[1,0]]]

@gamestart = false # ゲームを始める
@gameover  = false # ゲームを終える
@gamepause = false # ゲームを一時中断する
@gamerec   = [Rectangle.new(x: 350, y: 470, width: 320, height: 50, color: 'maroon', z: 9998),
              Rectangle.new(x: 345, y: 465, width: 330, height: 60, color: 'silver', z: 9997)]
  # ゲーム開始前とかに出てくるテキストボックスみたいなもの
@gamelabel = Text.new("Press 'Enter' to start.", x: 360, y: 485, size: 20, color: 'white', z: 9999)
  # 上のテキストボックスみたいなものの中身

@score = 0 # 現在のスコアを格納
@lines = 0 # 今までの消したライン数を格納
sclnposx = 345; scposy = 360
@scorelabel = Text.new("0", x: sclnposx+70, y: scposy, size: 20, color: 'white') # 現在のスコアを表示
Text.new("Score:", x: sclnposx, y: scposy,    size: 20, color: 'white')
@lineslabel = Text.new("0", x: sclnposx+70, y: scposy+30, size: 20, color: 'white') # 現在の消去ライン数を表示
Text.new("Lines:", x: sclnposx, y: scposy+30, size: 20, color: 'white')
@scoreline = [100, 300, 500, 800] # 順に1,2,3,4ライン消した時の得点
@backtoback = false # 直前のライン消しがTetrisかT-spinならtrue
@harddropscore = 2 # ハードドロップ1マス毎のスコア
@softdropscore = 1 # ソフトドロップ1マス毎のスコア

#####################
## method
#####################


def fieldjudge(tetrimino,di,dj)
  # tetriminoが(di,dj)だけ動いたら@fieldnowにぶつかるかを判定。
  dx = @blocksize*0.5 + @blocksize * di
  dy = @blocksize*0.5 + @blocksize * dj
  tetrimino.each do |block|
    @fieldnow.each do |x|
      # block.x/yは現在のblockの左上頂点の座標。
      # ここでは移動後のblockの中心座標が@fieldnowの各ブロックに含まれるか判定している。
      return true if (x.contains? block.x+dx, block.y+dy)
    end
  end
  return false
end

def walljudge(tetrimino,di,dj)
  # tetriminoが(di,dj)だけ動いたらwallにぶつかるかを判定。
  # @fieldbackから外れるかどうかで代用している。
  dx = @blocksize*0.5 + @blocksize * di
  dy = @blocksize*0.5 + @blocksize * dj
  tetrimino.each do |block|
    return true unless (@fieldback.contains? block.x+dx, block.y+dy)
  end
  return false
end

def fieldjudgeblock(block,di,dj)
  # blockが(di,dj)だけ動いたら@fieldnowにぶつかるかを判定。
  dx = @blocksize*0.5 + @blocksize * di
  dy = @blocksize*0.5 + @blocksize * dj
  @fieldnow.each do |x|
    # block.x/yは現在のblockの左上頂点の座標。
    # ここでは移動後のblockの中心座標が@fieldnowの各ブロックに含まれるか判定している。
    return true if (x.contains? block.x+dx, block.y+dy)
  end
  return false
end

def walljudgeblock(block,di,dj)
  # blockが(di,dj)だけ動いたらwallにぶつかるかを判定。
  # @fieldbackから外れるかどうかで代用している。
  dx = @blocksize*0.5 + @blocksize * di
  dy = @blocksize*0.5 + @blocksize * dj
  return true unless (@fieldback.contains? block.x+dx, block.y+dy)
  return false
end

def srsI(tetrimino, st)
  # SRSの実装。Iミノのみ。
  nextst = (@rotatestate + st + 4) % 4 # 回転後のミノの状態
  di = 0; dj = 0 # 左右、上下にどれだけ動かすか
  # 1.座標を左右に動かしてみる
  if @rotatestate == 0
    # 回転前がNorthなら右回転だろうが左回転だろうが左端へ
    di = st == 1 ? -2 : -1
  elsif @rotatestate == 2
    # 回転前がSouthなら右回転だろうが左回転だろうが右端へ
    di = st == 1 ? 2 : 1
  elsif @rotatestate == 1
    # 回転前がEastなら右回転で左へ、左回転で2つ右へ
    di = st == 1 ? -1 : 2
  elsif @rotatestate == 3
    # 回転前がWestなら右回転で2つ左へ、左回転で右へ
    di = st == 1 ? -2 : 1
  end
  unless fieldjudge(tetrimino,di,dj) || walljudge(tetrimino,di,dj)
    movetetrimino(tetrimino,di,dj)
    return true
  end
  # 2.座標を左右に動かしてみる(2)
  if @rotatestate == 0
    # 回転前がNorthなら右回転だろうが左回転だろうが右端へ
    di = st == 1 ? 1 : 2
  elsif @rotatestate == 2
    # 回転前がSouthなら右回転だろうが左回転だろうが左端へ
    di = st == 1 ? -1 : -2
  elsif @rotatestate == 1
    # 回転前がEastなら右回転で2つ右へ、左回転で左へ
    di = st == 1 ? 2 : -1
  elsif @rotatestate == 3
    # 回転前がWestなら右回転で右へ、左回転で2つ左へ
    di = st == 1 ? 1 : -2
  end
  unless fieldjudge(tetrimino,di,dj) || walljudge(tetrimino,di,dj)
    movetetrimino(tetrimino,di,dj)
    return true
  end
  # 3.ミノの端のブロックを軸とした回転
  if @rotatestate == 0
    # 回転前がNorthなら左端へ。右回転で下へ、左回転で2つ上へ
    # 左端中心の回転と考えると直感的
    di = st == 1 ? -2 : -1
    dj = st == 1 ? 1 : -2
  elsif @rotatestate == 2
    # 回転前がSouthなら右端へ。右回転で上へ、左回転で2つ下へ
    # 右端中心の回転と考えると直感的
    di = st == 1 ? 2 : 1
    dj = st == 1 ? -1 : 2
  elsif @rotatestate == 1
    # 回転前がEastなら上端へ。右回転で左へ、左回転で2つ右へ
    # 上端中心の回転と考えると直感的
    dj = st == 1 ? -2 : -1
    di = st == 1 ? -1 : 2
  elsif @rotatestate == 3
    # 回転前がWestなら下端へ。右回転で右へ、左回転で2つ左へ
    # 下端中心の回転と考えると直感的
    dj = st == 1 ? 2 : 1
    di = st == 1 ? 1 : -2
  end
  unless fieldjudge(tetrimino,di,dj) || walljudge(tetrimino,di,dj)
    movetetrimino(tetrimino,di,dj)
    return true
  end
  # 4.ミノの端のブロックを軸とした回転(2)
  if @rotatestate == 0
    # 回転前がNorthなら右端へ。右回転で2つ上へ、左回転で下へ
    # 右端中心の回転と考えると直感的
    di = st == 1 ? 1 : 2
    dj = st == 1 ? -2 : 1
  elsif @rotatestate == 2
    # 回転前がSouthなら左端へ。右回転で2つ下へ、左回転で上へ
    # 左端中心の回転と考えると直感的
    di = st == 1 ? -1 : -2
    dj = st == 1 ? 2 : -1
  elsif @rotatestate == 1
    # 回転前がEastなら下端へ。右回転で2つ右へ、左回転で左へ
    # 下端中心の回転と考えると直感的
    dj = st == 1 ? 1 : 2
    di = st == 1 ? 2 : -1
  elsif @rotatestate == 3
    # 回転前がWestなら上端へ。右回転で2つ左へ、左回転で右へ
    # 上端中心の回転と考えると直感的
    dj = st == 1 ? -1 : -2
    di = st == 1 ? -2 : 1
  end
  unless fieldjudge(tetrimino,di,dj) || walljudge(tetrimino,di,dj)
    movetetrimino(tetrimino,di,dj)
    return true
  end
  # 5.無理でした
  false
end

def srsTSZJL(tetrimino, st)
  # SRSの実装。TSZJL。tetriminoの回転状態をst(-1 or 1)だけ進めたかったが出来なかった状態を想定。
  nextst = (@rotatestate + st + 4) % 4 # 回転後のミノの状態
  di = 0; dj = 0 # 左右、上下にどれだけ動かすか
  # 1.座標を左右に動かしてみる
  if nextst == 1
    di = -1 # 回転後がEastなら左へ
  elsif nextst == 3
    di = 1  # 回転後がWestなら右へ
  elsif @rotatestate == 1
    di = 1  # 回転前がEast(回転後はNorthかSouth)なら右へ
  elsif @rotatestate == 3
    di = -1 # 回転前がWest(回転後はNorthかSouth)なら左へ
  end
  unless fieldjudge(tetrimino,di,dj) || walljudge(tetrimino,di,dj)
    movetetrimino(tetrimino,di,dj)
    return true
  end
  # 2.ダメなら更に座標を上下に動かしてみる
  if nextst == 1 || nextst == 3
    dj = -1 # 回転後がEastかWestなら上へ
    di = nextst == 1 ? -1 : 1
  else
    dj = 1  # 回転後がNorthかSouthなら下へ
    di = @rotatestate == 1 ? 1 : -1
  end
  unless fieldjudge(tetrimino,di,dj) || walljudge(tetrimino,di,dj)
    movetetrimino(tetrimino,di,dj)
    return true
  end
  # 3.元に戻して座標を上下に2マス動かしてみる
  di = 0; dj = 0
  if nextst == 1 || 3
    dj = 2  # 回転後がEastかWestなら2つ下へ
  else
    dj = -2 # 回転後がNorthかSouthなら2つ上へ
  end
  unless fieldjudge(tetrimino,di,dj) || walljudge(tetrimino,di,dj)
    movetetrimino(tetrimino,di,dj)
    return true
  end
  # 4.ダメなら更に座標を左右に動かしてみる
  if nextst == 1
    di = -1 # 回転後がEastなら左へ
  elsif nextst == 3
    di = 1  # 回転後がWestなら右へ
  elsif @rotatestate == 1
    di = 1  # 回転前がEast(回転後はNorthかSouth)なら右へ
  elsif @rotatestate == 3
    di = -1 # 回転前がWest(回転後はNorthかSouth)なら左へ
  end
  unless fieldjudge(tetrimino,di,dj) || walljudge(tetrimino,di,dj)
    movetetrimino(tetrimino,di,dj)
    return true
  end
  # 5.無理でした
  false
end

def rotatejudge(tetrimino, st)
  # tetriminoの回転状態をst(-1 or 1)だけ進め、問題なければ回転を行う
  # 回転を行ったらtrueを、できなかったらfalseを返す
  a = []
  case @nowminonum
  when 0; a = @rotateO
  when 1; a = @rotateI
  when 2; a = @rotateT
  when 3; a = @rotateS
  when 4; a = @rotateZ
  when 5; a = @rotateJ
  when 6; a = @rotateL
  end
  nextst = (@rotatestate + st + 4) % 4
  rotateNG = false # そのまま回転できないならtrue
  # そのまま回転できるかチェック
  4.times do |blk|
    di = a[nextst][blk][0] - a[@rotatestate][blk][0]
    dj = a[nextst][blk][1] - a[@rotatestate][blk][1]
    rotateNG = rotateNG || fieldjudgeblock(tetrimino[blk],di,dj)
    rotateNG = rotateNG ||  walljudgeblock(tetrimino[blk],di,dj)
  end
  # まあ色々あるのでとりあえず回転させとく
  4.times do |blk|
    di = a[nextst][blk][0] - a[@rotatestate][blk][0]
    dj = a[nextst][blk][1] - a[@rotatestate][blk][1]
    tetrimino[blk].x += @blocksize * di
    tetrimino[blk].y += @blocksize * dj
  end
  unless rotateNG
    # そのまま回転できるんならいいんじゃない？
    @rotatestate = nextst
    return true
  else
    # そのまま回転できないならSRS判定を行う
    rotated = false
    if @nowminonum == 1
      rotated = srsI(tetrimino, st)
    elsif @nowminonum != 0
      rotated = srsTSZJL(tetrimino, st)
    end
    # 何をやってもダメだったら回転前の状態に戻す
    unless rotated
      4.times do |blk|
        di = a[nextst][blk][0] - a[@rotatestate][blk][0]
        dj = a[nextst][blk][1] - a[@rotatestate][blk][1]
        tetrimino[blk].x -= @blocksize * di
        tetrimino[blk].y -= @blocksize * dj
      end
      return false
    end
    # SRSできたらSRSしたよ
    @rotatestate = nextst
    return true
  end
  false
end

def renewfield(completelines,deleteline)
  # 揃っているラインの配列と揃ったライン数を受け取り、盤面を更新する
  # 横のラインごとに見ていく
  completelines.each do |linej|
    # blockごとに見ていく
    deleteblocks = [] # 消すblockを格納していく
    ### p [:linej, linej]
    @fieldnow.each do |block|
      # blockがlinejの位置に有ればdeleteblocksに格納
      check1 = @fieldoffset[1]+@blocksize*linej
      check2 = @fieldoffset[1]+@blocksize*(linej+1)
      if check1 <= block.y+@blocksize*0.5 && block.y+@blocksize*0.5 <= check2
        ### p [:block, block.x, block.y]
        deleteblocks.push(block)
        # p [:dbsize, ]
      end
    end
    ### p [:deleting, @fieldnow.size, :dbsize, deleteblocks.size]
    # 実際にここでdeleteblocksの中身を削除していく
    deleteblocks.each do |block|
      @fieldnow.delete(block)
      block.remove
    end
    ### p [:deleted, @fieldnow.size]
    # フィールドに残っているブロックのうち消えたラインより上にあるものを下にずらしていく
  end
  # フィールドに残っているブロックのうち消えたラインより上にあったものを下にずらしていく
  completelines.each do |linej|
    @fieldnow.each do |block|
      block.y += @blocksize if (block.y-@fieldoffset[1])/20 < linej
    end
  end
  20.times do |j|
    10.times do |i|
      @fieldnowbool[i][j] = false
    end
  end
  @fieldnow.each do |block|
    tmpi = (block.x - @fieldoffset[0])/20
    tmpj = (block.y - @fieldoffset[1])/20
    @fieldnowbool[tmpi][tmpj] = true
  end
end

def lineclearcheck()
  # どこかのラインが揃っているかチェックし、揃っていれば盤面を更新
  # 何ライン消したかを返す
  completelines = []
  deleteline = 0
  20.times do |j|
    lineall = true
    10.times do |i|
      lineall = lineall && @fieldnowbool[i][j]
    end
    deleteline += 1 if lineall
    completelines.push(j) if lineall
  end
  # p [:deleteline, deleteline]
  completelines.sort!
  renewfield(completelines, deleteline) unless deleteline == 0
  deleteline
end

def newsquare(a, c)
  # 新しいSquareをnewして返す。
  # 引数はaが(i,j), cが色。# (i,j)はfieldを(0,0)~(9,19)とみたときの座標。
  tmp = Square.new(
    x: @fieldoffset[0] + @blocksize*a[0] + 1, y: @fieldoffset[1] + @blocksize*a[1] + 1,
    size: @blocksize - 2, color: c)
  tmp
end

def maketetrimino(num)
  # 指定されたnumのテトリミノを開始位置に作って返す。
  tetrimino = []
  case num
    # aはフィールドを(0,0)~(9,19)と見た時のブロックの位置。
  when 0; a = [[4,0],[4,1],[5,0],[5,1]]; c = 'yellow' # O
  when 1; a = [[3,0],[4,0],[5,0],[6,0]]; c = 'teal'   # I
  when 2; a = [[3,1],[4,0],[4,1],[5,1]]; c = 'purple' # T
  when 3; a = [[3,1],[4,0],[4,1],[5,0]]; c = 'green'  # S
  when 4; a = [[3,0],[4,0],[4,1],[5,1]]; c = 'red'    # Z
  when 5; a = [[3,0],[3,1],[4,1],[5,1]]; c = 'blue'   # J
  when 6; a = [[3,1],[4,1],[5,0],[5,1]]; c = 'orange' # L
  end
  ### OO  IIII   T    SS  ZZ   J      L
  ### OO        TTT  SS    ZZ  JJJ  LLL
  ### ブロックのindexはiが小さい方が若くiが同じならjが小さい方が若い
  
  4.times do |i|
    tmp = newsquare(a[i],c)
    tetrimino.push(tmp)
  end
  tetrimino
end

def createnewtetrimino()
  # ミノが下まで落ちた時に新しくnextからテトリミノを生成する。
  # 新しいテトリミノを返す。具体的には@nextsnumを介して@randomtetriの残りを順に取り出す。
  # @randomtetriが空であれば新しくランダムな配列を作る。
  if @randomtetri == []
    @randomtetri = [0,1,2,3,4,5,6]
    @randomtetri.sort_by! {rand}
  end
  # 表示されていたnextを各々remove
  3.times {|i| @nextsmino[i][@nextsnum[i][0]].each {|block| block.remove}}
  # ピタゴラスイッチ...このとき@nextsnumの中身は1要素しかない3つの配列であることに注意!
  @nowminonum = @nextsnum[0].pop
  @nextsnum[0].push(@nextsnum[1].pop)
  @nextsnum[1].push(@nextsnum[2].pop)
  @nextsnum[2].push(@randomtetri.pop)     # ピタゴラスイッチ
  # 新たなnextを各々addして表示
  3.times {|i| @nextsmino[i][@nextsnum[i][0]].each {|block| block.add}}
  # 新しいテトリミノを作成して描画
  tetrimino = maketetrimino(@nowminonum)
  tetrimino
end

def dohold(nowtetrimino)
  # 実際にホールド操作を行う
  # とりあえず今のテトリミノとホールドは盤面から消す
  allremove(nowtetrimino)
  allremove(@holdmino[@holdnum])
  # 今のミノの番号を次のホールド用に保持しておく
  nextholdnum = @nowminonum
  # ホールド操作をしたことがあるかで分岐
  if @holdnum == -1
    # ホールド操作が初めてなら新しいミノはnextのやつになる。
    nowtetrimino = createnewtetrimino() # @nowminonumも更新される
  else
    # 既にホールドしたことがあれば新しいミノはholdのやつになる。
    @nowminonum = @holdnum              # やっぱり@nowminonum更新
    nowtetrimino = maketetrimino(@nowminonum)
  end
  # 今のホールドのミノを盤面から消す
  allremove(@holdmino[@holdnum])
  # 次のホールドのミノを盤面に描画する
  @holdnum = nextholdnum  # @holdnumも更新
  alladd(@holdmino[@holdnum])
  nowtetrimino
end

def nowtofield(nowtetrimino)
  # 現在のテトリミノをフィールド上のものとして扱うことにする
  nowtetrimino.each do |nowblock|
    @fieldnow.push(nowblock)
    tmpi = (nowblock.x - @fieldoffset[0]) / 20
    tmpj = (nowblock.y - @fieldoffset[1]) / 20
    @fieldnowbool[tmpi][tmpj] = true
  end
end

def movetetrimino(tetrimino, di, dj)
  # tetrimino全体を(di,dj)だけ動かす。
  tetrimino.each do |block|
    block.x += @blocksize * di
    block.y += @blocksize * dj
  end
  tetrimino
end

def scoreplus(num)
  # scoreにnum点プラスする。
  @score += num
  @scorelabel.text = @score.to_s
end

def linesplus(num)
  # linesにnum点プラスする。
  @lines += num
  @lineslabel.text = @lines.to_s
end

def gameoverjudge(tetrimino)
  # 新しく生成したミノが既にフィールドのミノと重なっていればゲームオーバー
  if fieldjudge(tetrimino,0,0)
    @gameover = true
    return true
  end
  return false
end

def alladd(a)
  # 描画したいものが入っている配列aを受け取り、中身を全て描画する
  a.each { |x| x.add }
end

def allremove(a)
  # 画面から消したいものが入っている配列aを受け取り、中身を全て画面から消す
  a.each { |x| x.remove }
end

#####################
## visual
#####################

excolor = 'silver'
exsize = 15
Text.new("Move left:  left, A, keypad 4", x: 120, y: 550, size: exsize, color: excolor)
Text.new("Move right:  right, D, keypad 6", x: 340, y: 550, size: exsize, color: excolor)
Text.new("Hard drop:  up, W, keypad 8", x: 120, y: 570, size: exsize, color: excolor)
Text.new("Soft drop:  down, S, keypad 2", x: 340, y: 570, size: exsize, color: excolor)
Text.new("Rotate clockwise:  L, C", x: 120, y: 590, size: exsize, color: excolor)
Text.new("Rotate counter-clockwise:  J, Z", x: 340, y: 590, size: exsize, color: excolor)
Text.new("Hold:  X, K", x: 120, y: 610, size: exsize, color: excolor)
Text.new("Pause:  P", x: 120, y: 630, size: exsize, color: excolor)
Text.new("Exit:  Esc, Backspace", x: 340, y: 630, size: exsize, color: excolor)

#####################
## key event
#####################

on :key_down do |event|
  # ゲーム中のみに反応するやつら：移動、回転
  if @gamestart && !@gameover && !@gamepause
    case event.key
    when 'left', 'a', 'keypad 4'
      @moveleft = true unless @move
      @move = true
    when 'right', 'd', 'keypad 6'
      @moveright = true unless @move
      @move = true
    when 'up', 'w', 'keypad 8'
      @harddrop = true unless @move
      @move = true
    when 'down', 's', 'keypad 2'
      @softdrop = true
    when 'c', 'l'
      @rotateright = true unless @rotate
      @rotate = true
    when 'z', 'j'
      @rotateleft = true unless @rotate
      @rotate = true
    when 'x', 'k'
      @hold = true
    end
  end
  # ここからは先程のifの外
  case event.key
  when 'p'
    # ゲームスタート前やゲームオーバー後に反応しないように
    next unless @gamestart
    next if @gameover
    # ポーズしてなかったらポーズする、ポーズしてたらポーズ解除
    if @gamepause
      @gamepause = false
      allremove(@gamerec)
      @gamelabel.remove
    else
      @gamepause = true
      alladd(@gamerec)
      @gamelabel.text = "Pause"
      @gamelabel.add
    end
  when 'return'
    # スタート前ならスタートする、オーバー後なら画面を閉じる
    unless @gamestart
      @gamestart = true
      allremove(@gamerec)
      @gamelabel.remove
    end
    close if @gameover
  when 'backspace', 'escape' then close end
end

on :key_up do |event|
  case event.key
  when 'down', 's', 'keypad 2'
    @softdrop = false
  end
end

#####################
## mouse event
#####################

# on :mouse_down do |event|
#   puts "(#{event.x}, #{event.y})"
# end

#####################
## update
#####################

@tick = 0      # 1フレームごとにインクリメント
@droptick = 30 # @droptickフレームごとに判定を行う。小さいほど速く落ちる
@softdroptick = 0 # ソフトドロップ用の一時的なdroptick。
@solidifytickmax = 30 # ミノが下まで落ちてから固まるまでの猶予(tick)
@solidifytick = -1
  # ミノが下まで落ちてるとsolidifytickmaxに、デクリメントしていって0になると固まる。
  # 移動や回転の動作でmaxに戻る。
@avoidinfinitymax = 200 # 下に落ちてからこれtick分経過すると強制的に固まる。infinity防止。
@avoidinfinity = -1
  # ミノが下まで落ちるとavoidinfinitymaxに、デクリメントしていって0になると固まる。
  # 移動や回転の動作では変化しない。再び下に落ちられるようになったときのみmaxに戻る。

nextsholdframedepict() # nextとholdの枠を描画する
nowtetrimino = createnewtetrimino() # 最初のミノ

update do
  next unless @gamestart
  next if @gamepause

  @solidifytick -= 1 if @solidifytick > 0 # とりあえず固化判定デクリメント
  @avoidinfinity -= 1 if @avoidinfinity > 0 # infinity防止用のも同様に

  # ゲームオーバー後の挙動
  if @gameover
    unless @gamelabel.text == "GameOver. Press 'Enter' to exit."
      @gamelabel.text = "GameOver. Press 'Enter' to exit."
      alladd(@gamerec)
      @gamelabel.add
      # 現フィールドに存在する全てのミノを灰色に
      @fieldnow.each do |block|
        block.color = 'gray'
      end
    end
    next
  end

  # ホールド判定
  if @hold
    unless @holded
      # 直前にホールドしてなかった場合のみホールドする
      nowtetrimino = dohold(nowtetrimino)
      @holded = true
      # 新たにミノが開始位置に生成されるので色々やる必要がある
      # が、考えるのが面倒なので下まで落ちた後createnewtetriminoしてからの処理をコピペする
      @rotatestate = 0 # 回転状態初期化
      @tick = 0; @solidifytick = -1; @avoidinfinity = -1 # tickシリーズ初期化
      # 新しく生成したミノが既存のミノに重なっていればゲームオーバー
      if gameoverjudge(nowtetrimino)
        @gameover = true
        nowtofield(nowtetrimino)
      end
    end
    @hold = false
  end

  # ソフトドロップの操作がされていればなんかする
  if @softdrop
    # ソフトドロップの操作が始まったら@softdroptickを@droptickの1/tmpdivに(切り上げ)
    tmpdiv = 20 # ソフトドロップの落下速度を自然落下速度の何倍にするか
    @softdroptick = (@droptick + tmpdiv - 1) / tmpdiv if @softdroptick == 0
  else
    # ソフトドロップの操作をやめたら@softdroptickを0にしてお休み
    @softdroptick = 0 unless @softdroptick == 0
  end

  # 移動を行う操作がされていれば移動判定を行う
  if @move
    if @moveleft || @moveright
      puts "movejudge error." if @moveleft && @moveright
      di = 0; dj = 0
      di = -1 if @moveleft  # 左に1, 下に0
      di = 1  if @moveright # 右に1, 下に0
      @moveleft = false; @moveright = false
      # 移動後にぶつからないなら移動する
      unless (fieldjudge(nowtetrimino,di,dj) || walljudge(nowtetrimino,di,dj))
        movetetrimino(nowtetrimino, di, dj)
        @solidifytick = @solidifytickmax # 動いたら固まるまでの時間リセット
      end
    elsif @harddrop
      # 下に移動できるだけ移動する
      until fieldjudge(nowtetrimino,0,1) || walljudge(nowtetrimino,0,1)
        movetetrimino(nowtetrimino,0,1)
        scoreplus(@harddropscore) # ハードドロップは1マス@harddropscore点にする
      end
      @solidifytick = 0 # 一瞬で固まるようにする
      @harddrop = false
    elsif @softdrop
      @softdrop = false
    end
    @move = false
  end

  # 回転を行う操作がされていれば回転判定を行う
  if @rotate
    statetransition = 0
    statetransition =  1 if @rotateright # 右回転
    statetransition = -1 if @rotateleft  # 左回転
    @rotateright = false; @rotateleft = false
    # 回転した場合は固まるまでの時間リセット
    @solidifytick = @solidifytickmax if rotatejudge(nowtetrimino,statetransition)
    @rotate = false
  end

  # 一定時間(@droptick or @softdroptick)経つか固化判定のタイミングが来たらなんかする
  if (@softdroptick == 0 && @tick % @droptick == 0) || (@softdroptick != 0 && @tick % @softdroptick == 0) || (@solidifytick == 0 || @avoidinfinity == 0)
    # 下に落ちるか判定。フィールド上のブロック又は壁にぶつかるなら新しいテトリミノを生成する
    if (fieldjudge(nowtetrimino,0,1) || walljudge(nowtetrimino,0,1))
      if @solidifytick == 0 || @avoidinfinity == 0
        # 固化かinfinity防止のタイムリミットが来ていたら新しいミノの生成
        @holded = false # 直前にホールドしてたフラグも消える
        nowtofield(nowtetrimino)
        nowtetrimino = createnewtetrimino()
        @rotatestate = 0 # 回転状態初期化
        @tick = 0; @solidifytick = -1; @avoidinfinity = -1 # tickシリーズ初期化
        # 新しく生成したミノが既存のミノに重なっていればゲームオーバー
        if gameoverjudge(nowtetrimino)
          @gameover = true
          nowtofield(nowtetrimino)
        end
      else
        # 固化判定が始まってなかったなら開始。infinity防止のやつも同様
        @solidifytick  = @solidifytickmax  if @solidifytick  == -1
        @avoidinfinity = @avoidinfinitymax if @avoidinfinity == -1
      end
      # 固化判定が始まっていてまだリミットが来ていなければ放置(既にデクリメントしているので)
    else
      # 下に落ちられるなら固化判定はナシで下に1個落ちる
      @solidifytick = -1  # お休み
      @avoidinfinity = -1 # お休み
      movetetrimino(nowtetrimino, 0, 1)
      scoreplus(@softdropscore) if @softdrop # ソフトドロップ中なら1マス@softdropscore点
    end
  end

  # いずれかのラインが揃っているかチェック
  tmpline = lineclearcheck()
  if tmpline < 0 || tmpline > 4
    puts "Linecheck error."
  elsif tmpline == 4
    # Tetrisならbacktobackを確認してスコア加算
    coefficient = @backtoback ? 1.5 : 1
    scoreplus((coefficient * @scoreline[tmpline-1]).to_i)
    linesplus(tmpline)
    @backtoback = true
  elsif tmpline > 0
    # ライン消えてたらscore加算
    scoreplus(@scoreline[tmpline-1])
    linesplus(tmpline)
    @backtoback = false
  end

  @tick += 1
  @tick = 0 if @tick >= @droptick   # @tickが0から@droptick-1まででループするように
end


#####################
## show
#####################

show