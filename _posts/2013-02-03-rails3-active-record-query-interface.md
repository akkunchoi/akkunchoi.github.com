---
layout: posts
title: rails3-active-record-query-interface
tags: rails
---

ActiveRecordのクエリーインタフェースの解説 http://guides.rubyonrails.org/active_record_querying.html のまとめ。


<pre><code data-language="ruby">#
class Client < ActiveRecord::Base
  has_one :address
  has_many :orders
  has_and_belongs_to_many :roles
end
class Address < ActiveRecord::Base
  belongs_to :client
end
class Order < ActiveRecord::Base
  belongs_to :client, :counter_cache => true
end
class Role < ActiveRecord::Base
  has_and_belongs_to_many :clients
end
</code></pre>


## 取得

情報取得するには以下の finder method が利用できます。戻り値は ActiveRecord::Relation インスタンスです。

- where
- select
- group
- order
- reorder
- reverse_order
- limit
- offset
- joins
- includes
- lock
- readonly
- from
- having

find メソッドというのもあります。`Model.find(options)` を実行すると、次のような動作になります。

- オプションをSQLクエリに変換する
- SQLクエリを実行し、結果をデータベースから取り出す
- 結果を行ごとに適切なモデルクラスで、インスタンス化
- 指定されていれば、after_find コールバックを実行する

### オブジェクトを１つだけ取得する（主キー）

<pre><code data-language="ruby"># id = 10 の オブジェクトを取得
client = Client.find(10)
# => #<Client id: 10, first_name: "たかし">
# 
# sql: SELECT * FROM clients WHERE (clients.id = 10) LIMIT 1
# 
</code></pre>

もし、データが見つからなかった場合は `ActiveRecord::RecordNotFound` 例外が発生します。


### オブジェクトを１つだけ取得する（first）

<pre><code data-language="ruby"># first 
client = Client.first
# => #<Client id: 1, ... >
# 
# sql: SELECT * FROM clients LIMIT 1
# 
</code></pre>

もし、データが見つからなければ、`nil` を返します。`Model.first!` だと、例外が発生します。


### オブジェクトを１つだけ取得する（last）

<pre><code data-language="ruby"># last
client = Client.last
# => #<Client id: 221, ... >
# 
# sql: SELECT * FROM clients ORDER BY clients.id DESC LIMIT 1
# 
</code></pre>

もし、データが見つからなければ、`nil` を返します。`Model.last!`だと、例外が発生します。


### オブジェクトを複数取得する（主キー）

`find` メソッドでidの配列を渡すと、そのオブジェクトを配列で返します。

<pre><code data-language="ruby"># find multiple
client = Client.find([1, 10]) # または Client.find(1, 10)
# => [#<Client id: 1, ... >, #<Client id: 10, ... >]
# 
# sql: SELECT * FROM clients WHERE (clients.id IN (1,10)) 
# 
</code></pre>

ひとつも見つからなかった場合に、`ActiveRecord::RecordNotFound`例外が発生します。


### オブジェクト全体（all）

テーブル内の全件処理したい場合は`all`メソッドを使う。

<pre><code data-language="ruby"># all
User.all.each do |user|
  NewsLetter.weekly_deliver(user)
end
</code></pre>

ただ、`all'`はテーブルの全データを取得して、インスタンス化し、メモリ内に保持するので、何千件もあるとすぐメモリ不足になります。
この問題を解決するために、`find_each`と`find_in_batches`という２通りの方法が用意されています。

### オブジェクト全体（find_each）

全件をいくつかのブロックに分けて処理していく。デフォルトでは1000件ごと。
findの標準的なオプション（:order, :limitを除く）が使用できる。

<pre><code data-language="ruby"># find_each
User.find_each do |user|
  NewsLetter.weekly_deliver(user)
end

# :start, :batch_size オプションが追加で使用できる
User.find_each(:start => 2000, :batch_size => 5000) do |user|
  NewsLetter.weekly_deliver(user)
end
</code></pre>

:startはバッチを再開する場合や、並列してワーカーを実行する場合などに利用できる。

### オブジェクト全体（find_in_batches）

find_eachと似ているが、こちらは配列で取得する。

<pre><code data-language="ruby"># find_in_batches
Invoice.find_in_batches(:include => :invoice_lines) do |invoices|
  export.add_invoices(invoices)
end
</code></pre>


## 条件

String SQLそのまま
Array プレースホルダ
Hash {:name => 'hoge'} 

## 順序

Client.order("created_at")
Client.order("orders_count ASC, created_at DESC")

## Select

特定のカラムだけ取得する。
select使うと Readonly になる。

Client.select("viewable_by, locked")

## Limit, Offset

Client.limit(5)
Client.offset(30)

## Group

Client.group("date(created_at)")

## Having

Order.select("date(created_at) as ordered_date, sum(price) as total_price")
  .group("date(created_at)")
  .having("sum(price) > ?", 100)

## Overriding

### except

### only

### reorder

### reverse_order

## Readonly

Readonlyなやつを更新しようとしたら ActiveRecord::ReadOnlyRecord 例外

## Locking


## Join

Stringで 
Client.joins('LEFT OUTER JOIN addresses ON addresses.client_id = clients.id')

Array/Hashで


Category.joins(:posts)

## Eager loading

Client.includes(:address).limit(10)


## Scope

class Post < ActiveRecord::Base
  scope :published, where(:published => true)
end


## Dynamic finder

rails4でdeprecated

## Find or build a new object

## Finding by SQL
## select_all
## pluck
## Existence of Objects

## Calculations

## Running EXPLAIN



