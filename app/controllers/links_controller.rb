class LinksController < ApplicationController

require 'pry'

  def new
    @link = Link.new
    @links = Link.all
  end

  def create
    @link = Link.new(link_params)
    verified_link = @link.create_short_url(@link)
    redirect_to link_path(verified_link)
  end

  def show
    @link = Link.find(params[:id])
  end

  private

  def link_params
    params.require(:link).permit(:original_url)
  end

end
