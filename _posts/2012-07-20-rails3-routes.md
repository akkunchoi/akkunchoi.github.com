---
layout: posts
title: Rails3 routes.rb まとめ
tags: ruby rails
---

* toc
{:toc}

## はじめに

これはRails3のルーティングを理解するための自分用メモです。

## ルーティングとRails

ルーティングとは「URL」と「コントローラー、アクション、パラメータ」とのマッピングのこと。

[公式のガイド]にはこう書いてある。

> The Rails router recognizes URLs and dispatches them to a controller’s action. It can also generate paths and URLs, avoiding the need to hardcode strings in your views.
>
> 訳: RailsのルーターはURLを確認して、コントローラのアクションに処理を振り分けまする。また、パスやURLを生成することで、ビューへのハードコード避けることもできます。

「URL => アクション」だけでなく、「アクション => URL」も可能だそうだ。


ガイドに沿って、まずは最もシンプルな例を試してみる。Railsでは`config/routes.rb`にDSLで記述する。Rails2とRails3ではかなり書き方が違うので注意する（後方互換性はある？）。

    # -- config/routes.rb

    match "/patients/:id" => "patients#show"

この一行で「`/patients/17` に HTTP GET すると、PatientsController の show アクションが呼ぶ」という設定になる。


さらに（resourcesなどで設定していれば）ビューではこのような記述ができる

    # @patient = Patient.find(17)
    <%= link_to "Patient Record", patient_path(@patient) %>

`patient_path(@patient)` は `/patients/17` を返す。これを**named helper**と呼ぶらしい。

Railsでは「パス」と「URL」を区別している。URLはスキーム、ドメイン名を含む文字列`http://example.com/hoge/moge/`でパスは`/hoge/moge`の部分。ふだんはパスを使って、必要な時だけURLを使うようにするといい。`patient_url(@patient)`でURLを取得できる。

コンソールから`rake routes`を実行すると、ルーティングの設定を確認できる。これはroutes.rbを書き換えた後や、現在の構成を確認したい場合など、頻繁に使うことになるだろう。

named helperを`rails console`で試す場合は`app.users_path`で呼び出すことができる。
    

Railsでのルーティングは`resources`を上手く使うのがコツらしい。
`resources`を使うとリソース（って何なんだという話だけど）のCRUD（Create, Read, Update, Delete）を行うルーティングが一度に生成される。これを使うと一貫性があり、記述量を減らすことができる。詳しくは[REST]へ。


## Resource Routing

基本の設定

    resources :photos

PhotosControllerに対して7つのルートを生成する。
    
    HTTP Verb  Path             action    named_helper 
    ---------  -----            ------    ----------
    GET        /photos          index     photos_path 
    GET        /photos/new      new       new_photo_path
    POST       /photos          create    photos_path
    GET        /photos/:id      show      photo_path(:id)
    GET        /photos/:id/edit edit      edit_photo_path(:id)
    PUT        /photos/:id      update    photo_path(:id)
    DELETE     /photos/:id      destroy   photo_path(:id)

Railsではこんな遷移を想定しているようです。

    index (GET /photos)
      |
      |-- (GET /photos/new)      --> new 
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

### resources - 基本

    # PhotosControllerにひもづける
    resources :photos

    # 複数の場合は一行でもOK
    resources :photos, :books, :users

### resource - idを伴わない場合

例えば、各ユーザーのプロフィールなど。
コントローラは`ProfileController`ではなく、`ProfilesController`になるので注意（resourcesも同時使う場合に同じコントローラ使いたいだろうということらしい）。

    resource :profile

`resources`と異なるのは「index がない」「:id がない」の２点

    GET        /profile/new      new       new_profile_path
    POST       /profile          create    profile_path
    GET        /profile          show      profile_path
    GET        /profile/edit     edit      edit_profile_path
    PUT        /profile          update    profile_path
    DELETE     /profile          destroy   profile_path

