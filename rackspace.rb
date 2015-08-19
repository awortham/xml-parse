class Rackspace
  def self.service
    service = Fog::Storage.new({
      provider:           'rackspace',
      rackspace_username: "buzztown",
      rackspace_api_key:  "54461b34f1acbfc75b888b5f5c53ae85",
      rackspace_region:   :dfw,
    })
  end

  def self.dir
    service.directories.get 'KML_images', public: true
  end
end

# dir = service.directories.get 'KML_images', public: true
# file = dir.files.create key: File.basename('./Smelter_summit_hike_copy.jpg'), body: File.open('./Smelter_summit_hike_copy.jpg')

# files_to_upload.each do |path|
#   file = dir.files.create key: File.basename(path), body: File.open(path, 'r')
#   puts "public URL for #{file} is #{file.public_url}"
# end
