require 'spec_helper'

RSpec.describe Pload do
  before do
    Post.create! author: Author.create!
    Post.create! # null author
  end

  after do
    [Post, Author].map(&:delete_all)
  end

  def raise_pload(*args)
    raise_error(Pload::AssociationNotLoadedError, *args)
  end

  describe '.raise?' do
    it 'is on by default' do
      expect(Pload).to be_raise
    end

    it 'can be disabled' do
      begin
        Pload.silent!
        expect(Pload).not_to be_raise
      ensure
        # I don't want to expose a public interface for
        # re-activating Pload. Disabling isn't thread-safe
        # and therefore pload should only be disabled at
        # initialization.
        Pload.remove_instance_variable(:@raise)
        expect(Pload).to be_raise
      end
    end
  end

  describe 'collection' do
    context 'when marked for ploading' do
      it 'raises when not included' do
        expect { Post.pload.each(&:author) }.to raise_pload(
          /N\+1 query detected:\n  Post => :author/
        )
      end

      it 'does not raise when included' do
        expect { Post.pload.includes(:author).each(&:author) }.not_to raise_error
      end
    end

    context 'when not marked for ploading' do
      it 'does not raise when not included' do
        expect { Post.all.each(&:author) }.not_to raise_error
      end
    end
  end

  describe 'instance' do
    it 'raises when not included' do
      expect { Author.first.pload.posts }.to raise_pload
    end

    it 'does not raise when not included with pload: false' do
      expect { Author.first.pload.posts(pload: false) }.not_to raise_error
    end
  end

  describe 'nesting' do
    it 'marks has_many children for pload' do
      Post.pload(author: :posts).each do |post|
        expect(post).to be_pload
        expect(post.author).to be_pload if post.author
        expect(post.author.posts).to be_pload if post.author
      end
    end

    it 'marks belongs_to children for pload' do
      Author.pload(:posts).each do |author|
        expect(author).to be_pload
        expect(author.posts).to be_pload
        expect(author.posts.first).to be_pload
        expect(author.posts.first.author).to be_pload
      end
    end
  end
end
