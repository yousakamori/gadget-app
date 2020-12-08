class V1::PostsController < ApplicationController
  before_action :set_post, only: [:update, :destroy]

  def index
    @posts = Post.all

    render json: @posts
  end

  def show
    @post = Post.with_attached_images.includes(:tags).find(params[:id])
    render json: @post.as_json(methods: :images_url, include: :tags)
  end

  def create
    @post = Post.new(post_content_params)
    sent_tags = post_tags_params[:tags] === nil ? [] : post_tags_params[:tags]
    if @post.save
      @post.save_tag(sent_tags)
      render json: @post, status: :created
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  def update
    sent_tags = post_tags_params[:tags] === nil ? [] : post_tags_params[:tags]
    if @post.update(post_content_params)
      @post.save_tag(sent_tags)
      # imagesが空の場合に、updateメソッドで初期化
      if post_content_params[:images] === nil
        @post.update(images: nil)
      end
      render json: @post
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
  end

  def search
    if params[:post_name]
      @posts = Post.search(params[:post_name])
      render json: @posts
    end
  end

  private
    def set_post
      @post = Post.find(params[:id])
    end

    def post_content_params
      params.require(:post).permit(:description, :user_id, images: [])
    end

    def post_tags_params
      params.require(:post).permit(tags: [])
    end
end
