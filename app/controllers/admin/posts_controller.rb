class Admin::PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: %i[ show edit update destroy ]

  # GET /admin/posts
  def index
    @posts = Post.all.order(created_at: :desc)
  end

  # GET /admin/posts/1
  def show
  end

  # GET /admin/posts/new
  def new
    @post = Post.new
  end

  # GET /admin/posts/1/edit
  def edit
  end

  # POST /admin/posts
  def create
    @post = Post.new(post_params)
    @post.user = current_user

    respond_to do |format|
      if @post.save
        format.html { redirect_to [ :admin, @post ], notice: "Post was successfully created." }
        format.json { render :show, status: :created, location: [ :admin, @post ] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/posts/1
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to [ :admin, @post ], notice: "Post was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: [ :admin, @post ] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/posts/1
  def destroy
    @post.destroy!

    respond_to do |format|
      format.html { redirect_to admin_posts_path, notice: "Post was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    def set_post
      @post = Post.find_by(slug: params[:id]) || Post.find(params[:id])
    end

    def post_params
      params.expect(post: [ :title, :slug, :excerpt, :category, :published, :published_at, :content ])
    end
end
