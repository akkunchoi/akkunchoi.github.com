---
layout: posts
title: DatabaseException Incorrect key file for table 'mydatabase/mytable.MYI'; try to repair it 
tags: MySQL
---

MySQLで```DELETE FROM ... ```で一行消したらDatabaseExceptionが発生してアクセスできなくった。
メッセージには ```Incorrect key file for table 'mydatabase/mytable.MYI'; try to repair it``` とある。

テーブルが壊れたらしいので修復する。

    mysql> check table mytable;
    +-----------------------------+-------+----------+----------------------------+
    | Table                       | Op    | Msg_type | Msg_text                   |
    +-----------------------------+-------+----------+----------------------------+
    | mydatabase.mytable | check | warning  | Table is marked as crashed |
    | mydatabase.mytable | check | error    | Found 426 keys of 427      |
    | mydatabase.mytable | check | error    | Corrupt                    |
    +-----------------------------+-------+----------+----------------------------+
    3 rows in set (0.07 sec)

    mysql> repair table mytable;
    +-----------------------------+--------+----------+----------+
    | Table                       | Op     | Msg_type | Msg_text |
    +-----------------------------+--------+----------+----------+
    | mydatabase.mytable | repair | status   | OK       |
    +-----------------------------+--------+----------+----------+
    1 row in set (0.14 sec)

check, repair はMyISAMでしか実行できないらしい。InnoDBの場合はどうなってるのだろう。

- <http://blog.kaburk.com/os/linux/mysql-broken.html>
- <http://blog.livedoor.jp/roid2008/archives/50574239.html>

