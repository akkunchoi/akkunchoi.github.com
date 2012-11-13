---
layout: posts
title: Rails3 routes.rb まとめ
tags: ruby rails
---

* toc
{:toc}

## はじめに

この記事はRails3のルーティングを理解するための自分用メモです。随時書き足し、整理していきます。


## ルーティングとは

まずルーティングとは何か？[公式のガイド] にはこう書かれてます。

> The Rails router recognizes URLs and dispatches them to a controller’s action. It can also generate paths and URLs, avoiding the need to hardcode strings in your views.

訳: RailsのルーターはURLを確認して、コントローラのアクションに処理を振り分けます。また、パスやURLを生成することで、ビューへのハードコードを避けることもできます。

Railsのルーティングは大きく分けて２つの機能を持ちます。

- URL から、「どのコントローラー」の「どのアクション」に「どういうパラメータ」を与えて処理を実行するかを定義する
- ビューに URL を記述する際は、ハードコーディングを避けるためURLを直接記述せずに、専用の方法で生成する

この機能のおかげで、URL構造とアプリケーション構造を独立して設計することを可能にします。
URL構造とアプリケーション構造の橋渡しの役目が `config/routes.rb` です。

Railsではルーティングを `config/routes.rb` に専用DSLで記述します。
Rails2とRails3ではかなり書き方が違うので注意が必要です（後方互換性はある？）。このページでは Rails3 においてのDSLを解説しています。

## シンプルな例

<pre><code data-language="ruby"># config/routes.rb
match "/patients/:id" => "patients#show", :as => :patient
</code></pre>

この一行の設定で「**/patients/17** に HTTP GET すると、**PatientsController の show アクションを id=17 のパラメータで実行する**」という設定になります。

そして名前付きルート (Named Route Helper) を使用して URL を生成することができます。

<pre><code data-language="ruby"># on view..
patient_path(17) # /patients/17
</code></pre>

名前付きルートを使うことで、アプリケーション側ではURL構造を気にせず設計できるようになります。

また、名前付きルートには path の他に url もあります。

<pre><code data-language="ruby"># on view..
patient_url(17)  # http://localhost:3000/patients/17
</code></pre>

## デバッグ

コンソールから `rake routes` を実行すると、現在のルーティングの設定を確認できます。

    $ rake routes
    patient        /patients/:id(.:format)       patients#show
                 
名前付きルートを `rails console` で試す場合は `app.patient_path` のようにすると呼び出すことができます。

    $ rails console
    [1] (main)> app.patient_path(17)
    => "/patients/17"
    
## Resource Routing

match を使ってアクションを定義していくのは面倒ですよね。Webアプリケーションはほとんど**CRUD**の構造なので、CRUDのアクションを自動で設定できれば楽になります。Railsでは `resources` を使って７のアクション(index, new, create, show, edit, update, destroy) を一度に設定できます。

Railsのデフォルトはこの Resource Routing で、これをうまく使うことで一貫性がある構造になり、記述量も格段に減らすことができます。

### 生成されるルート

<pre><code data-language="ruby"># config/routes.rb
resources :photos
</code></pre>

この一行で７つのルートが生成されます。
    
    HTTP Verb       Path                    action       named_helper 
    ---------       -----                   ------       ----------
    GET             /photos                 index        photos_path 
    GET             /photos/new             new          new_photo_path
    POST            /photos                 create       photos_path
    GET             /photos/:id             show         photo_path(:id)
    GET             /photos/:id/edit        edit         edit_photo_path(:id)
    PUT             /photos/:id             update       photo_path(:id)
    DELETE          /photos/:id             destroy      photo_path(:id)
    
それぞれ、PhotosControllerの index, new, create, show, edit, update, destroy アクションに対応しています。

