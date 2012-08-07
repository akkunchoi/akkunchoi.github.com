require 'jekyll/site'

module JekyllExtend
  
  # Used to remove #related_posts so that it can be overridden
  def self.included(klass)
    klass.class_eval do
      remove_method :site_payload
    end
  end

  def site_payload
    tags = post_attr_hash('tags')
    tags = tags.sort {|(k1, v1), (k2, v2)| v2.size <=> v1.size }

    {"site" => self.config.merge({
        "time"       => self.time,
        "posts"      => self.posts.sort { |a, b| b <=> a },
        "pages"      => self.pages,
        "html_pages" => self.pages.reject { |page| !page.html? },
        "categories" => post_attr_hash('categories'),
        "tags"       => tags})}
  end
  module ClassMethods

  end
end

module Jekyll
  class Site
    include JekyllExtend
    extend JekyllExtend::ClassMethods 
  end
  class Post
    def filepath
      @base + '/' + @name
    end
    def last_commit_time
      # %ar, %aD, %ai
      @last_commit_time ||= `git log -1 --pretty=format:"%ai" #{self.filepath}`
    end
    # Convert this post into a Hash for use in Liquid templates.
    #
    # Returns <Hash>
    def to_liquid
      self.data.deep_merge({
        "last_commit_time"  => self.last_commit_time,
        "title"      => self.data["title"] || self.slug.split('-').select {|w| w.capitalize! || w }.join(' '),
        "url"        => self.url,
        "date"       => self.date,
        "id"         => self.id,
        "categories" => self.categories,
        "next"       => self.next,
        "previous"   => self.previous,
        "tags"       => self.tags,
        "content"    => self.content })
    end
  end
end


