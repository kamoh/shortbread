class LinksController < ApplicationController

  def index
    @link = Link.create
  end

end
