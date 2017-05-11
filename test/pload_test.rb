require 'test_helper'

class PloadTest < Minitest::Spec
  before do
    Post.create! Array.new(3).map { { author: Author.create! } }
  end

  after do
    [Post, Author].map(&:delete_all)
  end

  it 'does not raise for belongs_to when not marked for ploading' do
    Post.all.each(&:author)
  end

  it 'raises for belongs_to marked for ploading' do
    error = assert_raises Pload::AssociationNotLoadedError do
      Post.pload.each(&:author)
    end

    assert_match(/N\+1 query detected:\n  Post => :author/, error.message)
  end

  it 'does not raise for belongs_to with includes' do
    Post.pload.includes(:author).each(&:author)
    Post.pload.joins(:author).includes(:author).each(&:author)
  end
end
