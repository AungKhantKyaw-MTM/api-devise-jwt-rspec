require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :controller do
  before(:each) do
    @user = User.create!(name: 'John Doe', email: 'john@dummy.com', password: 'aung123')
    @valid_attributes = { name: "New Name", email: "newemail@dummy.com" }
    @invalid_attributes = { name: "", email: "newemail@example.com" }
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  include Devise::Test::ControllerHelpers

  describe "PUT #update" do
    context "with valid parameters" do
      it "updates the user account" do
        sign_in @user
        put :update, params: { user: @valid_attributes }
        @user.reload
        expect(@user.name).to eq("New Name")
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['status']['message']).to eq("Account updated successfully.")
      end
    end

    context "with invalid parameters" do
      it "does not update the user account" do
        sign_in @user
        put :update, params: { user: @invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['status']['message']).to include("Account couldn't be updated successfully.")
      end
    end
  end

  describe "DELETE #destroy" do
    context "when user is signed in" do
      it "deletes the user account" do
        sign_in @user
        expect {
          delete :destroy
        }.to change(User, :count).by(-1)
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['status']['message']).to eq("Account deleted successfully.")
      end
    end

    context "when user deletion fails" do
      it "returns an error message" do
        sign_in @user
        allow_any_instance_of(User).to receive(:destroy).and_return(false)
        delete :destroy
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['status']['message']).to include("Account couldn't be deleted.")
      end
    end
  end
end
