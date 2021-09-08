class ChangeOriginalLinkToText < ActiveRecord::Migration[4.2]
  def change
    change_column :links, :original_url, :text
  end
end
