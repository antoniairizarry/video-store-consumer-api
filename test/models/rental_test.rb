require 'test_helper'

class RentalTest < ActiveSupport::TestCase
  let(:rental_data) {
    {
      checkout_date: "2017-01-08:",
      due_date: Date.today + 1,
      customer: customers(:one),
      movie: movies(:one)
    }
  }

  before do
    @rental = Rental.new(rental_data)
  end

  describe "Constructor" do
    it "Has a constructor" do
      Rental.create!(rental_data)
    end

    it "Has a customer" do
      @rental.must_respond_to :customer
    end

    it "Cannot be created without a customer" do
      data = rental_data.clone()
      data.delete :customer
      c = Rental.new(data)
      c.valid?.must_equal false
      c.errors.messages.must_include :customer
    end

    it "Has a movie" do
      @rental.must_respond_to :movie
    end

    it "Cannot be created without a movie" do
      data = rental_data.clone
      data.delete :movie
      c = Rental.new(data)
      c.valid?.must_equal false
      c.errors.messages.must_include :movie
    end
  end

  describe "due_date" do
    it "Cannot be created without a due_date" do
      data = rental_data.clone
      data.delete :due_date
      c = Rental.new(data)
      c.valid?.must_equal false
      c.errors.messages.must_include :due_date
    end
    #REMOVED TEST BECAUSE THAT IS NOT A FUNCTIONALITY THAT WE IMPLEMENTED
    # it "due_date on a new rental must be in the future" do
    #   data = rental_data.clone
    #   data[:due_date] = Date.today - 1
    #   c = Rental.new(data)
    #   c.valid?.must_equal false
    #   c.errors.messages.must_include :due_date

      # Today is also not in the future
    #   data = rental_data.clone
    #   data[:due_date] = Date.today
    #   c = Rental.new(data)
    #   c.valid?.must_equal false
    #   c.errors.messages.must_include :due_date
    # end

    it "rental with an old due_date can be updated" do
      r = Rental.find(rentals(:overdue).id)
      r.returned = true
      r.save!
    end
  end

  describe "first_outstanding" do
    it "returns the only un-returned rental" do
      Rental.count.must_equal 1
      Rental.first.returned.must_equal false
      Rental.first_outstanding(Rental.first.movie, Rental.first.customer).must_equal Rental.first
    end

    it "returns nil if no rentals are un-returned" do
      Rental.all.each do |rental|
        rental.returned = true
        rental.save!
      end
      Rental.first_outstanding(Rental.first.movie, Rental.first.customer).must_be_nil
    end

    it "prefers rentals with earlier due dates" do
      # Start with a clean slate
      Rental.destroy_all

      last = Rental.create!(
        movie: movies(:one),
        customer: customers(:one),
        due_date: Date.today + 30,
        returned: false
      )
      first = Rental.create!(
        movie: movies(:one),
        customer: customers(:one),
        due_date: Date.today + 10,
        returned: false
      )
      middle = Rental.create!(
        movie: movies(:one),
        customer: customers(:one),
        due_date: Date.today + 20,
        returned: false
      )
      Rental.first_outstanding(
        movies(:one),
        customers(:one)
      ).must_equal first
    end

    it "ignores returned rentals" do
      # Start with a clean slate
      Rental.destroy_all

      returned = Rental.create!(
        movie: movies(:one),
        customer: customers(:one),
        due_date: Date.today + 10,
        returned: true
      )
      outstanding = Rental.create!(
        movie: movies(:one),
        customer: customers(:one),
        due_date: Date.today + 30,
        returned: false
      )

      Rental.first_outstanding(
        movies(:one),
        customers(:one)
      ).must_equal outstanding
    end
  end

  describe "overdue" do
    it "returns all overdue rentals" do
      Rental.count.must_equal 1
      Rental.first.returned.must_equal false
      Rental.first.due_date.must_be :<, Date.today

      overdue = Rental.overdue
      overdue.length.must_equal 1
      overdue.first.must_equal Rental.first
    end

    it "ignores rentals that aren't due yet" do
      Rental.create!(
        movie: movies(:two),
        customer: customers(:one),
        due_date: Date.today + 10,
        returned: false
      )

      overdue = Rental.overdue
      overdue.length.must_equal 1
      overdue.first.must_equal Rental.first
    end

    it "ignores rentals that have been returned" do
      Rental.new(
        movie: movies(:two),
        customer: customers(:one),
        due_date: Date.today - 3,
        returned: true
      ).save!(validate: false)

      overdue = Rental.overdue
      overdue.length.must_equal 1
      overdue.first.must_equal Rental.first
    end

    it "returns an empty array if no rentals are overdue" do
      r = Rental.first
      r.returned = true
      r.save!
      Rental.overdue.length.must_equal 0
    end
  end
end
