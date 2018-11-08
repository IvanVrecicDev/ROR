require 'rails_helper'

RSpec.describe Table, :type => :model do

  let (:restaurant) {
    Restaurant.create(
      :title => "Some restaurant",
      :open_at => "10:00",
      :close_at => "20:00"
    )
  }

  subject {
    described_class.new(:restaurant => restaurant, :number => 1)
  }

  describe "Validations" do
    it "is valid with valid attributes" do
      expect(subject).to be_valid
    end

    it "is not valid without restaurant" do
      subject.restaurant = nil
      expect(subject).to_not be_valid
    end

    it "is not valid when table with number in restaurant exist" do
      Table.create(:restaurant => restaurant, :number => 1)
      expect(subject).to_not be_valid
    end

    it "is not valid without number" do
      subject.number = nil
      expect(subject).to_not be_valid
    end

  end

  describe "Associations" do
    it "belongs to restaurant" do
      assc = described_class.reflect_on_association(:restaurant)
      expect(assc.macro).to eq :belongs_to
    end

    it "has many reservations" do
      assc = described_class.reflect_on_association(:reservations)
      expect(assc.macro).to eq :has_many
    end
  end

end
