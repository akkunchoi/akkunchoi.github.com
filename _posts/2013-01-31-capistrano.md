---
layout: posts
title: capistrano
tags: ruby dev
---

暫定まとめ。

## Rails のデプロイ

RAILS_ENVを忘れたり、assets:precompileを忘れたりして無駄に時間を使ってしまうことが多いので、capistranoを使うようにしました。
大げさかなと思ってあまり積極的ではなかったですが、セットアップも簡単で、1コマンドで本番リリースできるので導入して良かったです。

以下導入手順です。

まずはGemに追加し、インストールする。

<pre><code data-language="ruby"># Gemfile
group :development do
  gem 'capistrano'
  gem 'capistrano-ext'
  gem 'capistrano_colors'
end      
</code></pre>

初期化を実行。Capfileが作成される。

    $ bundle exec capify .


Capfileを編集する。
<pre><code data-language="ruby"># Capfile
# assets pipelineを使う場合はコメントを外す
load 'deploy/assets'
</code></pre>

よく config.assets.precompile にファイルを追加するのを忘れて泣く。。

config/deploy.rbを作成する。

<pre><code data-language="ruby"># config/deploy.rb
require "bundler/capistrano"

set :application, "sample"
set :repository,  "myuser@example.com:sample.git"
set :scm, :git
set :branch, :master

set :git_enable_submodules, 1

role :web, "example.com"                          # Your HTTP server, Apache/etc
role :app, "example.com"                          # This may be the same as your `Web` server
role :db,  "example.com", :primary => true # This is where Rails migrations will run

set :user, 'myuser'
set :use_sudo, false

set :rails_env, 'production'
set :deploy_to, "/var/www/#{application}"

def restart_file
  File.join(current_path, 'tmp', 'restart.txt')
end

namespace :deploy do
  task :restart, :roles => :app do
    run "touch #{restart_file}"
  end
end

after "deploy:update_code", :role => [:app] do
  run "cp #{release_path}/config/database.yml.sample #{release_path}/config/database.yml"
end

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"
</code></pre>

初期化してディレクトリを作成する。

    $ cap deploy:setup
    
deploy:cold すると、db:migrate が実行される。

    $ cap deploy:cold

普段のデプロイはこっちでいい。coldとの違いはよくわかっていない。

    $ cap deploy

データベースファイルの設定が違う場合はどうなるんだろう？？


デプロイ先のディレクトリはこんな感じになります。

    /
    |-- current/  => 特定のreleaseにシンボリックリンク
    |-- releases/
    |     |-- 20130130160241/
    |     |-- 20130123040226/
    |     `-- ....
    `--shared/
          |-- assets
          |-- bundle
          |-- log
          |-- pids
          `-- system





