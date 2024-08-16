class Api::V1::PostsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :update, :destroy]
  before_action :set_post, only: [:show, :update, :destroy]
  before_action :authorize_user!, only: [:update, :destroy]

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid

  def index
    @posts = Post.all
    render json: { status: 200, message: "Fetching all posts", data: @posts }, status: :ok
  rescue StandardError => e
    render json: { status: 500, error: "An error occurred while fetching posts: #{e.message}" }, status: :internal_server_error
  end

  def show
    render json: @post
  rescue StandardError => e
    render json: { status: 500, error: "An error occurred while fetching the post: #{e.message}" }, status: :internal_server_error
  end

  def create
    @post = current_user.posts.build(post_params)

    if @post.save
      render json: {
        status: 201, 
        message: 'Post created successfully.',
        data: @post
      }, status: :created
    else
      render json: { status: 422, errors: @post.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { status: 422, error: "Failed to create the post: #{e.message}" }, status: :unprocessable_entity
  rescue StandardError => e
    render json: { status: 500, error: "An unexpected error occurred: #{e.message}" }, status: :internal_server_error
  end

  def update
    if @post.update(post_params)
      render json: {
        status: 200, 
        message: 'Post updated successfully.',
        data: @post 
      }, status: :ok
    else
      render json: { status: 422, errors: @post.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { status: 422, error: "Failed to update the post: #{e.message}" }, status: :unprocessable_entity
  rescue StandardError => e
    render json: { status: 500, error: "An unexpected error occurred: #{e.message}" }, status: :internal_server_error
  end

  def destroy
    @post.destroy
    render json: {
      status: 200, 
      message: 'Post deleted successfully.',
    }, status: :ok
  rescue StandardError => e
    render json: { status: 500, error: "An error occurred while deleting the post: #{e.message}" }, status: :internal_server_error
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

  def authorize_user!
    unless @post.user_id == current_user.id
      render json: { status: 403, error: "You don't have authorization to update or delete the selected post!" }
    end
  end

  def record_not_found
    render json: { status: 404, error: "Post not found" }, status: :not_found
  end

  def record_invalid
    render json: { status: 422, error: "Record invalid" }, status: :unprocessable_entity
  end
end
