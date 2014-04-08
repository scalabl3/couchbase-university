class Question < ModelBase
	attr_accessor :q, :json, :markdown, :markdown_render, :votes, :answers
	
	def initialize(attr = {})
		load_parameter_attributes(attr)
	end
	
	def save
		
	end
	
	def add_answer(answer)
		
	end
	
	def self.retrieve_by_id(id)
		Map.new(CBU.get("q::#{id}"))
	end

	def self.get_unanswered
		
		q = []
		
		dd = CBU.design_docs["content"]
		dd.questions_unanswered.each do |r|
			doc = Map.new(CBU.get(r.id))
			unless doc.markdown_render?
				 doc.markdown_render = MarkdownRender::render_question(doc.q)
				 doc.stripped_render = ActionView::Base.full_sanitizer.sanitize(doc.markdown_render)
				 CBU.replace(r.id, doc)
			end
			q << doc
		end
		
		q
	end
end