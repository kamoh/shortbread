class LinksController < ApplicationController

require 'pry'

  def new
    @link = Link.new
    @links = Link.all
  end

  def create
    @link = Link.new(link_params)
    @link.save!
    
    redirect_to link_path(@link)
  end

  def show
    @link = Link.find(params[:id])
  end

  private

  def link_params
    params.require(:link).permit(:original_url)
  end

end
