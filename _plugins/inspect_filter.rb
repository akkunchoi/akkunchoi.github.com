module Jekyll
  module InspectFilter
    def asset_url(input)      
      input.inspect
    end
  end
end

Liquid::Template.register_filter(Jekyll::InspectFilter)
