class ChangeLinkTimesVisited < ActiveRecord::Migration
  def change
    change_column :links, :times_visited, :integer, :default => 0
  end
end
