haskelltter
===========

[![wercker status](https://app.wercker.com/status/fe6788dfe2d1125c2b995cc57cba90ea/m "wercker status")](https://app.wercker.com/project/bykey/fe6788dfe2d1125c2b995cc57cba90ea)

[ocamltter](https://github.com/yoshihiro503/ocamltter)のパクリ

使い方
------

### インストール

`install.sh` を実行するとインストールできます。

```sh
$ git clone git://github.com/amutake/haskelltter.git
$ cd haskelltter
$ ./install.sh
```

環境を汚されたくない方は hsenv を使うか、以下のように `cabal sandbox` を使ってください。

```sh
$ git clone git://github.com/amutake/haskelltter.git
$ cd haskelltter
$ git submodule init
$ git submodule update
$ cabal sandbox init
$ cabal sandbox add-source lib/twitter-types lib/twitter-conduit
$ cabal install --only-dependencies
$ cabal configure
$ cabal build
```

### モジュールのロードと認証

GHCi を起動してモジュールをロードします。

```sh
$ ghci
Prelude> :m Haskelltter
```

cabal sandbox を使った方は `cabal repl` を実行してください。

```sh
$ cabal repl
```

初回のみ、`setup` コマンドを実行して認証します。

```
Haskelltter> setup
Input consumer key: (コンシューマーキーを入力してください)
Input consumer secret: (コンシューマーシークレットを入力してください)
Authorize URL: https://api.twitter.com/oauth/authorize?...
Input PIN: (上のURLにWebブラウザでアクセスして認証してください。認証後に表示されるPINを入力してください)
```

`$HOME/.haskelltter` というディレクトリが作られ、そのなかに認証情報のファイルが作られます。`setup` コマンドを実行したあとは GHCi を再起動してください。

```
Done. Please reload GHCi.
Haskelltter> :q
Leaving GHCi.
$ ghci
Prelude> :m Haskelltter
```

### コマンド

```
l                     タイムラインを取得します
lc COUNT              タイムラインを COUNT の数だけ取得します
lu "NAME"             @NAME さんのツイートを取得します
m                     メンションを取得します
u "TEXT"              ツイートします
re ID "TEXT"          リプライします("@TARGET "はTEXTの前に自動的に挿入されます)
del ID                ツイートを削除します
rt ID                 ID のツイートをリツイートします
us                    ユーザーストリームです(終了はCtrl-C)
setup                 新しく認証します(認証情報のファイルは上書きされます)
```

ocamltterとほとんど同じです。
