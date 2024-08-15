class Api::V1::PostsController < ApplicationController
    before_action :authenticate_user!, only: [:create, :update, :destroy]
    before_action :set_post, only: [:show, :update, :destroy]
  
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  
    def index
      @posts = Post.all
      render json: @posts
    rescue StandardError => e
      render json: { error: "An error occurred while fetching posts: #{e.message}" }, status: :internal_server_error
    end
  
    def show
      render json: @post
    rescue StandardError => e
      render json: { error: "An error occurred while fetching the post: #{e.message}" }, status: :internal_server_error
    end
  
    def create
      @post = current_user.posts.build(post_params)
  
      if @post.save
        render json: @post, status: :created
      else
        render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: "Failed to create the post: #{e.message}" }, status: :unprocessable_entity
    rescue StandardError => e
      render json: { error: "An unexpected error occurred: #{e.message}" }, status: :internal_server_error
    end
  
    def update
      if @post.update(post_params)
        render json: @post
      else
        render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: "Failed to update the post: #{e.message}" }, status: :unprocessable_entity
    rescue StandardError => e
      render json: { error: "An unexpected error occurred: #{e.message}" }, status: :internal_server_error
    end
  
    def destroy
      @post.destroy
      head :no_content
    rescue StandardError => e
      render json: { error: "An error occurred while deleting the post: #{e.message}" }, status: :internal_server_error
    end
  
    private
  
    def set_post
      @post = Post.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      record_not_found
    end
  
    def post_params
      params.require(:post).permit(:title, :content)
    end
  
    def record_not_found
      render json: { error: "Post not found" }, status: :not_found
    end
  
    def record_invalid
      render json: { error: "Record invalid" }, status: :unprocessable_entity
    end
  end
  