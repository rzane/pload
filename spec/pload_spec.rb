require 'spec_helper'

RSpec.describe Pload do
  before do
    Post.create! author: Author.create!
  end

  after do
    [Post, Author].map(&:delete_all)
  end

  describe 'belongs_to' do
    context 'when marked' do
      it 'raises' do
        expect { Post.pload.each(&:author) }.to raise_error(
          Pload::AssociationNotLoadedError,
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
end
