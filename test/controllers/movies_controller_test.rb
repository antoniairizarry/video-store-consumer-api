require 'test_helper'

class MoviesControllerTest < ActionDispatch::IntegrationTest
  describe "index" do
    it "returns a JSON array" do
      get movies_url
      assert_response :success
      @response.headers['Content-Type'].must_include 'json'

      # Attempt to parse
      data = JSON.parse @response.body
      data.must_be_kind_of Array
    end

    it "should return many movie fields" do
      get movies_url
      assert_response :success

      data = JSON.parse @response.body
      data.each do |movie|
        movie.must_include "title"
        movie.must_include "release_date"
      end
    end

    it "returns all movies when no query params are given" do
      get movies_url
      assert_response :success

      data = JSON.parse @response.body
      data.length.must_equal Movie.count

      expected_names = {}
      Movie.all.each do |movie|
        expected_names[movie["title"]] = false
      end

      data.each do |movie|
        expected_names[movie["title"]].must_equal false, "Got back duplicate movie #{movie["title"]}"
        expected_names[movie["title"]] = true
      end
    end
  end

  describe "show" do
    it "Returns a JSON object" do
      get movie_url(title: movies(:one).title)
      assert_response :success
      @response.headers['Content-Type'].must_include 'json'

      # Attempt to parse
      data = JSON.parse @response.body
      data.must_be_kind_of Hash
    end

    it "Returns expected fields" do
      get movie_url(title: movies(:one).title)
      assert_response :success

      movie = JSON.parse @response.body
      movie.must_include "title"
      movie.must_include "overview"
      movie.must_include "release_date"
      movie.must_include "inventory"
      movie.must_include "available_inventory"
    end

    it "Returns an error when the movie doesn't exist" do
      get movie_url(title: "does_not_exist")
      assert_response :not_found

      data = JSON.parse @response.body
      data.must_include "errors"
      data["errors"].must_include "title"

    end
  end

  describe "create" do
    # before do
    #   @movie = {
    #     title: "Some Movie",
    #     overview: "Stuff hapens",
    #     release_date: "2020-2-20",
    #     inventory: 3,
    #     image_url: "someimage.jpeg",
    #     external_id: 1234
    #   }

    #   @bad_movie = {
    #     title: "Bad Movie",
    #     overview: nil,
    #     release_date: "2020-2-20",
    #     inventory: 1,
    #     image_url: "someotherimage.jpeg",
    #     external_id: 5678
    #   }
    # end
    it "creates a new movie" do
      @movie = {
        title: "Some Movie",
        overview: "Stuff hapens",
        release_date: "2020-2-20",
        inventory: 3,
        image_url: "someimage.jpeg",
        external_id: 1234
      }
      expect{post movies_path, params: @movie}.must_differ "Movie.count", 1
      expect(Movie.last.title).must_equal @movie[:title]
      must_respond_with :success
    end
    it "will not create an invalid movie" do
        @bad_movie = {
        title: nil,
        overview: "It's a bad movie",
        release_date: "2020-2-20",
        inventory: 1,
        image_url: "someotherimage.jpeg",
        external_id: 5678
      }
      expect{post movies_path, params: @bad_movie}.wont_change "Movie.count"
      must_respond_with :bad_request


    end
  end
end
