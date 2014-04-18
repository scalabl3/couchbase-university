#
#
#
class Cbdoc
  attr_reader :doc_render, :markdown_render, :breadcrumb, :doc_key, :cbd  
  attr_reader :nav_level, :nav_tree, :nav_parent, :nav_siblings, :nav_children
  attr_reader :exists
  
  def markdown_render
    (@cbd.markdown_render? and @cbd.markdown_render ? @cbd.markdown_render : nil)
  end
  
  
  alias_method :doc_render, :markdown_render
  
  def link
    (@cbd.link? ? @cbd.link : nil)
  end

  def markdown
    (@cbd.markdown? ? @cbd.markdown : nil)
  end
  
  def nav_title
    (@cbd.nav_title? ? @cbd.nav_title : nil)
  end
  
  def metadata
    (@cbd.metadata? ? @cbd.metadata : nil)
  end
  
  def exists?
    @exists
  end

	def breadcrumb?
		@cbd.breadcrumb?
	end
  
  def initialize(attrs)
    
    attrs = Map.new(attrs)

		# override Couchbase connection from Global to local (for background worker forks)
		@conn = nil
		@conn = attrs.conn if attrs.conn? and attrs.conn

    @breadcrumb = []
    @nav_children = []
    @nav_siblings = []
    @nav_tree = {}
    @markdown = ""
    @markdown_render = ""
    @nav_level = 0
    @exists = false    

    if attrs.doc_key?
      @doc_key = attrs.doc_key
      force_rerender = false
      force_rerender = true if attrs.force_rerender? and attrs.force_rerender

			t1 = Time.now.to_f
      if retrieve_doc
				t2 = Time.now.to_f
				Rails.logger.debug "Cbdoc::init - cbd 1 - #{t2-t1}"
        create_render(force_rerender)
				t3 = Time.now.to_f
				Rails.logger.debug "Cbdoc::init - cbd 2 - #{t3-t1} #{t3-t2}"
        create_breadcrumb
				t4 = Time.now.to_f
				Rails.logger.debug "Cbdoc::init - cbd 3 - #{t4-t1} #{t4-t3}"
      end
    end  

  end
  
  def retrieve_doc
		if @conn
			d = @conn.get(@doc_key)
		else 
    	d = CBD.get(@doc_key)
		end
		
    if d
      @cbd = Map.new(d)      
      @exists = true      
    else
      Rails.logger.error "Cbdoc::retrieve_doc - ERROR: Not Found #{@doc_key}"
			if @conn
				Rails.logger.info "@conn.connected? #{@conn.connected?}" 
				Rails.logger.info "@conn: #{@conn.inspect}" 
			else
				Rails.logger.info "@CBD.connected? #{CBD.connected?}" 
				Rails.logger.info "@CBD: #{CBD.inspect}" 				
			end
      nil
    end 
  end
  
  def create_render(force = false)
    if @cbd.markdown?
      #puts "CBD: Has markdown #{@doc_key}"
      
      if @cbd.markdown_render? and force == false
        Rails.logger.debug "Cbdoc::create_render - Has Markdown Render for #{@doc_key}"
      else
				Rails.logger.debug "Cbdoc::create_render - Creating Markdown Render for #{@doc_key}"
        @cbd.markdown_render = MarkdownRender::render(@cbd.markdown)
				if @conn
        	@conn.replace(@doc_key, @cbd)
				else
					CBD.replace(@doc_key, @cbd)
				end
      end
    else
      Rails.logger.error "Cbdoc::create_render - ERROR: No markdown #{@doc_key}"
      @markdown_render = nil
    end
  end
  
  def create_breadcrumb
	
		if @cbd.breadcrumb? and @cbd.breadcrumb
			@breadcrumb = @cbd.breadcrumb
		elsif false
    	@breadcrumb = []
    
	    #ap DocsNavTree.tree.by_link
    
	    root = Map.new({
	      name: "Docs",
	      link: "/d/",
	      dropdown: true,
	      dropdown_items: [],
	      final: false
	    })
      
	    DocsNavTree.by_level["nav_1"].each do |n|
	      item = Map.new({
	        name: n.nav_title,
	        link: n.full_link
	      })
	      root.dropdown_items << item
	    end
    
	    @breadcrumb << root
    
			puts "#{cbd.link} - #{@cbd.ancestors_links?}"
			
	    @cbd.ancestors_links.each_with_index do |al, i|

	      node = DocsNavTree.by_link[al]
      
	      parent = Map.new({
	        name: node.nav_title,
	        link: node.full_link,
	        dropdown: false,
	        dropdown_items: nil,
	        final: false
	      })
      
	      if node.nav_type == "folder"
	        parent.dropdown = true
	        parent.dropdown_items = []
        
	        node.descendants_links.each do |dl|
	          d = DocsNavTree.tree.by_link[dl]
          
	          item = Map.new({
	            name: d.nav_title,
	            link: d.full_link
	          })
          
	          parent.dropdown_items << item
	        end        
	      end 
      
	      @breadcrumb << parent

	    end
	    @breadcrumb << Map.new({name: @cbd.nav_title, link: nil, final: true, dropdown: false, dropdown_items: false })
			
			@cbd.breadcrumb = []
			@cbd.breadcrumb = @breadcrumb
			
			if @conn
	     	@conn.replace(@doc_key, @cbd)
			else
				CBD.replace(@doc_key, @cbd)
			end
		end
  end
  
  def child_links
    child_links = []

    @cbd.descendants_links.each do |dl|

      d = DocsNavTree.by_link[dl]      

      item = Map.new({
        name: d.nav_title,
        link: d.full_link
      })
      
      if d.metadata? and d.metadata.takeaway?
        item.takeaway = d.metadata.takeaway 
      end
      
      child_links << item
    end

    return child_links    
  end
    
end
