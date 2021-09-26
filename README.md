# Alpine Linux 環境に Linuxbrew を導入する手法

## はじめに

[Alpine Linux][EX001] とは、 [GNU libc6][EX002] と互換性を持つ非常に軽量な C 標準ライブラリである [musl][EX003] と、標準的な UNIX 環境において重要なコマンド類を単一の実行ファイルとして提供するプログラムである [Busybox][EX004] をベースとした超軽量な Linux のディストリビューションです。

また、 [Linuxbrew][EX005] とは、 Mac OS X における、ソースコードの取得及びビルドに基づいたパッケージ管理システムである [Homebrew][EX006] を Linux の各ディストリビューション向けに移植したものであり、現在は [Homebrew][EX006] と統合されています。

ここで、 [Alpine Linux][EX001] が導入されている環境に [Linuxbrew][EX005] を導入する手法として、 [Linuxbrew][EX005] 公式ページで述べられている ["Install Linuxbrew on Alpine Linux"][EX007] に示す手法がありますが、記述内容が古い上に、導入の際に以下に述べる問題が発生します。

- [Busybox][EX004] における ```grep``` や ```ps``` 等のコマンドのオプションや引数が標準的な Linux ディストリビューション等におけるそれと幾つかの差異があるため、 [Linuxbrew][EX005] のインストールスクリプトが正常に動作しない。
- [Linuxbrew][EX005] が内部で使用する ruby の処理系である ```portable-ruby``` の実行形式のバイナリファイルが、 [musl][EX003] に適合しないために [Linuxbrew][EX005] が適切に動作しない。

以上の問題を回避するために、予め [Alpine Linux][EX001] 上に [Linuxbrew][EX005] 環境を構築するために必要な apk パッケージを導入し、 ```ldd``` コマンドが ```--version``` オプションを受け取った時に適切なバージョンを返すように ```ldd``` コマンドのラッパースクリプトの修正を行いました。

次に、ディレクトリ ```/home/linuxbrew``` 以下に手動で [Linuxbrew][EX005] のディレクトリツリーを作成し、ディレクトリ ```/home/linuxbrew/.linuxbrew/Homebrew``` 以下に [Linuxbrew][EX005] 本体の git リポジトリを ```git clone``` コマンドを用いて取得しました。

その後、ディレクトリ ```/home/linuxbrew/.linuxbrew/Homebrew/Library/Homebrew/vendor/portable-ruby``` を作成し、 ```/home/linuxbrew/.linuxbrew/Homebrew/Library/Homebrew/vendor/portable-ruby/2.6.3_2``` 以下に [Linuxbrew][EX005] の内部で使用する ruby の処理系をソースコードからビルドしました。

そして、 ```/home/linuxbrew/.linuxbrew/bin/brew tap homebrew/core``` コマンドにより、 Tap リポジトリ ```homebrew/core``` を取得しました。

最後に、 ```/home/linuxbrew/.linuxbrew/bin/brew shellenv``` の出力に基づいて [Linuxbrew][EX005] 関連お環境変数の設定を行い、 [Linuxbrew][EX005] において使用する ```glibc, linux-headers, gcc``` の導入を行いました。

以上の作業を行なった後、 ```brew doctor``` コマンドによる [Linuxbrew][EX005] の診断等の結果、 [Alpine Linux][EX001] 環境上において [Linuxbrew][EX005] が正常に動作することを確認しました。

本稿では、手動による [Linuxbrew][EX005] のディレクトリツリーの作成に基づいた [Alpine Linux][EX001] 環境における [Linuxbrew][EX005] の導入手法について述べます。

本稿では、 [導入手法][CHAP01] の章において、 [Alpine Linux][EX001] 環境における [Linuxbrew][EX005] の導入手法について順を追って具体的に述べ、 [結論][CHAP02] の章において、本稿の結論について述べます。

