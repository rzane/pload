require 'active_record'
require 'pload/version'

module Pload
  class AssociationNotLoadedError < StandardError
    def initialize(owner, reflection)
      super "N+1 query detected:\n  #{owner.class} => :#{reflection.name}"
    end
  end

  module Relation
    def pload
      clone.pload!
    end

    def pload!
      @ploading = true
      self
    end

    def ploading?
      @ploading
    end

    def each
      return super unless ploading?

      super do |record, *args|
        yield record.pload, *args
      end
    end
  end

  module Base
    def self.prepended(base)
      base.singleton_class.delegate :pload, to: :all
    end

    def pload?
      @pload
    end

    def pload
      @pload = true
      self
    end
  end

  module Association
    def reader
      if owner.pload? && !loaded?
        raise Pload::AssociationNotLoadedError.new(owner, reflection)
      end

      super
    end
  end
end

ActiveRecord::Base.prepend Pload::Base
ActiveRecord::Relation.prepend Pload::Relation
ActiveRecord::Associations::CollectionAssociation.prepend Pload::Association
ActiveRecord::Associations::SingularAssociation.prepend Pload::Association
