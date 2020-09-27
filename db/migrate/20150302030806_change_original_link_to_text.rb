class ChangeOriginalLinkToText < ActiveRecord::Migration[5.1]
  def change
    change_column :links, :original_url, :text
  end
end
