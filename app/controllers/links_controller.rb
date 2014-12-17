class LinksController < ApplicationController

require 'pry'

  def retrieve
    if @link = Link.find_by(short_url: params[:unknown])
      forward(@link)
    else
      redirect_to root_path
    end
  end

  def forward(link)
    link.times_visited += 1
    link.save!
    redirect_to link.original_url
  end

  def new
    @link = Link.new
    @links = Link.all
  end

  def create
    @link = Link.new(link_params)
    verified_link = @link.create_base_url(@link)
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
