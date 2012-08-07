module Jekyll
  class TagIndexIndex < Page
    def initialize(site, base, dir)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'
      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'tag_index_index.html')
      self.data['title'] = 'Tags'
    end
  end
  class TagIndex < Page
    def initialize(site, base, dir, tag)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'
      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'tag_index.html')
      self.data['tag'] = tag
      # tag_title_prefix = site.config['tag_title_prefix'] || 'Posts Tagged &ldquo;'
      # tag_title_suffix = site.config['tag_title_suffix'] || '&rdquo;'
      # self.data['title'] = "#{tag_title_prefix}#{tag}#{tag_title_suffix}"
      self.data['title'] = tag
    end
  end
  class TagGenerator < Generator
    safe true
    def generate(site)
      if site.layouts.key? 'tag_index'
        dir = site.config['tag_dir'] || 'tag'
        site.tags.keys.each do |tag|
          write_tag_index(site, File.join(dir, tag), tag)
        end
        # write index of tag_index
        index = TagIndexIndex.new(site, site.source, dir)
        index.render(site.layouts, site.site_payload)
        index.write(site.dest)
        site.pages << index
      end
    end
    def write_tag_index(site, dir, tag)
      index = TagIndex.new(site, site.source, dir, tag)
      index.render(site.layouts, site.site_payload)
      index.write(site.dest)
      site.pages << index
    end
  end
end
