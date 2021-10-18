# Linuxbrew-for-Alpine -- Linuxbrew が導入された Alpine Linux 環境の作成スクリプト

## 概要

本リポジトリは、[Alpine Linux][EX001] 環境における [Linuxbrew][EX002] の導入手法について述べた文書である ["Alpine Linux 環境への Linuxbrew の導入手法"][EX004] と、 [Linuxbrew][EX002] が導入された [Alpine Linux][EX001] 環境の [Vagrant Box][EX006] を作成する為のスクリプトファイル等を同梱したリポジトリです。

なお、前述の文書である ["Alpine Linux 環境に Linuxbrew を導入する手法"][EX001] で述べた手法で構築した [Linuxbrew][EX002] も以下の URL にて配布しています。

[https://github.com/z80oolong/Linuxbrew-for-Alpine/releases][EX003]

## Vagrant Box の作成法

本リポジトリに同梱されているスクリプトファイルを用いて、 [Linuxbrew][EX002] が導入された [Alpine Linux][EX001] 環境の [Vagrant Box][EX006] を作成するには、予め [Vagrant][EX006], [VirtualBox][EX007], [libvirt][EX008] を導入する必要があります。

その後は、以下のようにしてスクリプトファイル ```build-box.sh``` を起動し、 [Linuxbrew][EX002] が導入された [Alpine Linux][EX001] 環境の [Vagrant Box][EX006] を作成します。

```
 ...
 $ cd ./Linuxbrew-for-Alpine/virtualbox  # (provider に virtualbox を用いる場合は、ディレクトリ ./Linuxbrew-for-Alpine/libvirt に移動する)
 $ ./build-box.sh                        # (スクリプトファイルを起動する)
 ...
 $ cd ./Linuxbrew-for-Alpine/libvirt     # (provider に libvirt を用いる場合は、ディレクトリ ./Linuxbrew-for-Alpine/virtualbox に移動する)
 $ ./build.sh                            # (スクリプトファイルを起動する)
 ...
```

上記のスクリプトファイルを起動した後は、 ```./build-box.sh``` の存在するディレクトリに、 ```releases/``` ディレクトリが作成されますので、以下のようにして [Vagrant Box][EX006] を導入します。

```
 ...
 $ cd ./releases
 $ vagrant box add ./alpine-brew-virtualbox-yyyy-mm-dd.json # (provider が virtualbox 向けの Vagrant Box の導入。)
                                                            # (なお、上記の yyyy-mm-dd は、バージョン番号)
 ...
 $ cd ./releases
 $ vagrant box add ./alpine-brew-libvirt-yyyy-mm-dd.json    # (provider が libvirt 向けの Vagrant Box の導入。)
                                                            # (なお、上記の yyyy-mm-dd は、バージョン番号)
 ...
```

なお、 [Vagrant Box][EX006] の導入の際は、 ```vagrant box add``` コマンドの引数には、 JSON 形式のファイルを指定することに留意して下さい。

## 謝辞

まず最初に、超軽量な Linux のディストリビューションである [Alpine Linux][EX001] を開発した [Alpine Linux][EX001] の開発コミュニティの各位に心より感謝致します。

そして、 [Linuxbrew][EX002] 本体のリポジトリの開発を行っている [Shaun Jackman 氏][EX005]を始めとする [Linuxbrew][EX002] の開発コミュニティの各氏に心より感謝致します。また、 [Linuxbrew][EX002] の詳細に関しては、 [Linuxbrew 公式ページ][EX002]及び [Linuxbrew][EX002] のリポジトリに同梱される各種資料も併せて参考にしました。

最後に、 [Linuxbrew][EX005] 及び [Alpine Linux 環境][EX001]そして Linux 全体に関わる全ての皆様に心より感謝致します。

<!-- 外部リンク一覧 -->

[EX001]:https://www.alpinelinux.org/
[EX002]:https://docs.brew.sh/Homebrew-on-Linux
[EX003]:https://github.com/z80oolong/Linuxbrew-for-Alpine/releases
[EX004]:https://github.com/z80oolong/Linuxbrew-for-Alpine/blob/master/Linuxbrew-for-Alpine.md
[EX005]:http://sjackman.ca/
[EX006]:https://www.vagrantup.com/
[EX007]:https://www.virtualbox.org/
[EX008]:https://libvirt.org/
