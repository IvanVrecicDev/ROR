require 'rails_helper'

RSpec.describe Reservation, :type => :model do

  let (:restaurant) {
    Restaurant.create(
      :title => "Some restaurant",
      :open_at => "10:00",
      :close_at => "20:00"
    )
  }

  let (:table) {
    Table.create(:restaurant => restaurant, :number => 1)
  }

  subject {
    described_class.new(
      :table => table,
      :start_at => "18.07.2016 12:00",
      :end_at => "18.07.2016 13:00"
    )
  }

  describe "Validations" do
    it "is valid with valid attributes" do
      expect(subject).to be_valid
    end

    it "is not valid without table" do
      subject.table_id = nil
      expect(subject).to_not be_valid
    end

    it "is not valid without start_at" do
      subject.start_at = nil
      expect(subject).to_not be_valid
    end

    it "is not valid without end_at" do
      subject.end_at = nil
      expect(subject).to_not be_valid
    end

    it "is not valid with incorect date interval" do
      subject.start_at = "18.07.2016 12:00"
      subject.end_at = "18.07.2016 11:00"
      expect(subject).to_not be_valid
    end

    it "is valid when matching rest. time work when open_at<close_at" do
      subject.restaurant.open_at = "10:00"
      subject.restaurant.close_at = "20:00"
      subject.start_at = "18.07.2016 12:00"
      subject.end_at = "18.07.2016 20:00"
      expect(subject).to be_valid
    end

    it "is valid when matching rest. time work when open_at=close_at" do
      subject.restaurant.open_at = "00:00"
      subject.restaurant.close_at = "00:00"
      subject.start_at = "18.07.2016 12:00"
      subject.end_at = "21.07.2016 20:00"
      expect(subject).to be_valid
    end

    it "is valid when matching rest. time work when open_at>close_at" do
      subject.restaurant.open_at = "20:00"
      subject.restaurant.close_at = "10:00"
      subject.start_at = "18.07.2016 05:00"
      subject.end_at = "18.07.2016 07:00"
      expect(subject).to be_valid
    end

    it "is not valid when not matching rest. time work when open_at<close_at" do
      subject.restaurant.open_at = "10:00"
      subject.restaurant.close_at = "20:00"
      subject.start_at = "18.07.2016 01:00"
      subject.end_at = "18.07.2016 11:00"
      expect(subject).to_not be_valid
    end

    it "is not valid when not matching rest. time work when open_at>close_at" do
      subject.restaurant.open_at = "20:00"
      subject.restaurant.close_at = "10:00"
      subject.start_at = "18.07.2016 01:00"
      subject.end_at = "19.07.2016 11:00"
      expect(subject).to_not be_valid
    end

    it "is not valid when not matching rest. time work when open_at!=close_at and reservation>1day" do
      subject.restaurant.open_at = "20:00"
      subject.restaurant.close_at = "10:00"
      subject.start_at = "18.07.2016 21:00"
      subject.end_at = "21.07.2016 09:00"
      expect(subject).to_not be_valid
    end

    it "is not valid when overlaps another reservation: is in another" do
      another_reservation = Reservation.create(
        :table_id => subject.table_id,
        :start_at => "18.07.2016 12:00",
        :end_at => "18.07.2016 13:00"
      )

      subject.start_at = "18.07.2016 12:20"
      subject.end_at = "18.07.2016 13:00"
      expect(subject).to_not be_valid

    end

    it "is not valid when overlaps another reservation: full cover another" do
      another_reservation = Reservation.create(
        :table_id => subject.table_id,
        :start_at => "18.07.2016 12:00",
        :end_at => "18.07.2016 13:00"
      )

      subject.start_at = "18.07.2016 11:59"
      subject.end_at = "18.07.2016 13:10"
      expect(subject).to_not be_valid

    end

    it "is not valid when overlaps another reservation: intersects another" do
      another_reservation = Reservation.create(
        :table_id => subject.table_id,
        :start_at => "18.07.2016 12:00",
        :end_at => "18.07.2016 13:00"
      )

      subject.start_at = "18.07.2016 11:59"
      subject.end_at = "18.07.2016 12:10"
      expect(subject).to_not be_valid

    end

    it "is when not overlaps another reservation" do
      another_reservation = Reservation.create(
        :table_id => subject.table_id,
        :start_at => "18.07.2016 12:00",
        :end_at => "18.07.2016 13:00"
      )

      subject.start_at = "18.07.2016 11:59"
      subject.end_at = "18.07.2016 12:00"
      expect(subject).to be_valid

    end

  end

  describe "Associations" do
    it "belongs to table" do
      assc = described_class.reflect_on_association(:table)
      expect(assc.macro).to eq :belongs_to
    end

    it "has one restaurant" do
      assc = described_class.reflect_on_association(:restaurant)
      expect(assc.macro).to eq :has_one
    end
  end

end
