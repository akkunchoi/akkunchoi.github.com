---
layout: posts
title: Rails3 routes.rb まとめ
tags: ruby rails
---

* toc
{:toc}

## Basics

ルーティングとはURLとコントローラー、アクションとのマッピング。
Railsでは`config/routes.rb`にDSLで記述する。
Rails2とRails3ではかなり書き方が変わっている。

`resources`を上手く使うのがコツのようだ。
`resources`を使うとリソース（って何なんだという話だけど）のCRUD（Create, Read, Update, Delete）を行うルーティングが生成される。これを使うと一貫性があり、記述量を減らすことができる。

[公式のガイド](http://guides.rubyonrails.org/routing.html)に沿って、まずは最もシンプルな例を試してみる。

    # -- config/routes.rb

    match "/patients/:id" => "patients#show"

この一行で**/patients/17 に HTTP GET すると、PatientsController の show アクションが呼ばれる**という設定になる。

また、ビューで`patient_path(patient_id)`するとURL生成のヘルパーが使用できる(named_helperと言うらしい)
_path ではなく _url にすると、host, port, path_prefix が付いたURLが生成できる。

`rake routes`を実行すると、ルーティングの設定が確認できる。
named_helperを`rails console`で試す場合は`app.users_path`で呼び出すことができる。

以上で基本終わり。以降設定の詳細を見ていく。

TODO named_helper生成の仕組み
    
## Resources

    #
    # HTTP Verb  Path             action  named_helper 
    # ---------  -----            ------  ----------
    # GET        /photos          index   photos_path 
    # GET        /photos/new      new     new_photo_path
    # POST       /photos          crete   photos_path
    # GET        /photos/:id      show    photo_path(:id)
    # GET        /photos/:id/edit edit    edit_photo_path(:id)
    # PUT        /photos/:id      update  photo_path(:id)
    # DELETE     /photos/:id      destroy photo_path(:id)

    resources :photos

### Namespace

namespaceはpathとcontrollerに付けられるprefix

    # HTTP Verb  Path               action  named_helper 
    # ---------  -----              ------  ----------
    # GET        /admin/photos      index   admin_photos_path 
    # GET        /admin/photos/new  new     new_admin_photo_path
    #   省略...
    # 

    namespace :admin do
      resources :photos
    end

### Scope (Controller)

controllerのみprefix

    # HTTP Verb  Path         action  named_helper 
    # ---------  -----        ------  ----------
    # GET        /photos      index   photos_path 
    # GET        /photos/new  new     new_photo_path
    #   省略...
    # 

    scope :module => "admin" do
      resources :photos
    end

または

    resources :photos, :module => "admin"

### Scope (Path)

pathのみprefixを付ける場合場合

    # HTTP Verb  Path               action  named_helper 
    # ---------  -----              ------  ----------
    # GET        /admin/photos      index   photos_path 
    # GET        /admin/photos/new  new     new_photo_path
    #   省略...
    # 

    scope "/admin" do    
      resources :photos
    end

または

    resources :photos, :path => '/admin/photos'
   
`:path`を使えば自由にパスを変更できる

    # GET  /hoge

    resources :photos, :path => 'hoge' 

### Nested Resources

    resources :photos do
      resources :comments
    end 

TODO

### member

    # GET /photos/:id/preview
    
    resources :photos do
      member do
        get 'preview'
      end
    end

    ... or

    resources :photos do
      get 'preview', :on => :member
    end

### collection

    # GET /photos/search

    resources :photos do
      collection do
        get 'search'
      end
    end
    
    ... or
    
    resources :photos do
      get 'search', :on => :collection
    end

## Non-Resourceful

### dynamic

    match ':controller(/:action(/:id))'

    # GET /photos/show/1/2
    # { :controller => “photos”, :action => “show”, :id => “1”, :user_id => “2” }
    match ':controller/:action/:id/:user_id'

    match ':controller(/:action(/:id))', :controller => /admin\/[^\/]+/

### static

    # GET /photos/show/1/with_user/2
    # { :controller => “photos”, :action => “show”, :id => “1”, :user_id => “2” }
    match ':controller/:action/:id/with_user/:user_id'

### defaults

    # GET /photos/1
    # { :controller => "photos", :action => "show", :id => "1", :format => "jpg"
    match 'photos/:id' => 'photos#show', :defaults => { :format => 'jpg' }

### named

    # logout_path, logout_url
    match 'exit' => 'sessions#destroy', :as => :logout

TODO

- :via
- :constraints
- :subdomain
- Advanced Constraints

### glob

    # GET /photos/12               :other => "12"
    # GET /photos/long/path/to/12, :other => "long/path/to/12".
    match 'photos/*other' => 'photos#unknown'

### redirection

TODO

### root

TODO

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
- <http://guides.rubyonrails.org/routing.html>

