class PagesController < ApplicationController
  def show
    @page = Page.find_by!(name: params[:name])
  end
end
