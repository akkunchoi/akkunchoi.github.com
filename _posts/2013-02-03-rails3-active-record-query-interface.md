Rails3 - Active Record Query Interface

---
layout: posts
title: Rails3 - Active Record Query Interface
tags: rails
---

* Toc
{:toc}

[ActiveRecordのクエリーインタフェースの解説](http://guides.rubyonrails.org/active_record_querying.html) を参考に、コードを書いて確認していきます。

## 準備

bundlerでインストールします。

<pre><code data-language="ruby"># Gemfile
source 'https://rubygems.org'
      
gem "activerecord", "~> 3.2.12"                             
gem 'sqlite3'
</code></pre>

active_recordを単体で使えるようにセットアップします。

<pre><code data-language="ruby"># main.rb
require 'rubygems'
require 'bundler/setup'

require "active_record"                                     

# database connection
ActiveRecord::Base.establish_connection(                    
  adapter:  "sqlite3",
  database: ":memory:"                                      
)
</code></pre>

例で使用するマイグレーションとモデルを作成します。

<pre><code data-language="ruby"># main.rb
# migration
class Init < ActiveRecord::Migration
  def self.up
    create_table(:clients){|t|
      t.string :name
      t.integer :orders_count
      t.timestamps
    }
    create_table(:orders){|t|
      t.references :client
      t.integer :price
      t.datetime :ordered_date
      t.timestamps
    }
    create_table(:addresses){|t|
      t.references :client
      t.string :pref
    }
  end
  def self.down
    drop_table :clients
    drop_table :orders
    drop_table :addresses
  end
end

# run migrate
Init.migrate(:up)

# models
class Client < ActiveRecord::Base
  has_one :address
  has_many :orders
end
class Address < ActiveRecord::Base
  belongs_to :client
end
class Order < ActiveRecord::Base
  belongs_to :client, :counter_cache => true
end

</code></pre>

準備が整いました。データを入れてみます。

<pre><code data-language="ruby"># main.rb
Client.create({:name => "Alice"})
Client.create({:name => "Bob"})
Client.create({:name => "Carol"})
Address.create({:client => Client.find(1), :pref => "Osaka"})
Order.create({:client => Client.find(2), :price=> 20})
Order.create({:client => Client.find(2), :price=> 50})

</code></pre>

SQLを確認するためにloggerを設定します。

<pre><code data-language="ruby"># main.rb
ActiveSupport::LogSubscriber.colorize_logging = false
ActiveRecord::Base.logger = Logger.new(STDOUT)
</code></pre>



## オブジェクトをひとつだけ取り出す

### find - 主キーによる検索

普通は id で検索します。

<pre><code data-language="ruby"># find
puts Client.find(1).name
# => SELECT "clients".* FROM "clients" WHERE "clients"."id" = ? LIMIT 1  [["id", 1]]
# "Alice"
</code></pre>

もしデータが見つからなかった場合は`ActiveRecord::RecordNotFound`例外が発生します。

<pre><code data-language="ruby"># find but not found
begin
  Client.find(100)
rescue ActiveRecord::RecordNotFound => e
  p e
  #<ActiveRecord::RecordNotFound: Couldn't find Client with id=100> 
end
</code></pre>


以前はこの find の引数に色々パラメータを入れて複雑な条件をするのが主流でした。現在では後述の`ActiveRecord::Relation`を使う方が良いです。 find はもっぱら、主キーからオブジェクトを取得する目的だけに使われるようになったようです。


### first

最初の項目を取得します。`LIMIT 1`と同じです。
`first`はレコードが存在していなければ`nil`を返しますが、`first!`にすると、`ActiveRecord::RecordNotFound`例外が発生します。

<pre><code data-language="ruby"># first
puts Client.first.name
# => SELECT "clients".* FROM "clients" LIMIT 1
# "Alice"
</code></pre>


### last

最後の項目を取得します。降順にして`LIMIT 1`にすることで取得しています。
`last`はレコードが存在していなければ`nil`を返しますが、`last!`にすると、`ActiveRecord::RecordNotFound`例外が発生します。

<pre><code data-language="ruby"># last
puts Client.last.name
# => SELECT "clients".* FROM "clients" ORDER BY "clients"."id" DESC LIMIT 1 
# "Carol"
</code></pre>


## 複数のオブジェクトを取り出す

id の配列をfindすると一度に複数のオブジェクトを取得できます。

<pre><code data-language="ruby"># find(array)
p Client.find([1,2])
# => SELECT "clients".* FROM "clients" WHERE "clients"."id" IN (1, 2)
# [#<Client id: 1, name: "Alice">, #<Client id: 2, name: "Bob">]
</code></pre>

ひとつでもレコードが見つからなければやはり`ActiveRecord::RecordNotFound`です。

find, first, last は [ActiveRecord::FinderMethods](https://github.com/rails/rails/blob/v3.2.12/activerecord/lib/active_record/relation/finder_methods.rb) で定義されています。

## 複数のオブジェクトをまとめて処理する

テーブル内のレコード全件を処理したい場合は`all`メソッドを使うことができます。

<pre><code data-language="ruby"># all
Client.all.each do |c|
  # ...
end
</code></pre>

ただ、`all`はテーブルの全データを取得して、インスタンス化し、メモリ内に保持するので、何千件もあるとすぐメモリ不足になります。
（allは実行された時点で、データベースにクエリーを投げます。戻り値は`ActiveRecord::Relation`ではありません。ここは間違いやすいので注意です）

この問題を解決するために、`find_each`と`find_in_batches`という２通りの方法が用意されています。

### find_each 

全件をいくつかのブロックに分けて処理していくので、効率的に全件処理できます。。デフォルトでは1000件ごとです。
findの標準的なオプション（`:order`, `:limit`を除く）が使用できます。

<pre><code data-language="ruby"># find_each
Client.find_each(:include => :address) do |c|
  p c
end
# SELECT "clients".* FROM "clients" WHERE ("clients"."id" >= 0) ORDER BY "clients"."id" ASC LIMIT 1000
# SELECT "addresses".* FROM "addresses" WHERE "addresses"."client_id" IN (1, 2, 3) 

#<Address id: 1, client_id: 1, pref: "Osaka">                              
# nil
# nil

# :start, :batch_size オプションが追加で使用できる
Client.find_each(:start => 2000, :batch_size => 5000) do |c|
  # ...
end
</code></pre>

`:start`はバッチを再開する場合や、並列してワーカーを実行する場合などに利用できます。

### find_in_batches

find_eachと似てますが、こちらはブロックの引数が配列になります。

<pre><code data-language="ruby"># find_in_batches
Client.find_in_batches(:include => :orders, :batch_size => 2) do |clients|
  puts clients.size
end

# 一回目のバッチ
# SELECT "clients".* FROM "clients" WHERE ("clients"."id" >= 0) ORDER BY "clients"."id" ASC LIMIT 2
# SELECT "addresses".* FROM "addresses" WHERE "addresses"."client_id" IN (1, 2)
# => 2

# 二回目のバッチ
# SELECT "clients".* FROM "clients" WHERE ("clients"."id" > 2) ORDER BY "clients"."id" ASC LIMIT 2
# SELECT "addresses".* FROM "addresses" WHERE "addresses"."client_id" IN (3)
# => 1
</code></pre>


## ActiveRecord::Relation

条件を指定して取得するには以下のメソッドを使います。これらは`ActiveRecord::Relation`オブジェクトを返します。

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

<pre><code data-language="ruby">p Client.where("1").class
# ActiveRecord::Relation
</code></pre>

`find` に同じようなオプションを与えることもできます（古いやり方）。

## Where

SQLのWhere文を構築します。String, Array, Hash のどれかを引数に入れて使います。

Stringの場合、SQLを直接書くようなイメージです。エスケープなどはされません。ユーザー入力値をそのまま入れないようにしましょう。

<pre><code data-language="ruby"># where(string)
Client.where("orders_count = '2'")
# SELECT "clients".* FROM "clients" WHERE (orders_count = '2')
# => [#<Client id: 2, name: "Bob", orders_count: 2, created_at: "2013-03-06 19:12:44", updated_at: "2013-03-06 19:12:44">]

# これはやってはいけない！
Client.where("first_name LIKE '%#{params[:first_name]}%'")
</code></pre>

Arrayにすると、プレースホルダーが使えます。`?` にエスケープされた値が入るので安全です。
[詳細](http://guides.rubyonrails.org/security.html#sql-injection)。

<pre><code data-language="ruby"># where(array, ...)
Client.where("orders_count = ?", params[:orders])
</code></pre>

プレースホルダーはハッシュにもできます。

<pre><code data-language="ruby"># where(array, hash)
Client.where("created_at >= :start_date AND created_at <= :end_date",
  {:start_date => params[:start_date], :end_date => params[:end_date]})
</code></pre>

Hashにするとすっきりします。

<pre><code data-language="ruby"># where(hash)
Client.where(:orders_count => 2)
</code></pre>

範囲指定もできます。

<pre><code data-language="ruby"># where(key => range)
Client.where(:created_at => (Time.now.midnight - 1.day)..Time.now.midnight)
# sql: 
# SELECT * FROM clients WHERE (clients.created_at BETWEEN '2008-12-21 00:00:00' AND '2008-12-22 00:00:00')
</code></pre>

Subset条件（IN構文）を使うには、値を配列にします

<pre><code data-language="ruby"># where(key => array)
Client.where(:orders_count => [1,3,5])
# sql:
# SELECT * FROM clients WHERE (clients.orders_count IN (1,3,5))
</code></pre>


## Order

`ORDER BY`です。

<pre><code data-language="ruby"># order by
Client.order("created_at")
Client.order("orders_count ASC, created_at DESC")
</code></pre>

## Select

`SELECT`句です。これを指定すると、取得されたオブジェクトは Readonly になります。

<pre><code data-language="ruby"># select
Client.select(:orders_count)
# sql: 
# SELECT orders_count FROM "clients"
</code></pre>

selectとした列以外を取得しようとすると、ActiveRecord::MissingAttributeError になります。

<pre><code data-language="ruby"># select error
c = Client.select(:orders_count).first
begin
  p c.name
rescue ActiveModel::MissingAttributeError => e
  p e
end
# #<ActiveModel::MissingAttributeError: missing attribute: name>
</code></pre>

`SELECT DISTINCT` 相当は `uniq()` です。

<pre><code data-language="ruby"># select distinct
Client.select(:name).uniq
# sql:
# SELECT DISTINCT name FROM clients

q = Client.select(:name).uniq
q = uniq(false) # uniq解除
</code></pre>


## Limit, Offset

`LIMIT`と`OFFSET`句です。

<pre><code data-language="ruby"># limit, offset
Client.limit(5)
Client.offset(30)
</code></pre>

## Group

`GROUP BY` です。

<pre><code data-language="ruby"># group by
Client.group("date(created_at)")
# sql: SELECT "clients".* FROM "clients" GROUP BY date(created_at)
</code></pre>

## Having

<pre><code data-language="ruby"># having
Order.select("date(created_at) as ordered_date, sum(price) as total_price")
  .group("date(created_at)")
  .having("sum(price) > ?", 100)
# sql: SELECT date(created_at) as ordered_date, sum(price) as total_price FROM "orders" GROUP BY date(created_at) HAVING sum(price) > 100
</code></pre>

## 上書き - Overriding

構築したクエリから一部を除外したり、特定の条件だけにするメソッドが用意されてます。

- `except()`: 指定クエリを除外（`:order`, `:where`など）
- `only()`: 指定クエリだけにする（`:order`, `:where`など）
- `reorder()`: default scope で指定した order を上書きします
- `reverse_order()`: 逆順にします

`except`を使ってみます。例外的な処理が発生する場合に使えるかもです。

<pre><code data-language="ruby"># except
clients = Client.where("orders_count > 0")
p clients
# [#<Client id: 2, name: "Bob">]

clients = clients.except(:where)
p clients
# [#<Client id: 1, name: "Alice">, #<Client id: 2, name: "Bob">, #<Client id: 3, name: "Carol">]
</code></pre>

## 読み込み専用 - Readonly

Readonlyなオブジェクトを更新しようとすると、例外が発生します。

<pre><code data-language="ruby"># readonly
client = Client.readonly.first
client.name = "hoge"
client.save # raise ActiveRecord::ReadOnlyRecord
</code></pre>

## ロック - Locking

### 楽観的ロック

integer型の`lock_version`という名前のカラムが存在すると、Railsが自動的に楽観的ロックを行なってくれます。
更新する度に`lock_version`の値をインクリメントしていき、競合を検知する仕組みです。

更新が競合した場合、`ActiveRecord::StaleObjectError`が発生します。

<pre><code data-language="ruby"># lock_version
c1 = Client.find(1)
c2 = Client.find(1)
 
c1.first_name = "Michael"
c1.save
 
# sql: 
# begin transaction
# UPDATE "clients" SET "name" = 'Michael', "updated_at" = '2013-03-13 17:17:59.886521', "lock_version" = 1 WHERE ("clients"."id" = 1 AND "clients"."lock_version" = 0)
# commit transaction

c2.name = "should fail"
c2.save # Raises an ActiveRecord::StaleObjectError
</code></pre>

`ActiveRecord::Base.lock_optimistically = false` でこの機能を無効にできます。

`set_locking_column` で既定の`lock_version`というカラム名を変更できます。

<pre><code data-language="ruby"># set_locking_column
class Client < ActiveRecord::Base
  set_locking_column :lock_client_column
end
</code></pre>


### 悲観的ロック

悲観的ロックはデータベースシステムの機能を利用します。

リレーションを構築する時に`lock`を使うと、選択行の排他的ロックを獲得します。
`lock`を使ったリレーションはデッドロックを避けるために、通常`transaction`ブロックで囲みます。

<pre><code data-language="ruby"># transaction
Address.transaction do
  a = Address.lock.first
  a.pref = "Hokkaido"
  a.save
end
# begin transaction
# UPDATE "addresses" SET "pref" = 'Hokkaido' WHERE "addresses"."id" = 1
# commit transaction
</code></pre>


共有ロックなどロックタイプを変更したい場合は引数にタイプを与えてやります。

<pre><code data-language="ruby"># lock in share mode
Address.transaction do
  a = Address.lock("LOCK IN SHARE MODE").first
  a.increment!(:views)
end
</code></pre>

すでにインスタンスを取得しているなら、`with_lock`でトランザクションを開始できます。

<pre><code data-language="ruby"># with_lock
a = Address.first
a.with_lock do
  # このブロックはtransaction内で、itemはロックされてます
  a.increment!(:views)
end
</code></pre>


<!--
## Join

whereと同様、Stringで与えると、SQLをそのまま記述できます。

<pre><code data-language="ruby"># joins(string)
Client.joins('LEFT OUTER JOIN addresses ON addresses.client_id = clients.id')
# sql:
# SELECT clients.* FROM clients LEFT OUTER JOIN addresses ON addresses.client_id = clients.id
</code></pre>

[associations](http://guides.rubyonrails.org/association_basics.html) を定義していれば、もっと簡単に書くことができるようになります。

<pre><code data-language="ruby"># joins(symbol)
#
#   
class Category < ActiveRecord::Base
  has_many :posts
end
class Post < ActiveRecord::Base
  belongs_to :category
  has_many :comments
  has_many :tags
end
class Comment < ActiveRecord::Base
  belongs_to :post
  has_one :guest
end
class Guest < ActiveRecord::Base
  belongs_to :comment
end
class Tag < ActiveRecord::Base
  belongs_to :post
end

# 1テーブルをjoin
# 投稿があるすべてのカテゴリーを返す
Category.joins(:posts)
# sql:
# SELECT categories.* FROM categories
    INNER JOIN posts ON posts.category_id = categories.id

# 複数テーブルをjoin
# カテゴリーが設定されていて、１つ以上のコメントがある、全ての投稿を返す
Post.joins(:category, :comments)

# sql:
# SELECT posts.* FROM posts
#   INNER JOIN categories ON posts.category_id = categories.id
#   INNER JOIN comments ON comments.post_id = posts.id
</code></pre>

もっと深い場合

<pre><code data-language="ruby"># joins(hash)

# Guestによるコメントを持つ投稿を全て返す
Post.joins(:comments => :guest)
# sql:
# SELECT posts.* FROM posts
#    INNER JOIN comments ON comments.post_id = posts.id
#    INNER JOIN guests ON guests.comment_id = comments.id

# GuestによるコメントがありTagを１つ以上持つ投稿があるカテゴリを返す
Category.joins(:posts => [{:comments => :guest}, :tags])
# sql:
# SELECT categories.* FROM categories
#   INNER JOIN posts ON posts.category_id = categories.id
#   INNER JOIN comments ON comments.post_id = posts.id
#   INNER JOIN guests ON guests.comment_id = comments.id
#   INNER JOIN tags ON tags.post_id = posts.id
</code></pre>

もちろんjoinしたテーブルはwhereで条件を追加できる。

<pre><code data-language="ruby"># join-where
Client.joins(:orders).where(:orders => {:created_at => time_range})
</code></pre>

## Eager loading

アソシエーションを使ってレコードを複数取得すると、*N + 1 クエリー問題*が発生する。N件のデータを取得するのに、N+1の問い合わせが必要になる。

<pre><code data-language="ruby"># normal
clients = Client.limit(10) # 1回目: clientsテーブルを読む
 
clients.each do |client|
  puts client.address.postcode # 10回繰り返し: addressesテーブルを読む
end

# 合計11回のクエリー
</code></pre>

`includes`を使えば、一度にレコードを取りに行ってくれる。

<pre><code data-language="ruby"># includes
Client.includes(:address).limit(10)

clients = Client.includes(:address).limit(10)
 
clients.each do |client|
  puts client.address.postcode
end

# sql:
# SELECT * FROM clients LIMIT 10
#
# SELECT addresses.* FROM addresses
#   WHERE (addresses.client_id IN (1,2,3,4,5,6,7,8,9,10))
# 
# 2クエリーに減った！
</code></pre>

使い方は`joins`と似ている。

<pre><code data-language="ruby"># includes nested association
Category.includes(:posts => [{:comments => :guest}, :tags]).find(1)
</code></pre>

`joins`はの場合はINNER JOIN。
`includes`で`where`を追加すると、LEFT OUTER JOINになる。
[Specifying Conditions on Eager Loaded Associations](http://guides.rubyonrails.org/active_record_querying.html#specifying-conditions-on-eager-loaded-associations)

## Scope

<pre><code data-language="ruby"># scope
class Post < ActiveRecord::Base
  scope :published, where(:published => true)

  # チェーンできる
  scope :published_and_commented, published.and(self.arel_table[:comments_count].gt(0))
  
  # 時間を扱う場合は現在日時を束縛しないように、lambdaにしないといけない
  scope :last_week, lambda { where("created_at < ?", Time.zone.now ) }

  # lambdaにする場合は、引数を受け取ることができる
  scope :1_week_before, lambda { |time| where("created_at < ?", time) }
end

Post.published
Post.published_and_commented
Post.last_week
Post.1_week_before(Time.zone.now) 

# 引数を受け取るならクラスメソッドにした方が良いらしい
class Post < ActiveRecord::Base
  def self.1_week_before(time)
    where("created_at < ?", time)
  end
end
</code></pre>


`default_scope`は強制的に全てのクエリにスコープが付けられる。論理削除に便利。

<pre><code data-language="ruby"># default_scope
class Client < ActiveRecord::Base
  default_scope where("removed_at IS NULL")
end

# スコープを一時的に外したい場合は unscoped
Client.unscoped.all
</code></pre>

## Dynamic finder

rails4でdeprecated

## Find or build a new object

## Finding by SQL
## select_all
## pluck
## Existence of Objects

## Calculations

## Running EXPLAIN

-->

