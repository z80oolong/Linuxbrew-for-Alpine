Vagrant.configure("2") do |config|
  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
  end

  config.vm.define "alpine-brew-20210926"
  config.vm.provider "virtualbox" do |vb|
    vb.name   = "alpine-brew-20210926"
    vb.memory = 2048
  end
  config.vm.box = "alpine/alpine64"
  config.vm.synced_folder "./", "/vagrant"

  config.vm.provision "shell", privileged: true, inline: %q[
    echo "nameserver 1.1.1.1" >  /etc/resolv.conf
    echo "nameserver 8.8.8.8" >> /etc/resolv.conf
    echo "nameserver 8.8.4.4" >> /etc/resolv.conf

    apk update
    apk add bash build-base curl file git gzip libc6-compat ncurses
    apk add ruby ruby-sdbm ruby-gdbm ruby-etc ruby-irb ruby-json sudo
    apk add grep openssl coreutils procps linux-headers

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
     cd /home/linuxbrew/.linuxbrew/bin && ln -sf ../Homebrew/bin/brew .)

    mkdir -p /home/linuxbrew/.linuxbrew/Homebrew/Library/Homebrew/vendor/portable-ruby
    (cd /home/linuxbrew/.linuxbrew/Homebrew/Library/Homebrew/vendor/portable-ruby && \
     mkdir src && cd src && \
     curl -L -o ruby-2.6.3.tar.gz https://cache.ruby-lang.org/pub/ruby/2.6/ruby-2.6.3.tar.gz && \
     tar -xvf ruby-2.6.3.tar.gz; cd ruby-2.6.3 && \
     ./configure --prefix=/home/linuxbrew/.linuxbrew/Homebrew/Library/Homebrew/vendor/portable-ruby/2.6.3_2 && \
     make && make install)
    (cd /home/linuxbrew/.linuxbrew/Homebrew/Library/Homebrew/vendor/portable-ruby && \
     ln -sf 2.6.3_2 current && \
     rm -rf src)

    chown -R vagrant:vagrant /home/linuxbrew
  ]

  config.vm.provision "shell", privileged: false, inline: %q[
    mkdir -p /home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/homebrew/homebrew-core
    /home/linuxbrew/.linuxbrew/bin/brew tap homebrew/core
    /home/linuxbrew/.linuxbrew/bin/brew update

    /home/linuxbrew/.linuxbrew/bin/brew shellenv >> ~/.bashrc 
    /home/linuxbrew/.linuxbrew/bin/brew shellenv >> ~/.profile
    eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)

    brew install --ignore-dependencies --force-bottle --force glibc
    brew install --ignore-dependencies --force-bottle --force linux-headers
    for f in `brew deps -n gcc`; do
      brew install --ignore-dependencies --force-bottle --force $f
    done
    brew install --ignore-dependencies --force-bottle --force gcc

    brew install -dvs hello
    brew install -dvs patchelf

    brew cleanup --prune=all

    brew doctor
  ]
end