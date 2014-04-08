module VideosHelper
	def get_videos
		dd = CBU.design_docs["content"]
		
		videos = []
		dd.videos.each do |r|
			videos << Map.new(CBU.get(r.id))
		end
		
		return videos
	end
end
