---
layout: posts
title: Gitの運用方法（ブランチング）
tags: git
---

## Git-flow

Vincent Driessenさんの [A successful Git branching model](http://nvie.com/posts/a-successful-git-branching-model/) ([日本語訳](http://keijinsonyaban.blogspot.jp/2010/10/successful-git-branching-model.html))

- メインブランチ (master, develop)
- サポートブランチ
  - フィーチャーブランチ
  - リリースブランチ (release-*)
  - ホットフィックスブランチ (hotfix-*)

基本は２本のメインブランチ master と develop を持つ。masterは出荷可能な安定状態を保つ。develop 開発版の最新状態を保つ。

develop ブランチのソースコードが安定した場合は、master ブランチにマージする。

フィーチャーブランチ（トピックブランチ）は新機能を開発するためのブランチ。developから派生し、developにマージされる。

マージは必ず --no-ff オプションを付ける（デフォルトにしたいができない）。

リリースブランチは新しいリリースの準備をサポートする。 develop から派生し、develop や master にマージされる。リリースブランチでは新機能などの開発を行なってはいけない。master にマージして、タグ付けを行った後は削除する。

ホットフィックスブランチは master から派生し、develop や master にマージする。緊急の修正を行うためのブランチ。

まとめるとこのようになる。

    master ------------------------------------------------>
      \                          \                /   /
       \                          \--- hotfix --/    /
        \                                           /
         \                           /-- release --/
          \                         /
           \-- develop ------------------------------------>
                 \               /
                  \-- feature --/


## 小規模プロジェクトでの運用（akkunchoi流）

最初は master ブランチしか持ちません。
即終了するかもしれないプロジェクトのために不要なブランチを作る手間を省きます。
この時点ではまだ、 master は開発版の役割です。

安定版と開発版を分けたくなった段階で初めて master から dev ブランチを作成します。master は安定版で、dev を開発版とします。

フィーチャーブランチはよほど大きな機能でない限りは作成しません。作成後は dev にマージします。dev がある程度安定した段階で master にマージします。

ホットフィックスは master に直接コミットします。リリースブランチは作成しません。タグ付けは行います。

master と dev のメインブランチが基本なのは git-flowモデルと同じです。一言で説明するとgit-flowのサポートブランチがないバージョンです。規模が大きくなってきたら git-flowモデルに移行してもいいと思います。

マージする際は --no-ff 必須にします。


## その他

<http://d.hatena.ne.jp/akihito_s/20111112>
<http://sourceforge.jp/projects/setucocms/wiki/Git%E3%83%AA%E3%83%9D%E3%82%B8%E3%83%88%E3%83%AA%E9%81%8B%E7%94%A8%E3%83%AB%E3%83%BC%E3%83%AB>
<http://firn.jp/2011/05/24/git-flow>
<http://najeira.blogspot.jp/2012/01/git.html>

