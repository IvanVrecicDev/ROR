module ChargifyEntity
  extend ActiveSupport::Concern

  def load_from_chargify_source chargify_object
    # prepare colums: leave only chargify columns
    columns = self.class.column_names - self.class.custom_columns
    attributes = chargify_object.attributes.extract!(*columns).merge({chargify_id: chargify_object.id})
    self.assign_attributes attributes
  end

  def update_from_chargify_source chargify_object, &block
    # update and save object
    self.load_from_chargify_source chargify_object
    yield(self) if block_given?
    self.save
    self
  end

  module ClassMethods
    def create_from_chargify_source chargify_object, &block
      resource = self.new
      # convert chargify object to fr object
      resource.load_from_chargify_source chargify_object
      yield(resource) if block_given?
      resource.save
      resource
    end
	
    def custom_columns
      ['id']
    end
  end
end