newとcreate、editとupdateは対になっており、フォームと実行を想定しています。
Railsではこんな遷移を想定しています。

    index (GET /photos)
      |
      |--> (GET /photos/new)      --> new 
      |                               |
      |                               `-- (POST /photos) --> create
      |
      |-- (GET /photos/:id)      --> show
      |
      |-- (GET /photos/:id/edit) --> edit 
      |                               |
      |                               `--(PUT /photos/:id)--> update
      |
      `-- (DELETE /photos/:id)   --> destroy


### 基本

<pre><code data-language="ruby"># config/routes.rb
# PhotosControllerにひもづける
resources :photos

# 複数のリソースを定義する場合は一行で書いてもOK
resources :photos, :books, :users
</code></pre>

### idを伴わない場合

デフォルトでは show, edit, update, destroy は id を含むようになっています。
しかし各ユーザーのマイページのように、パラメータが不要なURLの場合もあります。

その場合は resource**s** ではなく、resource にします。

<pre><code data-language="ruby"># config/routes.rb
resource :profile
</code></pre>

:profile は複数形にしなくても、対応するコントローラは ProfilesController と複数形になるのに注意。
これは resources と同時に使う場合に、同じコントローラになった方がいいだろうという優しさらしい。

resource**s**と異なるのは「index がない」「:id がない」の２点。

生成されるのは以下の６つのルート。

    GET        /profile/new      new       new_profile_path
    POST       /profile          create    profile_path
    GET        /profile          show      profile_path
    GET        /profile/edit     edit      edit_profile_path
    PUT        /profile          update    profile_path
    DELETE     /profile          destroy   profile_path

### Namespace - path and controller prefix

namespace は path と controller に付けられるプレフィックスです。

<pre><code data-language="ruby"># config/routes.rb
namespace :admin do
  # コントローラは Admin::PhotosController です
  resources :photos
end
</code></pre>

URLと Named helper はこうなります。

    # GET        /admin/photos      index   admin_photos_path 
    # GET        /admin/photos/new  new     new_admin_photo_path
    # 省略...

### Scope - controller prefix 

Scope はコントローラのみプレフィックスを付けます。

<pre><code data-language="ruby"># config/routes.rb
scope :module => "admin" do
  # コントローラは Admin::PhotosController です
  resources :photos
end

# またはこのようにも記述できます
resources :photos, :module => "admin"
</code></pre>

パス、Named helperにはつかない。コントローラの構成をモジュール化したい場合に使えます。
    
    # GET        /photos         index      admin_photos_path 
    # GET        /photos/new     new        new_admin_photo_path
    # 省略...

### Scope - path prefix

パスのみプレフィックスを付ける場合

<pre><code data-language="ruby"># config/routes.rb
scope "/admin" do    
  # コントローラは PhotosController です
  resources :photos
end

# またはこのようにも記述できます
# :path は絶対パスで
resources :photos, :path => '/admin/photos'
</code></pre>

コントローラーとNamed helperには影響しない。URLだけ変更したい場合に使います。

    # GET        /admin/photos          index       photos_path 
    # GET        /admin/photos/new      new         new_photo_path
    # 省略...

さらに、`:path` を使えば自由にパスを変更できます。

<pre><code data-language="ruby"># config/routes.rb
# :path は相対パスにする
# /hoge => photo#index に対応
resources :photos, :path => 'hoge' 
</code></pre>

### Nested Resources - has_manyな場合に

<pre><code data-language="ruby"># config/routes.rb
resources :photos do
  resources :comments
end 

# photo_comments GET /photos/:photo_id/comments     comments#index
# photo_comment  GET /photos/:photo_id/comments/:id comments#show
</code></pre>
    
ネストは何階層でも可能だけど、混乱をまねくため１階層以上にすべきではない。Named helperも長くなる。

### member, collection - 追加のアクション

基本の7ルート以外のルートを追加したい場合は`member`か`collection`を使う。
`member`は :id 付きのルートで、`collection`は:idなしのルート。

`GET /photos/:id/preview` で preview アクションを呼ぶ設定。

<pre><code data-language="ruby"># config/routes.rb
resources :photos do
  member do
    get 'preview'
  end

  # または
  get 'preview', :on => :member
end
</code></pre>
    
`GET /photos/search`で search アクションを呼ぶ設定。

<pre><code data-language="ruby"># config/routes.rb
resources :photos do
  collection do
    get 'search'
  end

  # または
  get 'search', :on => :collection
end
</code></pre>

### collection と match

/photos/hoge, /photos/moge といちいちアクションを定義するのが面倒な場合は match を使います。

<pre><code data-language="ruby"># config/routes.rb
resources :photos do
  # TODO Named helperも自動生成できないだろうか...
  # /photos/:action photos#(?-mix:[^0-9]+)
  collection do
    # 数字の場合は member アクションに流れるようにする
    match ':action', :action => /[^0-9]+/
  end
end
</code></pre>



## Non-Resourceful Routes

resources じゃないルート。

### Dynamic

この設定で、

<pre><code data-language="ruby"># config/routes.rb
match ':controller(/:action(/:id))'
</code></pre>

`GET /photos/show/1/2`すると、パラメータはこうなる。

    { :controller => “photos”, :action => “show”, :id => “1”, :user_id => “2” }

パラメータは自由に追加できる

<pre><code data-language="ruby"># config/routes.rb
match ':controller/:action/:id/:user_id'
</code></pre>

namespaceの:moduleと、matchの:controllerは同時には使えない。そういう場合はこうする。

<pre><code data-language="ruby"># config/routes.rb
match ':controller(/:action(/:id))', :controller => /admin\/[^\/]+/
</code></pre>

### Static

URLに特定の文字列を含むような場合。

この設定で、

<pre><code data-language="ruby"># config/routes.rb
match ':controller/:action/:id/with_user/:user_id'
</code></pre>
    
`GET /photos/show/1/with_user/2` するとパラメータはこうなる

    { :controller => “photos”, :action => “show”, :id => “1”, :user_id => “2” }

### query strings

この設定で

<pre><code data-language="ruby"># config/routes.rb
match ':controller/:action/:id'
</code></pre>

`GET /photos/show/1?user_id=2`すると

    { :controller => “photos”, :action => “show”, :id => “1”, :user_id => “2” }

`GET /photos/show/1?id=2` この場合はどうなるか？
`:id => '1'`になる。クエリ文字列よりも :id の方が優先されるようです。


### Defaults

<pre><code data-language="ruby"># config/routes.rb
# GET /photos/1
# { :controller => "photos", :action => "show", :id => "1", :format => "jpg"
match 'photos/:id' => 'photos#show', :defaults => { :format => 'jpg' }
</code></pre>

### Naming - matchでも名前を付ける

<pre><code data-language="ruby"># config/routes.rb
# logout_path, logout_url
match 'exit' => 'sessions#destroy', :as => :logout
</code></pre>

### Constraints (HTTP verb) - HTTPメソッドで制約する

`/photos/show`かつGETメソッドに限定する

<pre><code data-language="ruby"># config/routes.rb
match 'photos/show' => 'photos#show', :via => :get

# 上記と下記は同じ。短縮形
get 'photos/show'
</code></pre>

    
複数のメソッドを付けられます

<pre><code data-language="ruby"># config/routes.rb
match 'photos/show' => 'photos#show', :via => [:get, :post]
</code></pre>

### Constraints (parameter) - パラメータを制約する

こうすると`/photos/A12345`のようなパスにマッチする。
`/photos/12`にはマッチしない。

<pre><code data-language="ruby"># config/routes.rb
match 'photos/:id' => 'photos#show', :constraints => { :id => /[A-Z]\d{5}/ }
# これは同じ意味
match 'photos/:id' => 'photos#show', :id => /[A-Z]\d{5}/ 
</code></pre>

制約は正規表現を受け取るが、`^ $ \b \B`は使えない。でも先頭に固定されているので使う必要がない。

### Constraints (request) - リクエストで制約をする 

[ActionDispatch::Request]オブジェクトのメソッドで制約がかけられる。

<pre><code data-language="ruby"># config/routes.rb
match "photos", :constraints => {:subdomain => "admin"}

# ブロックを与えることもできる
namespace "admin" do
  constraints :subdomain => "admin" do
    resources :photos
  end
end
</code></pre>

### Advanced Constraints - 制約クラス

<pre><code data-language="ruby"># config/routes.rb
match "*path" => "blacklist#index", :constraints => BlacklistConstraint.new

class BlacklistConstraint
  def matches?(request)
    # マッチするならtrue 
  end
end
</code></pre>

### glob

<pre><code data-language="ruby"># config/routes.rb
match 'photos/*other' => 'photos#unknown'
</code></pre>

こうなる。

    # GET /photos/12               :other => "12"
    # GET /photos/long/path/to/12, :other => "long/path/to/12".


これは、

<pre><code data-language="ruby"># config/routes.rb
match 'books/*section/:title' => 'books#show'
</code></pre>

こうなる。

    # GET /books/some/section/last-words-a-memoir
    # {:section => "some/section", :title => "last-words-a-memoir"}


### redirection

301 “Moved Permanently” redirectになります。

<pre><code data-language="ruby"># config/routes.rb
match "/stories" => redirect("/posts")

# 値を引き継ぐ場合
match "/stories/:name" => redirect("/posts/%{name}")

# ブロックでもいいよ
match "/stories/:name" => redirect {|params| "/posts/#{params[:name].pluralize}" }
match "/stories" => redirect {|p, req| "/posts/#{req.subdomain}" }
</code></pre>


### Rack

TODO 

<pre><code data-language="ruby"># config/routes.rb
match "/application.js" => Sprockets
</code></pre>

### トップページ - root

<pre><code data-language="ruby"># config/routes.rb
# GET /   => PagesController, 'main' action
root :to => 'pages#main'
</code></pre>

## Customized Resource

TODO

## 設定例

### Resource で Static な文字列を挟みたい時

<pre><code data-language="ruby"># config/routes.rb
resources :users do
  member do
    match 'category/:category', :action => :show, :as => :category
  end
  resources :images do
    collection do
      match 'category/:category', :action => :index, :as => :category
    end
  end
end
</code></pre>

    $ rake routes
    category_user        /users/:id/category/:category(.:format)             users#show
    category_user_images /users/:user_id/images/category/:category(.:format) images#index

### /about や /help のような静的ページのようなアクションを量産したい

<pre><code data-language="ruby"># config/routes.rb
match ':action', :controller => :pages_controller
</code></pre>

/about は PagesController#about に、
/help は PagesController#help になります。

## 参考

- <http://d.hatena.ne.jp/willnet/20100424/1272119369>
- <http://guides.rubyonrails.org/routing.html>
- [http://wiki.usagee.co.jp/ruby/rails/RailsGuides...](<http://wiki.usagee.co.jp/ruby/rails/RailsGuides%E3%82%92%E3%82%86%E3%81%A3%E3%81%8F%E3%82%8A%E5%92%8C%E8%A8%B3%E3%81%97%E3%81%A6%E3%81%BF%E3%81%9F%E3%82%88/Rails%20Routing%20from%20the%20Outside%20In>)

[公式のガイド]: http://guides.rubyonrails.org/routing.html
[ActionDispatch::Request]: http://api.rubyonrails.org/classes/ActionDispatch/Request.html
