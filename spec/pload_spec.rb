require 'spec_helper'

RSpec.describe Pload do
  before do
    Post.create! author: Author.create!
  end

  after do
    [Post, Author].map(&:delete_all)
  end

  def raise_pload(*args)
    raise_error(Pload::AssociationNotLoadedError, *args)
  end

  describe 'belongs_to' do
    context 'when marked' do
      it 'raises' do
        expect { Post.pload.each(&:author) }.to raise_pload(
          /N\+1 query detected:\n  Post => :author/
        )
      end

      it 'does not raise when included' do
        expect { Post.pload.includes(:author).each(&:author) }.not_to raise_error
      end
    end

    context 'when not marked' do
      it 'does not raise' do
        expect { Post.all.each(&:author) }.not_to raise_error
      end
    end
  end

  describe 'instance' do
    it 'raises' do
      expect { Author.first.pload.posts }.to raise_pload
    end

    it 'can be bypassed' do
      expect { Author.first.pload.posts(pload: false) }.not_to raise_error
    end
  end
end
