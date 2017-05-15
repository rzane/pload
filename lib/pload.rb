require 'active_record'
require 'pload/version'

module Pload
  class AssociationNotLoadedError < StandardError
    def initialize(owner, reflection)
      super "N+1 query detected:\n  #{owner.class} => :#{reflection.name}"
    end
  end

  module Relation
    def pload(*args)
      spawn.pload!(*args)
    end

    def pload?
      extending_values.include? PloadedRelation
    end

    def pload!(*args)
      relation = extending(PloadedRelation)
      relation = relation.includes(*args) if args.any?
      relation
    end
  end

  module PloadedRelation
    def first(*)
      super.pload
    end

    def last(*)
      super.pload
    end

    def each
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
    def reader(pload: true)
      if pload && owner.pload? && !loaded?
        raise Pload::AssociationNotLoadedError.new(owner, reflection)
      end

      if pload && owner.pload?
        super().pload
      else
        super()
      end
    end
  end
end

ActiveRecord::Base.prepend Pload::Base
ActiveRecord::Relation.prepend Pload::Relation
ActiveRecord::Associations::SingularAssociation.prepend Pload::Association
ActiveRecord::Associations::CollectionAssociation.prepend Pload::Association
