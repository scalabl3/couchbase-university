#
#
#
class DocsNavTree 
  
  class << self; attr_accessor :by_level, :by_link, :flat, :hierarchy, :links_only end  
  @@by_level = nil
	@@by_link = nil
	@@flat = nil
	@@hierarchy = nil
	@@links_only = nil
  
  def self.by_level
    self.generate if @@by_level.nil?
    #x = Marshal.load (Marshal.dump(@@by_level))
		@@by_level
  end

	def self.by_link
    self.generate if @@by_link.nil?
    #x = Marshal.load (Marshal.dump(@@by_link))
		@@by_link
  end

  def self.flat
    self.generate if @@flat.nil?
    #x = Marshal.load (Marshal.dump(@@flat))
		@@flat
  end

  def self.hierarchy
    self.generate if @@hierarchy.nil?
    #x = Marshal.load (Marshal.dump(@@hierarchy))
		@@hierarchy
  end

  def self.links_only
    self.generate if @@links_only.nil?
    #x = Marshal.load (Marshal.dump(@@links_only))
		@@links_only
  end
    
  def self.generate
    
    Rails.logger.info "DocsNavTree::generate - Retrieving and storing docs navigation hierarchies and references" if defined?(Rails) and Rails.logger

		@@by_level = Map.new    
		@@by_link = Map.new
		@@hierarchy = Map.new(CBU.get("docs-nav-tree"))
    @@flat = Map.new(CBU.get("docs-nav-tree-flat"))
		@@links_only = []

    ddoc = CBD.design_docs["docs"]
		
		ddoc.nav.each do |r|
			begin		  
		    d = Map.new(CBD.get(r.id))		    
		    @@by_level[d.subtype] ||= []
		    @@by_level[d.subtype] << d
		    @@by_link[d.link] = {}
		    @@by_link[d.link] = d
				@@links_only << d.link				
			rescue
				puts r.id
		    #puts d.full_link
			end
		end
    
		@@by_level.freeze
		@@by_link.freeze
		@@hierarchy.freeze
    @@flat.freeze
		@@links_only.freeze
		
    #puts "===========>> NAV TREE"
    #ap @@tree
    #puts "<<=========== NAV TREE"
    
  end
  
    
  def self.to_json(active_link)
    @@hierarchy.to_json
  end
    
end
