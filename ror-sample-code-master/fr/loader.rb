# require 'pandoc-ruby'
require 'fileutils'
class UserDocument::Loader < UserDocument

  # avaliable document formats
  FORMATS = [:pdf, :docx, :doc, :html]

  FORMATS.each do |f|
    define_method(:"to_#{f}") do
      load(f)
    end
  end

  def load format
    unless FORMATS.include?format.to_sym
      self.errors.add(:base, 'Invalid file format')
      return {file: false, generation: false}
    end

    generated_document = file_path(format)
    if File.exists?(generated_document) && File.mtime(generated_document) > self.entries_updated_at
      return { file: generated_document, generation: false }
    end
    # Start resque worker
    generation = Resque.enqueue(DocumentGenerator, self.id, format)
    { file: false, generation: generation }
  end


  def preview
    if !self.check_preview
      generation = Resque.enqueue(PreviewGenerator, self.id)
      return {
        success: true,
        document: {images: false, generation: generation, id: self.id, name: self.name}
      }
    else
      # read from cache
      images = $redis.lrange("#{self.id}:user_document:preview", 0, -1)
      if images.blank?
	# or read from file
        images = Dir.glob("#{directory_path}/preview-*.png").sort.map {|i| Base64.encode64(File.open(i, "rb").read)}
        $redis.rpush("#{self.id}:user_document:preview", images)
      end
      return {
        success: true,
        document: {images: images, generation: false, id: self.id, name: self.name}
      }
    end
    {success: false}
  end

  def check_preview
    File.exists?("#{directory_path}/preview-0.png") && File.mtime("#{directory_path}/preview-0.png") > self.entries_updated_at
  end

end
