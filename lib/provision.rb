# Provision Code.

Vagrant.configure("2") do |config|
  config.vm.provision "shell", privileged: true, inline: %q[
    echo "nameserver 1.1.1.1" >  /etc/resolv.conf
    echo "nameserver 8.8.8.8" >> /etc/resolv.conf
    echo "nameserver 8.8.4.4" >> /etc/resolv.conf
    echo "==> /etc/resolv.conf <=="
    cat  /etc/resolv.conf

    echo "http://nl.alpinelinux.org/alpine/v3.14/community" > /etc/apk/repositories
    echo "http://nl.alpinelinux.org/alpine/edge/main"      >> /etc/apk/repositories
    echo "http://nl.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
    echo "#http://nl.alpinelinux.org/alpine/edge/testing"  >> /etc/apk/repositories
    echo "==> /etc/apk/repositories <=="
    cat  /etc/apk/repositories

    echo "vagrant:vagrant" | chpasswd
    echo "root:vagrant" | chpasswd

    apk update
    apk add bash build-base curl file git gzip libc6-compat ncurses
    apk add ruby ruby-sdbm ruby-gdbm ruby-etc ruby-irb ruby-json sudo
    apk add grep coreutils procps readline-dev zlib-dev linux-headers

    cp -prv /usr/bin/ldd /usr/bin/ldd.old
    echo '#!/bin/sh' > /usr/bin/ldd
    echo 'while test $# -gt 0; do' >> /usr/bin/ldd
    echo '  case "$1" in' >> /usr/bin/ldd
    echo '    --vers | --versi | --versio | --version)' >> /usr/bin/ldd
    echo "      echo 'ldd (Alpine MUSL 2.13) 2.13'" >> /usr/bin/ldd
    echo '      exit 0' >> /usr/bin/ldd
    echo '      ;;' >> /usr/bin/ldd
    echo '  esac' >> /usr/bin/ldd
    echo 'done' >> /usr/bin/ldd
    echo 'exec /lib/ld-musl-x86_64.so.1 --list "$@"' >> /usr/bin/ldd
    chmod 0755 /usr/bin/ldd

    mkdir -p /home/linuxbrew/.linuxbrew
    (cd /home/linuxbrew/.linuxbrew && \
     mkdir Caskroom Cellar Frameworks bin etc include lib opt sbin share tmp && \
     mkdir -p var/homebrew/links && \
     git clone https://github.com/Homebrew/brew ./Homebrew && \
     cd /home/linuxbrew/.linuxbrew/bin && \
     ln -sf ../Homebrew/bin/brew . && \
     true)

    export CFLAGS="$CFLAGS -O3 -ggdb3 -Wall -Wextra -Wdeclaration-after-statement -Wdeprecated-declarations"
    export CFLAGS="$CFLAGS -Wimplicit-function-declaration -Wimplicit-int -Wpointer-arith -Wwrite-strings"
    export CFLAGS="$CFLAGS -Wmissing-noreturn -Wno-cast-function-type -Wno-constant-logical-operand -Wno-long-long"
    export CFLAGS="$CFLAGS -Wno-missing-field-initializers -Wno-overlength-strings -Wno-packed-bitfield-compat"
    export CFLAGS="$CFLAGS -Wno-parentheses-equality -Wno-self-assign -Wno-tautological-compare -Wno-unused-parameter"
    export CFLAGS="$CFLAGS -Wno-unused-value -Wsuggest-attribute=noreturn -Wno-unused-variable -Wno-implicit-fallthrough"
    export CFLAGS="$CFLAGS -Wno-address-of-packed-member -Wno-incompatible-pointer-types -Wno-declaration-after-statement"
    export CFLAGS="$CFLAGS -Wno-empty-body -Wno-sign-compare -Wno-unused-but-set-variable"
    export CXXFLAGS="$CXXFLAGS $CFLAGS"

    mkdir -p /home/linuxbrew/.linuxbrew/Homebrew/Library/Homebrew/vendor/portable-ruby
    (cd /home/linuxbrew/.linuxbrew/Homebrew/Library/Homebrew/vendor/portable-ruby && \
     mkdir src && \
     cd src && \
     curl -L -o ruby-2.6.8.tar.gz https://cache.ruby-lang.org/pub/ruby/2.6/ruby-2.6.8.tar.gz && \
     tar -xvf ruby-2.6.8.tar.gz; cd ruby-2.6.8 && \
     ./configure --prefix=/home/linuxbrew/.linuxbrew/Homebrew/Library/Homebrew/vendor/portable-ruby/2.6.8 \
                 --enable-load-relative --with-static-linked-ext --with-out-ext=openssl,tk,sdbm,gdbm,dbm,win32,win32ole \
                 --without-gmp --disable-install-doc --disable-install-rdoc --disable-dependency-tracking && \
     make -j4 && \
     make install && \
     true) || false
    (cd /home/linuxbrew/.linuxbrew/Homebrew/Library/Homebrew/vendor/portable-ruby && \
     ln -sf 2.6.8 current && \
     rm -rf src && \
     true) || false

    chown -R vagrant:vagrant /home/linuxbrew
  ]

  config.vm.provision "shell", privileged: false, inline: %q[
    curl -sL https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub >> ~/.ssh/authorized_key
    chmod 0600 ~/.ssh/authorized_key
    chmod 0700 ~/.ssh

    mkdir -p /home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/homebrew/homebrew-core
    git config --global init.defaultBranch master

    (/home/linuxbrew/.linuxbrew/bin/brew tap homebrew/core && \
     /home/linuxbrew/.linuxbrew/bin/brew update && \
     true) || false

    /home/linuxbrew/.linuxbrew/bin/brew shellenv >> ~/.bashrc 
    /home/linuxbrew/.linuxbrew/bin/brew shellenv >> ~/.profile
    eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)

    (brew install --force-bottle --force glibc && \
     brew install --force-bottle --force linux-headers && \
     true) || false
    for f in `brew deps -n gcc`; do
      (brew install --force-bottle --force $f && true) || false
    done
    (brew install --force-bottle --force gcc && true) || false

    brew install -dvs hello
    brew install -dvs patchelf

    brew cleanup --prune=all

    brew doctor
  ]
end
