module TrainingHelper
	def get_training
		dd = CBU.design_docs["content"]
		
		training = []
		dd.training.each do |r|
			training << Map.new(CBU.get(r.id))
		end
		
		return training
	end
	
	def build_nav
		html = ""
		v = get_training
		v.each do |t|
			html += "<li>"
			html += "<a href=\"#{t.link}\">"
			html += "<div class=\"pull-left\" style=\"line-height: 3em;margin-right: 5px;\">"
			if t.platform == "server"
				html += "<i class=\"fa fa-desktop\" style=\"font-size: 16px\"></i>"
			else
				html += "<i class=\"fa fa-mobile\" style=\"font-size: 28px;margin-left: 2px;margin-right: 8px;\"></i>"
			end
			html += "</div>"
			html += "<div>"
			html += "<span style=\"font-size: 13px;font-weight: normal;\">"
			html += t.course + "<br />"
			html += "</span>"
			html += "<span style=\"font-size: 14px;\">"
			html += t.nav_title
			html += "</span>"
			html += "</div>"
			html += "</a>"
			html += "</li>"
		end
	 return html.html_safe
	end
end
