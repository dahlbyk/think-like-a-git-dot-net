module SiteHelper
  def include_page(title)
    page = @pages.find( :title => title )
    render(page)
  end

  def clearer(content = nil)
    tag :div, content, :class => 'clear'
  end

  def sitemap
    @sitemap ||= Sitemap.from_file('lib/sitemap.txt')
  end

  def nav_list(options = {})
    options.merge!({
      :current_section => @page.title.dasherize,
      :link_path_template => @page.nav_list_links || '/sections/%s.html',
    })
    sitemap.nav_list(options)
  end

  def section_path(section_title)
    path = sitemap.section_path(section_title)
    if @page.epic
      '#%s' % path
    else
      '/sections/%s.html' % path
    end
  end

  def section_link(*args)
    html_options = args.extract_options!
    section_name, text = *args
    text ||= section_name
    html_options = html_options.merge( :href => section_path(section_name) )
    tag(:a, text, html_options)
  end

  def prev_section_link(text = nil, html_options = {})
    prev_section, _ = sitemap.prev_and_next(@page.title)
    return unless prev_section
    text ||= prev_section
    href = section_path(prev_section)
    html_options = html_options.merge(:href => href)
    tag(:a, text, html_options) + tag(:link, :rel => 'prev', :href => href)
  end
  def next_section_link(text = nil, html_options = {})
    _, next_section = sitemap.prev_and_next(@page.title)
    return unless next_section
    text ||= next_section
    href = section_path(next_section)
    html_options = html_options.merge(:href => href)
    tag(:a, text, html_options) + tag(:link, :rel => 'next', :href => href)
  end

  def linear_nav_links
    prev_section, next_section = sitemap.prev_and_next(@page.title)
    clearer + tag(:div, :class => 'linear_nav_links') {
      ''.tap { |s|
        s << prev_section_link('&larr; ' + prev_section, :class => 'prev') if prev_section
        s << next_section_link(next_section + ' &rarr;', :class => 'next') if next_section
      }
    }
  end

  def todo(message)
    puts '*' * 80
    puts '*' * 80
    puts '** ' + message
    puts '*' * 80
    puts '*' * 80
  end

  def twitter_user(handle)
    tag :a, '@' + handle.to_s, :href => "https://twitter.com/#!/#{handle}"
  end
end

Webby::Helpers.register(SiteHelper)
