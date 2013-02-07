---
layout: posts
title: rails3-active-record-query-interface
tags: rails
---

[ActiveRecordのクエリーインタフェースの解説](http://guides.rubyonrails.org/active_record_querying.html) のまとめ。

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


## オブジェクトの取得

情報取得するには以下の finder method が利用できます。これを呼び出すことで、SQLを書かずにクエリーを実行することができます。戻り値は ActiveRecord::Relation インスタンスです。

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

- 1. オプションをSQLクエリに変換する
- 2. SQLクエリを実行し、結果をデータベースから取り出す
- 3. 結果を行ごとに適切なモデルクラスで、インスタンス化
- 4. 指定されていれば、after_find コールバックを実行する

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


### テーブル内の全件を取得する（all）

テーブル内のレコード全件を処理したい場合は`all`メソッドを使います。

<pre><code data-language="ruby"># all
User.all.each do |user|
  NewsLetter.weekly_deliver(user)
end
</code></pre>

ただ、`all'`はテーブルの全データを取得して、インスタンス化し、メモリ内に保持するので、何千件もあるとすぐメモリ不足になります。
この問題を解決するために、`find_each`と`find_in_batches`という２通りの方法が用意されています。

### テーブル内の全件を取得する（find_each）

全件をいくつかのブロックに分けて処理していくので、効率的に全件処理できます。。デフォルトでは1000件ごとです。
findの標準的なオプション（:order, :limitを除く）が使用できます。

<pre><code data-language="ruby"># find_each
User.find_each do |user|
  NewsLetter.weekly_deliver(user)
end

# :start, :batch_size オプションが追加で使用できる
User.find_each(:start => 2000, :batch_size => 5000) do |user|
  NewsLetter.weekly_deliver(user)
end
</code></pre>

:startはバッチを再開する場合や、並列してワーカーを実行する場合などに利用できます。

### テーブル内の全件を取得する（find_in_batches）

find_eachと似ているけど、こちらは配列で取得します。

<pre><code data-language="ruby"># find_in_batches
Invoice.find_in_batches(:include => :invoice_lines) do |invoices|
  export.add_invoices(invoices)
end
</code></pre>


## Where

SQLのWhere文を構築します。String, Array, Hash のどれかを引数に入れて使います。

Stringの場合、SQLを直接書くようなイメージです。エスケープなどはされません。ユーザー入力値をそのまま入れないようにしましょう。

<pre><code data-language="ruby"># where(string)
Client.where("orders_count = '2'")

# これはやってはいけない！
Client.where("first_name LIKE '%#{params[:first_name]}%'")
</code></pre>

Arrayにすると、プレースホルダーが使えます。'?' にエスケープされた第二引数の値が置き換わるので安全です。
[詳細](http://guides.rubyonrails.org/security.html#sql-injection)。

<pre><code data-language="ruby"># where(array, ...)
Client.where("orders_count = ?", params[:orders])
</code></pre>

プレースホルダーはハッシュにもできます。

<pre><code data-language="ruby"># where(array, hash)
Client.where("created_at >= :start_date AND created_at <= :end_date",
  {:start_date => params[:start_date], :end_date => params[:end_date]})
</code></pre>


Hashにするとさらに読みやすくなります。

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

ORDER BY です。

<pre><code data-language="ruby"># order by
Client.order("created_at")
Client.order("orders_count ASC, created_at DESC")
</code></pre>

## Select

特定のカラムだけ取得する。selectを使うと Readonly になります。

<pre><code data-language="ruby"># select
Client.select("viewable_by, locked")
# sql: 
# SELECT viewable_by, locked FROM clients
</code></pre>

selectとした列以外を取得しようとすると、ActiveRecord::MissingAttributeError になります。

`SELECT DISTINCT` 相当は `uniq()` です。

<pre><code data-language="ruby"># select distinct
Client.select(:name).uniq
# sql:
# SELECT DISTINCT name FROM clients

q = Client.select(:name).uniq
q = uniq(false) # uniq解除

</code></pre>


## Limit, Offset

<pre><code data-language="ruby"># limit, offset
Client.limit(5)
Client.offset(30)
</code></pre>

## Group

<pre><code data-language="ruby"># group by
Client.group("date(created_at)")
</code></pre>


## Having

<pre><code data-language="ruby"># having
Order.select("date(created_at) as ordered_date, sum(price) as total_price")
  .group("date(created_at)")
  .having("sum(price) > ?", 100)
</code></pre>

## 上書き - Overriding

構築したクエリから一部を除外したり、特定の条件だけにするメソッドが用意されてます。

- except(): 指定クエリを除外（:order, :whereなど）
- only(): 指定クエリだけにする（:order, :whereなど）
- reorder(): default scope で指定した order を上書きします
- reverse_order(): 逆順にします


## 読み込み専用 - Readonly

Readonlyなオブジェクトを更新しようとすると、例外が発生します。

<pre><code data-language="ruby"># readonly
client = Client.readonly.first
client.visits += 1
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
  
c2.name = "should fail"
c2.save # Raises an ActiveRecord::StaleObjectError
</code></pre>

`ActiveRecord::Base.lock_optimistically = false` でこの機能を無効にできます。

`set_locking_column` でlock_versionというカラム名を変更できます。

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
Item.transaction do
  i = Item.lock.first
  i.name = 'Jones'
  i.save
end
# SQL (0.2ms)   BEGIN
# Item Load (0.3ms)   SELECT * FROM `items` LIMIT 1 FOR UPDATE
# Item Update (0.4ms)   UPDATE `items` SET `updated_at` = '2009-02-07 18:05:56', `name` = 'Jones' WHERE `id` = 1
# SQL (0.8ms)   COMMIT
</code></pre>


共有ロックなどロックタイプを変更したい場合は引数にタイプを与えてやります。

<pre><code data-language="ruby"># lock in share mode
Item.transaction do
  i = Item.lock("LOCK IN SHARE MODE").find(1)
  i.increment!(:views)
end
</code></pre>

すでにインスタンスを取得しているなら、`with_lock`でトランザクションを開始できます。

<pre><code data-language="ruby"># with_lock
item = Item.first
item.with_lock do
  # このブロックはtransaction内で、itemはロックされてます
  item.increment!(:views)
end
</code></pre>

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



