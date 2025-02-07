# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_blog, only: %i[show edit update destroy]
  before_action :ensure_current_user, { only: %i[edit update destroy] }

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show
    return unless @blog.secret? && @blog.user != current_user

    raise ActiveRecord::RecordNotFound, '権限がありません'
  end

  def new
    @blog = Blog.new
  end

  def edit; end

  def create
    @blog = current_user.blogs.new(blog_params)

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @blog.update(blog_params)
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog.destroy!

    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def set_blog
    @blog = Blog.find(params[:id])
  end

  def blog_params
    permitted_params = params.require(:blog).permit(:title, :content, :secret)
    permitted_params[:random_eyecatch] = current_user.premium? ? 1 : 0
    permitted_params
  end

  def ensure_current_user
    return unless current_user.id != @blog.user_id

    raise ActiveRecord::RecordNotFound, '権限がありません'
  end
end