なお本稿では、特段の断りが無い限り、 [Linuxbrew][EX005] の導入作業を行なった [Alpine Linux][EX001] 環境及び [Linuxbrew][EX005] の導入先等は以下の通りであるとします。

- [Alpine Linux][EX001] 環境 … [Vagrant Cloud alpine/alpine64][EX013] より取得できる [Alpine Linux][EX001] 仮想環境
- [Linuxbrew][EX005] の導入先 … ディレクトリ ```/home/linuxbrew/.linuxbrew```
- 一般ユーザアカウント … ```vagrant```
- シェルスクリプト … ```/bin/bash```

## <a id="CHAP01">導入手法</a>

本章では、 [Alpine Linux][EX001] 環境に [Linuxbrew][EX005] を導入する為の具体的な手法について述べます。

先ず、 ["Linuxbrew に依存する apk パッケージの導入"][SEC0101] の節において、 [Linuxbrew][EX005] を [Alpine Linux][EX001] 環境に導入する上で、 [Linuxbrew][EX005] の導入に必要となる apk パッケージの導入手法について述べ、 ["ldd コマンドの修正"][SEC0102] の節において、 ```ldd --version``` コマンドの出力が適切なものとなるための ```ldd``` コマンドのラッパースクリプトの修正手法について述べます。

次に、 ["手動による Linuxbrew のツリーの作成"][SEC0103] の節において、ディレクトリ ```/home/linuxbrew``` 以下に [Linuxbrew][EX005] を動作させるために必要なファイル群を格納するためのディレクトリツリーを手動で作成する手法について述べ、 ["Linuxbrew の内部で使用する Ruby 処理系のビルド"][SEC0104] の節において、 [Linuxbrew][EX005] 関連のコマンドを動作させるために使用する ruby 処理系をソースコードからビルドする手法について述べます。

そして、 ["Tap リポジトリ ```homebrew/core``` の取得と Linuxbrew ツリーの更新"][SEC0105] の節において、 [Linuxbrew][EX005] の中核をなす Tap リポジトリである ```homebrew/core``` を取得し、 [Linuxbrew][EX005] 本体を最新の状態に更新する為の具体的な手法について述べます。

また、 ["Linuxbrew 関連の環境変数の設定"][SEC0106] の節において、 [Linuxbrew][EX005] を動作させるのに必要となる環境変数の設定について述べ、 ["glibc, linux-headers, gcc の導入"][SEC0107] の節において、 [Linuxbrew][EX005] によって実行ファイルをビルドしたり、導入される実行ファイルを動作させるために必要となる [Linuxbrew][EX005] のパッケージである ```glibc, linux-headers``` 及び ```gcc``` を導入するための具体的手法について述べます。

最後に、 ["動作確認"][SEC0108] の節において、以上で述べた手法により導入した [Linuxbrew][EX005] についての最終的な動作確認について述べます。

### <a id="SEC0101">Linuxbrew に依存する apk パッケージの導入</a>

[Alpine Linux][EX001] 環境に [Linuxbrew][EX005] を導入する為に、先ず、 [Linuxbrew][EX005] の動作に関して必要となる [Alpine Linux] 環境の apk パッケージを導入します。

導入する apk パッケージについては、 ["Install Linuxbrew on Alpine Linux"][EX007] に記述されたパッケージを参照しますが、 ```ruby-dbm``` パッケージは既に obsolete となっているため、これに代えて ```ruby-sdbm, ruby-gdbm``` を導入します。

また、 [Alpine Linux][EX001] 環境における [Busybox][EX004] で実装されている ```grep, ps``` 等の一部コマンドにおいて、標準の Linux ディストリビューションにおける同様のコマンドと引数及びオプションの仕様が異なるものがあるので、追加で ```grep, coreutils, procps``` を導入する必要があります。

