# README

## 注意
* 未完成です。
* 動くと思うが、全部の発言をnotifyしてくれないと思う。
* 特に発言者の icon の表示がない。とりあえず、好きなアイコンを１つ決められるようにしてお茶を濁している。

## 必要なもの
* libnotify
* ruby >= 1.9.1
* gem, bundle install ができる環境

## 準備
<pre>
  git clone https://github.com/hitsumabushi/lingr_notifyer.git
  cd lingr_notifyer 
  bundle install
</pre>

## 設定
### 基本的な設定
setting.rb に書く。
現状設定できるのは以下の３つ。
* Linger\_user        : Lingrに登録しているメールアドレス
* Linger\_password    : Lingr\_userのパスワード
* Linger\_icon\_path  : notify の時に表示したいアイコン。(Default: "")

## 実行
<pre>
  ruby notify.rb &
</pre>
