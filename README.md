# これはなに
 テトリスをRuby2Dで作りました

 最低限キレずに遊べるものを…と思ったけどオートリピートがないのは辛いかもしれない

 こういうの↓
 
<img src="https://i.gyazo.com/5e218e390ed14620cc6e0c3e48c212f8.gif" alt="DT砲" width="444"/>


# あそぶ
## 起動方法
 コマンドプロンプトやWindows PowerShellなどで
 `ruby mytetris.rb` と入力してください
* ruby2dを使用しています。`gem install ruby2d`とかでどうぞ
* rubyを使用しています。[RubyInstaller](https://rubyinstaller.org/)で自分はやりますた

## 操作方法

<img src="https://i.gyazo.com/6d0b2753a3e31a90854fc25754167b1d.png" alt="操作説明" width="580"/>

# その他
## 実装したもの
* ミノの挙動
  * 左右移動、回転
  * ソフト / ハードドロップ
  * SRS！！！！！！！！！！！！！！！！！！
* システム関係
  * バッグシステム
  * ホールド
  * ネクスト

## 実装できていないもの
* ミノの挙動
  * 左右移動のオートリピート
  * ロックダウン（Infinity可能）
* 時間軸関係あるやつ
  * 落下速度の増加
  * スコアの増加
* スコア関係
  * T-spinのスコア（現状普通に同じライン数を消すのと変わらない）
  * それに伴ってTetris以外のBack-to-Backも実装できていない
* その他
  * ゴースト
  * ゲームモードの実装
  * せりあがるブロック
  * ゲームオーバー後のリスタート
  * キーコンフィグ

## 参考
* [テトリス（tetris）のガイドラインを理解する](https://qiita.com/ki_ki33/items/35566f052af7b916607b)
* [SRS - Tetrisチャンネル](https://tetrisch.github.io/main/srs.html)
