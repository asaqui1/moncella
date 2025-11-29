class ProductsController < ApplicationController
  def index
    @categories = Category.all
    @q = Product.ransack(params[:q])

    @products = @q.result.includes(:category)

    # Filter by category
    @products = @products.where(category_id: params[:category_id]) if params[:category_id].present?

    # Filter by on_sale
    @products = @products.where(on_sale: true) if params[:on_sale].present?

    # Filter by new products (added in last 3 days)
    if params[:new].present?
      @products = @products.where("created_at >= ?", 3.days.ago)
    end

    # Filter by recently updated (updated in last 3 days)
    if params[:recent].present?
      @products = @products.where("updated_at >= ?", 3.days.ago)
    end

    @products = @products.page(params[:page]).per(12)
  end

  def show
    @product = Product.find(params[:id])
  end
end
