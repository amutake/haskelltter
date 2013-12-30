haskelltter
===========

[ocamltter](https://github.com/yoshihiro503/ocamltter)のパクリ

使い方
------

1. `$HOME/.haskelltter` というディレクトリを作り、その中に以下の形式の `oauth_consumer.json` というファイルと `access_token.json` というファイルを作ります。

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

2. インストールします。

```sh
$ git clone git://github.com/amutake/haskelltter.git
$ cd haskelltter
$ ./install.sh
```

環境を汚されたくない方は、

```sh
$ git clone git://github.com/amutake/haskelltter.git
$ cd haskelltter
$ cabal sandbox init
$ cabal sandbox add-source lib/twitter-types lib/twitter-conduit
$ cabal install --only-dependencies
$ cabal configure
$ cabal build
```

3. ghci でモジュールをインポートします。

```sh
$ ghci
$ :m Haskelltter
```

cabal sandbox を使った方は、

```sh
$ cabal repl
```

4. コマンドを実行します。

```
- l                     list timeline
- lc COUNT              list timeline (COUNT lines)
- lu "NAME"             list NAME's timeline
- m                     list mentions (tweet containing @YOU)
- u "TEXT"              post a new message
- re ID "TEXT"          reply to ID
- del ID                delete tweet of ID
- rt ID                 retweet ID
```

ocamltterとほとんど同じです。