そして、 ["Linuxbrew の内部で使用する Ruby 処理系のビルド"][SEC0104] の節にて後述する [Linuxbrew][EX005] 内部で使用する ruby 処理系をソースコードからビルドする際に使用するヘッダファイル群を集めたパッケージである ```linux-headers``` 及び、 ruby 処理系から OpenSSL を扱うために必要となるパッケージである ```openssl``` も同時に導入する必要があります。 

```
 # apk upgrade
 # apk add bash build-base curl file git gzip libc6-compat ncurses 
 # apk add ruby ruby-sdbm ruby-gdbm ruby-etc ruby-irb ruby-json sudo        
 # apk add grep openssl coreutils procps linux-headers
```

### <a id="SEC0102">ldd コマンドの修正</a>

標準的な Linux ディストリビューションのコマンドの一つである ```ldd``` コマンドは、指定した実行ファイル若しくは共有ライブラリについて、その実行ファイル及び共有ライブラリが依存している共有ライブラリを表示するためのコマンドです。

また、 ```ldd``` コマンドに ```--version``` オプションを指定すると、 ```ldd``` コマンドを実行している環境において使用している標準 C ライブラリのバージョン番号を表示させることが出来ます。

例えば、 [Ubuntu 20.04][EX008] 環境において ```ldd --version``` コマンドを実行すると、以下のようなメッセージが標準出力に出力されます。

```
 $ ldd --version
 ldd (Ubuntu GLIBC 2.31-0ubuntu9.2) 2.31
 Copyright (C) 2020 Free Software Foundation, Inc.
 This is free software; see the source for copying conditions.  There is NO
 warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 作者 Roland McGrath および Ulrich Drepper。
```

しかし、 [Alpine Linux][EX001] 環境では、標準 C ライブラリに [musl][EX003] が使用されており、 [Alpine Linux][EX001] 環境において ```ldd --version``` コマンドを実行すると、以下のようなメッセージが標準エラーメッセージに出力されます。

```
 # ldd --version
 musl libc (x86_64)
 Version 1.2.2
 Dynamic Program Loader
 Usage: /lib/ld-musl-x86_64.so.1 [options] [--] pathname
```

[Linuxbrew][EX005] の動作において、標準 C ライブラリのバージョンを検出する必要が有る場合には、コマンド ```ldd --version``` の標準出力の結果が使用されるために、 [Alpine Linux][EX001] 環境で [Linuxbrew][EX005] を動作させる場合は、標準 C ライブラリのバージョンを検出が出来ずに不具合が発生します。

ここで、 [Alpine Linux][EX001] 環境において ```ldd``` コマンドの実行ファイルの実体は、以下のように、共有ライブラリファイル ```/lib/ld-musl-x86_64.so.1``` にオプション ```--list``` と実行時に指定された引数とオプションを渡して直接実行するためのシェルスクリプト形式のラッパーであることが判ります。

```
 # cat /usr/bin/ldd
 #!/bin/sh
 exec /lib/ld-musl-x86_64.so.1 --list "$@"
```

そこで、 [Alpine Linux][EX001] 環境において [Linuxbrew][EX005] を動作させる際には、スクリプトファイル ```/usr/bin/ldd``` を別のファイルに退避させた上で、以下の通りに、 ```ldd``` コマンドに ```--version``` オプションを渡した時に適当な出力を返すように ```/usr/bin/ldd``` を修正する必要があります。

```
 # cp -pv /usr/bin/ldd /usr/bin/ldd.old
 `/usr/bin/ldd' -> `/usr/bin/ldd.old'
 # vi /usr/bin/ldd
 # cat /usr/bin/ldd
 #!/bin/sh
 while test $# -gt 0; do
   case "$1" in
     --vers | --versi | --versio | --version)
       echo 'ldd (Alpine MUSL 2.13) 2.13'
       exit 0
       ;;
   esac
 done
 exec /lib/ld-musl-x86_64.so.1 --list "$@"
