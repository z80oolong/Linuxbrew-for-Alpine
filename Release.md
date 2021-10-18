# Alpine Linux 環境に Linuxbrew を導入する手法

ここでは、 ["Alpine Linux 環境に Linuxbrew を導入する手法"][EX001] で述べた手法で構築した [Linuxbrew][EX002] を tarball で固めたものを以下に配布します。

この tarball を [Alpine Linux][EX003] 環境で使用する際は、以下のようにして [”Linuxbrew に依存する apk パッケージの導入”][EX001SEC0101] を参照して [Linuxbrew][EX002] に依存する apk パッケージを導入します。

```
 # apk update
 # apk add --force --quiet libcrypto3
 # apk add bash build-base curl file git gzip libc6-compat ncurses
 # apk add ruby ruby-sdbm ruby-gdbm ruby-etc ruby-irb ruby-json sudo
 # apk add grep coreutils procps readline-dev zlib-dev linux-headers
```

次に、ディレクトリ ```/home``` に移動し、本ページにて取得した tarball である ```Linuxbrew-for-Alpine-2021-10-17.tar.gz``` を以下の通りにして展開します。例えば、 ```Linuxbrew-for-Alpine-20210926.tar.gz``` を共有ディレクトリ ```/vagrant``` に置いている場合は、以下のように展開します。

```
 # cd /home
 # tar -xvf /vagrant/Linuxbrew-for-Alpine-2021-10-17.tar.gz
```

上記の展開により、ディレクトリ ```/home/linuxbrew``` 以下に、 [Linuxbrew][EX002] 本体及び [Linuxbrew][EX002] の中核をなす Tap リポジトリが作成されます。その後は、ディレクトリ ```/home/linuxbrew``` 以下のファイルの所有権を一般ユーザに変更することを忘れないようにします。

```
 # chown -R vagrant:vagrant /home/linuxbrew
```

そして、 ["Linuxbrew 関連の環境変数の設定"][EX001SEC0106] を参照して、 [Linuxbrew][EX002] を動作させるために必要な環境変数を設定します。

```
 $ /home/linuxbrew/.linuxbrew/bin/brew shellenv >> ~/.bashrc 
 $ /home/linuxbrew/.linuxbrew/bin/brew shellenv >> ~/.profile
 $ eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
```

以上の作業の後は、 ["動作確認"][EX001SEC0108] を参照して、  [Linuxbrew][EX002] が正常に動作するか確認します。

```
 $ brew doctor
 Your system is ready to brew.
 $ brew install -dvs hello
 $ brew install -dvs patchelf
```

ここで、 [Linuxbrew][EX002] の tarball の sha256 の値を示します。

```
a1c49f6e71225981679791ab6a0c09a2e60d2132def3ac2b229bb7f246ddf1a6  Linuxbrew-for-Alpine-20210926.tar.gz
```
 
<!-- 節リスト -->

[EX001SEC0101]:https://github.com/z80oolong/Linuxbrew-for-Alpine/blob/master/README.md#SEC0101
[EX001SEC0106]:https://github.com/z80oolong/Linuxbrew-for-Alpine/blob/master/README.md#SEC0106
[EX001SEC0108]:https://github.com/z80oolong/Linuxbrew-for-Alpine/blob/master/README.md#SEC0108

<!-- 外部リンクリスト -->

[EX001]:https://github.com/z80oolong/Linuxbrew-for-Alpine/blob/master/README.md
[EX002]:https://docs.brew.sh/Homebrew-on-Linux
[EX003]:https://www.alpinelinux.org/
