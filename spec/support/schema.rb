ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

ActiveRecord::Schema.define do
  create_table :authors do |t|
    t.string :name
  end

  create_table :posts do |t|
    t.string :title
    t.belongs_to :author
  end
end

class Post < ActiveRecord::Base
  belongs_to :author
end

class Author < ActiveRecord::Base
  has_many :posts
end
