class ChangeLinkTimesVisited < ActiveRecord::Migration[4.2]
  def change
    change_column :links, :times_visited, :integer, :default => 0
  end
end
