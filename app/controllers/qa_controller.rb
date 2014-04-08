class QaController < ApplicationController

  def index
		@q_arr = Question::get_unanswered
		@q_arr.each do |q|			
			
			puts q.class.to_s			
			ap q
			5.times { puts }
		end
		puts @q_arr.first.keys
		#ap @q		
  end

  def question		
		puts params.inspect
	  @q = Question::retrieve_by_id(params[:question])		
  end

	def new
		
	end
	
	def by_tag
		q = {
			tags: params[:tags],
			complete_list: true,
			total_count: 3,
			result_count: 3,
			questions: [
				{ 
					q: "Are wild cards like * and % supported in view queries?",
					a: "Not exactly, no, but in many cases using a range query with partial text in the startkey can substitute for many wildcard necessities, but not all of them. For instance to get all the keys that start with \"user::\" you can do startkey=\"user\" and endkey=\"user\uefff\". You cannot do things like startkey=\"u%er\" which would match indexed key's of \"user\" and \"uzer\"."
				},
				{ 
					q: "How could model a graph with views?",
					a: "This is a bit involved to answer because it's a very open ended question in terms of defining what your \"graph\" actually is and how you will be querying it. If you are doing it \"Twitter style\" it's not actually a graph but a list of followers and people you follow. While technically it's a graph of limited depth, it's more like two lists. If you are querying the graph based on the relationship attributes between nodes, this can be very complex very quickly. If you are also querying for many levels of depth (or degrees of separation) this can also be quite complicated. Graph databases are specifically designed in their data structures for traversing and querying graph structures. However, they are not as good as general purpose data stores, so it's a good idea to do a polyglot combination of Couchbase and them (I have used Couchbase and Neo4J together very nicely)."
				},
				{ 
					q: "Are there options to change the default order of collation?",
					a: "Not out of the box, I am sure there is a way to modify and build that from source. You are welcome to post on the Couchbase google group if this is important to you. Unicode collation is far more favorable than byte-order."
				}
			]
		}
		render json: q.to_json
	end
end
