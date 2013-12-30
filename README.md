haskelltter
===========

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

### 設定ファイル

`$HOME/.haskelltter` というディレクトリを作り、その中に以下の形式の `oauth_consumer.json` というファイルと `access_token.json` というファイルを作ります。

oauth_consumer.json

```js
{
    "consumer_key": "ここにconsumer key",
    "consumer_secret": "ここにconsumer secret"
}
```

access_token.json

```js
{
    "oauth_token": "ここにaccess_token",
    "oauth_token_secret": "ここにaccess_token_secret"
}
```

### ghci でモジュールをインポート

```sh
$ ghci
ghci> :m Haskelltter
```

cabal sandbox を使った方は、

```sh
$ cabal repl
```

### コマンド

```
l                     タイムラインを取得します
lc COUNT              タイムラインを COUNT の数だけ取得します
lu "NAME"             @NAME さんのタイムラインを取得します
m                     メンションを取得します
u "TEXT"              ツイートします
re ID "TEXT"          リプライします("@TARGET "はTEXTの前に自動的に挿入されます)
del ID                ツイートを削除します
rt ID                 ID のツイートをリツイートします
us                    ユーザーストリームです(終了はCtrl-C)
setup                 oauth_consumer.json と access_token.json を新しく作ります(ファイルは上書きされます)
```

ocamltterとほとんど同じです。
