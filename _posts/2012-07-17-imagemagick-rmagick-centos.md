---
layout: default
title: CentOS に ImageMagick, RMagick のインストール
---

{{ page.title }}
================================

## RPM

    $ wget http://www.imagemagick.org/download/linux/CentOS/x86_64/ImageMagick-6.7.8-3.x86_64.rpm
    $ sudo rpm -ivh ImageMagick-6.7.8-3.x86_64.rpm ImageMagick-6.7.8-3.x86_64.rpm

    エラー: 依存性の欠如:
        libHalf.so.4()(64bit) は ImageMagick-6.7.8-3.x86_64 に必要とされています	libIex.so.4()(64bit) は ImageMagick-6.7.8-3.x86_64 に必要とされています
        libIlmImf.so.4()(64bit) は ImageMagick-6.7.8-3.x86_64 に必要とされています
        libImath.so.4()(64bit) は ImageMagick-6.7.8-3.x86_64 に必要とされています
        libXt.so.6()(64bit) は ImageMagick-6.7.8-3.x86_64 に必要とされています
        libfftw3.so.3()(64bit) は ImageMagick-6.7.8-3.x86_64 に必要とされています
        libgs.so.8()(64bit) は ImageMagick-6.7.8-3.x86_64 に必要とされています
        liblcms.so.1()(64bit) は ImageMagick-6.7.8-3.x86_64 に必要とされています	libltdl.so.3()(64bit) は ImageMagick-6.7.8-3.x86_64 に必要とされています	librsvg-2.so.2()(64bit) は ImageMagick-6.7.8-3.x86_64 に必要とされています
        libwmflite-0.2.so.7()(64bit) は ImageMagick-6.7.8-3.x86_64 に必要とされています

ソースからやった方が早いかも。

## ソースからインストール

依存ライブラリ

    $ sudo yum install libjpeg-devel libpng-devel

make

    $ wget http://www.imagemagick.org/download/ImageMagick.tar.gz
    $ tar zxvf ImageMagick.tar.gz
    $ cd ImageMagick-6.7.8-3
    $ ./configure
    $ make
    $ sudo make install
    $ convert -list format # JPEG,PNG があればOK

試してみる

    $ convert hoge.jpg hoge.png # ..OK
  
libjpegが入ってない場合...エラーになる。

    $ convert star-off.jpg star-off.png 
    convert: no decode delegate for this image format

    $ convert -list format # JPEGがない

## RMagickがインストールできるかどうか確認

    $ cd 適当なディレクトリ
    $ vi Gemfile

    source 'https://rubygems.org'
    gem 'rmagick'

    $ bundle install --path bundle

    Gem::Installer::ExtensionBuildError: ERROR: Failed to build gem native extension.
     
    ...
     
    Package MagickCore was not found in the pkg-config search path.
    Perhaps you should add the directory containing `MagickCore.pc'
    to the PKG_CONFIG_PATH environment variable
    No package 'MagickCore' found
    
    ...
    
    Can't install RMagick 2.13.1. Can't find MagickWand.h.
    *** extconf.rb failed ***
    Could not create Makefile due to some reason, probably lack of
    necessary libraries and/or headers.  Check the mkmf.log file for more
    details.  You may need configuration options.

PKG_CONFIG_PATH を設定しろとのこと

    $ export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig

    $ bundle install --path bundle ## 成功しました


試してみる

    $ bundle console

    irb(main):001:0> require "RMagick"
    LoadError: libMagickCore.so.5: cannot open shared object file: No such file or directory - /home/admin/downloads/rmagick-test/bundle/ruby/1.9.1/gems/rmagick-2.13.1/lib/RMagick2.so


ダイナミックリンクライブラリのパスを設定する。

    $ sudo vi /etc/ld.so.conf

        /usr/local/lib

    $ sudo /sbin/ldconfig
    $ sudo /sbin/ldconfig -p | grep Magick


### 参考

- <http://qiita.com/items/6b1c6c7257042a159cc9>
- <http://6rats.blog62.fc2.com/blog-entry-78.html>



## 最後に

CentOS6.3だったのでyumから入れられました。めでたしめでたし。

    $ sudo make uninstall
    $ sudo vi /etc/ld.so.conf # 変更を削除
    $ sudo /sbin/ldconfig

    $ sudo yum install ImageMagick ImageMagick-devel