### namespace - path and controller prefix

namespaceはpathとcontrollerに付けられるprefix

    namespace :admin do
      # Admin::PhotosController
      resources :photos
    end


    # HTTP Verb  Path               action  named helper 
    # ---------  -----              ------  ----------
    # GET        /admin/photos      index   admin_photos_path 
    # GET        /admin/photos/new  new     new_admin_photo_path
    #   省略...
    # 

### scope - controller prefix 

controllerのみprefixを付ける。

    scope :module => "admin" do
      # Admin::PhotosController
      resources :photos
    end

または

    # Admin::PhotosController
    resources :photos, :module => "admin"

Path, named helperにはつかない。内部の構成をモジュール化したい場合に使える。
    
    # HTTP Verb  Path         action  named helper 
    # ---------  -----        ------  ----------
    # GET        /photos      index   photos_path 
    # GET        /photos/new  new     new_photo_path
    #   省略...
    # 

### scope - path prefix

pathのみprefixを付ける場合

    scope "/admin" do    
      resources :photos
    end

または

    # :path は絶対パスで
    resources :photos, :path => '/admin/photos'

コントローラーとnamed helperには影響しない。URLだけ変更したい場合に使う。

    # HTTP Verb  Path               action  named helper 
    # ---------  -----              ------  ----------
    # GET        /admin/photos      index   photos_path 
    # GET        /admin/photos/new  new     new_photo_path
    #   省略...
    # 

`:path`を使えば自由にパスを変更できる

    # photo_index   GET  /hoge  photo#index
    # :path は相対パスで
    resources :photos, :path => 'hoge' 

### Nested Resources - has_manyな場合

    resources :photos do
      resources :comments
    end 
    
    # photo_comments GET /photos/:photo_id/comments     comments#index
    # photo_comment  GET /photos/:photo_id/comments/:id comments#show
    
ネストは何階層でも可能だけど、混乱をまねくため１階層以上にすべきではない。named helperも長くなる。

### member, collection - ルーティングを追加

基本の7ルート以外のルートを追加したい場合は`member`か`collection`を使う。memberは:id付きのルートで、collectionは:idなしのルート。

`GET /photos/:id/preview` で preview アクションが呼ばれるようにするためにはこうする。

    resources :photos do
      member do
        get 'preview'
      end
      # または
      # get 'preview', :on => :member
    end
    
`GET /photos/search`で search アクションが呼ばれるようにするためにはこうする。

    resources :photos do
      collection do
        get 'search'
      end
      # または
      # get 'search', :on => :collection
    end

### member,collection と match の合わせ技

いちいち定義するのは面倒なので match を使います。

    # TODO named helperも自動生成できないだろうか...
    # /hotels/:action hotels#(?-mix:[^0-9]+)

    resources :hotels do
      collection do
        # 数字の場合は :id に流れるようにする
        match ':action', :action => /[^0-9]+/
      end
    end

## Non-Resourceful Routes

### dynamic

このようなルート設定で、

    match ':controller(/:action(/:id))'

`GET /photos/show/1/2`すると、パラメータはこうなる。

    { :controller => “photos”, :action => “show”, :id => “1”, :user_id => “2” }

パラメータは自由に追加できる

    match ':controller/:action/:id/:user_id'

namespace, :moduleと、matchの:controllerは同時には使えない。そういう場合はこうする。

    match ':controller(/:action(/:id))', :controller => /admin\/[^\/]+/

### static

URLに特定の文字列を含むような場合。

このような設定で、

    match ':controller/:action/:id/with_user/:user_id'
    
`GET /photos/show/1/with_user/2` するとパラメータはこうなる

    { :controller => “photos”, :action => “show”, :id => “1”, :user_id => “2” }

### query strings

このルーティングで、

    match ':controller/:action/:id'

`GET /photos/show/1?user_id=2`すると

    { :controller => “photos”, :action => “show”, :id => “1”, :user_id => “2” }

