---
layout: default
title: Test DoubleとPHPUnit
tags: xUnit
---

{{ page.title }}
================

## Test Doubleについて

単体テストを書く時に問題になるのが、依存コンポーネントの扱いだ。例えばデータベースが必要だったり、外部サービスへの接続が必要だったりすると、テストごとに毎回セットアップしていたら途方も無い時間がかかるし、そもそも依存関係が複雑でテストができない場合もある。

このような場合に、実際のオブジェクトではなく代役（Double）のオブジェクトを使うのが Test Doubleというテスト技法だ。Test Doubleにはスタブ、モック、フェイク、ダミーなど様々な手法がある。

特に重要で間違いやすいのが「モック」と「スタブ」だ。英単語では「モック」は模造品、「スタブ」は切り株、切り残しという意味だが、Test Doubleにおいては「モック」は出力の確認、「スタブ」は入力の差し替えを意味する。

[xUnit Patterns](http://xunitpatterns.com/Test%20Double.html) にTest Doubleのより詳しい解説がある。Test Doubleを使用する理由は、テスト対象オブジェクト（SUT: System Under Test）が、あるコンポーネントに依存（DOC: depended-on component）するために、「 出力を確認できない」「 入力を設定できない」「 遅い」という原因によりテストが困難になるからである。

## PHPUnitの例

例として、CMS的なシステムを考える。テスト対象オブジェクト Page は作成者を意味する User と永続化を行う Database に依存している。

テスト対象オブジェクト

    class Page{
      protected $user;
      protected $title;
      protected $body;
      protected $database;

      public function setUser($user) {
        $this->user = $user;
      }

      public function setTitle($title) {
        $this->title = $title;
      }

      public function setBody($body) {
        $this->body = $body;
      }

      public function setDatabase(Database $database){
        $this->database = $database;
      }

      public function save(){
        $s = sprintf(
          '%s wrote: "%s" %s', $this->user->getName(), $this->title, $this->body
        );
        $this->database->write($this->title, $s);
      }
    }

依存コンポーネントの Database と User

    interface Database{
      public function write();
    }

    interface User{
      public function getName();
    }

Pageのsaveメソッドをテストするには Database と User が必要である。しかし、Pageをテストするためだけなのに、わざわざ Database や User をインスタンス化する必要は全くない。User::getNameでダミーの値を返すようにしたり、 Database::write メソッドで何が与えられたか確認するだけで十分だ。

PHPUnitにはモックとスタブの生成機能がある。どちらも getMock というメソッドで生成できる。テストコードはこのようになる。

    class PageTest extends PHPUnit_Framework_TestCase{
      public function testSave(){
        // モック
        $dbMock = $this->getMock('Database');
        $dbMock->expects($this->once())
                ->method('write')
                ->with($this->equalTo('New Title'), $this->equalTo('aaa wrote: "New Title" New Text'));

        // スタブ
        $userStub = $this->getMock('User');
        $userStub->expects($this->any())
                ->method('getName')
                ->will($this->returnValue('aaa'));

        // Exercise
        $page = new Page();
        $page->setDatabase($dbMock);
        $page->setUser($userStub);
        $page->setBody('New Text');
        $page->setTitle('New Title');

        // Verify
        $page->save();
      }
    }


getMock メソッドによりモックを生成する。普通のクラスだけでなく、インタフェースでも抽象クラスでも良い。オプションでコンストラクタを実行するかどうかも制御できる。

    $dbMock = $this->getMock('Database');

expects メソッドでどのような動作をするかをの設定を開始し、引数に何度呼ばれるべきかを設定する。```$this->once()```の他には any, never, atLeastOnce, once, exactly, at が利用できる。スタブとして生成するならコール回数の確認を行わない ```$this->any()``` にする。

method メソッドでどのメソッドについての動作か指定する。

with メソッドでexpectation を設定し、will メソッドで戻り値を設定する。

    $dbMock->expects($this->once())
            ->method('write')
            ->with($this->equalTo('New Title'), $this->equalTo('aaa wrote: "New Title" New Text'));

このように、依存コンポーネントのimplementが存在しないにもかかわらず、対象オブジェクトがテストできるというのはとても強力だ。

しかしPHPUnitのモック生成機能はわかりにくい（覚えにくい）。

他にもSimpleTestがモック生成機能をサポートしていたり、Mockery, Phakeといったモック生成ライブラリがあるらしいので、そのうち調べてみようと思う。


## 参考

- [bliki](http://capsctrl.que.jp/kdmsnr/wiki/bliki/?TestDouble)
- [xUnit Patterns](http://xunitpatterns.com/Test%20Double.html)
- [PHPUnit](http://www.phpunit.de/manual/3.6/ja/test-doubles.html)

