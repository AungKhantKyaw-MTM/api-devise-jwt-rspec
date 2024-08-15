require 'rails_helper'

RSpec.describe Api::V1::PostsController, type: :request do
  include Devise::Test::IntegrationHelpers

  before(:each) do
    @user = User.create(email: 'test@example.com', password: 'password', id: '1')
    @post1 = Post.create(title: 'Test Post', content: 'This is a test post', user: @user)
    sign_in @user
    Rails.logger.debug "User: #{@user.inspect}"
    Rails.logger.debug "Post: #{@post1.inspect}"
  end  

  describe 'GET #index' do
    it 'returns a list of posts' do
      get '/api/v1/posts'
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(Post.count)
    end
  end

  describe 'GET #show' do
    context 'when the post exists' do
      it 'returns the post' do
        get "/api/v1/posts/#{@post1.id}"
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['title']).to eq(@post1.title)
      end
    end

    context 'when the post does not exist' do
      it 'returns a not found error' do
        get '/api/v1/posts/0'
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('Post not found')
      end
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new post' do
        post_params = { title: 'New Post', content: 'Content for new post' }
        expect {
          post '/api/v1/posts', params: { post: post_params }
        }.to change(Post, :count).by(1)
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['title']).to eq('New Post')
      end
    end

    context 'with invalid parameters' do
      it 'returns an error' do
        post_params = { title: '', content: '' }
        post '/api/v1/posts', params: { post: post_params }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include("Title can't be blank")
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid parameters' do
      it 'updates the post' do
        put "/api/v1/posts/#{@post1.id}", params: { post: { title: 'Updated Title' } }
        @post1.reload
        puts response.body
        expect(response).to have_http_status(:ok)
        expect(@post1.title).to eq('Updated Title')
      end
    end
    
    context 'with invalid parameters' do
      it 'returns an error' do
        put "/api/v1/posts/#{@post1.id}", params: { post: { title: '' } }
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include("Title can't be blank")
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the post' do
      expect {
        delete "/api/v1/posts/#{@post1.id}"
      }.to change(Post, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end
end
