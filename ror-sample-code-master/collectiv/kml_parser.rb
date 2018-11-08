class KMLParser

  def self.parse file
    begin
      doc = read file
    rescue Exception => e
      raise "Can't read file. #{e.to_s}"
    end

    data = doc.search('Placemark').map do |placemark|
      boundary = placemark.search('coordinates').text.split.map{|row| row.split(',')[0..1].join(' ') }.join(',')
      {
        name: placemark.search("name").text,
        boundaries: "POLYGON((#{boundary}))"
      }
    end if doc
    data
  end

  def self.read file
    if file.present? && File.exist?(file)
      return File.open(file) { |f| Nokogiri::XML(f) }
    else
      raise "File #{file} doesn't exist."
    end
  end
end
