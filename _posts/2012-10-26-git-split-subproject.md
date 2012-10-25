---
layout: posts
title: Git サブプロジェクトの切り出し
tags: git
---

サブプロジェクトを切り出して、リポジトリを分割する方法。

## サブプロジェクトの切り出し

あらかじめサブプロジェクトを subproject_dir ディレクトリにまとめておきます。

サブプロジェクトから、ブランチを生成します。

    git subtree split -P subproject_dir -b subproject_branch

subproject_branch に今までの履歴込でブランチが作成されました。ただし、**切り出し元とは共通の祖先はありません**。

別のリポジトリにしたいならリモート指定すれば良いし、subtreeで管理してもいい。

## 切り出したサブプロジェクトを削除

切り出し元からサブプロジェクトを完全に削除するならもう一手間いります。

切り出し元の方で subproject_dir を削除します。これは**歴史改変**を行います。超危険コマンドです。関係者の同意のもと行なって下さい。

    git filter-branch --tree-filter 'rm -rf subproject_dir' HEAD

これで subproject_dir に関する変更は今までの履歴も含めて削除されます。

歴史改変された master はそのままでは push できません。
push するとこんなこと言われます。
（オプションで削除できるようにすることもできるみたい）

>  ! [remote rejected] master (deletion of the current branch prohibited)

filter-branch 後の状態でブランチを切っておきます。

    git co -b filtered

master はresetして巻き戻します。

    git reset --hard {最初のコミットまで戻す}
    git push -f origin master

これで巻き戻せました。
filter-branch 後の結果を master にマージします。
    
    git merge filtered