`GET /photos/show/1?id=2` この場合はどうなるか？`:id => '1'`になる。クエリ文字列よりも:idの方が優先されるようだ。


### defaults

    # GET /photos/1
    # { :controller => "photos", :action => "show", :id => "1", :format => "jpg"
    match 'photos/:id' => 'photos#show', :defaults => { :format => 'jpg' }

### naming - matchでも名前を付ける

    # logout_path, logout_url
    match 'exit' => 'sessions#destroy', :as => :logout

### constraints (HTTP verb) - HTTPメソッドで制約する

`/photos/show`かつGETメソッドに限定する

    match 'photos/show' => 'photos#show', :via => :get

    # 短縮形
    get 'photos/show'
    
複数のメソッドを付けられる

    match 'photos/show' => 'photos#show', :via => [:get, :post]


### constraints (parameter) - パラメータに制約する

これは、

    match 'photos/:id' => 'photos#show', :constraints => { :id => /[A-Z]\d{5}/ }

    # これも同じ
    match 'photos/:id' => 'photos#show', :id => /[A-Z]\d{5}/ 

`/photos/A12345`のようなパスにマッチする。

制約は正規表現を受け取るが、`^ $ \b \B`は使えない。でも先頭に固定されているので使う必要がない。

### constraints (request) - リクエストで制約をする 

[ActionDispatch::Request]オブジェクトのメソッドで制約がかけられる。

    match "photos", :constraints => {:subdomain => "admin"}

    # ブロックを与えることもできる
    namespace "admin" do
      constraints :subdomain => "admin" do
        resources :photos
      end
    end

### Advanced Constraints - 制約クラス

    match "*path" => "blacklist#index", :constraints => BlacklistConstraint.new
    
    class BlacklistConstraint
      def matches?(request)
        # マッチするならtrue 
      end
    end

### glob

これは、

    match 'photos/*other' => 'photos#unknown'

こうなる。

    # GET /photos/12               :other => "12"
    # GET /photos/long/path/to/12, :other => "long/path/to/12".


これは、

    match 'books/*section/:title' => 'books#show'

こうなる。

    # GET /books/some/section/last-words-a-memoir
    # {:section => "some/section", :title => "last-words-a-memoir"}


### redirection

301 “Moved Permanently” redirectになります。

    match "/stories" => redirect("/posts")
    
    # 値を引き継ぐ場合
    match "/stories/:name" => redirect("/posts/%{name}")

    # ブロックでもいいよ
    match "/stories/:name" => redirect {|params| "/posts/#{params[:name].pluralize}" }
    match "/stories" => redirect {|p, req| "/posts/#{req.subdomain}" }

### Rack

TODO 

    match "/application.js" => Sprockets

### root

    # GET /   => PagesController, 'main' action
    root :to => 'pages#main'

## Customized Resource

TODO

## こんなこともできました

### resourcesでmatchを使う

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

$ rake routes

    category_user        /users/:id/category/:category(.:format)             users#show
    category_user_images /users/:user_id/images/category/:category(.:format) images#index



## 参考

- <http://d.hatena.ne.jp/willnet/20100424/1272119369>
- <http://guides.rubyonrails.org/routing.html>
- [http://wiki.usagee.co.jp/ruby/rails/RailsGuides...](<http://wiki.usagee.co.jp/ruby/rails/RailsGuides%E3%82%92%E3%82%86%E3%81%A3%E3%81%8F%E3%82%8A%E5%92%8C%E8%A8%B3%E3%81%97%E3%81%A6%E3%81%BF%E3%81%9F%E3%82%88/Rails%20Routing%20from%20the%20Outside%20In>)

[REST]: http://ja.wikipedia.org/wiki/REST
[公式のガイド]: http://guides.rubyonrails.org/routing.html
[ActionDispatch::Request]: http://api.rubyonrails.org/classes/ActionDispatch/Request.html
