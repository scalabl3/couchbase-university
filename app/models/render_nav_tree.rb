require 'digest/md5'
  
class RenderNavTree
  
  class << self; attr_reader :list, :html end  
  
  @@list = nil
  @@html = nil
  
  def self.list
    self.generate if @@list.nil? or @@html.nil?
    @@list
  end
  
  def self.html
    #self.generate if @@list.nil? or @@html.nil?
    #@@html
  end
  
  def self.generate
    Rails.logger.info "RenderNavTree - init -- Retrieving and storing flattened docs navigation html" if defined?(Rails) and Rails.logger
    self.generate_list
    #self.generate_html
  end
  
  def self.generate_list
    @@list = []    
    tree = Map.new(CBU.get("docs-nav-tree-flat"))
    
    tree.list.each_with_index do |n, i|
      n.full_nav_order = i
      @@list << n.dup
      #puts "[#{n.full_nav_order}][#{n.nav_level}][#{n.nav_order}] - [#{n.link}]"      
    end
    @@list.freeze
  end
  
  def self.generate_html(current_node_link = nil)        
	
		# generate full flat navigation list if it hasn't been generated yet
    self.generate_list if @@list.nil? 

    html = ""
    
		# deep copy the list
    list = Marshal.load(Marshal.dump(@@list))
    
    Rails.logger.error "ERROR 1" if list.object_id == @@list.object_id if defined?(Rails) and Rails.logger
    
    if (current_node_link)
      deep = list.find_index { |n| n.link == current_node_link && (n.nav_type == "folder+markdown" || n.nav_type == "markdown")}
      #puts "[#{deep}] - #{current_node_link}"      
      
      if deep 
        
        Rails.logger.error "ERROR 2" if list[deep].object_id == @@list[deep].object_id if defined?(Rails) and Rails.logger
        
        # set this element to active
        list[deep].nav_active = true
      
        top = deep
      
        while list[top].nav_level > 1
          top = list.find_index { |n| n.link == list[top].parent_link }
        
          # set parent element to active
          list[top].nav_active = true
        
          #puts "[#{top}] - #{list[top].link}"
        end
        
      end
    end
     
    ancestors = []
    
    list.each_with_index do |n, i|
      
      next_node = list[i+1] if i < list.size
      last_node = list[i-1] if i > 0
      
      open_subnav = (next_node and next_node.parent_link == n.link)
      close_all_subnav = (ancestors.size > 0 and next_node and next_node.parent_link.empty?)
      close_partial_subnav = (ancestors.size > 0 and next_node and ancestors.last.link != next_node.parent_link)
      final_close_subnav = (next_node.nil? and ancestors.size > 0)
      
      # #{(n.link == selected_node.link ? " docs-nav-active" : "")}
      
      css_li = "docs-#{n.nav_type} docs-nav docs-nav-li docs-nav-#{n.nav_level.to_s}"
      css_li += " active" if n.nav_active? and n.nav_active 
      #css_li += " hidden" if n.nav_level > 1
      
      
      
      html += "<li id=\"nav-item-#{n.full_nav_order}\""
      #html += "a=\"#{ancestors.size}\" l=\"#{n.link}\" p=\"#{n.parent_link}\""
      html += "class=\"#{css_li}\""
      html += ">"
      
      # only used if this li element will toggle a subnav
      toggle_id = "subnav-#{n.full_nav_order}"
      this_nav_active = toggle_id if open_subnav
      
      
      #n.nav_title = "[#{ancestors.size}] " + n.nav_title
      html += self.render_a(n, this_nav_active)
      
      # if the next node is a descendant, open a <ul>
      if open_subnav
        ancestors.push(n)
        
        css_ul = "nav docs-subnav collapse"
        css_ul += " in active" if n.nav_active? and n.nav_active
        
        html += "<ul id=\"#{toggle_id}\""
        #html += " p=\"#{n.link}\""
        html += " class=\"#{css_ul}\">"
        
      # close all open unordered lists if the next_node has no parent
      elsif close_all_subnav
        ancestors.size.downto(1) do
          html += "</ul>"          
        end
        ancestors = []
      # close some unordered lists if the next_node up to where recent ancestor doesn't match parent
      elsif close_partial_subnav
          while ancestors.last.link != next_node.parent_link
            html += "</ul>"
            ancestors.pop
          end
      # close any remaining unordered lists if they are still open and we are done
      elsif final_close_subnav
        ancestors.size.downto(1) do
          html += "</ul>"          
        end
        ancestors = []
      end
      
      
      html += "</li>"
      
    end
    
    
    #end with a blank
    n = Map.new({
      full_link: "",
      nav_level: 0,
      nav_title: " ",
      nav_type: "none"
    })
    css_li = "docs-#{n.nav_type} docs-nav docs-nav-li docs-nav-#{n.nav_level.to_s}"
    html += "<li class=\"#{css_li}\">"
    html += self.render_a(n)    
    html += "</li>"
    html += "<li class=\"#{css_li}\">"
    html += self.render_a(n)    
    html += "</li>"
    
    # save this as full structure (can be used to pull down json representation without nav_active classes, etc)
    if current_node_link.nil?
      #@@html = html 
      Rails.logger.info "... saving @@html [#{current_node_link}]" if defined?(Rails) and Rails.logger
    end
    
    #File.open("/Users/jasdeep/Desktop/test.html", 'w') { |file| file.write(html) }
    #pp html
    return html
  end
  
  def self.render_a(node, toggle_id = nil)
    html = ""
    
    css_a = "docs-nav docs-nav-a docs-nav-#{node.nav_level.to_s}"
    href_a = node.full_link
    ihtml_a = ""
    
    css_span = "docs-nav docs-nav-span"
    
    css_i = "fa"
    
    if node.nav_type == "folder" and node.nav_level == 1
      css_i += " fa-book"
    elsif node.nav_type == "folder" and node.nav_active? and node.nav_active
      css_i += " fa-folder-o"
    elsif node.nav_type == "folder" and node.nav_level > 1
      css_i += " fa-folder"
		elsif node.nav_type == "folder+markdown"
			css_i += " fa-folder"
    elsif node.nav_type == "markdown" 
      css_i += " fa-file-text-o"
    else
      css_i = ""
    end
    
    ihtml_a += self.render_i(css_i)
    ihtml_a += render_span(node.nav_title, css_span)
    
    html += "<a class=\"#{css_a}\""
    html += " href=\"#{href_a}\"" if node.nav_type != "folder"
    html += " data-toggle=\"collapse\" data-target=\"##{toggle_id}\"" if toggle_id
    html += ">"
    html += ihtml_a
    html += "</a>"
    
    return html
  end  
    
  def self.render_i(css = "")
    html = ""
    html += "<i class=\"#{css}\">"
    html += "</i>"
  end
  
  def self.render_span(inner, css = nil)
    html = ""
    html += "<span#{ (css ? " class=\"#{css}\"" : '') }>"    
    html += inner
    html += "</span>"
  end
  
  def self.tree_with_expanded_path(node_link, cache_conn, ttl = 60 * 60 * 24)
    
		t1 = Time.now.to_f
		cached_nav = nil
		
		if !cache_conn.nil?			
    	cached_nav = cache_conn.get("navcache::#{node_link}")
		else
			cached_nav = CBU.get("navcache::#{node_link}", :ttl => ttl)
		end

    if cached_nav.nil?
      Rails.logger.debug "RenderNavTree::tree_with_expanded_path - Creating navcache::#{node_link}" if defined?(Rails) and Rails.logger
      cached_nav = self.generate_html(node_link)
			if cache_conn
      	cache_conn.add("navcache::#{node_link}", cached_nav, :ttl => ttl) unless node_link.nil? || node_link.empty?
			else
				CBU.set("navcache::#{node_link}", cached_nav, :ttl => ttl) unless node_link.nil? || node_link.empty?
			end
		else
			Rails.logger.debug "RenderNavTree::tree_with_expanded_path - Retrieved Cache [navcache::#{node_link}]" if defined?(Rails) and Rails.logger
    end
  
		t9 = Time.now.to_f
		Rails.logger.debug "RenderNavTree::tree_with_expanded_path - Render Time #{t9-t1}" if defined?(Rails) and Rails.logger
    return cached_nav
    
  end
  
  
end