require 'nokogiri'

class MarkdownRender
	
  def self.render(markdown, site_extras = true)
		rend = Redcarpet::Render::HTML
    rend = DOCHTML.new(:with_toc_data => true) if site_extras
    mdr = Redcarpet::Markdown.new(rend, :fenced_code_blocks => true, :tables => true, :lax_spacing => true)

		#t1 = Time.now.to_f
    html_content = mdr.render(markdown)
		#t2 = Time.now.to_f
		html_content = MarkdownRender::update_table_classes(html_content) if site_extras
		#t3 = Time.now.to_f 		
		html_content = MarkdownRender::update_image_classes(html_content) if site_extras
    #t3 = Time.now.to_f 		
    html_content = MarkdownRender::render_code_block_siblings(html_content) if site_extras
		#t4 = Time.now.to_f 
		#Rails.logger.info "MarkdownRender:: [#{(t3-t1).round(5)}] [#{(t2-t1).round(5)}] [#{(t3-t2).round(5)}]" if defined?(Rails) and Rails.logger
    return html_content
  end

	def self.render_question(markdown)
		rend = DOCHTML.new(:with_toc_data => true)
    mdr = Redcarpet::Markdown.new(rend, :fenced_code_blocks => true, :tables => true, :lax_spacing => true)

		html_content = mdr.render(markdown)
		
		return html_content		
	end
  
	def self.update_table_classes(html_content)
		#class="table table-condensed table-bordered table-striped"
		
		doc = Nokogiri::HTML(html_content)
    codes = doc.css "table"

		codes.each_with_index do |c, i|			
			c["class"] = "table table-condensed table-condensed-smalldevice table-bordered table-striped table-responsive" unless c["class"] == "gutterlines"
		end
		
		return doc.css('body')[0].serialize(save_with: 0)
	
	end
	
	
	def self.update_image_classes(html_content)
		#class="img-responsive"
		
		doc = Nokogiri::HTML(html_content)
    codes = doc.css "img"

		codes.each_with_index do |c, i|			
			c["class"] = "img-responsive"
		end
		
		return doc.css('body')[0].serialize(save_with: 0) 
		
	end
	
  def self.render_code_block_siblings(html_content)

    doc = Nokogiri::HTML(html_content)
    codes = doc.css "div.highlight"

    sibling_groups = []
    sg_index = 0
    sibling_count = 0

    codes.each_with_index do |c, i|
      sibling_groups[sg_index] ||= []
      #puts "#{i} < #{codes.size} - #{c.attributes["class"].value} ==> (#{c.next_sibling ? "true":"false"})"
      if (c.next_sibling && (codes[i+1] == c.next_sibling))
        sibling_groups[sg_index] << c if sibling_count == 0 
        sibling_groups[sg_index] << c.next_sibling 
        sibling_count += 1
      else
        # either next_sibling == nil
        # or next_sibling not attached to group
        # or next_sibling is a different element type
        # let's check if it's still attached to existing sibling group (previous_sibling), if so, add to group
        if c.previous_sibling == codes[i-i]
          sibling_groups[sg_index] << c
          sibling_count += 1
        # if we started a brand new sibling group (sibling_count is 0), add this to new array, incr count
        elsif sibling_count == 0
          sibling_groups[sg_index] ||= []      
          sibling_groups[sg_index] << c      
          sibling_count = 1
        # otherwise this element was added to a previous group (because sibling_count >= 1)
        # but next_sibling isn't attached, so reset the count and start a new group index
        # but don't create the sub-array in case it's last element
        else
          #puts "reset"
          sibling_count = 0
          sg_index += 1
        end    
      end
    end
    
    
    #p siblings.size
    # sibling_groups.each do |sg| 
    #       sg.each do |s|
    #         p s.attributes["class"].value
    #       end
    #     end
    
    
    sibling_groups.each_with_index do |sg, i|     

      if sg.size > 1
        c1 = '<ul class="nav nav-pills"></ul>'
        c2 = '<div class="tab-content"></div>'
        sg[0].add_previous_sibling(c1)
        tablist = sg[0].previous_sibling
        tablist.add_next_sibling(c2)
        tabs = tablist.next_sibling

        sg.each_with_index do |s, j|
          language = s.attributes["class"].value.split[1]
          #puts language
          np = Nokogiri::XML::Node.new "li", doc
          na = Nokogiri::XML::Node.new "a", doc
          na['href'] = "#tg#{i}-#{j}"
          na['data-toggle'] = "pill"
          na.content = "#{language.capitalize}"
          np['class'] = 'active' if j == 0
          na.parent = np
          np.parent = tablist

          nt = Nokogiri::XML::Node.new "div", doc
          nt['id'] = "tg#{i}-#{j}"
          nt['class'] = "tab-pane fade"
          nt['class'] = "tab-pane fade in active" if j == 0
          new_tab = tabs.add_child(nt)
          s.parent = new_tab
        end
      end
    end
    
    #doc.to_s #html(save_with:0)
    doc.css('body')[0].serialize(save_with: 0)
  end
  
  
end