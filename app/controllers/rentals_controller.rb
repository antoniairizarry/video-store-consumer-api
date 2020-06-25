class RentalsController < ApplicationController
  before_action :require_movie, only: [:check_out, :check_in]
  before_action :require_customer, only: [:check_out, :check_in]

  # GET /rentals
  def index
    data = Rental.all
    render status: :ok, json: data
  end

  #custom method
  #GET /rentals/currentlycheckedout
  #I know this is long. Too Bad!
  def currentlycheckedout
    rentals = Rental.where(returned: false)
    checkedout = []
    checkedout = rentals.map do |rental|
      {
        id: rental.id,  
        customer_id: rental.customer.id,
        title: rental.movie.title,
        name: rental.customer.name,
        # postal_code: rental.customer.postal_code,
        checkout_date: rental.checkout_date,
        due_date: rental.due_date,
        returned: rental.returned
      }
    end

    render status: :ok, json: checkedout
  end




  #*******************************************************
  # TODO: make sure that wave 2 works all the way
  def check_out
    rental = Rental.new(movie: @movie, customer: @customer, due_date: params[:due_date])

    if rental.save
      render status: :ok, json: {}
    else
      render status: :bad_request, json: { errors: rental.errors.messages }
    end
  end

  def check_in
    rental = Rental.first_outstanding(@movie, @customer)
    unless rental
      return render status: :not_found, json: {
        errors: {
          rental: ["Customer #{@customer.id} does not have #{@movie.title} checked out"]
        }
      }
    end
    rental.returned = true
    if rental.save
      render status: :ok, json: {}
    else
      render status: :bad_request, json: { errors: rental.errors.messages }
    end
  end

  def overdue
    rentals = Rental.overdue.map do |rental|
      {
          title: rental.movie.title,
          customer_id: rental.customer_id,
          name: rental.customer.name,
          postal_code: rental.customer.postal_code,
          checkout_date: rental.checkout_date,
          due_date: rental.due_date
      }
    end
    render status: :ok, json: rentals
  end

private
  # TODO: make error payloads arrays
  def require_movie
    @movie = Movie.find_by title: params[:title]
    unless @movie
      render status: :not_found, json: { errors: { title: ["No movie with title #{params[:title]}"] } }
    end
  end

  def require_customer
    @customer = Customer.find_by id: params[:customer_id]
    puts "here #{@customer}"
    puts "#{params}"
    unless @customer
      render status: :not_found, json: { errors: { customer_id: ["No such customer #{params[:customer_id]}"] } }
    end
  end
end