```

### <a id="SEC0103">手動による Linuxbrew のツリーの作成</a>

通常の Linux ディストリビューションにおいて、 [Linuxbrew][EX005] を導入する際には、 [Linuxbrew][EX005] の公式ページに記述の有る通りに、 [Linuxbrew のインストールスクリプト][EX009]の起動を行いますが、 [Alpine Linux][EX001] 環境では、 [Linuxbrew のインストールスクリプト][EX009]を実行しても、以下のようなエラーメッセージを出力して起動に失敗します。

```
 $ sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
 ...(略)...
 ==> Pouring portable-ruby-2.6.3_2.x86_64_linux.bottle.tar.gz
 Error: Failed to install ruby 2.6.3_2!
 Error: Failed to install Homebrew Portable Ruby and cannot find another Ruby 2.6.3!
 ...(略)...
```

以上のようなエラーメッセージが出力されるのは、 [Linuxbrew][EX005] 本体を起動するために使用される ruby 処理系を含む tarball であり、インストールスクリプトによってダウンロードされる tarball である ```portable-ruby-2.6.3_2.x86_64_linux.bottle.tar.gz``` に同梱されている実行ファイル群が、 [Linuxbrew][EX005] によって導入される [GNU glibc6 2.23][EX002] 及びそれ以降のバージョンの標準 C ライブラリに適合するように構築されているのが原因です。

以上の問題を回避するには、 [Alpine Linux][EX001] 環境上で [Linuxbrew のインストールスクリプト][EX009]を起動せずに、次に述べる手順にて手動で [Linuxbrew][EX005] を導入する必要があります。

まずは、ディレクトリ ```/home/linuxbrew``` 以下に [Linuxbrew][EX005] 本体及び Tap リポジトリを格納するためのディレクトリツリーを以下の通りにして作成し、ディレクトリ ```/home/linuxbrew/.linuxbrew/Homebrew``` 以下に、 ```git clone``` コマンドを用いて [Linuxbrew][EX005] 本体を構成するファイル群を取得します。

```
 # mkdir -p /home/linuxbrew/.linuxbrew
 # cd /home/linuxbrew/.linuxbrew
 # mkdir Caskroom Cellar Frameworks bin etc include lib opt sbin share tmp
 # mkdir -p var/homebrew/links
 # git clone https://github.com/Homebrew/brew ./Homebrew
```

そして、ディレクトリ ```/home/linuxbrew/.linuxbrew/bin``` 以下に、 ```brew``` コマンドの本体となるスクリプトファイル ```/home/linuxbrew/.linuxbrew/Homebrew/bin/brew``` へのシンボリックリンクを張ります。

```
 # cd /home/linuxbrew/.linuxbrew/bin
 # ln -sf ../Homebrew/bin/brew .
```

### <a id="SEC0104">Linuxbrew の内部で使用する Ruby 処理系のビルド</a>

[Linuxbrew][EX005] の各種コマンドを起動するために使用される ruby 処理系は、ディレクトリ ```/home/linuxbrew/.linuxbrew/Homebrew/Library/Homebrew/vendor/portable-ruby``` に置かれています。

["手動による Linuxbrew のツリーの作成"][SEC0103] の節で前述した通り、インストールスクリプトからダウンロードした実行バイナリファイル形式の ruby 処理系が [Linuxbrew][EX005] 内部で使用する ruby 処理系として使用できないため、 [Alpine Linux][EX001] 環境においては、 ruby 処理系のソースコードを [ruby の公式ページ][EX010]より入手し、ディレクトリ ```/home/linuxbrew/.linuxbrew/Homebrew/Library/Homebrew/vendor/portable-ruby/2.6.3_2``` 以下に、手動によるビルドに基づいて導入する必要があります。

[Linuxbrew][EX005] 内部で使用する ruby 処理系のビルドを行うには、まず、以下の通りにして、ディレクトリ ```/home/linuxbrew/.linuxbrew/Homebrew/Library/Homebrew/vendor/portable-ruby``` 以下に ```src``` ディレクトリを作成します。

そして、ディレクトリ ```src``` 以下に ruby 公式ページより [ruby 2.6.3 のソースコード][EX011]を取得します。

```
 # mkdir -p /home/linuxbrew/.linuxbrew/Homebrew/Library/Homebrew/vendor/portable-ruby
 # cd /home/linuxbrew/.linuxbrew/Homebrew/Library/Homebrew/vendor/portable-ruby
 # mkdir src
 # cd src
 # curl -L -o ruby-2.6.3.tar.gz https://cache.ruby-lang.org/pub/ruby/2.6/ruby-2.6.3.tar.gz
