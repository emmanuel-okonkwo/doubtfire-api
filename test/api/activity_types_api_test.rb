require 'test_helper'

class ActivityTypesApiTest < ActiveSupport::TestCase
  include Rack::Test::Methods
  include TestHelpers::AuthHelper
  include TestHelpers::JsonHelper

  def app
    Rails.application
  end

  def test_get_all_activity_types
    get '/api/activity_types'
    expected_data = ActivityType.all

    assert_equal expected_data.count, last_response_body.count

    response_keys = %w(name abbreviation)

    last_response_body.each do | data |
      activity_type = ActivityType.find(data['id'])
      assert_json_matches_model(data, activity_type, response_keys)
    end
  end

  # POST tests
  # Create a new activity type
  def test_post_activity_types
    # the number of teaching period before post
    no_activity_type = ActivityType.count

    # the data that we want to post/create
    data_to_post = {
      activity_type: FactoryBot.build(:activity_type),
      auth_token: auth_token
    }
    
    # perform the POST
    post_json '/api/activity_types', data_to_post
    
    # check if the request get through 
    assert_equal 201, last_response.status

    # check if the details posted match as expected
    response_keys = %w(name abbreviation)
    activity_type = ActivityType.find(last_response_body['id'])
    assert_json_matches_model(last_response_body, activity_type, response_keys)

    # check if the details in the newly created match as pre-set data
    assert_equal data_to_post[:activity_type]['name'], activity_type.name
    assert_equal data_to_post[:activity_type]['abbreviation'], activity_type.abbreviation
  end

  # PUT tests
  # Replace an activity type
  def test_put_activity_types
    # a dummy activity type
    activity_type = FactoryGirl.create(:activity_type)
    
    data_to_put = {
      activity_type: FactoryBot.build(:activity_type),
      auth_token: auth_token
    }

    # Update activity_type with data_to_put
    put_json "/api/activity_types/#{activity_type.id}", data_to_put
    
    #check if the request get through
    assert_equal 200, last_response.status

    # check if the details posted match as expected
    response_keys = %w(name abbreviation)
    activity_type_updated = activity_type.reload
    assert_json_matches_model(last_response_body, activity_type_updated, response_keys)

    # check if the details in the replaced teaching period match as data set to replace 
    assert_equal data_to_put[:activity_type]['name'], activity_type_updated.name
    assert_equal data_to_put[:activity_type]['abbreviation'], activity_type_updated.abbreviation
  end
end
