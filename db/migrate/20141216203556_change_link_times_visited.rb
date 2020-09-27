class ChangeLinkTimesVisited < ActiveRecord::Migration[5.1]
  def change
    change_column :links, :times_visited, :integer, :default => 0
  end
end
