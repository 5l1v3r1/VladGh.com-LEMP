#!/bin/bash

function install_apc() {
  # Get APC package
  echo "Downloading and extracting APC-${APC_VER}..." >&3
  wget -O ${TMPDIR}/APC-${APC_VER}.tgz "http://pecl.php.net/get/APC-${APC_VER}.tgz" & progress
  cd $TMPDIR
  tar xzvf APC-${APC_VER}.tgz
  check_download "APC" "${TMPDIR}/APC-${APC_VER}.tgz" "${TMPDIR}/APC-${APC_VER}/config.m4"
  cd ${TMPDIR}/APC-${APC_VER}

  # Compile APC source
  echo 'Configuring APC...' >&3
  ${DSTDIR}/php5/bin/phpize -clean
  ./configure --enable-apc --with-php-config=${DSTDIR}/php5/bin/php-config --with-libdir=${DSTDIR}/php5/lib/php & progress

  echo 'Compiling APC...' >&3
  make -j8 & progress

  echo 'Installing APC...' >&3
  make install

  # Copy configuration files
  echo 'extension = apc.so
apc.enabled = 1
apc.shm_size = 128M
apc.shm_segments=1
apc.write_lock = 1
apc.rfc1867 = On
apc.ttl=7200
apc.user_ttl=7200
apc.num_files_hint=1024
apc.mmap_file_mask=/tmp/apc.XXXXXX
apc.enable_cli=1
; Optional, for "[apc-warning] Potential cache slam averted for key... errors"
; apc.slam_defense = Off
' > /etc/php5/conf.d/apc.ini

  echo -e '\E[47;34m\b\b\b\b'"Done" >&3; tput sgr0 >&3
}

