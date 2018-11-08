class Neighbourhood < ActiveRecord::Base

  belongs_to :city
  has_many :collectives, dependent: :destroy

  validates_presence_of :boundaries, :name

  def includes_point? point
    sql = "SELECT ST_Intersects('#{point}', '#{self.boundaries}')"
    cursor = ActiveRecord::Base.connection.execute(sql)
    ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.include?(cursor.first['st_intersects'])
  end

  def as_geojson
    self.class.as_geojson("id = #{self.id}")
  end

  class << self

    def as_geojson condition = true
      sql = "SELECT id, name, ST_AsGeoJSON(boundaries) FROM neighbourhoods where #{condition};"

      cursor = self.connection.execute(sql)
      features = cursor.map do |row|
        {
          "type": "Feature",
          "geometry": JSON.parse(row["st_asgeojson"]),
          "properties": {
            "id": row["id"],
            "name": row["name"]
          }
        }
      end
      { "type": "FeatureCollection", "features": features }
    end

    def find_by_point args
      cursor = self.where("ST_Intersects('POINT(? ?)', neighbourhoods.boundaries)", args[0], args[1])
      cursor.first
    end

    def find_by_address address
      location = Geocoder.search(address).first
      (result = self.find_by_point location.coordinates.reverse) if location.present? && GEOCODER_LOCATION_TYPES.include?(location.precision)
      result
    end

  end

end
