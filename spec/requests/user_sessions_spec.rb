require 'rails_helper'

RSpec.describe Users::SessionsController, type: :controller do
  include Devise::Test::ControllerHelpers

  before(:each) do
    @user = User.create!(name: 'John Doe', email: 'john@example.com', password: 'password')
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "POST #create" do
    context "with valid credentials" do
      it "logs in the user and returns a JWT token" do
        post :create, params: { user: { email: @user.email, password: @user.password } }
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['message']).to eq('Logged in successfully.')
        expect(json_response['status']['token']).to be_present
      end
    end

    context "with invalid credentials" do
      it "returns an unauthorized status" do
        post :create, params: { user: { email: @user.email, password: 'wrong_password' } }
        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid Email or password.')
      rescue JSON::ParserError
        expect(response.body).to eq('Invalid Email or password.')
      end
    end
  end

  describe "DELETE #destroy" do
  context "when logged in" do
    it "logs out the user" do
      token = 'eyJhbGciOiJIUzI1NiJ9.eyJqdGkiOiI2YmJmMDNmYy00MGFkLTQyN2YtOTliNy1mMWExNTFlOTBmZTIiLCJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzIzNzA3NjIxLCJleHAiOjE3MjM3OTQwMjF9.T0epmUCawtFXH5WAcLRewXB6IqRBpLvfnYsZF7FUlxs'
      request.headers['Authorization'] = "Bearer #{token}"
      delete :destroy
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['status']).to eq(200)
      expect(json_response['message']).to eq('Logged out successfully.')
    end
  end

  context "when not logged in" do
    it "returns an unauthorized status" do
      delete :destroy
      expect(response).to have_http_status(:unauthorized)
      json_response = JSON.parse(response.body)
      expect(json_response['status']).to eq(401)
      expect(json_response['message']).to eq("Couldn't find an active session.")
    end
  end
end

end
