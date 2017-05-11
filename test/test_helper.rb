$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pload'
require 'pry'
require 'minitest/autorun'
require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

ActiveRecord::Schema.define do
  create_table :authors
  create_table :posts do |t|
    t.belongs_to :author
  end
end

ActiveRecord::Base.logger = Logger.new(STDOUT) if ENV['LOG']

class Post < ActiveRecord::Base
  belongs_to :author
end

class Author < ActiveRecord::Base
  has_many :posts
end
