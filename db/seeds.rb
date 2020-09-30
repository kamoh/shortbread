# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'logger'

logger = Logger.new(STDOUT)
logger.level = Logger::WARN

sql = File.read('db/default-data.sql') # Change path and filename as necessary
statements = sql.split(/;$/)
statements.pop

ActiveRecord::Base.transaction do
  statements.each do |statement|
    begin
    matches = statement.match(/VALUES \('(?<primary>[0-9]{1,})'/)
    #  puts statement
     queryresult = ActiveRecord::Base.connection.execute("select * from links where id = #{matches[:primary]}")
     if queryresult.count == 0
        # logger.info("Creating entry with id: #{matches[:primary]} in links table")
        ActiveRecord::Base.connection.execute(statement)
     else
        # logger.info("Already has a value in the links table with id: #{matches[:primary]}")
     end
    rescue
    logger.error("Unable to execute statement: #{statement}")
    end
  end
end
