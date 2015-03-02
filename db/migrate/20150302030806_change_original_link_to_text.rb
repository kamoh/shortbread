class ChangeOriginalLinkToText < ActiveRecord::Migration
  def change
    change_column :links, :original_url, :text
  end
end
