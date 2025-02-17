# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_blog, only: %i[show]
  before_action :ensure_current_user, only: %i[edit update destroy]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show; end

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
    @blog = Blog.where(secret: false)
                .or(Blog.where(user_id: current_user&.id))
                .find_by!(id: params[:id])
  end

  def blog_params
    permitted = %i[title content secret]
    permitted << :random_eyecatch if current_user.premium?
    params.require(:blog).permit(*permitted)
  end

  def ensure_current_user
    @blog = Blog.find_by!(id: params[:id], user_id: current_user.id)
  end
end
