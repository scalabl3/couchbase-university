module DocsHelper
	def nav_hierarchy
    r = RenderNavTree.tree_with_expanded_path(@doc_key, nil)
    r.html_safe
  end    
end
