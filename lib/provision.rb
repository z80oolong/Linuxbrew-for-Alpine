# Provision Code.

Vagrant.configure("2") do |config|
  # Setup /etc/resolv.conf.
  config.vm.provision "shell", privileged: true, inline: %q[
    (echo "nameserver 1.1.1.1" >  /etc/resolv.conf && \
     echo "nameserver 8.8.8.8" >> /etc/resolv.conf && \
     echo "nameserver 8.8.4.4" >> /etc/resolv.conf && \
     echo "==> /etc/resolv.conf <==" && \
     cat  /etc/resolv.conf) || exit 255
  ]

  # Setup /etc/apk/repositories.
  config.vm.provision "shell", privileged: true, inline: %q[
    (echo "http://nl.alpinelinux.org/alpine/v3.7/main"      >  /etc/apk/repositories && \
     echo "http://nl.alpinelinux.org/alpine/v3.7/community" >> /etc/apk/repositories && \
     echo "==> /etc/apk/repositories <==" && \
     cat  /etc/apk/repositories) || exit 255
  ]

  # Change password of user "vagrant" and "root".
  config.vm.provision "shell", privileged: true, inline: %q[
    (echo "vagrant:vagrant" | chpasswd && \
     echo "root:vagrant" | chpasswd) || exit 255
  ]

  # Run apk update, apk upgrade
  config.vm.provision "shell", privileged: true, inline: "apk --no-cache update"
  config.vm.provision "shell", privileged: true, inline: "apk --no-cache upgrade"

  # Install the packages required to install Linuxbrew. (ruby, curl, git, etc.)
  config.vm.provision "shell", privileged: true, inline: %q[
    apk add --no-cache bash build-base ruby curl file git gzip libc6-compat ncurses
  ]

  # Install the packages required to install Linuxbrew. (coreutils, linux-headers, etc.)
  config.vm.provision "shell", privileged: true, inline: %q[
    apk add --no-cache sudo grep coreutils procps readline-dev zlib-dev linux-headers
  ]

  # Fix /usr/bin/ldd.
  config.vm.provision "shell", privileged: true, inline: %q[
    (cp -prv /usr/bin/ldd /usr/bin/ldd.old && \
     echo '#!/bin/sh' > /usr/bin/ldd.tmp && \
     echo 'while test $# -gt 0; do' >> /usr/bin/ldd.tmp && \
     echo '  case "$1" in' >> /usr/bin/ldd.tmp && \
     echo '    --vers | --versi | --versio | --version)' >> /usr/bin/ldd.tmp && \
     echo "      echo 'ldd (Alpine MUSL 2.13) 2.13'" >> /usr/bin/ldd.tmp && \
     echo '      exit 0' >> /usr/bin/ldd.tmp && \
     echo '      ;;' >> /usr/bin/ldd.tmp && \
     echo '  esac' >> /usr/bin/ldd.tmp && \
     echo 'done' >> /usr/bin/ldd.tmp && \
     echo 'exec /lib/ld-musl-x86_64.so.1 --list "$@"' >> /usr/bin/ldd.tmp && \
     sync && \
     mv -v /usr/bin/ldd.tmp /usr/bin/ldd && \
     chmod -v 0755 /usr/bin/ldd && \
     echo "==> /usr/bin/ldd <==" && \
     cat /usr/bin/ldd) || exit 255
  ]

  # Create a directory tree for Linuxbrew.
  config.vm.provision "shell", privileged: true, inline: %q[
    mkdir -p /home/linuxbrew/.linuxbrew
    (cd /home/linuxbrew/.linuxbrew && \
     mkdir -v Caskroom Cellar Frameworks bin etc include lib opt sbin share tmp && \
     mkdir -pv var/homebrew/links && \
     git clone https://github.com/Homebrew/brew ./Homebrew && \
     cd /home/linuxbrew/.linuxbrew/bin && \
     ln -sfv ../Homebrew/bin/brew .) || exit 255
  ]

  # Build "portable-ruby" for use inside Linuxbrew.
  config.vm.provision "shell", privileged: true, inline: %q[
    export CFLAGS="$CFLAGS -O3 -ggdb3 -Wall -Wextra -Wdeclaration-after-statement -Wdeprecated-declarations"
    export CFLAGS="$CFLAGS -Wimplicit-function-declaration -Wimplicit-int -Wpointer-arith -Wwrite-strings"
    export CFLAGS="$CFLAGS -Wmissing-noreturn -Wno-cast-function-type -Wno-constant-logical-operand -Wno-long-long"
    export CFLAGS="$CFLAGS -Wno-missing-field-initializers -Wno-overlength-strings -Wno-packed-bitfield-compat"
    export CFLAGS="$CFLAGS -Wno-parentheses-equality -Wno-self-assign -Wno-tautological-compare -Wno-unused-parameter"
    export CFLAGS="$CFLAGS -Wno-unused-value -Wsuggest-attribute=noreturn -Wno-unused-variable -Wno-implicit-fallthrough"
    export CFLAGS="$CFLAGS -Wno-address-of-packed-member -Wno-incompatible-pointer-types -Wno-declaration-after-statement"
    export CFLAGS="$CFLAGS -Wno-empty-body -Wno-sign-compare -Wno-unused-but-set-variable"
    export CXXFLAGS="$CXXFLAGS $CFLAGS"

    (mkdir -pv /home/linuxbrew/.linuxbrew/Homebrew/Library/Homebrew/vendor/portable-ruby && \
     cd /home/linuxbrew/.linuxbrew/Homebrew/Library/Homebrew/vendor/portable-ruby && \
     mkdir -v src && \
     cd src && \
     curl -L -o ruby-2.6.8.tar.gz https://cache.ruby-lang.org/pub/ruby/2.6/ruby-2.6.8.tar.gz && \
     tar -xvf ruby-2.6.8.tar.gz; cd ruby-2.6.8 && \
     ./configure --prefix=/home/linuxbrew/.linuxbrew/Homebrew/Library/Homebrew/vendor/portable-ruby/2.6.8 \
                 --enable-load-relative --with-static-linked-ext --with-out-ext=openssl,tk,sdbm,gdbm,dbm,win32,win32ole \
                 --without-gmp --disable-install-doc --disable-install-rdoc --disable-dependency-tracking && \
     make -j4 && \
     make install) || exit 255
  ]

  # Remove "portable-ruby" source code.
  config.vm.provision "shell", privileged: true, inline: %q[
    (cd /home/linuxbrew/.linuxbrew/Homebrew/Library/Homebrew/vendor/portable-ruby && \
     ln -sfv 2.6.8 current && \
     rm -rfv src) || exit 255
  ]

  # Change owner of directory /home/linuxbrew 
  config.vm.provision "shell", privileged: true, inline: "chown -v -R vagrant:vagrant /home/linuxbrew"

  # Setup SSH connection.
  config.vm.provision "shell", privileged: false, inline: %q[
    (curl -sL https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub >> ~/.ssh/authorized_key && \
     chmod -v 0600 ~/.ssh/authorized_key && \
     chmod -v 0700 ~/.ssh) || exit 255
  ]

  # Initialize Linuxbrew Tap repository homebrew/homebrew-core
  config.vm.provision "shell", privileged: false, inline: %q[
    (mkdir -pv /home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/homebrew/homebrew-core && \
     git config --global init.defaultBranch master && \
     echo "==> git config --global init.defaultBranch master") || exit 255
  ]

  # Download Tap repository homebrew/homebrew-core
  config.vm.provision "shell", privileged: false, inline: "/home/linuxbrew/.linuxbrew/bin/brew tap homebrew/core"
  config.vm.provision "shell", privileged: false, inline: "/home/linuxbrew/.linuxbrew/bin/brew update"

  # Setup environment variable HOMEBREW_PREFIX, PATH, etc.
  config.vm.provision "shell", privileged: false, inline: %q[
    (/home/linuxbrew/.linuxbrew/bin/brew shellenv >> ~/.bashrc && \
     echo "/home/linuxbrew/.linuxbrew/bin/brew shellenv >> ~/.bashrc" && \
     /home/linuxbrew/.linuxbrew/bin/brew shellenv >> ~/.profile && \
     echo "/home/linuxbrew/.linuxbrew/bin/brew shellenv >> ~/.profile" && \
     eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv) && \
     echo 'eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)') || exit 255
  ]

  # Install glibc from Linuxbrew.
  config.vm.provision "shell", privileged: false, inline: "brew install --force-bottle --force glibc"

  # Install packages that depend on git, gcc, ruby from Linuxbrew.
  # (include curl and linux-headers.)
  config.vm.provision "shell", privileged: false, inline: %q[
    for f in `brew deps -n --union curl git gcc ruby`; do
      (brew install --force-bottle --force $f) || exit 255
    done
  ]

  # Setup environment variable HOMEBREW_FORCE_BREWED_CURL.
  # (because of using curl in Linuxbrew.)
  config.vm.provision "shell", privileged: false, inline: %q[
    (echo 'export HOMEBREW_FORCE_BREWED_CURL="1"' >> ~/.bashrc && \
     echo 'export HOMEBREW_FORCE_BREWED_CURL="1"' >> ~/.profile && \
     export HOMEBREW_FORCE_BREWED_CURL="1" && \
     echo 'export HOMEBREW_FORCE_BREWED_CURL="1"') || exit 255
  ]

  # Install git, gcc, ruby from Linuxbrew.
  config.vm.provision "shell", privileged: false, inline: "brew install --force-bottle --force git"
  config.vm.provision "shell", privileged: false, inline: "brew install --force-bottle --force gcc"
  config.vm.provision "shell", privileged: false, inline: "brew install --force-bottle --force ruby"

  # Build hello, patchelf from Linuxbrew.
  config.vm.provision "shell", privileged: false, inline: "brew install -dvs hello"
  config.vm.provision "shell", privileged: false, inline: "brew install -dvs patchelf"

  # Clean up cache of Linuxbrew and git and ruby apk packages.
  config.vm.provision "shell", privileged: false, inline: "brew cleanup --prune=all"
  config.vm.provision "shell", privileged: true,  inline: "apk del --purge git ruby"

  # Diagnose Linuxbrew.
  config.vm.provision "shell", privileged: false, inline: "brew doctor"
end
