require 'active_support/core_ext/hash'
require 'open-uri'
require './rackspace'

include Magick

class ParseXml
  attr_accessor :file, :final_urls, :file_name

  def initialize(file, original_file_name)
    @original_file_name = original_file_name
    @file               = file
    @final_urls         = []
    @file_name          = ''
  end

  def parse_file
    Nokogiri::XML(File.open(file))
  end

  def gather_urls
    parse_file.to_s.scan(/\bhttps?:[^)''"]+\.(?:jpg|jpeg|gif|png)/)
  end

  def gather_placemarks
    hashum['kml']['Document']['Placemark'].map do |place|
      if place.include?('name') && place.include?('description')
        place['name'].gsub!(/\s/,'_').downcase
      end
    end.compact
  end

  def hashum
    Hash.from_xml(parse_file.to_xml)
  end

  def copy_file_and_reset_variable
    FileUtils.copy_file(file, @original_file_name)
    @file = "./#{@original_file_name }"
  end

  def do_work_son
    copy_file_and_reset_variable

    gather_urls.each_with_index do |url, index|
      assign_file_name(index, url)
      upload_to_rackspace(open(url))
      rewrite_file(url)
    end
  end

  def assign_file_name(index, url)
    @file_name = "#{file[0...-4]}_#{gather_placemarks[index]}#{index}#{url.dup[-4..-1]}"
  end

  def process_temp(temp)
    if temp.class == StringIO
      image_list  = Magick::ImageList.new
      img         = image_list.from_blob(temp.read).first
      temp        = img.to_blob
    end
    temp
  end

  def upload_to_rackspace(temp)
    temp = process_temp(temp)

    rackspace_image = Rackspace.dir.files.create key: File.basename(file_name), body: temp

    p "Successfully Uploaded image to Rackspace"
    final_urls << rackspace_image.public_url
  end

  def rewrite_file(url)
    File.write(file, File.read(file).gsub(/#{url}/, final_urls.last))
  end
end