```

次に、以下の通りに [ruby 2.6.3 のソースコード][EX011]を展開し、ディレクトリ ```/home/linuxbrew/.linuxbrew/Homebrew/Library/Homebrew/vendor/portable-ruby/2.6.3_2``` 以下にソースコードのビルドに基づいて [Linuxbrew][EX005] 内部で使用する ruby 処理系を導入します。

```
 # tar -xvf ruby-2.6.3.tar.gz
 # cd ruby-2.6.3
 # ./configure --prefix=/home/linuxbrew/.linuxbrew/Homebrew/Library/Homebrew/vendor/portable-ruby/2.6.3_2
 # make
 # make install
```

その後、ディレクトリ ```/home/linuxbrew/.linuxbrew/Homebrew/Library/Homebrew/vendor/portable-ruby``` に移動し、以下のようにしてディレクトリ ```2.6.3_2``` より ```current``` に向けてシンボリックリンクを張ります。

そして、ディレクトリ ```src``` に残っている ruby 処理系のソースコードを削除します。

```
 # cd /home/linuxbrew/.linuxbrew/Homebrew/Library/Homebrew/vendor/portable-ruby
 # ln -sf 2.6.3_2 current
 # rm -rf src
```

### <a id="SEC0105">Tap リポジトリ ```homebrew/core``` の取得と Linuxbrew ツリーの更新</a>

[Linuxbrew][EX005] は、一般ユーザの権限において各種パッケージを管理するシステムであるため、 [Linuxbrew][EX005] の各種コマンドは、管理者権限の環境において実行することは推奨されていません。

従って、 [Linuxbrew][EX005] の中核の Formula が納められている Tap リポジトリである ```homebrew/core``` を取得するには、一般ユーザの権限で、コマンド ```/home/linuxbrew/.linuxbrew/bin/brew``` を実行する必要があります。

そこで、以下のようにして、ディレクトリ ```/home/linuxbrew``` 以下の全てのファイルの所有者を一般ユーザに変更し、 ```su``` コマンドにより、一般ユーザの環境に移ります。

```
 # chown -R vagrant:vagrant /home/linuxbrew
 # su - vagrant
```

そして、以下のようにして、```/home/linuxbrew/.linuxbrew/bin/brew tap homebrew/core``` コマンドにより、 Tap リポジトリ ```homebrew/core``` を取得し、 ```/home/linuxbrew/.linuxbrew/bin/brew update``` コマンドにより、 [Linuxbrew][EX005] 本体のリポジトリを更新します。

```
 $ mkdir -p /home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/homebrew/homebrew-core
 $ /home/linuxbrew/.linuxbrew/bin/brew tap homebrew/core
 $ /home/linuxbrew/.linuxbrew/bin/brew update
