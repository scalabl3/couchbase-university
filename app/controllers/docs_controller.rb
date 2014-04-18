class DocsController < ApplicationController
	include AuthenticationHelper
	include DocsHelper
  before_filter :set_cache_buster, :check_session
  skip_before_filter :verify_authenticity_token

  def set_cache_buster
    #response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    #response.headers["Pragma"] = "no-cache"
    #response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
    
  def test123
    @doc_key = "home"
    @nav_tree = DocsNavTree.tree
  end

  def article
				
    @doc_key = params[:document_id]    

		t1 = Time.now.to_f
    @doc = Cbdoc.new({ doc_key: @doc_key, force_rerender: false})    
    t2 = Time.now.to_f

    unless @doc.exists?
      render json: { error: "Document Not Found - [#{@doc_key}]", item: CBD.get(@doc_key) }
    end
		Rails.logger.debug "DocsController::article - ProcessingTime #{t2-t1}"
  end
  
  def article_images
		k = "#{params[:node_id]}/#{params[:asset_id]}"
		d = CBD.get(k)
		if d.nil?
			Rails.logger.info "ArticleImage Missing: #{k}"
			send_data nil
		else
			d = Map.new(d)
			Rails.logger.info "BinaryData Missing: #{k}" unless d.binary?
			send_data ::Base64.decode64(d.binary), type: "#{d.subtype}/#{d.format}", disposition: 'inline'
		end
    #render json: { asset: params[:asset_id], article_id: params[:node_id] }
  end
  
  def cache_nav_and_render
    # ddocs = CBU.design_docs["cache"]
    #     
    #     ddocs.nav.each do |r|
    #       CBU.delete(r.id)
    #     end
    #     
    #     docs_list = DocsNavTree.flat.list
    #     cache_list = []
    #     
    #     list_start = 0
    #     list_end = 0
    #     
    #     docs_list.each_with_index do |n, i|
    #       
    #       cache_list << Map.new(n)
    #       
    #       if (i > 0 and (i + 1) % 20 == 0)
    #         list_end = i
    #         list_range = (list_start..list_end) 
    #         CacheAll.perform_async(cache_list, list_range, docs_list.size, 60 * 60, (1...24))
    #         list_start = i+1
    #         cache_list = []     
    #       end
    #       
    #       if (i == docs_list.size - 1)
    #         list_end = i
    #         list_range = (list_start..list_end) 
    #         CacheAll.perform_async(cache_list, list_range, docs_list.size, 60 * 60, (1...24))
    #         cache_list = []
    #       end
    #     end
    #     
    #     
    #     
    render :text => 'Initiated Caching...'
  end
	
end