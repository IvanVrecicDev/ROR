class DocumentGenerator
  @queue = :document_queue

  def self.perform(id, format)
    Resque.logger.info "***Document Generation: started, id = #{id}, format = #{format}***"
    ActiveRecord::Base.clear_active_connections!
    self.run id, format, logger: Resque.logger
    result = SocketPusher.push('/document_channel', {title: 'download', message: {id: id, download: format}})
    Resque.logger.info "MSG sent: #{result}"
    Resque.logger.info "***Document Generation: finished***"
  end

  def self.run id, format, opts = {logger: false}
    resource = UserDocument.find(id)
    # parse md content with mustache
    data = UserDocument::Parser.parse(resource.document.content.path, resource.mustache_entries)
    # create file with pandoc
    PandocRuby.convert(data, :from => :markdown, :o => resource.file_path(format))
    opts[:logger].info "File converted: #{resource.file_path(format)}" if opts[:logger]
  end
end