```

### <a id="SEC0106">Linuxbrew 関連の環境変数の設定</a>

[Alpine Linux][EX001] 環境において、 [Linuxbrew][EX005] を正常に動作させるためには、 [Linuxbrew][EX005] が使用する環境変数 ```HOMEBREW_PREFIX, PATH``` 等を適切な値に設定する必要があります。

ここで、 [Linuxbrew][EX005] を適切に動作させるための各種環境変数の値は ```/home/linuxbrew/.linuxbrew/bin/brew shellenv``` コマンドによって出力されます。

従って、以下の通りにして ```/home/linuxbrew/.linuxbrew/bin/brew shellenv``` コマンドの出力内容を、 bash の設定ファイルである ```~/.bashrc, ~/.profile``` に追加します。

```
 $ /home/linuxbrew/.linuxbrew/bin/brew shellenv >> ~/.bashrc 
 $ /home/linuxbrew/.linuxbrew/bin/brew shellenv >> ~/.profile
 $ eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
```

### <a id="SEC0107">glibc, linux-headers, gcc の導入</a>

[Linuxbrew][EX005] で管理される各種パッケージは、 [Linuxbrew][EX005] において導入される [GNU glibc6 2.23][EX002] 以降の標準 C ライブラリの存在を前提として構築が行われています。また、 [Linuxbrew][EX005] において、ソースコードのビルドが行われる際においても、 [GNU glibc6 2.23][EX002] 以降の標準 C ライブラリの存在を前提としたビルドが行われます。

従って、 [Alpine Linux][EX001] 環境において [Linuxbrew][EX005] を正常に動作させるには、 [Linuxbrew][EX005] を用いて [GNU glibc6][EX002] 及び GNU C コンパイラを予め導入する必要があります。

また、パッケージ [Linuxbrew][EX005] で導入される GNU C コンパイラを正常に動作させるためには、 Linux 関連の C 処理系のヘッダファイル群である ```linux-headers``` も同時に導入する必要があります。

この際、全てのパッケージを導入する時は、 ```brew install``` コマンドにオプション ```--ignore-dependencies, --force-bottle, --force``` を指定し、全てのパッケージについて、強制的に実行形式のバイナリファイルからの導入を行うことに留意する必要があります。

```
 $ brew install --ignore-dependencies --force-bottle --force glibc
 $ brew install --ignore-dependencies --force-bottle --force linux-headers
 $ for f in `brew deps -n gcc`; do brew install --ignore-dependencies --force-bottle --force $f; done
 $ brew install --ignore-dependencies --force-bottle --force gcc
```

### <a id="SEC0108">動作確認</a>

以上の導入に関する作業が完了した後は、 [Linuxbrew][EX005] の動作確認を行います。まず、以下の通りにして ```brew doctor``` コマンドにより、 [Linuxbrew][EX005] 全体の診断プログラムを起動させます。

ここで、標準出力に ```Your system is ready to brew.``` が出力されていれば、正常に [Linuxbrew][EX005] が導入されています。

```
 $ brew doctor
 Your system is ready to brew.
```

最後に、以下のようにして ```hello, patchelf``` パッケージ等をソースコードから導入し、正常にこれらのパッケージが正常に導入されることを確認します。

```
 $ brew install -dvs hello
 $ brew install -dvs patchelf
```

## <a id="CHAP02">結論</a>

本稿における [Alpine Linux][EX001] 環境上の [Linuxbrew][EX005] において、まず最初に [Busybox][EX004] における ```grep``` や ```ps``` 等のコマンドのオプションや引数や ```ldd``` の動作が標準的な Linux ディストリビューション等の仕様と異なるために、 [Linuxbrew][EX005] に依存する apk パッケージの導入において、 ```grep, procps``` 等のパッケージを追加で導入し、また、 ```ldd``` コマンドのラッパースクリプトの修正を行いました。

次に、インストールスクリプトからダウンロードした実行バイナリファイル形式の ruby 処理系が [Alpine Linux][EX001] 環境での動作に適合しないため、インストールスクリプトによる [Linuxbrew][EX005] の導入に代えて、ディレクトリ ```/home/linuxbrew``` 以下に [Linuxbrew][EX005] のディレクトリツリーを手動で作成し、 [Linuxbrew][EX005] 本体の git リポジトリを ```git clone``` コマンドを用いて取得しました。

その後、 [Linuxbrew][EX005] の内部で使用する ruby の処理系が置かれているディレクトリ ```/home/linuxbrew/.linuxbrew/Homebrew/Library/Homebrew/vendor/portable-ruby/2.6.3_2``` 以下に [ruby 2.6.3 の処理系][EX011]をソースコードからビルドしました。

そして、 [Linuxbrew][EX005] の中核の Formula が納められている  Tap リポジトリ ```homebrew/core``` を取得しました。

最後に、 ```/home/linuxbrew/.linuxbrew/bin/brew shellenv``` の出力に基づいて [Linuxbrew][EX005] 関連お環境変数の設定を行い、 [Linuxbrew][EX005] の動作において前提となるパッケージである ```glibc, linux-headers, gcc``` の導入を行いました。

以上の作業を行なった後、 ```brew doctor``` コマンド等による [Linuxbrew][EX005] の動作確認の結果、 [Alpine Linux][EX001] 環境上において [Linuxbrew][EX005] が正常に動作することを確認しました。

本稿においては、 [Alpine Linux][EX001] 環境上における [Linuxbrew][EX005] の導入について述べましたが、 [Alpine Linux][EX001] 環境以外の標準的な [GNU libc6][EX002] が導入されていない Linux ディストリビューション等のように、 [Linuxbrew][EX005] のインストールスクリプトからダウンロードされる [Linuxbrew][EX005] の動作用の ruby 処理系の実行形式のバイナリファイル群が、当該環境に適合しない場合においても、本稿で述べた [Linuxbrew][EX005] の導入手法が有効であると考えられます。

## 謝辞

まず最初に、超軽量な Linux のディストリビューションである [Alpine Linux][EX001] を開発した [Alpine Linux][EX001] の開発コミュニティの各位に心より感謝致します。

そして、 [Linuxbrew][EX005] 本体のリポジトリの開発を行っている [Shaun Jackman 氏][EX012]を始めとする [Linuxbrew][EX005] の開発コミュニティの各氏に心より感謝致します。また、 [Linuxbrew][EX005] の詳細に関しては、 [Linuxbrew 公式ページ][EX005]及び [Linuxbrew][EX005] のリポジトリに同梱される各種資料も併せて参考にしました。

最後に、 [Linuxbrew][EX005] 及び [Alpine Linux 環境][EX001]そして Linux 全体に関わる全ての皆様に心より感謝致します。

## 追記

本稿の付録として、 vagrant を用いて [Alpine Linux][EX001] 環境に [Linuxbrew][EX005] を導入した際に使用した ```Vagrantfile``` を以下に添付致します。

<!-- 章・節のリンク一覧 -->

[CHAP01]:#CHAP01
[CHAP02]:#CHAP02

[SEC0101]:#SEC0101
[SEC0102]:#SEC0102
[SEC0103]:#SEC0103
[SEC0104]:#SEC0104
[SEC0105]:#SEC0105
[SEC0106]:#SEC0106
[SEC0107]:#SEC0107
[SEC0108]:#SEC0108

<!-- 外部リンク一覧 -->

[EX001]:https://www.alpinelinux.org/
[EX002]:https://www.gnu.org/software/libc/
[EX003]:https://musl.libc.org/
[EX004]:https://www.busybox.net/
[EX005]:https://docs.brew.sh/Homebrew-on-Linux
[EX006]:https://brew.sh/index_ja
[EX007]:https://github.com/Linuxbrew/brew/wiki/Alpine-Linux#update-linuxbrew
[EX008]:https://releases.ubuntu.com/20.04/
[EX009]:https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh
[EX010]:https://www.ruby-lang.org/ja/
[EX011]:https://www.ruby-lang.org/ja/news/2019/04/17/ruby-2-6-3-released/
[EX012]:http://sjackman.ca/
[EX013]:https://app.vagrantup.com/alpine/boxes/alpine64